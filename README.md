# PDscreen
# What's done from Jan 7 to Feb 28 (Jiayue)
 For area = 0:
 1. Check treated as 0 left 315 Proteins
 2. Check treated as missing value  left 317 Proteins

 Before applying T-test:
 There are proteins that only have one group, this make t-test failed.
 Identify proteins who have two groups and perform statistical test only on those proteins.
 
 For applying T-test:  non-transform data vs log-transform data
 1. non-transform data:
 (i) t-test for example protein IGKC and its plot
 (ii) Perform t-test for the whole proteins and extract their P-value
 (iii) Use p.adjusted function with flase discovery rate and filter the protein who has adjusted p-value < 0.05, discard the high p-value proteins.
 (iv) 170 Proteins are statisticallt significant
 
 2. log-transform data:
 zero intensity peoteins:
 (i)first time try with log transform and perform t-test, find that around 14.3% zero intensity exist. 
 (ii)the most count for protein who have zero intensity is 20 (20/21=95% zero) and the least count for protein who have zero intensity is 1 (1/21=4.7% zero)
 (iii)decide to make a plot and barplot for protein who has the middle count 10, I pick IGKC
 (iv) Check the distribution for both group (IGKC)
 
 t-test:
 (i) since not a large amount of zero intensity through all the obervations, decide to add a small number 0.001 to our data
 (ii) do log transformation on our new value data and then can perform t-test
 (iii) same as non-transform data, we left 129 proteins that are statistically significant
 
 3. Comparision for non-transform and log-transformation:
 (i) Looking for the Protein who is significant in non-transform data but is not significant in log-transform data
 (ii) Looking for the Protein who is not significant in non-transform data but is significant in log-transform data
 (iii) plot for whole data with and without log-transformation
 (iv) Pick one protein from (i) and plot with and without log-transformation
 (v) Pick one protein from (ii) and plot with and without log-transformation
 
 Conclusion: need log-transformation, before transformation, the data is right skewed and after log-transformation, the distribution of our data seems to have normal distribution with few outliers. (to do : )
 
 
 
# Next Steps

28 Jan
To write up a description for (with some individual protein plots):
  - the effect of applying a log transform to the values
  - looking at reliability with and without log transform
  - looking at between group differences with and without log transform

21 Jan 2022
  -t-tests / wilcoxon rank sum with and without log transform
  - function to compute statistical tests for each protein
  - logistic regression

Going back to the reliability:



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


