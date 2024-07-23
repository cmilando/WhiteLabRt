#' Run Spatial R(t) estimation and Estimate Reproduction Numbers
#'
#' This function performs ...
#'
#' @param report_dates A data frame ...
#' @param case_matrix A data frame ...
#' @param transfer_matrix A data frame ...
#' @param v2 ...
#' @param sip Vector of numeric values specifying the serial interval probabilities.
#' @param ... Additional arguments passed to rstan::sampling()
#' @return an object ...
#'
#' @details The function ensures ...
#'
#' @examples
#'\donttest{
#' data("sample_multi_site")
#' data("transfer_matrix")
#' Y <- as.matrix(sample_multi_site[, c(2, 3)])
#' for(i in 1:nrow(Y)) {
#'   for(j in 1:ncol(Y)) {
#'     Y[i,j] <- as.integer(Y[i,j])
#'   }
#' }
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

  NN <- as.integer(nrow(case_matrix))

  # Need to add validation for this
  # assumes things are daily
  week_vec = as.integer(ceiling((1:NN)/7))
  n_weeks = as.integer(length(unique(week_vec)))

  # need to do validation on serial interval

  # ------------------------------------------------------------
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
