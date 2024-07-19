# WhiteLabRt
A collection of functions related to novel methods for estimating R(t), created by the lab of Professor Laura White.

## Currently implemented methods

* **Temporal R(t) estimation**: Two-step Bayesian back and nowcasting for linelist data with missing reporting delays, adapted in STAN from [Li and White](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1009210)

  * Remaining todo's:

    * Implement the right-truncated NB distribution function in the likelihood and rng forms, see here: https://discourse.mc-stan.org/t/rng-for-truncated-distributions/3122/14 
for starters

* **Spatial R(t) estimation**: Zhenwei's code. Adapted into weekly, with an AR1 process for smoothing. 

  * Remaining todo's:

    * non-centered parameterization
    
    * AR1 process

## Future plans

* Genetic-based R(t)

## Useful references for STAN package development

* https://mc-stan.org/rstantools/articles/minimal-rstan-package.html
* https://mc-stan.org/rstantools/articles/developer-guidelines.html

### Devtools reminders

# for larger changes
devtools::document()
devtools::check() 
devtools::build()
## R CMD check --as-cran WhiteLabRt_1.0.tar.gz
devtools::install()

# 
devtools::build_vignettes()
browseVignettes('WhiteLabRt')

# for quick hits
devtools::load_all()
