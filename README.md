# WhiteLabRt
A collection of functions related to novel methods for estimating 
reproduction number, R(t), created by the lab of Professor Laura White at Boston University School of Public Health.

## Currently implemented methods

* **Temporal R(t) estimation**: Two-step Bayesian back and nowcasting for linelist data with missing reporting delays, adapted in STAN from [Li and White](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1009210)

  * Remaining todos:

    [] Implement the right-truncated NB distribution function in the likelihood and rng forms, see [here](https://discourse.mc-stan.org/t/rng-for-truncated-distributions/3122/14) for starters

* **Spatial R(t) estimation**: Calculating time-varying reproduction number, R(t), assuming a flux of infectors between various adjacent states. This was adapted in STAN from [Zhou and White](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010434)

  * Remaining todos:

    [] Continuing working on non-centered parameterization, AR1 process, and partial pooling
    [] Use tidy bayes for QC

## Future plans

* **Unified spatial-temporal R(t) estimation** Combining the two methods above.
* **Genetic-based R(t)** Using genetic data to inform R(t) calculation


