#' Plot Case Counts Over Time
#'
#' This function plots the number of cases over time from a data frame object. If the data frame
#' contains multiple locations, a specific location must be specified. The plot displays the total
#' number of cases against dates and annotates one of the earliest points with the location name.
#'
#' @param x A data frame containing the case counts with at least two columns: `date` and `cases`.
#'            The data frame may optionally include a `location` column, which is required if multiple
#'            locations are present.
#' @param loc An optional string specifying the location to filter the case counts by. If `loc` is
#'            provided and `location` column exists in `x`, the plot will only show data for the
#'            specified location. If multiple locations are present and `loc` is not specified,
#'            the function will stop with an error.
#' @param ... Additional arguments passed to the `plot` function.
#' @method plot caseCounts
#' @return a plot object for an object of class `caseCounts`
#'
#' @details If the `location` column is present in `x` and contains multiple unique values,
#'          the `loc` parameter must be specified to indicate which location's data to plot.
#'          The function adds a text annotation to the plot, labeling one of the earliest points
#'          with the specified location's name.
#'
#' @examples
#' data("sample_dates")
#' data("sample_location")
#' data("sample_cases")
#' case_Counts = create_caseCounts(sample_dates, sample_location, sample_cases)
#' plot(case_Counts)
#' @rdname plot.caseCounts
#' @import graphics
#' @importFrom grDevices rgb
#' @export
plot.caseCounts <- function(x, loc = NULL, ...){

  if(length(unique(x$location))>1) {
    stop('Specify loc="..." if more than one location exists')
  }

  if(!is.null(loc)) x <- subset(x, location = loc)

  plot(x = x$date, y = x$cases,
       xlab = 'Date', ylab = 'N. Cases')

  x_pos <- round(quantile(1:length(x$date), probs = c(0.05)))

  text(x = sort(x$date)[x_pos],
       y = sort(x$cases, decreasing = TRUE)[2],
       labels = unique(x$location))
}
