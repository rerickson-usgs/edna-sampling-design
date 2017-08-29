library(data.table)

## Simulate datasets

## + 1 needed because condor lives in 0 index work but R lives in 
condorIndex <- as.numeric(commandArgs(trailingOnly = TRUE)) + 1

## Read in parameter values data
parameterValue <- fread("./parmaterValue.csv")

## Number of datasets to simulate
nSims <- 2000

## Grab parameter values from table 
psi      = parameterValue[ Index == condorIndex, psi]
theta    = parameterValue[ Index == condorIndex, theta]
p        = parameterValue[ Index == condorIndex, p]
K        = parameterValue[ Index == condorIndex, K]
nSamples = parameterValue[ Index == condorIndex, nSamples]

## Loop through and simulate datasets

## Create Index in data table 
simulateData <- data.table(
    parameterIndex = rep(condorIndex, nSamples),
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
    Asim <- rbinom( n = nSamples, size = 1, prob = theta * Zsim) 
    Yobs <- rbinom( n = nSamples, size = K, prob = p  * Asim)
    
    simulateData[ , eval(YobsName) := Yobs]

    simulateData[ , eval(AobsName) := 0]
    simulateData[ eval(as.symbol(YobsName)) > 0, eval(AobsName) := 1]

    simulateData[ , eval(ZobsName) := 0]
    if(simulateData[ , sum(eval(as.symbol(AobsName))) > 0]){
        simulateData[ , eval(ZobsName) := 1]
    }
}

print(paste("done simulating data", condorIndex))
## -1 is needed to convert output to HTCondor's 0-based indexing 
write.csv(x = simulateData, file = "simulatedData.csv", row.names = FALSE)
