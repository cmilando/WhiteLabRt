#' The 'WhiteLabRt' package.
#'
#' @description A collection of functions related to novel methods for
#' estimating reproduction number, R(t), created by the lab of
#' Professor Laura White at Boston University School of Public Health.
#'
#' Currently implemented methods include (1) Temporal R(t) estimation:
#' Two-step Bayesian back and nowcasting for linelist data with missing
#' reporting delays, adapted in 'STAN' from
#' [Li et. al. 2021](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1009210),
#' and (2) Spatial R(t) estimation: Calculating time-varying reproduction number,
#' R(t), assuming a flux of infectors between various adjacent states,
#' in 'STAN' from [Zhou et. al. 2021](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010434).
#'
#' @name WhiteLabRt-package
#' @aliases WhiteLabRt
#' @useDynLib WhiteLabRt, .registration = TRUE
#' @import methods
#' @import Rcpp
#' @import graphics
#' @importFrom rstan stan
#' @importFrom rstantools rstan_config
#' @importFrom RcppParallel RcppParallelLibs
#' @importFrom stats rnbinom aggregate pgamma xtabs quantile
#'
#' @references
#' Stan Development Team (NA). RStan: the R interface to Stan. R package version 2.32.6. https://mc-stan.org
#'
"_PACKAGE"
NULL


