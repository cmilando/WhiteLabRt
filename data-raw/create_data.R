## code to prepare ALL datasets goes here


si_shape <- 2       ## shape parameter for serial interval assuming gamma distribution
si_rate  <- 0.5     ## rate parameter for serial interval assuming gamma distribution

w <- sapply(1:14, function(x){
  pgamma(x, si_shape, si_rate) - pgamma(x-1, si_shape, si_rate)
})

w <- w/sum(w)

Ra <- function(t) (20*cos(t/500) + (0.8*t - 50)^2 - (0.115 * t)^3)/1000 + 0.8
Rb <- function(t) (30*sin(t/150) + cos(t/20) - (t/50)^2)/8 - 0.006*t
Rc <- function(t) (30*cos(t/150) + 2*sin(t/20) + 2*(t/50)^2)/20 - 0.005*t

tmax <- 80

Rmatrix = cbind(Ra(1:tmax), Rb(1:tmax), Rc(1:tmax))
head(Rmatrix)

M <- matrix(NA, nrow = tmax, ncol = 3)
N <- matrix(NA, nrow = tmax, ncol = 3)
R_rev <- matrix(NA, nrow = tmax, ncol = 3)
R_this <- matrix(NA, nrow = tmax, ncol = 3)

# initialize
t = 1
R_rev[t, ] <- 1e-5
R_this[t, ] <- 1e-5
M[t, ] <- 10
N[t, ] <- 10
J <- 3
S <- length(w)

P <- matrix(c(0.8, 0.2, 0.1,
              0.15, 0.6, 0.3,
              0.05, 0.2, 0.6), 3)

set.seed(123)

for(t in 2:tmax) {

  # what are the boundaries of tau
  tau_end = min(S, t - 1)

  ## FIRST YOU CAN CALCULATE THE INNER
  # dim(Rmatrix[t, ])
  #inner_vec2 <- as.matrix(rep(Rmatrix[t, ],ta) %*% M[t - 1:tau_end, 1] %*% w[1:tau_end]

  ## need to repeat this
  #J = 1

  RR <- diag(Rmatrix[t, ])
  RR

  ## MM is m(t - 1), ..., m(1)
  ## where rows are regions
  ## and columns are time
  if(t == 2) {
    MM <- as.matrix(M[t - 1:tau_end, ])
  } else {
    MM <- t(as.matrix(M[t - 1:tau_end, ]))
  }
  MM
  WW <-  as.matrix(w[1:tau_end])

  inner_vec <- RR %*% MM %*% WW

  # Rmatrix[t, ]
  # RR <- matrix(rep(Rmatrix[t, ],times = tau_end), ncol = tau_end)
  # RR
  # RR %*% M[t - 1:tau_end, ]
  #
  # inner_vec = vector("numeric", J)
  # inner_vec[1:J] <- 0
  # ##
  # for(jx in 1:J) {
  #
  #   ## FOR EACH jx CALCULATE THE SUM
  #   for(tau in 1:tau_end) {
  #     inner_vec[jx] = inner_vec[jx] + Rmatrix[t, jx] * M[t - tau, jx] * w[tau]
  #   }
  #
  # }
  # inner_vec ## just 1 for each region
  # Rmatrix[t,]## //

  ##x
  # outer_vec = vector("numeric", J)
  # outer_vec[1:J] <- 0
  #
  # # this gets each m_j
  # for(j in 1:J) {
  #
  #   # now loop over all j' within each j
  #   for(jx in 1:J) {
  #
  #     # ****
  #     # the difference is whether you invert jx or j in P
  #     # ****
  #     outer_vec[j] = outer_vec[j] + P[jx, j] * inner_vec[jx]
  #
  #   }
  #
  # }
  outer_vec = t(P) %*% inner_vec

  M[t, ] = outer_vec
  N[t, ] = sapply(outer_vec, function(x) rpois(1, x))

  ## --------------------------------------------------
  ## reverse calc R
  sum_m_w_mat <- matrix(rep(MM %*% WW, times = J), byrow = T, nrow = J)

  # now the a, b, c ... matrix is really just P * rowwise the above
  c_mat <- t(P) * sum_m_w_mat
  c_mat

  R_rev[t, ] <- solve(t(c_mat) %*% c_mat) %*% t(c_mat) %*% M[t, ]

  R_rev[t, ]
  Rmatrix[t, ]
  DIG = 12
  stopifnot(round(R_rev[t, ], DIG) == round(Rmatrix[t, ], DIG))

  ## --------------------------------------------------
  ## calc this R based on N not MM
  if(t == 2) {
    NN <- as.matrix(N[t - 1:tau_end, ])
  } else {
    NN <- t(as.matrix(N[t - 1:tau_end, ]))
  }

  sum_m_w_mat <- matrix(rep(NN %*% WW, times = J), byrow = T, nrow = J)

  # now the a, b, c ... matrix is really just P * rowwise the above
  c_mat <- t(P) * sum_m_w_mat
  c_mat

  R_this[t, ] <- solve(t(c_mat) %*% c_mat) %*% t(c_mat) %*% N[t, ]

}

