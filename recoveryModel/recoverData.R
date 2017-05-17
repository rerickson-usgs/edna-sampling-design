library(rstan)

## will need to capture input index from HTCondor
## Also, add + 1 
condorIndex = 2240

inputDataFolder = "./simulatedDataSets/"
outputDataFolder = "./recoveredData/"

parameterValue <- read.csv("parmaterValue.csv")

K <- parameterValue$K[ parameterValue$Index == condorIndex]
d <- read.csv(paste0( inputDataFolder, "simulatedData", condorIndex, ".csv"))
nSims = dim(d)[2] - 1

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
    Y = d[, simIndex + 1]
    nObs = length(Y)
    A = as.numeric(Y >0)
    Z = as.numeric(Y >0)
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
        stanOut <- stan(file = 'modelWorksPdetect.Stan', data = stanData, chains = 3, iter = 8000)
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

write.csv(x = stanSummary, file = paste0(outputDataFolder, "stanSummary_", condorIndex, ".csv"), row.names = FALSE)
