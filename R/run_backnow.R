#' Run Back Calculation and Estimate Reproduction Numbers
#'
#' This function performs a back-calculation based on provided epidemic case count data,
#' estimating the time distribution of infections and reproduction numbers (r(t)).
#' It utilizes extensive input checks and parameter validation to ensure robust model execution.
#'
#' @param input A data frame or list that includes epidemic data with either class 'caseCounts'
#'              or 'lineList'. The input type determines initial processing steps.
#' @param MAX_ITER Integer, maximum number of iterations for the back-calculation model.
#'                 Requires at least 2000 iterations; high numbers can significantly increase runtime.
#' @param norm_sigma Numeric, the standard deviation for the normal distribution in the Bayesian framework.
#' @param sip Vector of numeric values specifying the serial interval probabilities.
#' @param NB_maxdelay Integer, the maximum delay for the right-truncated negative binomial distribution used in modeling.
#' @param NB_size Integer, the size parameter for the negative binomial distribution.
#' @param n_trunc Integer, the truncation number for the final result matrices (defaults to `NB_size`).
#' @param workerID Optional integer to specify a worker ID for parallel processing frameworks; defaults to 0.
#' @param printProgress Binary integer (0 or 1), specifying whether to print progress to console; affects performance.
#' @param preCalcTime Boolean, if TRUE, the function calculates a preliminary runtime estimate before full execution.
#' @param ... Additional arguments passed to underlying functions when converting input to the required format.
#' @return an object of class `backnow` with the following structure
#'
#'      - est_back: back-calculated case counts
#'
#'      - est_back_date: dates for back-calculated case counts
#'
#'      - est_rt: back-calculated R(r)
#'
#'      - est_rt_date: dates for back-calculated R(t)
#'
#'      - geweke_back: Geweke diagnostics for the estimated back-calculation of cases
#'
#'      - geweke_rt; Geweke diagnostics for R(t)
#'
#'      - report_date: a vector of dates, matches reported_cases
#'
#'      - report_cases: a vector of reported cases
#'
#'      - MAX_ITER: the input for `MAX_ITER`
#'
#'      - norm_sigma: the input for `norm_sigma`
#'
#'      - NB_maxdelay: the input for `NB_maxdelay`
#'
#'      - si: the input for serial interval `si`
#'
#'      - NB_size: the input for `NB_size`
#'
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
#' data("sample_onset_dates")
#' data("sample_report_dates")
#' line_list <- create_linelist(sample_report_dates, sample_onset_dates)
#' sip <- si(14, 4.29, 1.18)
#' results <- run_backnow(
#'   line_list,
#'   MAX_ITER = as.integer(2000),
#'   norm_sigma = 0.5,
#'   sip = sip,
#'   NB_maxdelay = as.integer(20),
#'   NB_size = as.integer(6),
#'   workerID = 1,
#'   printProgress = 1,
#'   preCalcTime = TRUE)
#'}
#' @importFrom dplyr group_by summarize
#' @export
run_backnow <- function(input,
                        MAX_ITER,
                        norm_sigma,
                        sip,
                        NB_maxdelay,
                        NB_size,
                        n_trunc = NB_size,
                        workerID = NULL,
                        printProgress = 0,
                        preCalcTime = TRUE,...) {

  # ---------------------------------------------------------
  # input checking
  if(all(c("caseCounts", "lineList") %in% class(input)))    stop()
  if(all(!(c("caseCounts", "lineList") %in% class(input)))) stop()

  input_type <- NA
  if("caseCounts" %in% class(input)) {
    input_type = 'caseCounts'
    # get lineList, with random each time, from ...
    caseCounts_line <- convert_to_linelist(input, ...)
  }

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

  # maxiter checks
  stopifnot(is.integer(MAX_ITER))
  stopifnot(MAX_ITER >= 2000)
  if(MAX_ITER >= 30000) warning('`MAX_ITER` >= 30,000 will lead to long run times')

  # norm sigma for bayesian parameters
  stopifnot(is.numeric(norm_sigma))
  stopifnot(norm_sigma > 0)

  # NB_maxdelay, the maximum of the right truncated distribution
  stopifnot(is.integer(NB_maxdelay))
  stopifnot(NB_maxdelay >= 0)
  stopifnot(NB_maxdelay < 50)

  # vector for SIP
  stopifnot(is.vector(sip))
  stopifnot(all(is.numeric(sip)))
  stopifnot(all(sip >= 0))

  # size of the NB distribution
  stopifnot(is.integer(NB_size))
  stopifnot(NB_size >= 0)

  #
  if(is.null(workerID)) workerID <- as.integer(0)
  stopifnot(is.numeric(workerID))
  workerID <- as.integer(workerID)
  stopifnot(workerID >= 0)

  #
  stopifnot(printProgress %in% c(0, 1))
  if(!dir.exists(file.path(".", "tmp")) & printProgress == 1) {
    warning("`tmp` dir does not exist, setting printProgress to `0`. Manually create a `tmp` directory in the present folder to view worker specific progress")
    printProgress <- as.integer(0)
  }
  printProgress <- as.integer(printProgress)

  # get min_day, this is how you offset outputs
  # min_day is the first reporting day of generation 1,
  # where min_day = 0 would be the infection day of generation 1
  # essential you can take the min report day and subtract the max report delay
  infect_date <- min(caseCounts_line$report_date) - NB_maxdelay

  # ---------------------------------------------------------
  # run first to get a time estimate
  ##
  if(preCalcTime) {

    startup_start_time <- Sys.time()
    out_list <-
      backnow_cm(outcome       = caseCounts_line$delay_int,
                 days          = caseCounts_line$report_int,
                 week          = caseCounts_line$week_int,
                 weekend       = caseCounts_line$is_weekend,
                 workerID      = workerID,
                 printProgress = as.integer(0),
                 iter          = 1,
                 sigma         = norm_sigma,
                 maxdelay      = NB_maxdelay,
                 si            = sip,
                 size          = NB_size)
    startup_end_time <- Sys.time()
    startup_elapsed <- difftime(startup_end_time, startup_start_time, units = 'hours')
    # checks
    stopifnot(ncol(out_list$Back) == max(caseCounts_line$report_int) + NB_maxdelay)
    stopifnot(ncol(out_list$R) == max(caseCounts_line$report_int) + NB_maxdelay - NB_size - 1)
    ##
    start_time <- Sys.time()
    out_list <-
      backnow_cm(outcome       = caseCounts_line$delay_int,
                 days          = caseCounts_line$report_int,
                 week          = caseCounts_line$week_int,
                 weekend       = caseCounts_line$is_weekend,
                 workerID      = workerID,
                 printProgress = as.integer(0),
                 iter          = 100,
                 sigma         = norm_sigma,
                 maxdelay      = NB_maxdelay,
                 si            = sip,
                 size          = NB_size)
    end_time <- Sys.time()
    elapsed <- difftime(end_time, start_time, units = "hours")
    ##
    scale_up <- MAX_ITER / 100
    total_est_time <- startup_elapsed + (elapsed - startup_elapsed) * scale_up

    # Use sprintf to format the output
    formatted_output <- sprintf("Estimated run time: %.2f hours", total_est_time)
    message(formatted_output)

  }

  # ---------------------------------------------------------
  # n backnow

  out_list <-
    backnow_cm(outcome       = caseCounts_line$delay_int,
               days          = caseCounts_line$report_int,
               week          = caseCounts_line$week_int,
               weekend       = caseCounts_line$is_weekend,
               workerID      = workerID,
               printProgress = printProgress,
               iter          = MAX_ITER,
               sigma         = norm_sigma,
               maxdelay      = NB_maxdelay,
               si            = sip,
               size          = NB_size)
  end_time <- Sys.time()
  elapsed <- end_time - start_time


  # ---------------------------------------------------------
  # process back-calculation and r(t) across chains
  # after 1000 burn-in
  # also every 2 ...
  N_BURN_IN <- 1000
  probs_to_export <- c(0.025, 0.5, 0.975)

  back1  <- out_list$Back[seq(N_BURN_IN + 1, nrow(out_list$Back), by = 2), ]
  dim(back1)

  # depending on the onset distribution, you may have some NA cols at the tails
  # replace these with 0s
  zero_cols <- c()
  for(j in 1:ncol(back1)) {
    if(all(is.na(back1[, j]))) zero_cols <- c(j, zero_cols)
  }
  if(length(zero_cols) > 0) {
    back1[, zero_cols] <- 0
  }

  for(j in 1:ncol(back1)) {
    if(any(is.na(back1[, j]))) stop("some NA values in `back`")
  }

  est_back <- apply(back1, 2, function(x) quantile(x, probs = probs_to_export))

  # gewke diagnostics
  gback1 <- geweke.diag(back1)$z
  gback1[is.nan(gback1)] <- 0
  gb1  <- sum(abs(gback1) > 1.96) / length(gback1)

  # ---------------------------------------------------------
  # process the r(t)
  r1 <- out_list$R[seq(N_BURN_IN + 1, nrow(out_list$R), by = 2), ]
  dim(r1)

  # depending onthe onset distribution, you may have some NA cols at the tails
  # replace these with 0s
  zero_cols <- c()
  for(j in 1:ncol(r1)) {
    if(all(is.na(r1[, j]))) zero_cols <- c(j, zero_cols)
  }
  if(length(zero_cols) > 0) {
    r1[, zero_cols] <- 0
  }

  for(j in 1:ncol(r1)) {
    if(any(is.na(r1[, j]))) stop("some NA remains in `r1`")
  }

  ##
  est_r <- apply(r1, 2, function(x) quantile(x, probs = probs_to_export))
  dim(est_r)

  # gewke diagnostics
  gr1 <- geweke.diag(r1)$z
  gr1[is.nan(gr1)] <- 0
  gr1 <- sum(abs(gr1) > 1.96) / length(gr1)

  # ---------------------------------------------------------
  #
  report_date <- report_int <- NULL
  output_table <- caseCounts_line %>%
    group_by(report_date) %>%
    summarize(.groups = 'keep',
              n = n())

  ## DIM OF EST_BACK = length(report_date) + NB_maxdelay
  pre <-  seq.Date(min(output_table$report_date) - NB_maxdelay,
                   min(output_table$report_date) - 1, by = '1 day')

  x_est <- c(pre, output_table$report_date)

  ## DIM OF RT is = length(report_date) + NB_maxdelay - NB_size - 1
  # but its the last dates
  rt_size  <- ncol(r1)
  rt_first <- length(x_est) - rt_size + 1
  rt_last  <- length(x_est)

  ## TRUNCATE EST_BACK AND EST_R BY N_TRUNC
  est_back[, ((ncol(est_back) - n_trunc):ncol(est_back))] <- NA
  est_r[, ((ncol(est_r) - n_trunc):ncol(est_r))] <- NA


  return(structure(class = "backnow", list(est_back      = est_back,
                                    est_back_date = x_est,
                                    est_rt        = est_r,
                                    est_rt_date   = x_est[rt_first:rt_last],
                                    geweke_back   = gb1,
                                    geweke_rt     = gr1,
                                    report_date   = output_table$report_date,
                                    report_cases  = output_table$n,
                                    MAX_ITER      = MAX_ITER,
                                    norm_sigma    = norm_sigma,
                                    NB_maxdelay   = NB_maxdelay,
                                    si            = sip,
                                    NB_size       = NB_size)))

}

