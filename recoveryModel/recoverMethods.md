# Simulation and recovery scenarios

This file provides an overview of the numerical methods used to simulate and recover datasets using a multi-level occurrence model. 
We specifically describe our numerical workflow. 
The [README file](../README.md) provides descriptions of the files within this folder.
Within this file, we provide more details about how each file works. 
We end with a high-level overview of our methods in the last section.

## Generating parameter combinations

The file `generateParameters.R` takes input parameter values and expands them to a table of all possible parameter combinations.
The file writes the results to a file `paramaterValue.csv`.

## Demonstrating the code

The file `demonstrateModel.R` shows how to use our model on a single dataset, outside of a high-throughput workflow. 

## Simulating datasets

The file `simulateData.R` is run from the command line using an index number as an input argument  (e.g., `Rscript simulateData.R 1`).
The input argument begin as zero and the upper argument should be the last row number less one of the `parameterValues.csv` file (the reason for this is that HTCondor starts counting a 0, whereas R starts counting at 1).
The file then loops through each simulation and generates a dataset.
The simulated dataset is then written to a CSV file, `simulatedData.csv` (HTCondor adds its index to the end of the file).

## Recovering parameters

We build our recover model using the `Stan` syntax in a `.stan` file: `modelWorksPdetect.stan`.
This file is called through a `R` script: `recoverData.R`, which also formats the simulated datasets to used by `Stan`.
The summary of the recovered parameters is saved as `stanSummary.csv`. 
Like the simulated datasets output files, HTConodor add an index number to the end of the file.

## Summarizing results

The file `summarizeResults.R` gathers up the recovered parameters files, merges them, and plots the results.

## High-throughput workflow

We used HTCondor for our high-throughput workflow.
The `my.dag` is a `DAGman` file that manages two HTCondor submit files: `genSubmit.sub` and `recSubmit.sub`.
The first file runs the code that generates simulated datasets.
The second file runs the code that recovers parameter estimates from the simulated datasets. 













