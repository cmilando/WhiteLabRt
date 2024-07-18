#' Calculate a Serial Interval Distribution
#'
#' This function computes the probability distribution function (PDF) of the
#' serial interval using a gamma distribution with specified
#' shape and rate parameters. The serial interval is defined as the time
#' between successive cases in a chain of transmission. This implementation
#' generates a discrete PDF at the *daily* level.
#'
#' The function uses the `pgamma` function to calculate cumulative
#' probabilities for each day up to `ndays` and then differences these
#' to get daily probabilities. The resulting probabilities are normalized to
#' sum to 1, ensuring that they represent a valid probability distribution.
#'
#' @param ndays Integer, the number of days over which to calculate the
#' serial interval distribution.
#' @param shape Numeric, the shape parameter of the gamma distribution.
#' @param rate Numeric, the rate parameter of the gamma distribution.
#' @param leading0 Logical, should a leading 0 be added to indicate t0?
#'
#' @return Numeric vector representing the serial interval probabilities
#' for each of the first `ndays` days. The probabilities are normalized
#' so that their sum is 1.
#'
#' @examples
#' si(ndays = 14, shape = 4.29, rate = 1.18)
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#' @export
si <- function(ndays, shape, rate, leading0 = TRUE) {

  prob <- numeric(ndays)

  for (i in 1:ndays){
    prob[i] <- pgamma(i, shape = shape, rate = rate) -
      pgamma(i - 1, shape = shape, rate = rate)
  }

  result <- prob/sum(prob)

  # Add a leading 0 to indicate no cases
  if(leading0) result <- c(0, result)

  return(result)
}
