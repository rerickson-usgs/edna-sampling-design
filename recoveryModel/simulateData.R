library(data.table)

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

write.csv(x = parameterValue, file = "parmaterValue.csv", row.names = FALSE)

## Simulate datasets
fileFolder <- "./simulatedDataSets/"


## Number of datasets to simulate
nSims <- 10

## Loop through parameter values 
for(Idx in parameterValue[ , Index]){
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
    
    print(Idx)
    write.csv(x = simulateData, file = paste0(fileFolder, "simulatedData",
                                              Idx, ".csv"),
              row.names = FALSE)
    }


    



