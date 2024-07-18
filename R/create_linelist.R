#' Create a Line List from Report and Onset Dates
#'
#' This function constructs a line list data frame using vectors of report
#' and onset dates.
#'
#' @param report_dates A vector of dates representing when cases were
#' reported; must be of type Date.
#' @param onset_dates A vector of dates representing when symptoms onset
#' occurred; must be of type Date. This vector can contain NA values,
#' but not exclusively or none at all.
#'
#' @return A data frame with the following columns:
#' report_dates, delay_int, onset_dates, is_weekend, report_int, and week_int.
#' This data frame is ordered by report_dates and assigned a class
#' attribute of `lineList`.
#'
#' @details The function ensures the following:
#'          - The length of `report_dates` and `onset_dates` must be equal.
#'          - There should be no NA values in `report_dates`.
#'          - `onset_dates` must contain some but not all NA values.
#'          - Each non-NA onset date must be earlier than or equal to its
#'            corresponding report date.
#'          If any of these conditions are violated, the function will
#'          stop with an error message.
#'          Additionally, the function calculates the delay in days between
#'          onset and report dates,
#'          identifies weekends, and calculates reporting and week intervals
#'          based on the earliest date.
#'
#' @examples
#' data("sample_onset_dates")
#' data("sample_report_dates")
#' line_list <- create_linelist(sample_report_dates, sample_onset_dates)
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#' @export
create_linelist <- function(report_dates, onset_dates) {

  # -----------------------------------------------------
  # check types
  stopifnot(all(! is.na(as.Date(report_dates))))
  if(any(is.na(as.Date(onset_dates)))) warning("Some onset dates are NA")

  # length equal
  stopifnot(length(report_dates) == length(onset_dates))

  # NO NA report dates
  stopifnot(!any(is.na(report_dates)))

  # some NA onset dates
  which_na <- which(is.na(onset_dates))
  cond1 <- length(which_na) == 0
  cond2 <- length(which_na) == length(report_dates)
  if(cond1) stop("No missing onset_dates - what will you impute??")
  if(cond2) stop("All onset_dates missing")

  # all onset must be < report
  for(i in 1:length(report_dates)) {
    if(!is.na(onset_dates[i])) {
      if(onset_dates[i] > report_dates[i])
        stop(paste0("On day ", i,", onset >= report"))
    }
  }

  # -----------------------------------------------------
  # add additional columns
  report_date <- report_int <- NULL

  report_dates <- as.Date(report_dates)
  onset_dates <- as.Date(onset_dates)

  d <- data.frame(report_date = report_dates, onset_date = onset_dates)

  d <- d[order(report_dates),]

  # the reporting delay
  d$delay_int <- as.numeric(d$report_date - d$onset_date)

  # boolean for is Weekend
  d$is_weekend <- ifelse(weekdays(as.Date(d$report_date)) %in%
                           c("Saturday", "Sunday"), 1, 0)


  # min_day is the first reporting day of generation 1,
  # where min_day = 0 would be the infection day of generation 1
  # offset and covert to numbers
  min_day = min(d$report_date)

  # sets the integer used for the report date
  d$report_int <- as.vector(as.Date(d$report_date) - as.Date(min_day) + 1)

  # gets the week
  d$week_int <- ceiling(d$report_int / 7)

  # type convert
  d$delay_int  <- as.integer(d$delay_int)
  d$is_weekend <- as.integer(d$is_weekend)
  d$report_int <- as.integer(d$report_int)
  d$week_int   <- as.integer(d$week_int)

  d <- d[, c("report_date", "delay_int",   "onset_date",
             "is_weekend",  "report_int",  "week_int" )]

  # set class
  class(d) <- c("lineList", class(d))

  return(d)
}
