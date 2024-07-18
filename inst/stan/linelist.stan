functions {

  vector prop(vector x, vector onset, int maxdelay, int cd) {
    int n = num_elements(x);
    vector[n] x1;
    int dem;
    vector[maxdelay] p1;
    vector[maxdelay] p;
    vector[maxdelay] p2;
    vector[maxdelay] result;
    int count = 1;

    // Create logical vector
    for (i in 1:n) {
      if (x[i] <= maxdelay && onset[i] >= cd) {
        x1[count] = x[i];
        count += 1;
      }
    }

    // Truncate x1 to the actual size of valid elements
    vector[count-1] x1_truncated;
    for (i in 1:(count-1)) {
      x1_truncated[i] = x1[i];
    }

    dem = count - 1;

    // Initialize p1
    for (i in 1:maxdelay) {
      p1[i] = 0;
    }

    // Populate p1
    for (i in 1:maxdelay) {
      for (j in 1:dem) {
        if (x1_truncated[j] == (maxdelay - i + 1)) {
          p1[i] += 1;
        }
      }
    }

    // Calculate proportion
    p = p1 / dem;

    // Calculate cumulative sum
    p2[1] = p[1];
    for (i in 2:maxdelay) {
      p2[i] = p2[i-1] + p[i];
    }

    // Calculate result
    for (i in 1:maxdelay) {
      result[i] = 1 - p2[i];
    }

    return result;
  }

}

data {
  //
  int<lower=1>     J;         // Number of Betas: aka n weeks + 1 is_weekend
  int<lower=1>     sipN;      // SIP length
  vector[sipN]     sip;       // SIP
  int<lower=1>  maxdelay;
  int<lower=1>  ndays;
  int<lower=1>  windowsize;

  // OBSERVED
  int<lower=1>     N_obs;           // Number of individuals
  matrix[N_obs, J] dum_obs;         // matrix of indicator values
  int              Y_obs[N_obs];    // observed reporting delays
  int              ReportOnset[N_obs]; // which days did these occur on ...

  // MISSING
  int<lower=1>      N_miss;        // Number of individuals with missing data
  matrix[N_miss, J] dum_miss;      // matrix of indicator values
  int               ReportDays[N_miss]; // which days were things reported on

  // Tells you the true order of cases
  int  missvector[N_obs + N_miss];
}


parameters {
  vector[J] betas;         // one param for each week + 1 is_weekend
  real<lower=0.01> phi;    // a single dispersion param
}


transformed parameters {

  vector[N_obs] mu_obs;          // each person has their own mu
  mu_obs = exp(dum_obs * betas); // dot-product, gives mu_vector

  vector[N_miss] mu_miss;          // each person has their own mu
  mu_miss = exp(dum_miss * betas); // dot-product, gives mu_vector

}

model {

  // prior for beta and size
  betas ~ normal(0, 1);
  phi ~ normal(0, 1);

  // likelihood
  // *******************************
  // UPDATE THIS TO RIGHT TRUNCATED
  Y_obs ~ neg_binomial_2(mu_obs, phi);
  // *******************************

}

generated quantities {

 // -- THE DATA THAT WERE MISSING ONSET INFORMATION
  vector[N_miss] y_rep_miss;
  vector[N_miss] guessOnset;

  for(n in 1:N_miss) {
    // *******************************
    // UPDATE THIS TO RIGHT TRUNCATED
    y_rep_miss[n] = neg_binomial_2_rng(mu_miss[n], phi);
    // *******************************
    guessOnset[n] = ReportDays[n] - y_rep_miss[n];
  }


 // -- BUILD TOWARDS CALCULATING RT -->
 // (1) Create vetors for onset days (allOnset) and reporting delays (allY)
 vector[N_obs + N_miss] allOnset;
 vector[N_obs + N_miss] allY;
 int i_miss = 1;
 int i_true = 1;
 for(n in 1:(N_obs + N_miss)) {
   if(missvector[n] == 0) {
     allOnset[n] = ReportOnset[i_true];
     allY[n]     = Y_obs[i_true];
     i_true += 1;
   } else {
    allOnset[n] = guessOnset[i_miss];
    allY[n]     = ReportDays[i_miss] - guessOnset[i_miss];
    i_miss += 1;
   }
 }

  // (2) ok now create the full summed out-matrix of daily counts
 vector[ndays + maxdelay] day_onset_tally;
 vector[ndays + maxdelay] day_onset_tally_x;
 for (j in 1:(ndays + maxdelay)){
    int local_sum = 0;
    for(n in 1:(N_obs + N_miss)) {
      if(allOnset[n] == (j - maxdelay + 1)) {
        local_sum += 1;
      }
    }
    day_onset_tally[j]   = local_sum;
    day_onset_tally_x[j] = j - maxdelay + 1;
 }


 // -- NOWCASTING BLOCK ---
 // so now you need to summarize the values in allOnset
 vector[maxdelay] weights;
 weights = prop(allY, allOnset, maxdelay, -maxdelay);

 // Now do now-casting on the daily tallys of the tail
 vector[maxdelay] day_onset_tally_tail;
 day_onset_tally_tail = day_onset_tally[(ndays + 1):(ndays + maxdelay)];

 vector[maxdelay] check;
 for(i in 1:maxdelay) {
   check[i] = 0;
   if(day_onset_tally_tail[i] < 1) {
      check[i] = 1;
     day_onset_tally_tail[i] = 1;
   }
 }

 // here's where you calculate what to add
 // rnb(out1$back2[i], weights[i]))
 //     size, prob
 // so the size is back2, which is the onset
 // and the prob is from weights

 vector[maxdelay] trunc;
 vector[maxdelay] mu_local;
 vector[maxdelay] phi_local;

 for(i in 1:maxdelay) {

   mu_local[i] = day_onset_tally_tail[i] * (1 - weights[i]) / weights[i];

   phi_local[i] = day_onset_tally_tail[i];

   trunc[i] =  neg_binomial_2_rng(mu_local[i], phi_local[i]);

   day_onset_tally_tail[i] = day_onset_tally_tail[i] + trunc[i];

   if(check[i] == 1) {
     day_onset_tally_tail[i] -= 1;
   }

   if(day_onset_tally_tail[i] < 0) {
     day_onset_tally_tail[i] = 0;
   }

   day_onset_tally[ndays + i] = day_onset_tally_tail[i];


 }

 // --- END NOWCASTING BLOCK ---

 // -- R(t)
 // ok first i guess calculate lambda
 // t - tau
 // lambda is a function of k and

 // R(t) is t - windowsize, ...., t

 vector[ndays + maxdelay] rt;

 for(t in 1:(ndays + maxdelay)) {

   if(t < windowsize) {

     rt[t] = 0;

   } else {

     real num1 = 0;
     real den1 = 0;

     // Each R(t) has several k loops
     // -- right if t = windowsize, then k = 1, so this has to be k + 1
     for(k in (t - windowsize + 1):(t)) {

      // Numerator is just counts
      num1 += day_onset_tally[k];

      // Lambda
      real lambda = 0;

      for(j in 1:min(k, sipN)) {
         lambda += day_onset_tally[k - j + 1] * sip[j];
      }

      den1 += lambda;

     }

     // how are 1 and 0.2 chosen?
     rt[t] = (num1 + 1)/(den1 + 0.2);
   }

 }



}

