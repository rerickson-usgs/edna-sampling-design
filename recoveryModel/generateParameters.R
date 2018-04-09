library(data.table)

## Generate all possible parameter combinations and place into table and then save
K_in          <- c( 2, 4, 8, 16)

theta_in      <- c(1.0,  0.8, 0.4, 0.2, 0.1, 0.05)
p_in          <- c(1.0, 0.8, 0.8, 0.4, 0.2, 0.1, 0.05)
psi_in        <- 1.0
nSamples_in   <- c(  5,  10, 20, 40, 80, 120)

parameterValue <- data.table(expand.grid(
    K = K_in,
    theta = theta_in,
    p = p_in,
    psi = psi_in,
    nSamples = nSamples_in))
parameterValue[ , Index :=  1:dim(parameterValue)[1]]

dim(parameterValue)

fileFolder = "./"

write.csv(x = parameterValue,
          file = paste0("parmaterValue.csv"),
          row.names = FALSE)


