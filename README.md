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


### current errors during R CMD CHECK

WhiteLabRt-package.html:15:44 (WhiteLabRt-package.Rd:7): Error: <main> is not recognized!
  WhiteLabRt-package.html:15:44 (WhiteLabRt-package.Rd:7): Warning: discarding unexpected <main>
  WhiteLabRt-package.html:49:1 (WhiteLabRt-package.Rd:12): Warning: discarding unexpected </main>
  WhiteLabRt-package.html:4:1 (WhiteLabRt-package.Rd:7): Warning: <link> inserting "type" attribute
WhiteLabRt-package.html:12:1 (WhiteLabRt-package.Rd:7): Warning: <script> proprietary attribute "onload"
WhiteLabRt-package.html:12:1 (WhiteLabRt-package.Rd:7): Warning: <script> inserting "type" attribute
WhiteLabRt-package.html:17:1 (WhiteLabRt-package.Rd:7): Warning: <table> lacks "summary" attribute

convert_to_linelist.html:15:44 (convert_to_linelist.Rd:5): Error: <main> is not recognized!
  convert_to_linelist.html:15:44 (convert_to_linelist.Rd:5): Warning: discarding unexpected <main>
  convert_to_linelist.html:101:1 (convert_to_linelist.Rd:57): Warning: discarding unexpected </main>
  convert_to_linelist.html:4:1 (convert_to_linelist.Rd:5): Warning: <link> inserting "type" attribute
convert_to_linelist.html:12:1 (convert_to_linelist.Rd:5): Warning: <script> proprietary attribute "onload"
convert_to_linelist.html:12:1 (convert_to_linelist.Rd:5): Warning: <script> inserting "type" attribute
convert_to_linelist.html:17:1 (convert_to_linelist.Rd:5): Warning: <table> lacks "summary" attribute
convert_to_linelist.html:43:1 (convert_to_linelist.Rd:15): Warning: <table> lacks "summary" attribute

create_caseCounts.html:15:44 (create_caseCounts.Rd:5): Error: <main> is not recognized!
  create_caseCounts.html:15:44 (create_caseCounts.Rd:5): Warning: discarding unexpected <main>
  create_caseCounts.html:84:1 (create_caseCounts.Rd:42): Warning: discarding unexpected </main>
  create_caseCounts.html:4:1 (create_caseCounts.Rd:5): Warning: <link> inserting "type" attribute
create_caseCounts.html:12:1 (create_caseCounts.Rd:5): Warning: <script> proprietary attribute "onload"
create_caseCounts.html:12:1 (create_caseCounts.Rd:5): Warning: <script> inserting "type" attribute
create_caseCounts.html:17:1 (create_caseCounts.Rd:5): Warning: <table> lacks "summary" attribute
create_caseCounts.html:39:1 (create_caseCounts.Rd:10): Warning: <table> lacks "summary" attribute

create_linelist.html:15:44 (create_linelist.Rd:5): Error: <main> is not recognized!
  create_linelist.html:15:44 (create_linelist.Rd:5): Warning: discarding unexpected <main>
  create_linelist.html:84:1 (create_linelist.Rd:44): Warning: discarding unexpected </main>
  create_linelist.html:4:1 (create_linelist.Rd:5): Warning: <link> inserting "type" attribute
create_linelist.html:12:1 (create_linelist.Rd:5): Warning: <script> proprietary attribute "onload"
create_linelist.html:12:1 (create_linelist.Rd:5): Warning: <script> inserting "type" attribute
create_linelist.html:17:1 (create_linelist.Rd:5): Warning: <table> lacks "summary" attribute
create_linelist.html:36:1 (create_linelist.Rd:10): Warning: <table> lacks "summary" attribute

out_list_demo.html:15:44 (out_list_demo.Rd:6): Error: <main> is not recognized!
  out_list_demo.html:15:44 (out_list_demo.Rd:6): Warning: discarding unexpected <main>
  out_list_demo.html:44:1 (out_list_demo.Rd:11): Warning: discarding unexpected </main>
  out_list_demo.html:4:1 (out_list_demo.Rd:6): Warning: <link> inserting "type" attribute
