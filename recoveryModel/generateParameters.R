library(data.table)

## Generate all possible parameter combinations and place into table and then save
K_in        <- c( 2, 3, 4, 8, 16)
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


fileFolder = "./"

write.csv(x = parameterValue, file = paste0("parmaterValue.csv"), row.names = FALSE)


