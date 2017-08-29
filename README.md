# Code to simulate eDNA study simulation

Richard A. Erickson, Christopher M. Merkes, and Erica L. Mize

This code supports the manuscript "Sampling designs for landscape-level eDNA monitoring programs using three-level occurrence models. 
Specifically, we used this code to examine different sampling methods for eDNA-based studies as well as the ability of a three-level occupancy model to recover parameters. Our code can be used to conduct power analysis of eDNA-based studies or analyzed eDNA-based models with a three-level occupancy model. 
(Both of these uses would require some adaption by the user and require the user understand the statistical assumptions of occupancy models, experimental design, the [R](https://www.r-project.org/) and [Stan](http://mc-stan.org/) languages, and eDNA-based studies).



There are two folders within this repository and each corresponds to a different part of the manuscript.
The `sampleSize` folder corresponds to the power analysis done in the manuscript.
The `recoverModel` folder corresponds to using the model to recover datasets as well as the code necessary to simulate the data.
The simulated datasets used for the manuscript are housed as a ScienceBase Product (DOI here).


## Power analysis

The `sampleSize` folder contains script files to examine necessary sample sizes to detect DNA assuming the speices is present at a site (i.e., phi = 1). This code can be adapted to conduct a power analysis assuming a species is present at a site. The specific files included here are:

- An RMarkdown Files and the resulting PDF:
  - `sampleSize.Rmd`
  - `sampleSize.PDF`
- Figures used in the corresponding manuscript that are outputs from markdown file and are used within the manuscript. These figures are described in both the `sampleSize` files and the corresponding article:
  - `compareSites` in both PDF and JPG format 
  - `detectingOne` in both PDF and JPG format

A user would most likely want to either read the `sampleSize.PDF` or adapt the `sampleSize.Rmd` code for their own use.


## Statistical recovery model

The `recoverModel` file contains script to simulate different eDNA-based sampling designs and then recover the data using a three-level occupancy model. The code has been developed to use HTCondor. We have previously developed tutorials for [HTCondor](https://my.usgs.gov/bitbucket/projects/CDI/repos/hunting_invasive_species_with_htcondor/browse). The specific files and folders included here are:

- `simulatedDataSets` a folder where the simulate datasets are placed. One token dataset is placed in the folder so that `git` will track the folder when cloned to a new location.
- `demonstrateModel.R` is a file that demonstrates how the Stan models works. The file was used to test and devlepe the Stan model, although users may find it helpful if they want to use our model to recreate their work. 
- The following files are used by HTCondor for the data simulation and recovery 
  - `generateParameters.R` is a file that creates `parmaterValue.CSV`, which contains all possible parameter values.
  - `Dockerfile` contains code to build the Docker image used for the project. 
  - `eDNArecover.sh` is a shell file that runs the R file to recover simulated data. 
  - `eDNAsimulate.sh` is a shell file that runs the R file to simulate data. 
  - `genSubmit.sub` is an HTCondor file that runs the code while it simulates data.
  - `modelWorksPdetect.stan` is the working Stan model used for the project.
  - `my.dag` runs the two submit files for the project.
  - `recoverData.R` is the R code used to call the Stan model with RStan.
  - `recSubmit.sub` is an HTCondor file that runs the code to recover parameters using the Stan model.
  - `simulateData.R` simulates the datasets recovered by the model. 

A user of the model would most likely want to examine the `demonstrateModel.R` file and use it with the Stan model if they want to analyze their own data.
A user who wants to recreate our workflow would most likely want to start reading `my.dag` and follow our workflow from that file. 

## Contact for code 

Primary code developer:  Richard A. Erickson (rerickson@usgs.gov)


## Disclaimer

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](https://www2.usgs.gov/visual-id/credit_usgs.html#copyright/).


"This software has been approved for release by the U.S. Geological Survey (USGS). Although the software has been subjected to rigorous review, the USGS reserves the right to update the software as needed pursuant to further analysis and review. No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. Furthermore, the software is released on condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from its authorized or unauthorized use."

This software is provided "AS IS".
