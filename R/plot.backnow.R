#' Plot Estimates or Reproduction Numbers
#'
#' This function plots estimates of case numbers or reproduction numbers (`r(t)`) based on the
#' provided object. It can handle two types of plots: 'est' for estimated case numbers over time,
#' and 'rt' for estimated reproduction numbers over time.
#'
#' @param x An object containing the necessary data for plotting. This object should have
#'            specific structure depending on the `plottype`:
#'            - For `plottype = 'est'`, `x` should contain `report_date`, `report_cases`,
#'              `est_back_date`, and `est_back`, where `est_back` is expected to be a matrix
#'              with three rows representing the lower bound, estimate, and upper bound.
#'            - For `plottype = 'rt'`, `x` should contain `est_rt_date` and `est_rt`,
#'              with `est_rt` formatted similarly to `est_back`.
#' @param plottype A character string specifying the type of plot to generate. Valid options
#'                 are 'est' for case estimates and 'rt' for reproduction numbers.
#' @param ... Additional arguments passed to the plot function.
#' @method plot backnow
#' @return a plot object for an object of class `backnow`
#'
#' @details Depending on the `plottype`:
#'          - 'est': Plots the reported cases over time with a polygon representing the
#'            uncertainty interval and a line showing the central estimate.
#'          - 'rt': Plots the reproduction number over time with a similar style.
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
#'   sip = sip,
#'   NB_maxdelay = as.integer(20),
#'   window_size = as.integer(6), chains = 1)
#'}
#' @rdname plot.backnow
#' @import graphics
#' @export
plot.backnow <- function(x, plottype, ...){

  stopifnot(plottype %in% c('est', 'rt'))

  if(plottype == 'est') {

    llx <- x$ll

    ll_df <- as.data.frame(table(llx$report_date))

    plot(x = as.Date(ll_df$Var1),
         y = ll_df$Freq,
         xlab = 'Date', ylab = 'N. Cases')

    newx <- x$est_df$x
    lb <- x$est_df$lb
    ub <- x$est_df$ub

    polygon(c(rev(newx), newx), c(rev(ub), lb),
            col = 'grey80', border = NA)

    lines(x = x$est_df$x, y = x$est_df$med, col='red')

    legend("topright",
           legend = c("Reported cases", "Predicted Onset"),
           col = c("black", "red"),
           lty = c(NA, 1), # Line types
           pch = c(1, NA), # Point types (1 is a default point type)
           cex = 0.8) # Text size


  } else {

    # subset out all zero
    row_i = 1
    while(x$rt_df$med[row_i] == 0) {
      row_i = row_i + 1
    }

    trunc_df <- x$rt_df[(row_i):nrow(x$rt_df), ]

    plot(x =  trunc_df$x,
         y =  trunc_df$med, col = 'white',
         xlab = 'Date', ylab = 'R(t)')

    newx <- trunc_df$x
    lb <- trunc_df$lb
    ub <- trunc_df$ub

    polygon(c(rev(newx), newx), c(rev(ub), lb),
            col = 'grey80', border = NA)

    lines(x =  trunc_df$x, y =  trunc_df$med,
          col = 'red', lt = '11')

    abline(a = 1, b = 0)

    legend("topright",
           legend = c("Reported cases", "Predicted R(t)"),
           col = c("black", "red"),
           lty = c(NA, 1), # Line types
           pch = c(1, NA), # Point types (1 is a default point type)
           cex = 0.8) # Text size

  }

}
