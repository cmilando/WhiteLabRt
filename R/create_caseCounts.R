#' Create a Case Counts Data Frame
#'
#' This function constructs a data frame from vectors representing dates, locations,
#' and case numbers, ensuring that all input vectors meet specific data integrity
#' requirements. It checks for the correct data types, non-negative case numbers,
#' and uniformity in vector lengths. The function also ensures no missing values are
#' present and that all data pertain to a single location.
#'
#' @param date_vec A vector of dates corresponding to case reports; must be of type Date.
#' @param location_vec A character vector representing the location of the case reports;
#'                     all entries must refer to the same location.
#' @param cases_vec A numeric vector representing the number of cases reported on each date;
#'                  values must be non-negative integers.
#'
#' @return A data frame named `caseCounts` with columns `date`, `cases`, and `location`.
#'         Each row corresponds to a unique report of cases on a given date at a specified location.
#'         The data frame is assigned a class attribute of `caseCounts`.
#'
#' @details The function performs several checks to ensure the integrity of the input:
#'          - It verifies that all vectors have the same length.
#'          - It confirms that there are no negative numbers in `cases_vec`.
#'          - It checks for and disallows any missing values in the data frame.
#'          It throws errors if any of these conditions are not met, indicating that
#'          the input vectors are not appropriately formatted or contain invalid data.
#'
#' @examples
#' data("sample_dates")
#' data("sample_location")
#' data("sample_cases")
#' case_Counts = create_caseCounts(sample_dates, sample_location, sample_cases)
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#' @export
create_caseCounts <- function(date_vec, location_vec, cases_vec) {

  # check types
  stopifnot(all(! is.na(as.Date(date_vec))))
  stopifnot(all(is.character(location_vec)))
  stopifnot(all(is.numeric(cases_vec)))

  # no negative case numbers
  stopifnot(all(cases_vec >= 0))

  # assumes this is just for one location
  if(length(unique(location_vec)) > 1) warning('More than 1 location')

  # should all have the same length
  stopifnot(length(date_vec) == length(location_vec))
  stopifnot(length(date_vec) == length(cases_vec))

  # create caseCounts
  caseCounts <- data.frame(date = as.Date(date_vec),
                           cases = cases_vec,
                           location = location_vec)

  # no is.na
  necessary_columns <- c('date', 'cases', 'location')
  stopifnot(all(! is.na(caseCounts[, necessary_columns])))

  # add class attribute
  class(caseCounts) <- c("caseCounts", class(caseCounts))

  return(caseCounts)

}
