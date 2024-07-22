#' Run Back Calculation and Estimate Reproduction Numbers
#'
#' This function performs a back-calculation based on provided epidemic case count data,
#' estimating the time distribution of infections and reproduction numbers (r(t)).
#' It utilizes extensive input checks and parameter validation to ensure robust model execution.
#'
#' @param input A data frame or list that includes epidemic data with either class 'caseCounts'
#'              or 'lineList'. The input type determines initial processing steps.
#' @param sip Vector of numeric values specifying the serial interval probabilities.
#' @param NB_maxdelay Integer, the maximum delay for the negative binomial distribution used in modeling.
#' @param window_size Integer, the number of days of the R(t) averaging window.
#' @param ... Additional arguments passed to rstan::sampling()
#' @return an object of class `backnow`
#'
#' @details The function ensures input data is of the correct class and processes it accordingly.
#'          It handles different input classes by either converting `caseCounts` to `lineList` or
#'          directly using `lineList`. The function stops with an error if the input doesn't meet expected standards.
#'          It performs simulations to estimate both the back-calculation of initial infections and reproduction numbers
#'          over time, while checking and adjusting for potential NA values and ensuring that all conditions for the
#'          model parameters are met. Output includes estimates of initial infections and reproduction numbers along
#'          with diagnostic statistics.
#'
#' @examples
#'\donttest{

#'}
#' @import rstan
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#' @export
run_backnow <- function(input,
                        sip,
                        NB_maxdelay = as.integer(20),
                        window_size = as.integer(7),
                        ...) {

  # ---------------------------------------------------------
  # input checking
  input_type <- NA
  if("lineList" %in% class(input)) {
    input_type = 'lineList'
    caseCounts_line <- input
  }
  stopifnot(!is.na(input_type))

  ## stop if there are no NA delay_ints, or if they are all NA
  which_na <- which(is.na(caseCounts_line$delay_int))
  cond1 <- length(which_na) == 0
  cond2 <- length(which_na) == nrow(caseCounts_line)
  if(cond1 | cond2) stop("delay INTS must have some missing data.")

  # NB_maxdelay, the maximum of the right truncated distribution
  stopifnot(is.integer(NB_maxdelay))
  stopifnot(NB_maxdelay >= 0)
  stopifnot(NB_maxdelay < 50)

  # vector for SIP
  stopifnot(is.vector(sip))
  stopifnot(all(is.numeric(sip)))
  stopifnot(all(sip >= 0))

  # R(t) averaging window size
  stopifnot(is.integer(window_size))
  stopifnot(window_size >= 0)

  # ---------------------------------------------------------
  ll <- caseCounts_line

  ll$value <- 1
  ll$id <- 1:nrow(ll)
  ll <- data.frame(ll)
  Y <- ll$delay_int

  ## THIS SHOULD BE DEFINED BY REPORTING DATE
  reference_date = as.Date(min(as.Date(ll$report_date), na.rm = T) - 1)
  ll$report_date_int <- as.vector(ll$report_date - reference_date)
  ll$onset_date_int <- as.vector(ll$onset_date - reference_date)

  ## Get daily tally
  rr <- as.data.frame(table(ll$report_date_int))
  colnames(rr) = c('report_date_int', 'n')

  # Create a wide format table
  wide_table <- xtabs(~ id + week_int, data = ll)

  # Convert xtabs result to a data frame
  wide_df <- as.data.frame.matrix(wide_table)

  # Add 'week' prefix to column names
  colnames(wide_df) <- paste0("week", colnames(wide_df))
  stopifnot(dim(wide_df)[1] == dim(ll)[1])

  # Merge the wide format table with the original data
  dt_wide <- cbind(ll[, c('id', 'onset_date_int', 'report_date_int', 'is_weekend')],
                   wide_df)

  n_weeks = max(ll$week_int)

  ##
  miss_rows <- is.na(dt_wide$onset_date_int)
  miss_rows2 <- is.na(Y)
  stopifnot(identical(miss_rows, miss_rows2))

  ## CHECK THAT YOU HAVE AT LEAST ONE PERSON PER WEEK
  # Group by week_int and calculate the required summaries
  ll$onset_date2 <- ll$onset_date
  ll$onset_date2[is.na(ll$onset_date2)] <- 0
  week_check <- aggregate(onset_date2 ~ week_int, data = ll,
                          FUN = function(x) {
                            c(n = length(x), n_not_na = sum(!(x == 0)))
                          })

  # Split the aggregated results into separate columns
  week_check$n <- week_check$onset_date2[, "n"]
  week_check$n_not_na <- week_check$onset_date2[, "n_not_na"]
  week_check$onset_date2 <- NULL

  # Keep the .groups argument equivalent
  week_check <- week_check[order(week_check$week_int), ]

  # Viewing the week_check
  for(w_i in 1:nrow(week_check)) {
    if(week_check$n_not_na[w_i] == 0) {
      warning(paste0("Week ", w_i, " has no delay data"))
    }
  }


  ########

  stopifnot(sip[1] == 0)

  stan_data <- list(
    ##
    J = as.integer(n_weeks + 1),
    sipN = as.integer(length(sip)),
    sip = sip,
    maxdelay = as.integer(NB_maxdelay),
    missvector = as.integer(1*miss_rows),
    ndays = max(dt_wide$report_date_int),
    windowsize = as.integer(window_size),
    ##
    N_obs = as.integer(nrow(dt_wide[!miss_rows, ])),
    dum_obs = as.matrix(dt_wide[!miss_rows, -c(1:3)]),
    Y_obs = as.integer(Y[!miss_rows]), ## DELAY
    ReportOnset = as.integer(unlist(dt_wide[!miss_rows, 2])), ## ONSET
    ##
    N_miss = as.integer(nrow(dt_wide[miss_rows, ])),
    dum_miss = as.matrix(dt_wide[miss_rows, -c(1:3)]),
    ReportDays = as.integer(unlist(dt_wide[miss_rows, 3]))
  )

  ########

  mod1 <- rstan::sampling(object = stanmodels$linelist,
                       data = stan_data, ...)

  ########

  out <- rstan::extract(mod1)

  if(any(is.na(out$mu_miss))) warning('Some missing MU_MISS!')

  # ########

  est_df <- data.frame(
    x = reference_date + out$day_onset_tally_x[1, ],
    med = apply(out$day_onset_tally, 2, quantile, probs = 0.5),
    lb = apply(out$day_onset_tally, 2, quantile, probs = 0.025),
    ub = apply(out$day_onset_tally, 2, quantile, probs = 0.975)
  )

  # ########

  rt_df <- data.frame(
    x = reference_date + out$day_onset_tally_x[1, ],
    med = apply(out$rt, 2, quantile, probs = 0.5),
    lb = apply(out$rt, 2, quantile, probs = 0.025),
    ub = apply(out$rt, 2, quantile, probs = 0.975)
  )

  # ########

  return(structure(class = "backnow",
                   list(est_df        = est_df,
                        rt_df         = rt_df,
                        betas = apply(out$betas, 2, mean),
                        ll = ll,
                        NB_maxdelay   = NB_maxdelay,
                        si            = sip,
                        window_size   = window_size)))
}

