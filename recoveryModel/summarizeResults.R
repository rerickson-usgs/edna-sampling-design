library(data.table)
library(ggplot2)

## Get file names
filePath <- "./dataOut"
allFiles <- list.files(filePath)
saveFiles <- paste0(filePath, "/", allFiles[grep("stanSummary", allFiles)])
saveFiles

## merge files together
l <- lapply( saveFiles, fread, sep=",")
allData <- rbindlist( l )

dim(allData)

## Create histogram of all SEs here

ggplot(allData, aes(x = pRecoveredSE)) + geom_histogram() +
    theme_minimal() + ylab("Count") + xlab("Recovered se for p")
    

ggplot(allData, aes(x = pRecoveredSE)) + geom_histogram() 


## Readin, create factors, and merge in parameter Values

params <- fread("parmaterValue.csv")

params[ , K2 := factor(paste( "K = ", K))]
params[ , theta2 := factor(paste("theta =", theta))]
params[ , p2 := factor(paste("p =", p))]
params[ , psi2 := factor(paste("psi =", psi))]


setkey(params, "Index")
setkey(allData, "ParameterIndex")

allData <- allData[params]

colnames(allData)

head(allData)

## Frist, summarize NA datasets
dND <- allData[ , list(nondetect = length(which(is.na(pRecovered))),
                       detect = length(which(!is.na(pRecovered))),
                       pMed = median(  pRecovered, na.rm = TRUE),
                       pL80 = quantile(pRecovered, 0.10, na.rm = TRUE),
                       pU80 = quantile(pRecovered, 0.90, na.rm = TRUE),
                       thetaMed = median(  thetaRecovered, na.rm = TRUE),
                       thetaL80 = quantile(thetaRecovered, 0.10, na.rm = TRUE),
                       thetaU80 = quantile(thetaRecovered, 0.90, na.rm = TRUE),
                       psiMed = median(  psiRecovered, na.rm = TRUE),
                       psiL80 = quantile(psiRecovered, 0.10, na.rm = TRUE),
                       psiU80 = quantile(psiRecovered, 0.90, na.rm = TRUE)
                       ),
               by =  list(ParameterIndex, K, theta, p, psi, nSamples, K2, p2, psi2, theta2)]

head(dND)
dND[ , detectPer := detect/(nondetect + detect)]

dND[ , K2 := factor(K2, levels = levels(K2)[order(as.numeric(gsub("K =  ", "", levels(K2))))])]

dND[ , nSamples2 := factor(nSamples, levels = unique(nSamples))]
levels(dND$nSamples2) <- paste("n =", levels(dND$nSamples2))

head(dND)
ggplot(dND, aes(x = theta, y = thetaMed,
                color = K2)) + geom_point() + stat_smooth(method = 'lm') +
    facet_grid( p2  ~ K2)

thetaMod <- lm(thetaMed ~ theta*K2*p2 - 1, data = dND)
summary(thetaMod)
par(mfcol = c(2,2))
plot(thetaMod)

ggDetect <- ggplot(data = dND, aes(color = K2,
                                   shape = K2,
                                   y = detectPer,
                                   x = factor(nSamples),  group = p2)) +
    geom_point(position = position_dodge(width = 0.80)) +
    facet_grid( p2 ~  theta2 ) +
    scale_color_manual("Molecular\nreplicates",
                       values = c("red", "blue", "black", "seagreen", "orange")) +
    scale_shape_manual("Molecular\nreplicates", values = 15:19) +
    theme_minimal() +
    ylab(expression(over("Number of simulations with >1 detection",
                         "Total number of simulations (n =  2000)"))) +
    xlab("Number of samples per site (J)")

print(ggDetect)
ggsave(filename = "ggDetect.pdf", ggDetect, width = 11, height = 6)

ggTheta <- ggplot(data = dND, aes(color = K2,
                                  shape = K2,
                                  x = factor(nSamples),
                                  y = thetaMed, 
                                  ymin = thetaL80,
                                  ymax = thetaU80,
                                  group = K2)) +
    geom_hline(aes(yintercept = theta)) +
    geom_linerange(position = position_dodge(width = 0.80)) +
    geom_point(position = position_dodge(width = 0.80)) +
    facet_grid( theta2 ~ p2) +
    scale_color_manual("Molecular\nreplicates",
                       values = c("red", "blue", "black", "seagreen", "orange")) +
    scale_shape_manual("Molecular\nreplicates",
                       values = 15:19) + 
    theme_minimal() +
    ylab("Recovered theta from samples with any detection") +
    xlab("Number of samples per site (J)")
print(ggTheta)


ggsave(filename = "ggTheta.pdf", ggTheta, width = 11, height = 6)

dND[ theta <= 0.05, ][ p > .8 | p < 0.1, ][ nSamples < 10, .(K, p, nSamples, psiL80, psiMed, psiU80)]


