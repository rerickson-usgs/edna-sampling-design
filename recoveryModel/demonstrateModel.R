## This file demonstrates how to simulate data and use RStan to call our Stan model.

library(data.table)
library(rstan)

## Set option for Stan

options(mc.cores = parallel::detectCores() - 1)

## Define logit and siteSampleIinverse logit funcionts
invLogit <- function(x){1/(1 + exp(-x))}
invLogit(c(0,10))

## Simulate one site with constanst sampling probability and detection probability

## Probability of species occuring within the site
pPsi <- c(0.5)
nPsi <- length(pPsi)
nSamplesPerSite <- 40

## Probability of DNA occuring with a sample 
pTheta = c(0.5)
nTheta <- length(pTheta)
nReplicatesPerSample <- 2

## Detection probabiltiy (varies by site)
pDetection <- c(0.50)
nP <- length(pDetection)

siteTable <- data.table(
    siteIndex = rep(1:nPsi, each = nSamplesPerSite),
    pPsi = rep(pPsi, each = nSamplesPerSite),
    siteSample = rep(1:nSamplesPerSite, times = nPsi)
)


siteTable[ , Z := rbinom(n = nrow(siteTable), 1, prob = siteTable[ , pPsi])]
print(siteTable, 6)
siteTable[ , sum(Z)/nSamplesPerSite, by = list(siteIndex)]
    
## Probability of detecion (varies across site)
sampleTable <- data.table(
    siteIndex = rep( 1:nPsi, each = nTheta),
    pTheta = rep( pTheta, each = nTheta),
    pDetection = rep( pDetection, each = nP)
)

print(sampleTable)
sampleTable[ , thetaID := as.numeric(as.factor(pTheta))]

setkey( siteTable, "siteIndex")
setkey( sampleTable, "siteIndex")

siteSampleTable <- copy(siteTable[sampleTable, allow.cartesian = TRUE])
print(siteSampleTable, 30)

## Simulate A
siteSampleTable[ , A := rbinom(n = nrow(siteSampleTable), 1,
                               prob =  Z * pTheta)]

## Simulate Y
siteSampleTable[ , Y := rbinom(n = nrow(siteSampleTable), nReplicatesPerSample,
                               prob =  Z * A * pDetection)]
siteSampleTable[ , Aobs := 0]
siteSampleTable[ Y > 0, Aobs := 1]


siteSampleTable[ , Zobs := 0]
siteSampleTable[ Y > 0, Zobs := 1]

siteSampleTable[ Z > 0,] 
siteSampleTable[ A > 0,] 

siteSampleTable[ Aobs != A, ]


## calcuate Aobs and Zobs basd upon the data 
siteSampleTable[ , siteSample := paste(siteIndex, siteSample, sep = "_")]
siteSampleTable[ , sum(Y), by = list(siteIndex, siteSample)]

siteSampleTable[ , siteSampleID := as.numeric(factor(siteSample))]

siteSampleTable[ , pID := as.numeric(factor(pPsi))]


siteSampleTable[ Aobs!= A, ]

## Format data for Stan
stanData <- list(
    ## Total number of observations 
    nObs = nrow(siteSampleTable), 
    ## Number of unique sample probs (currently assume 1 per site
    nTheta = nTheta,
    ## Number of sites         
    nPsi = nPsi,
    ## Number of sites         
    nPdetect = nP,
    ## Sum of positive detects per site sample combination 
    Y = siteSampleTable[ , Y],
    ## Was DNA detected at a Site?
    Z = siteSampleTable[ , Zobs],
    ## Was detected withing a sample?
    A = siteSampleTable[ , Aobs],
    ## Dummy variable for theta
    thetaID = siteSampleTable[ , thetaID],
    ## Dummy variable for psiID
    psiID = siteSampleTable[ , siteIndex],
    ## Dummy variable for pID
    pID = siteSampleTable[ , pID],
    ## Number of molecular replicates 
    K = nReplicatesPerSample
)

system.time(
    stanOut1 <- stan(file = 'modelWorksPdetect.Stan', data = stanData, chains = 3, iter = 8000)
)


## examine recovered values 
sampleTable
pTheta
pPsi
pDetection

pairs(stanOut1, pars = c("muPpsi", "muPtheta", "muPdetect"))
x11()
plot(stanOut1, pars = c("pPsi", "pTheta", "pDetect"))
x11()
traceplot(stanOut1, pars = c("pPsi", "pTheta", "pDetect", "lp__"))


