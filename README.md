# eDNA study simulation

Richard A. Erickson, Christopher M. Merkes, and Erica L. Mize

This code supports USGS project IP-XXXXXX. Specifically, we used this code to examine different sampling methods for eDNA-based studies as well as the ability of a three-level occupancy model to recover parameters. Our code can be used to conduct power analysis of eDNA-based studies or analyzed eDNA-based models with a three-level occupancy model. (Both of these uses would require some adaption by the use and require the user understand the statistical assumptions of occupancy models, experimental design, the [R](https://www.r-project.org/) and [Stan](http://mc-stan.org/) languages, and eDNA-based studies).


The `sampleSize` folder contains script files to examine necessary sample sizes to detect DNA assuming the speices is present at a site (i.e., phi = 1). This code can be adapted to conduct a power analysis assuming a species is present at a site. The specific files included here are:

- File 1
- File 2
- ...

The `recoverModel` file contains script to simulate different eDNA-based sampling designs and then recover the data using a three-level occupancy model. The code has been developed to use HTCondor. We have previously developed tutorials for [HTCondor](https://my.usgs.gov/bitbucket/projects/CDI/repos/hunting_invasive_species_with_htcondor/browse). The specific files included here are:

- File 1
- File 2
- ...

Primary code developer:  Richard A. Erickson (rerickson@usgs.gov)
