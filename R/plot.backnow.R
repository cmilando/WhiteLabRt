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
#'   norm_sigma = 0.5, 
#'   sip = sip,
#'   NB_maxdelay = as.integer(20), 
#'   NB_size = as.integer(6), 
#'   workerID = 1, 
#'   printProgress = 1, 
#'   preCalcTime = TRUE)
#' plot(results, 'est')
#' plot(results, 'rt')
#'}
#' @rdname plot.backnow
#' @import graphics
#' @export
plot.backnow <- function(x, plottype, ...){
  
  stopifnot(plottype %in% c('est', 'rt'))
  
  if(plottype == 'est') {
    
    plot(x = x$report_date, y = x$report_cases,
         xlab = 'Date', ylab = 'N. Cases')
    
    newx <- x$est_back_date
    lb <- x$est_back[1, ]
    ub <- x$est_back[3, ]
    
    polygon(c(rev(newx), newx), c(rev(ub), lb), 
            col = 'grey80', border = NA)
    
    lines(x = x$est_back_date, y = x$est_back[2, ], col = 'red', lt = '11')
    
  } else {
    
    plot(x = x$est_rt_date, y = x$est_rt[2,], col = 'white',
         xlab = 'Date', ylab = 'r(t)')
    
    newx <- x$est_rt_date
    lb <- x$est_rt[1, ]
    ub <- x$est_rt[3, ]
    
    polygon(c(rev(newx), newx), c(rev(ub), lb), 
            col = 'grey80', border = NA)
    
    lines(x = x$est_rt_date, y = x$est_rt[2, ], col = 'red', lt = '11')
  }
  
}
