# Code to simulate eDNA study simulation

Richard A. Erickson, Christopher M. Merkes, and Erica L. Mize

This code supports the manuscript "Sampling designs for landscape-level eDNA monitoring programs using three-level occurrence models. Specifically, we used this code to examine different sampling methods for eDNA-based studies as well as the ability of a three-level occupancy model to recover parameters. Our code can be used to conduct power analysis of eDNA-based studies or analyzed eDNA-based models with a three-level occupancy model. (Both of these uses would require some adaption by the user and require the user understand the statistical assumptions of occupancy models, experimental design, the [R](https://www.r-project.org/) and [Stan](http://mc-stan.org/) languages, and eDNA-based studies).


The `sampleSize` folder contains script files to examine necessary sample sizes to detect DNA assuming the speices is present at a site (i.e., phi = 1). This code can be adapted to conduct a power analysis assuming a species is present at a site. The specific files included here are:

- An RMarkdown Files and the resulting PDF:
  - `sampleSize.Rmd`
  - `sampleSize.PDF`
- Figures used in the corresponding manuscript that are outputs from markdown file and are used within the manuscript. These figures are described in both the `sampleSize` files and the corresponding article:
  - `compareSites` in both PDF and JPG format 
  - `detectingOne` in both PDF and JPG format

A user would most likely want to either read the `sampleSize.PDF` or adapt the `sampleSize.Rmd` code for their own use.


The `recoverModel` file contains script to simulate different eDNA-based sampling designs and then recover the data using a three-level occupancy model. The code has been developed to use HTCondor. We have previously developed tutorials for [HTCondor](https://my.usgs.gov/bitbucket/projects/CDI/repos/hunting_invasive_species_with_htcondor/browse). The specific files and folders included here are:

- `simulatedDataSets` a folder where the simulate datasets are placed. One token dataset is placed in the folder so that `git` will track the folder when cloned to a new location. 
- 
- ...

Primary code developer:  Richard A. Erickson (rerickson@usgs.gov)


## Disclaimer

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](https://www2.usgs.gov/visual-id/credit_usgs.html#copyright/).


"This software has been approved for release by the U.S. Geological Survey (USGS). Although the software has been subjected to rigorous review, the USGS reserves the right to update the software as needed pursuant to further analysis and review. No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. Furthermore, the software is released on condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from its authorized or unauthorized use."

This software is provided "AS IS".
