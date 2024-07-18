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
#' Note: there is *no leading 0* in this implementation.
#'
#' @param ndays Integer, the number of days over which to calculate the
#' serial interval distribution.
#' @param alpha Numeric, the shape parameter of the gamma distribution.
#' @param beta Numeric, the rate parameter of the gamma distribution.
#'
#' @return Numeric vector representing the serial interval probabilities
#' for each of the first `ndays` days. The probabilities are normalized
#' so that their sum is 1.
#'
#' @examples
#' si(ndays = 14, shape = 4.29, rate = 1.18)
#'
#' @export
si <- function(ndays, shape, rate) {

  prob <- numeric(ndays)

  for (i in 1:ndays){
    prob[i] <- pgamma(i, shape = shape, rate = rate) -
      pgamma(i - 1, shape = shape, rate = rate)
  }

  result <- prob/sum(prob)

  return(result)
}
