library(rstan)
library(data.table)
## + 1 needed because condor lives in 0 index work but R lives in 
condorIndex <- as.numeric(commandArgs(trailingOnly = TRUE)) + 1


parameterValue <- read.csv("parmaterValue.csv")

K <- parameterValue$K[ parameterValue$Index == condorIndex]


inFilename <- paste0( "simulatedData", condorIndex -1, ".csv")
d <- fread(inFilename)
nSims = dim(d)[2] - 4

## create CSV to save outputs

stanSummary <- data.frame(ParameterIndex = rep(condorIndex, nSims),
                          pRecovered = NA,
                          thetaRecovered = NA,
                          psiRecovered = NA,
                          pRecoveredSE = NA,
                          thetaRecoveredSE = NA,
                          psiRecoveredSE = NA,
                          pRecoveredLower = NA,
                          thetaRecoveredLower = NA,
                          psiRecoveredLower = NA,
                          pRecoveredUpper = NA,
                          thetaRecoveredUpper = NA,
                          psiRecoveredUpper = NA
                          )

## Setup Stan input and then look at recovery of data

for(simIndex in 1:nSims){

    ZobsName <- paste0("Z_", simIndex + 1)
    AobsName <- paste0("A_", simIndex + 1)
    YobsName <- paste0("Y_", simIndex + 1)

    Z = d[, eval( as.sybmol( ZobsName))]
    A = d[, eval( as.sybmol( AobsName))]
    Y = d[, eval( as.sybmol( YobsName))]
    nObs = length(Y)
    
    ## Just leaving non-detects as NA, will need to be post-processed 
    if(sum(Y) != 0){
        stanData <- list(
            nObs = nObs,
            Y = Y,
            A = A,
            Z = Z,
            nObs = nObs,
            nTheta = 1,
            nPsi = 1,
            nPdetect = 1,
            psiID = rep(1 , nObs),
            thetaID = rep(1 , nObs),
            pID = rep(1 , nObs),
            K = K
        )
        stanOut <- stan(file = 'modelWorksPdetect.stan', data = stanData, chains = 3, iter = 8000)
        sumOut <- summary(stanOut)
        stanSummary$psiRecovered[ simIndex] <- sumOut$summary[ grep("pPsi", rownames(sumOut$summary)), "mean"]
        stanSummary$pRecovered[ simIndex] <- sumOut$summary[ grep("pDetect", rownames(sumOut$summary)), "mean"]
        stanSummary$thetaRecovered[ simIndex] <- sumOut$summary[ grep("pTheta", rownames(sumOut$summary)), "mean"]
        stanSummary$psiRecoveredSE[ simIndex] <- sumOut$summary[ grep("pPsi", rownames(sumOut$summary)), "se_mean"]
        stanSummary$pRecoveredSE[ simIndex] <- sumOut$summary[ grep("pDetect", rownames(sumOut$summary)), "se_mean"]
        stanSummary$thetaRecoveredSE[ simIndex] <- sumOut$summary[ grep("pTheta", rownames(sumOut$summary)), "se_mean"]
        stanSummary$psiRecoveredLower[ simIndex] <- sumOut$summary[ grep("pPsi", rownames(sumOut$summary)), "2.5%"]
        stanSummary$pRecoveredLower[ simIndex] <- sumOut$summary[ grep("pDetect", rownames(sumOut$summary)), "2.5%"]
        stanSummary$thetaRecoveredLower[ simIndex] <- sumOut$summary[ grep("pTheta", rownames(sumOut$summary)), "2.5%"]
        stanSummary$psiRecoveredUpper[ simIndex] <- sumOut$summary[ grep("pPsi", rownames(sumOut$summary)), "97.5%"]
        stanSummary$pRecoveredUpper[ simIndex] <- sumOut$summary[ grep("pDetect", rownames(sumOut$summary)), "97.5%"]
        stanSummary$thetaRecoveredUpper[ simIndex] <- sumOut$summary[ grep("pTheta", rownames(sumOut$summary)), "97.5%"]        
    }
}

write.csv(x = stanSummary, file = "stanSummary.csv", row.names = FALSE)
