library(data.table)
library(foreach)
library(doMC)
library(parallel)

registerDoMC(40)


## Generate all possible parameter combinations
K_in        <- c( 2, 4, 8, 16)
theta_in    <- c( 0.06, 0.24, 0.42, 0.75)
p_in        <- c( 0.15, 0.3, 0.35, 0.4, 0.75)
psi_in      <- c( 0.06, 0.24, 0.42, 0.75)
nSamples_in <- c( 5, 10, 20, 30, 60, 90, 120)


parameterValue <- data.table(expand.grid(
    K = K_in,
    theta = theta_in,
    p = p_in,
    psi = psi_in,
    nSamples = nSamples_in))

parameterValue[ , Index :=  1:dim(parameterValue)[1]]

fileFolder = "./simulatedDataSets/"

write.csv(x = parameterValue, file = paste0("parmaterValue.csv"), row.names = FALSE)

## Simulate datasets

## Number of datasets to simulate
nSims <- 2000

## Loop through parameter values 
##for(Idx in parameterValue[ , Index]){
foreach(Idx = 1:parameterValue[ , max(Index)]) %dopar% {
    psi      = parameterValue[ Index == Idx, psi]
    theta    = parameterValue[ Index == Idx, theta]
    p        = parameterValue[ Index == Idx, p]
    K        = parameterValue[ Index == Idx, K]
    nSamples = parameterValue[ Index == Idx, nSamples]
    
    ## Loop through and simulate datasets
    simulateData <- data.table(sampleIndex = 1:nSamples)

    for(sim in 1:nSims){
        simName <- paste0("sim", sim)
        Zsim <- rbinom( n = nSamples, size = 1, prob = psi)
        Asim <- rbinom( n = nSamples, size = 1, prob = Zsim * theta)
        Ysim <- rbinom( n = nSamples, size = K, prob = Asim * p)
        simulateData[ , eval(simName) := Ysim]
    }
    
    ##    print(Idx)
    ## -1 is needed to convert output to HTCondor's 0-based indexing 
    write.csv(x = simulateData, file = paste0(fileFolder, "simulatedData",
                                              Idx - 1, ".csv"),
              row.names = FALSE)
    }


    



