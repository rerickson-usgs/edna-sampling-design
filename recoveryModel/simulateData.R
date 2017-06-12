library(data.table)
library(foreach)
library(doMC)
library(parallel)

## Register number of cores for parallel compututing (i.e., HPC)
registerDoMC(40)

## Generate all possible parameter combinations and place into table and then save
K_in        <- c( 2, 4, 8, 16)
theta_in    <- c( 0.06, 0.24, 0.42, 0.76)
p_in        <- c( 0.15, 0.3, 0.35, 0.4, 0.75)
psi_in      <- 1
nSamples_in <- c( 5, 10, 20, 30, 50, 75, 100, 125)


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
nDataSetsToSimulate = parameterValue[ , max(Index)]
foreach(Idx = 1:nDataSetsToSimulate, .errorhandling="pass") %dopar% {

    ## Grab parameter values from table 
    psi      = parameterValue[ Index == Idx, psi]
    theta    = parameterValue[ Index == Idx, theta]
    p        = parameterValue[ Index == Idx, p]
    K        = parameterValue[ Index == Idx, K]
    nSamples = parameterValue[ Index == Idx, nSamples]

    ## Loop through and simulate datasets

    ## Create Index in data table 
    simulateData <- data.table(
        parameterIndex = rep(Idx, nSamples),
        Zindex = rep(1, nSamples),
        Aindex = rep(1:nSamples),
        Yindex = 1:(nSamples)
        )

    ## Loop through each simulation 
    for(sim in 1:nSims){
        ## Create observed parameter values names 
        ZobsName <- paste0("Z_", sim)
        AobsName <- paste0("A_", sim)
        YobsName <- paste0("Y_", sim)

        ## Simulated "known" Zs and As to generate observed Ys
        Zsim <- rep(psi, nSamples)
        Asim <- rbinom( n = nSamples, size = 1, prob = theta) * Zsim
        Yobs <- rbinom( n = nSamples, size = K, prob = p) * Asim

        simulateData[ , eval(YobsName) := Yobs]

        ## "observed As based upon Ys
        for(Aidx in 1:nSamples){
            if(sum(Yobs[simulateData[ , Aindex == Aidx]]) > 0){
                simulateData[ Aindex == Aidx, eval(AobsName) := 1]
            } else {
                simulateData[ Aindex == Aidx, eval(AobsName) := 0]
            }
        }
        ## Observed Z based upon As
        ## Note this code would need to be changed if there were multiple sites present 
        if(sum(Asim) > 0){
            simulateData[ , eval(ZobsName) := 1]
        } else {
            simulateData[ , eval(ZobsName) := 0]
        }
    }
    
    
    ##    print(Idx)
    ## -1 is needed to convert output to HTCondor's 0-based indexing 
    write.csv(x = simulateData, file = paste0(fileFolder, "simulatedData",
                                              Idx - 1, ".csv"),
              row.names = FALSE)
}



    



