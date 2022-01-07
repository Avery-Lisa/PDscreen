#install.packages('usethis')
#install.packages('devtools')
library(usethis)
library(devtools)load_all()
#devtools::document()
##usethis::use_package('readxl')
library(dplyr)
library(tidyverse)
library(readxl)

#'Proteome Discoverer Import
#'
#'A function to import the Excel ProteomeDiscoverer file and extract the protein intensities
#'
#'A third documentation chuck that appears in the details section of the help file
#'
#'@param excelFile The name of the file output by ProteomeDiscoverer
#'@importFrom readxl read_xlsx
#'@keywords import
#'@export

importData <- function(excelFile){
  require(readxl)
  data <- readxl::read_xlsx(path=excelFile)
  return(data)
}


#tidyverse to document import from

# Step 1:
# import the excel data

PDO<-importData("/Users/jiayuefeng/Desktop/practicum/PDscreen/ProteomeDiscovererOutput.xlsx")
Name_Abb<-importData("/Users/jiayuefeng/Desktop/practicum/PDscreen/Protein name and abbreviations.xlsx")
# Note:
#--------------
#  This will only work if you have saved sampleInformation.csv to an Excel File
# The importData file should be updated to accept either csv or xlsx files
Sample_info<-importData("/Users/jiayuefeng/Desktop/practicum/PDscreen/sampleInformation.xlsx")

PDO<-importData("ProteomeDiscovererOutput.xlsx")
Name_Abb<-importData("Protein name and abbreviations.xlsx")

Sample_info<-read.csv("sampleInformation.csv")

# Note:
#--------------
# This works on this particular file, but it should be flexible enough to extract all columns that have 'Area' in the column name, look up the grep function
# extract protein intensity data (all fields starting with Area)
c1<-seq(8,52)
protein_intensity_data<-PDO[, c1]

# identify the protein name from the ascension number

# Note:
#--------------
# It might be the case that there are proteins in the PDO data that are not in the Name_Abb data and vice versa.
# Therefore, to link them you need to merge via the Description field - because you can't rely on the order being the same
# What we want is a file with the protein intensity and the protein name, the Description and Ascension numbers are not important
# extract the data for accession wihout NA number
PDO$name <- NA # add a column called name with NA
# find index for rows ascension is not NA
ascension_not_NA<-!is.na(PDO[,1])
# extract description that has ascension number
ascension_Description<-PDO$Description[ascension_not_NA]
# extract description from data file name ABB
name_ABB_Desciption<-Name_Abb$Description
# match two above description get the reorder index
reorder_index<-match(ascension_Description,name_ABB_Desciption)
# according to ascension number to add the name back
PDO$name[ascension_not_NA]<-Name_Abb$Name[reorder_index]
glimpse(PDO)


# Note:
#--------------
# You need to conduct this type of operation on ALL of the columns that contain Area in the name, these are the intensity values for different samples
# Once you extract the letter (in the example below it is A), then you need to match that letter with the letter in  the SampleName column of the Sample_info data.
# Note that in the SampleName column all of the letters have a 2 after them, this 2 is not important and can be removed. Samples are matched by letter only
# identify the technical replicates
col_name<-"A5:Area"
col_name<-paste0(letter,":Area")
col_name

# mutate tidyverse ifelse

library(tidyverse)
data%>% mutate(intensity=ifelse(condition, yes,no))
# condition:


# recode missing values to zero

PDO <- as.data.frame(PDO)
PDO[is.na(PDO)] <- 0

# match with the clinical data, identify the technical replicates and recorde any missing values to 0
# document all manipulations to a log file.

PDO$name

sampleinformation %>%mutate(intensity=ifelse(samplename=))

