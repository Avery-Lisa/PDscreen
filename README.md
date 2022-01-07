# PDscreen

# Next Steps

7 Jan 2022: 
Look at the difference between reliability if proteins with Area=0 are treated as 0 vs if they are treated as missing (NA)

Look for candidate biomarkers with the following tests:
- t-tests
- Wilcoxon test
- logistic regression
- test of proportion for ANY protein

Control for multiple testing

Which proteins discriminate between groups? Which test(s) are most appropriate?

Programming tasks:

- main.R, encapsulate code as a function for protein screening
- Document the function (using Roxygen https://r-pkgs.org/man.html )


8 October improved the import function

1 October 2021 package initialised

# References

A good reference for github and R:
https://happygitwithr.com/new-github-first.html 

A good reference for writing R packages:
https://r-pkgs.org/


# Project Goals:
A package to import data from Proteome Discoverer, screen and identify proteins of interest

Step 1. Import & wrangle the data 

- import the excel data 
- extract protein intensity data (all fields starting with Area)
- identify the protein name from the ascension number
- identify the technical replicates
- recode missing values to zero
- match with the clinical data, identify the technical replicates and recode any missing values to 0
- document all manipulations to a log file. 

# Package Development Goals:

- write a function, with documentation to import the sampleInformation.csv data. This is just practice function writing so take as an argument the filename and output the number of unique IDS.


