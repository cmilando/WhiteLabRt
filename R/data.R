#' Sample dates
#'
#' Sample of case report dates from a single location.
#'
#' @format A vector of length 80.
#' \describe{
#' \item{Dates}{Dates of reported aggregated cases}
#' }
#'
#'
"sample_dates"
#> [1] "sample_dates"


#' Sample cases
#'
#' Sample of aggregated case counts from a single location.
#'
#' @format A vector of length 80.
#' \describe{
#' \item{Cases}{Numeric}
#' }
#'
#'
"sample_cases"

#' Sample location
#'
#' An vector of a single location to accompany `sample_dates` and `sample_cases`.
#' This is to emphasize that linelist functions are for a single location
#'
#' @format A vector of length 80.
#' \describe{
#' \item{Location}{Character}
#' }
#'
#'
"sample_location"

#' Sample hierachical model output
#'
#' an example `rstan` output object from spatialrt()
#'
#' @format An rstan object
#' \describe{
#' \item{list}{list}
#' }
#'
#'
"sample_m_hier"

#' Sample back-calculation output
#'
#' an example `backnow` output object from run_backnow()
#'
#' @format An backnow object
#' \describe{
#' \item{list}{list}
#' }
#'
#'
"out_list_demo"

#' Sample report dates
#'
#' Line-list data, case report dates.
#'
#' @format A vector of length 6380, one value per case.
#' \describe{
#' \item{Date}{Date of report}
#' }
#'
#'
"sample_report_dates"

#' Sample onset dates
#'
#' Line-list data, onset dates, with some missing.
#'
#' @format A vector of length 6380, one value per case.
#' \describe{
#' \item{Date}{Date of onset}
#' }
#'
#'
"sample_onset_dates"

#' Sample multi site
#'
#' A matrix of daily aggregated cases from two sites (Hoth and Tatooine).
#'
#' @format A data.table data frame with 80 rows and 2 variables:
#' \describe{
#' \item{Cases for Site1}{Number of aggregated cases for Site 1}
#' \item{Cases for Site1}{Number of aggregated cases for Site 2}
#' }
#'
#'
"sample_multi_site"

#' Transfer matrix
#'
#' A matrix of daily transfers between two sites (Hoth and Tatooine).
#' Each row sums to 1.
#'
#' @format A data.table data frame with 160 rows and 2 variables:
#' \describe{
#' \item{Transfer to Site1}{Fraction of transfer to Site 1}
#' \item{Transfer to Site2}{Fraction of transfer to Site 2}
#' }
#'
#'
"transfer_matrix"