# plot(M[,1], type = 'l', col = 'red')
# lines(N[, 1], col = 'red')
# lines(M[,2], type = 'l', col = 'green')
# lines(N[, 2], col = 'green')
# lines(M[,3], type = 'l', col = 'blue')
# lines(N[,3], type = 'l', col = 'blue')
#
# plot(Rmatrix[,1], type = 'l', col = 'red', ylim = c(0, 5))
# lines(R_this[, 1], col = 'red')
# lines(Rmatrix[,2], type = 'l', col = 'green')
# lines(R_this[, 2], col = 'green')
# lines(Rmatrix[,3], type = 'l', col = 'blue')
# lines(R_this[,3], type = 'l', col = 'blue')

# decide how many columns to give
J = 2
M <- M[, 1:J]
N <- N[, 1:J]
P <- P[1:J, 1:J]

# ------------------------------------------------------------------------
## NOW EXPORT

## SAMPLE CASES
sample_cases = N[, 1]
usethis::use_data(sample_cases, overwrite = TRUE)

## SAMPLE DATES
ref_date = as.Date('2020-01-01')
sample_dates = seq.Date(from = ref_date, to = ref_date + nrow(N) - 1, by = 'day')
usethis::use_data(sample_dates, overwrite = TRUE)

## SAMPLE LOCATION
sample_location = rep("Tatooine", nrow(N))
usethis::use_data(sample_location, overwrite = TRUE)

## SAMPLE ONSET DATES
cc = create_caseCounts(date_vec = sample_dates,
                       location_vec = sample_location,
                       cases_vec = sample_cases)

ll = convert_to_linelist(caseCounts = cc, reportF_missP = 0.5)

sample_onset_dates = ll$onset_date
usethis::use_data(sample_onset_dates, overwrite = TRUE)

sample_report_dates = ll$report_date
usethis::use_data(sample_report_dates, overwrite = TRUE)

##  SAMPLE MULTI SITE
sample_multi_site = data.frame(date = sample_dates, N)
colnames(sample_multi_site)[2:3] <- c('Tatooine', 'Hoth')
usethis::use_data(sample_multi_site, overwrite = TRUE)

## TRANSFER MATRIX
# make daily
P_list <- lapply(1:nrow(N), function(x) P)
transfer_matrix <- do.call(rbind, P_list)
dim(transfer_matrix)
colnames(transfer_matrix) <- c('Tatooine', 'Hoth')
rn = vector("character", nrow(N))
for(i in seq(2, nrow(N) * 2, by = 2)) {
  rn[i-1] = paste0(sample_dates[i/2], ':Tatooine')
  rn[i]   = paste0(sample_dates[i/2], ':Hoth')
}
rownames(transfer_matrix) <- rn[1:nrow(transfer_matrix)]
head(transfer_matrix)
tail(transfer_matrix)
usethis::use_data(transfer_matrix, overwrite = TRUE)