ggPsi <- ggplot(data = dND, aes(color = K2,
                                shape = K2,
                                x= factor(nSamples),
                                y = psiMed, 
                                ymin = psiL80,
                                ymax = psiU80,
                                group = K2)) +
    geom_hline(aes(yintercept = psi)) +
    geom_linerange(position = position_dodge(width = 0.80)) +
    geom_point(position = position_dodge(width = 0.80)) +
    facet_grid( theta2 ~ p2) +
    scale_color_manual("Molecular\nreplications",
                       values = c("red", "blue", "black", "seagreen", "orange")) +
    scale_shape_manual("Molecular\ndetection", values = 15:19) +
    theme_minimal() +
    ylab("Recovered psi from samples with any detection") +
    xlab("Number of samples per site (J)") +
    coord_cartesian(ylim = c(0,1))

print(ggPsi)


ggsave(filename = "ggPsi.pdf", ggPsi, width = 11, height = 6)


ggP <- ggplot(data = dND, aes(color = K2,
                              shape = K2,
                              x = factor(nSamples),
                              y = pMed, 
                              ymin = pL80,
                              ymax = pU80,
                              group = K2)) +
    geom_hline(aes(yintercept = p)) +
    geom_linerange(position = position_dodge(width = 0.80)) +
    geom_point(position = position_dodge(width = 0.80)) +
    facet_grid( p2 ~ theta2) +
    scale_color_manual("Molecular\nreplicates",
                       values = c("red", "blue", "black", "seagreen", "orange")) +
    scale_shape_manual("Molecular\nreplicates", values = 15:19) +
    theme_minimal() +
    ylab("Recovered p from samples with any detection") +
    xlab("Number of samples per site (J)")

print(ggP)
ggsave(filename = "ggP.pdf", ggP, width = 11, height = 6)

summary(dND)
dSubSetND <- dND[ p <= 0.40 & p > 0.05, ][
    nSamples == 10 | nSamples == 20 | nSamples == 40 , ][
    theta <= 0.40, ]

colnames(dSubSetND)

dSubSetND2med <- melt(dSubSetND,
                   measure.vars = c("pMed", 
                                    "thetaMed",
                                    "psiMed"),
                   id.vars = c("K", "p", "theta", "nSamples", "psi",
                               "K2", "p2", "theta2", "nSamples2", "psi2"),
                   variable.name = "parameter",
                   value.name = "median"
                   )

dSubSetND2l80 <- melt(dSubSetND,
                   measure.vars = c("pL80", 
                                    "thetaL80",
                                    "psiL80"),
                   id.vars = c("K", "p", "theta", "nSamples",
                               "K2", "p2", "theta2", "nSamples2"),
                   variable.name = "parameter",
                   value.name = "l80"
                   )

dSubSetND2u80 <- melt(dSubSetND,
                   measure.vars = c("pU80", 
                                    "thetaU80",
                                    "psiU80"),
                   id.vars = c("K", "p", "theta", "nSamples",
                               "K2", "p2", "theta2", "nSamples2"),
                   variable.name = "parameter",
                   value.name = "u80"
                   )




dSubSetND2med[ , l80 := dSubSetND2l80[ , l80]]
dSubSetND2med[ , u80 := dSubSetND2u80[ , u80]]

head(dSubSetND2med)

levels(dSubSetND2med$parameter) <- c("Probability\nof detection (p)",
                                     "Sample occurance\nprobability (theta)",
                                     "Site occurance\nprobability (psi)")

## Extract out data for vertical lines 

params[ , unique(nSamples)]
paramsSubset <- params[ p <= 0.40 & p > 0.05, ][
    nSamples == 10 | nSamples == 20 | nSamples == 40 , ][
    theta <= 0.40, ][ K2 == "K =  16", .(theta, p, psi, theta2, p2, psi2)]


paramsSubset

parSubMelt <- melt( paramsSubset,
                   measure.vars = c('p', 'theta', 'psi'),
                   id.vars = c('p2', 'theta2', 'psi2'),
     variable.name = "parameter",
     value.name = "yInt"
     )

levels(parSubMelt$parameter) <- c("Probability\nof detection (p)",
                                     "Sample occurance\nprobability (theta)",
                                     "Site occurance\nprobability (psi)")





ggPlotSubSet <- ggplot(data = dSubSetND2med, aes(x = factor(nSamples),
                                                 y = median,
                                                 ymin = l80,
                                                 ymax = u80,
                                                 color = K2,
                                                 shape = K2,
                                                 group = K2)) +
    geom_linerange(position = position_dodge(width = 0.80)) +
    geom_point(position = position_dodge(width = 0.80)) +
    facet_grid( parameter ~ p2 + theta2, scale = "free_y") +
    scale_color_manual("Molecular\nreplicates",
                       values = c("red", "blue", "black" , "seagreen", "orange")) +
    scale_shape_manual("Molecular\nreplicates", values = 15:19) +
    theme_minimal() +
    ylab("Recovered parameter value") +
    xlab("Number of samples per site (J)") +
    geom_hline(data = parSubMelt, aes(yintercept = yInt)) +
    coord_cartesian(ylim = c(0,1))

print(ggPlotSubSet)

ggsave(filename = "resultsSubSet.pdf",
       plot = ggPlotSubSet,
       width = 10, height = 6)

ggsave(filename = "resultsSubSet.jpg",
       plot = ggPlotSubSet,
       width = 10, height = 6)



