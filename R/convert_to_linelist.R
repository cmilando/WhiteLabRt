#' Convert Case Counts to a Line List
#'
#' This function takes a data frame of case counts and expands it into a line list format,
#' which is often used for epidemiological analysis. The function validates input data,
#' manages missingness, and assumes additional generation times based on the specified
#' reporting function.
#'
#' @param caseCounts A data frame with columns `date`, `cases`, and `location`.
#'                   The data frame must meet several criteria:
#'                   - It should only contain data for one location.
#'                   - Dates must be in Date format.
#'                   - Case numbers must be non-negative integers.
#'                   - No missing values are allowed in the necessary columns.
#' @param reportF A function used to simulate the delay from case reporting to case onset.
#'                Defaults to a negative binomial distribution function (`rnbinom`) if NULL.
#' @param reportF_args A list of additional arguments to pass to `reportF`.
#'                     Defaults to `list(size = 3, mu = 9)` when `reportF` is NULL.
#' @param reportF_missP A numeric probability between 0 and 1 (exclusive) indicating the
#'                      proportion of missing onset dates. It throws an error if it is out
#'                      of bounds or not numeric.
#'
#' @return A data frame in line list format, where each row corresponds to a case report.
#'         The data frame includes columns for the report date, the delay from report to onset,
#'         the onset date, weekend indicator, report interval in days from the first report,
#'         and week interval.
#'         The returned data frame has additional attributes set, including `min_day` and the
#'         class `lineList`.
#'
#' @details The function stops and sends error messages for various data integrity issues,
#'          such as incorrect data types, negative cases, or missing required columns.
#'          It also assumes that the input data is for only one location and handles
#'          NA generation according to `reportF_missP`.
#'
#' @examples
#' data("sample_dates")
#' data("sample_location")
#' data("sample_cases")
#' case_Counts <- create_caseCounts(sample_dates, sample_location, sample_cases)
#' line_list <- convert_to_linelist(case_Counts, reportF_missP = 0.5)
#' @importFrom stats rnbinom aggregate pgamma xtabs
#' @export
convert_to_linelist <- function(caseCounts,reportF_missP,
                            reportF = NULL,
                            reportF_args = NULL) {

  # ---------------------------------------
  # validate caseCounts
  necessary_columns <- c('date', 'cases', 'location')
  stopifnot(colnames(caseCounts) %in% necessary_columns)

  # check types
  stopifnot(all(! is.na(as.Date(caseCounts$date))))
  stopifnot(all(is.character(caseCounts$location)))
  stopifnot(all(is.numeric(caseCounts$cases)))

  # no negative case numbers
  stopifnot(all(caseCounts$cases >= 0))

  # assumes this is just for one location
  if(length(unique(caseCounts$location)) > 1) warning('More than 1 location')

  # no is.na
  stopifnot(all(! is.na(caseCounts[, necessary_columns])))

  # reportMissP must be 0 < x < 1

  if(!is.null(reportF_missP)) {
    stopifnot(is.numeric(reportF_missP))
    stopifnot(0 < reportF_missP & reportF_missP < 1)
  }


  # message if reportF is not specific
  if(is.null(reportF)) {
    message("reportF is NULL, setting to rnbinom(size = 3, mu = 9)")
    reportF = rnbinom
    reportF_args = list(size = 3, mu = 9)
  }

  # class
  stopifnot("caseCounts" %in% class(caseCounts))

  # ---------------------------------------
  # Expand case dates into individuals
  report_date_l <- lapply(1:nrow(caseCounts), function(i)
    caseCounts$date[rep(i, caseCounts$cases[i])])

  report_date_vec <- do.call(c, report_date_l)
  report_date_vec <- as.Date(report_date_vec)

  stopifnot(length(report_date_vec) == sum(caseCounts$cases))

  # ---------------------------------------
  ## now add other columns
  report_date <- report_int <- NULL
  d <- data.frame(report_date = sort(report_date_vec))

  ## need to assume some generation distribution here
  tryCatch({
    reportF_args$n <- length(report_date_vec)
    d$delay_int <- round(do.call(reportF, reportF_args))
  }, error = function(cond) {
    stop('Error in arguments to onset function: `n` or user specified')
  })

  # checking onset
  stopifnot(all(d$delay_int >= 0))

  # remove missingness
  if(!is.null(reportF_missP)) {
    stopifnot(is.numeric(reportF_missP))
    stopifnot(reportF_missP >= 0 & reportF_missP < 1)
    remove_delays <- sample(1:nrow(d), size = nrow(d) * reportF_missP)
    d$delay_int[remove_delays] <- NA
  }

  d$onset_date = d$report_date - d$delay_int

  # add extra columns
  d$is_weekend <- ifelse(weekdays(as.Date(d$report_date)) %in%
                           c("Saturday", "Sunday"), 1, 0)

  # min_day is the first reporting day of generation 1,
  # where min_day = 0 would be the infection day of generation 1
  # offset and covert to numbers
  min_day = min(d$report_date)

  # requires dplyr
  d$report_int <- as.vector(as.Date(d$report_date) - as.Date(min_day) + 1)
  d$week_int <- ceiling(d$report_int / 7)

  # type convert
  d$delay_int  <- as.integer(d$delay_int)
  d$is_weekend <- as.integer(d$is_weekend)
  d$report_int <- as.integer(d$report_int)
  d$week_int   <- as.integer(d$week_int)

  attr(d, "min_day") <- min_day

  class(d) <- c(class(d), "lineList")

  return(d)
}