out_list_demo.html:12:1 (out_list_demo.Rd:6): Warning: <script> proprietary attribute "onload"
out_list_demo.html:12:1 (out_list_demo.Rd:6): Warning: <script> inserting "type" attribute
out_list_demo.html:17:1 (out_list_demo.Rd:6): Warning: <table> lacks "summary" attribute

plot.backnow.html:15:44 (plot.backnow.Rd:5): Error: <main> is not recognized!
  plot.backnow.html:15:44 (plot.backnow.Rd:5): Warning: discarding unexpected <main>
  plot.backnow.html:89:1 (plot.backnow.Rd:46): Warning: discarding unexpected </main>
  plot.backnow.html:4:1 (plot.backnow.Rd:5): Warning: <link> inserting "type" attribute
plot.backnow.html:12:1 (plot.backnow.Rd:5): Warning: <script> proprietary attribute "onload"
plot.backnow.html:12:1 (plot.backnow.Rd:5): Warning: <script> inserting "type" attribute
plot.backnow.html:17:1 (plot.backnow.Rd:5): Warning: <table> lacks "summary" attribute
plot.backnow.html:38:1 (plot.backnow.Rd:10): Warning: <table> lacks "summary" attribute
plot.backnow.html:54:14 (plot.backnow.Rd:21): Warning: <code> attribute "id" has invalid value "..."

plot.caseCounts.html:15:44 (plot.caseCounts.Rd:5): Error: <main> is not recognized!
  plot.caseCounts.html:15:44 (plot.caseCounts.Rd:5): Warning: discarding unexpected <main>
  plot.caseCounts.html:83:1 (plot.caseCounts.Rd:40): Warning: discarding unexpected </main>
  plot.caseCounts.html:4:1 (plot.caseCounts.Rd:5): Warning: <link> inserting "type" attribute
plot.caseCounts.html:12:1 (plot.caseCounts.Rd:5): Warning: <script> proprietary attribute "onload"
plot.caseCounts.html:12:1 (plot.caseCounts.Rd:5): Warning: <script> inserting "type" attribute
plot.caseCounts.html:17:1 (plot.caseCounts.Rd:5): Warning: <table> lacks "summary" attribute
plot.caseCounts.html:38:1 (plot.caseCounts.Rd:10): Warning: <table> lacks "summary" attribute
plot.caseCounts.html:52:14 (plot.caseCounts.Rd:19): Warning: <code> attribute "id" has invalid value "..."

run_backnow.html:15:44 (run_backnow.Rd:5): Error: <main> is not recognized!
  run_backnow.html:15:44 (run_backnow.Rd:5): Warning: discarding unexpected <main>
  run_backnow.html:105:1 (run_backnow.Rd:57): Warning: discarding unexpected </main>
  run_backnow.html:4:1 (run_backnow.Rd:5): Warning: <link> inserting "type" attribute
run_backnow.html:12:1 (run_backnow.Rd:5): Warning: <script> proprietary attribute "onload"
run_backnow.html:12:1 (run_backnow.Rd:5): Warning: <script> inserting "type" attribute
run_backnow.html:17:1 (run_backnow.Rd:5): Warning: <table> lacks "summary" attribute
run_backnow.html:44:1 (run_backnow.Rd:17): Warning: <table> lacks "summary" attribute
run_backnow.html:67:14 (run_backnow.Rd:29): Warning: <code> attribute "id" has invalid value "..."

sample_cases.html:15:44 (sample_cases.Rd:6): Error: <main> is not recognized!
  sample_cases.html:15:44 (sample_cases.Rd:6): Warning: discarding unexpected <main>
  sample_cases.html:44:1 (sample_cases.Rd:11): Warning: discarding unexpected </main>
  sample_cases.html:4:1 (sample_cases.Rd:6): Warning: <link> inserting "type" attribute
