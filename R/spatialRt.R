#' Run Spatial R(t) estimation and Estimate Reproduction Numbers
#'
#' This function calculates R(t) that arises from transfer of infectors between
#' different states. There are different flavors of the model, but the base version
#' calculates a weekly R(t) within each state.
#'
#' @param report_dates A vector of reporting dates
#' @param case_matrix A matrix of cases, defined by integers
#' @param transfer_matrix A matrix that defines how infectors flow between states.
#' Each row of the transfer matrix must sum to 1.
#' @param v2 a flag indicating FALSE if the base algorithm is to be used, and TRUE if
#' the experimental algorithm is desired. The experimental version contains a
#' non-centered parameterization, an AR1 process, and partial pooling across states.
#' @param sip Vector of numeric values specifying the serial interval probabilities.
#' @param ... Additional arguments passed to rstan::sampling()
#' @return An rstan object.
#'
#' @examples
#'\donttest{
#' data("sample_multi_site")
#' data("transfer_matrix")
#' Y <- matrix(integer(1), nrow = nrow(sample_multi_site), ncol = 2)
#' for(i in 1:nrow(Y)) {
#'   for(j in c(2, 3)) {
#'     Y[i,j-1] <- as.integer(sample_multi_site[i,j])
#'   }
#' }
#' all(is.integer(Y))
#' sip <- si(14, 4.29, 1.18, leading0 = FALSE)
#' sample_m_hier <- spatialRt(report_dates = sample_multi_site$date,
#' case_matrix = Y,
#' transfer_matrix = transfer_matrix,
#' v2 = FALSE,
#' sip = sip, chains = 1)
#'}
#' @import rstan
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#' @export
spatialRt <- function(report_dates, case_matrix, transfer_matrix,
                      sip, v2 = FALSE, ...) {

  # ------------------------------------------------------------

  # report dates
  stopifnot(all(!is.na(as.Date(report_dates))))
  for(i in 2:length(report_dates)) {
    if(as.numeric(report_dates[i] - report_dates[i-1]) > 1) stop()
  }

  # case days
  stopifnot(all(!is.na(case_matrix)))
  stopifnot(all(is.integer(case_matrix)))
  stopifnot(nrow(case_matrix) == length(report_dates))

  # transfer matrix
  stopifnot(all(!is.na(transfer_matrix)))
  stopifnot(all(is.numeric(transfer_matrix)))
  stopifnot(nrow(transfer_matrix) == ncol(case_matrix) * length(report_dates))
  stopifnot(ncol(transfer_matrix) == ncol(case_matrix))
  for(i in 1:nrow(transfer_matrix)) {
    if(sum(transfer_matrix[i,]) != 1) stop()
  }

  # need to do validation on serial interval
  stopifnot(all(!is.na(sip)))
  stopifnot(all(is.numeric(sip)))
  stopifnot(sip[1] != 0)

  # ------------------------------------------------------------

  NN <- as.integer(nrow(case_matrix))

  week_vec = as.integer(ceiling((1:NN)/7))
  n_weeks = as.integer(length(unique(week_vec)))

  # Data list for Stan
  # also need to do data validation here
  stan_data <- list(
    N = NN,                 # number of days
    NW = n_weeks,           # n weeks
    week_vec = week_vec,    # which week is it
    J = ncol(case_matrix),  # n regions
    Y = case_matrix,        # cases
    P = transfer_matrix,    # transfer matrix
    S = length(sip),        # serial interval length
    W = sip,                # serial interval vector
    init_cases = case_matrix[1, ]     # initial cases
  )

  # -------------------------------------------------------------
  # run the STAN code, takes ~ 10min
  # this actually goes really quickly now ...

  if(! v2) {

    initf1 <- function() {
      #
      # vector<lower=0.00005>[J] xsigma;  // region-specific st-dev
      # matrix[NW,J] xbeta;         // time-region specific beta
      # matrix[NW,J] logR;          // time-region specific R values, in Log space
      #
      list(xsigma = rep(0.1, ncol(case_matrix)),
           xbeta = matrix(0, nrow = n_weeks, ncol = ncol(case_matrix)),
           logR = matrix(0.1, nrow = n_weeks, ncol = ncol(case_matrix)))
    }

    # then run
    # wow sometimes this takes 5 seconds.
    # why? good first guesses?
    # NB: max_treedepth, and adapt_delta really slow things down
    m_hier <- sampling(object = stanmodels$stan_sliding_v4,
                       data = stan_data,
                       init = initf1,
                       ...)

  } else {
    warning('v2 selected - under development')
    initf1 <- function() {
      #
      # // CENTRAL RT
      # real sigma_logRt_central;  // how do we scale it
      # vector[NW] logRt_central_error;          // draws from the st normal
      # real logRt_central_intercept;
      #
      # // DEVIATION
      # vector[J] sigma_logRt;    // central, could be region specific
      # matrix[NW, J] logRt_error; // for reach region, whats the avg deviation
      #
      list(sigma_logRt_central = 0,
           logRt_central_error = rep(0, n_weeks),
           logRt_central_intercept = 0,
           sigma_logRt = rep(0, ncol(case_matrix)),
           logRt_error = matrix(0, nrow = n_weeks, ncol = ncol(case_matrix)))
    }
    m_hier <- sampling(object = stanmodels$stan_sliding_v4nc1,
                       data = stan_data,
                       init = initf1,
                       ...)

  }

  # ----------------------------------------------------

  return(m_hier)

}
