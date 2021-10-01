# PDscreen
package to import data from Proteome Discoverer, screen and identify proteins of interest

1 October 2021 package initialised

A good reference for github and R:
https://happygitwithr.com/new-github-first.html 

A good reference for writing R packages:
https://r-pkgs.org/


# Project Goals:

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

# Silly Test Check