sample_cases.html:12:1 (sample_cases.Rd:6): Warning: <script> proprietary attribute "onload"
sample_cases.html:12:1 (sample_cases.Rd:6): Warning: <script> inserting "type" attribute
sample_cases.html:17:1 (sample_cases.Rd:6): Warning: <table> lacks "summary" attribute

sample_dates.html:15:44 (sample_dates.Rd:6): Error: <main> is not recognized!
  sample_dates.html:15:44 (sample_dates.Rd:6): Warning: discarding unexpected <main>
  sample_dates.html:44:1 (sample_dates.Rd:11): Warning: discarding unexpected </main>
  sample_dates.html:4:1 (sample_dates.Rd:6): Warning: <link> inserting "type" attribute
sample_dates.html:12:1 (sample_dates.Rd:6): Warning: <script> proprietary attribute "onload"
sample_dates.html:12:1 (sample_dates.Rd:6): Warning: <script> inserting "type" attribute
sample_dates.html:17:1 (sample_dates.Rd:6): Warning: <table> lacks "summary" attribute

sample_location.html:15:44 (sample_location.Rd:6): Error: <main> is not recognized!
  sample_location.html:15:44 (sample_location.Rd:6): Warning: discarding unexpected <main>
  sample_location.html:44:1 (sample_location.Rd:11): Warning: discarding unexpected </main>
  sample_location.html:4:1 (sample_location.Rd:6): Warning: <link> inserting "type" attribute
sample_location.html:12:1 (sample_location.Rd:6): Warning: <script> proprietary attribute "onload"
sample_location.html:12:1 (sample_location.Rd:6): Warning: <script> inserting "type" attribute
sample_location.html:17:1 (sample_location.Rd:6): Warning: <table> lacks "summary" attribute

sample_onset_dates.html:15:44 (sample_onset_dates.Rd:6): Error: <main> is not recognized!
  sample_onset_dates.html:15:44 (sample_onset_dates.Rd:6): Warning: discarding unexpected <main>
  sample_onset_dates.html:44:1 (sample_onset_dates.Rd:11): Warning: discarding unexpected </main>
  sample_onset_dates.html:4:1 (sample_onset_dates.Rd:6): Warning: <link> inserting "type" attribute
sample_onset_dates.html:12:1 (sample_onset_dates.Rd:6): Warning: <script> proprietary attribute "onload"
sample_onset_dates.html:12:1 (sample_onset_dates.Rd:6): Warning: <script> inserting "type" attribute
sample_onset_dates.html:17:1 (sample_onset_dates.Rd:6): Warning: <table> lacks "summary" attribute

sample_report_dates.html:15:44 (sample_report_dates.Rd:6): Error: <main> is not recognized!
  sample_report_dates.html:15:44 (sample_report_dates.Rd:6): Warning: discarding unexpected <main>
  sample_report_dates.html:44:1 (sample_report_dates.Rd:11): Warning: discarding unexpected </main>
  sample_report_dates.html:4:1 (sample_report_dates.Rd:6): Warning: <link> inserting "type" attribute
sample_report_dates.html:12:1 (sample_report_dates.Rd:6): Warning: <script> proprietary attribute "onload"
sample_report_dates.html:12:1 (sample_report_dates.Rd:6): Warning: <script> inserting "type" attribute
sample_report_dates.html:17:1 (sample_report_dates.Rd:6): Warning: <table> lacks "summary" attribute

si.html:15:44 (si.Rd:5): Error: <main> is not recognized!
  si.html:15:44 (si.Rd:5): Warning: discarding unexpected <main>
  si.html:82:1 (si.Rd:38): Warning: discarding unexpected </main>
  si.html:4:1 (si.Rd:5): Warning: <link> inserting "type" attribute
si.html:12:1 (si.Rd:5): Warning: <script> proprietary attribute "onload"
si.html:12:1 (si.Rd:5): Warning: <script> inserting "type" attribute
si.html:17:1 (si.Rd:5): Warning: <table> lacks "summary" attribute
si.html:39:1 (si.Rd:10): Warning: <table> lacks "summary" attribute

