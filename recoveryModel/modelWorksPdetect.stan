data {
  int<lower = 0> nObs; # number of observations 
  int<lower = 0> nPsi; # number of sites
  int<lower = 0> nTheta; # number of samples
  int<lower = 0> nPdetect; # number of detection probs
  int<lower = 0> Y[nObs]; # Replicate level detections per visit
  int<lower = 0> Z[nObs]; # site level detection 
  int<lower = 0> A[nObs]; # sample level detection 
  int<lower = 0> psiID[nObs]; # dummy variable for psi
  int<lower = 0> thetaID[nObs]; # dummy variable for theta
  int<lower = 0> pID[nObs]; # dummy variable for p
  int<lower = 0> K; # Number of PCR replicates 
}
parameters {
  vector[nPdetect] muPdetect;
  vector[nPsi]  muPpsi;
  vector[nTheta]  muPtheta;
}
model {
  // local variables to avoid recomputing log(psi) and log(1 - psi)
  vector[nPsi] log_inv_muPpsi;
  vector[nPsi] log1m_inv_muPpsi;

  vector[nTheta] log_inv_muPtheta;
  vector[nTheta] log1m_inv_muPtheta;

  for(sPsi in 1:nPsi){
    log_inv_muPpsi[sPsi]   = log_inv_logit(muPpsi[sPsi]);
    log1m_inv_muPpsi[sPsi] = log1m_inv_logit(muPpsi[sPsi]);
  }
  
  for(sT in 1:nTheta){  
    log_inv_muPtheta[sT]   = log_inv_logit(muPtheta[sT]);
    log1m_inv_muPtheta[sT] = log1m_inv_logit(muPtheta[sT]);
  }


  // Priors 
  muPpsi   ~ normal(0, 5);
  muPdetect ~ normal(0, 5);
  muPtheta ~ normal(0, 5);
  
  // likelihood
  for (d in 1:nObs) {
    if (Z[d] > 0){ # Has DNA been found at the site?
      if (A[d] > 0) { # Has DNA been detected within a sample?
	target += # Yes, DNA is in both site and sample 
	  log_inv_muPpsi[psiID[d]] +
	  log_inv_muPtheta[thetaID[d]] + 
	  binomial_logit_lpmf( Y[d] | K,
			       muPdetect[pID[d]] );
      } else {
	target += log_sum_exp( # Yes DNA is a the site, but not within sample
			      log_inv_muPpsi[psiID[d]] +
			      log_inv_muPtheta[thetaID[d]] + 
			      binomial_logit_lpmf(Y[d] | K,
						   muPdetect[pID[d]]),
			      log1m_inv_muPtheta[thetaID[d]]);
      }	  
    } else {
      target += log_sum_exp(
			    log_sum_exp( # No DNA at the site nor within sample
					log_inv_muPpsi[psiID[d]] +
					log_inv_muPtheta[thetaID[d]] + 
					binomial_logit_lpmf(Y[d] | K,
							     muPdetect[pID[d]]),
					log1m_inv_muPpsi[psiID[d]]),
			    log1m_inv_muPtheta[thetaID[d]]);
    }
  }
}
generated quantities {
  vector<lower = 0, upper = 1>[nPsi] pPsi;
  vector<lower = 0, upper = 1>[nPsi] pTheta;
  real<lower = 0, upper = 1> pDetect;

  for(sPsi in 1:nPsi){
    pPsi[sPsi]   = inv_logit(muPpsi[sPsi]);
  }

  for(sTheta in 1:nTheta){
    pTheta[sTheta] = inv_logit(muPtheta[sTheta]);
  }
  
  for(sP in 1:nPdetect){
    pDetect = inv_logit(muPdetect[sP]);
  }
}
