#install.packages('usethis')
#install.packages('devtools')
library(usethis)
library(devtools)load_all()
#devtools::document()
##usethis::use_package('readxl')
library(dplyr)
library(tidyverse)

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
Sample_info<-importData("/Users/jiayuefeng/Desktop/practicum/PDscreen/sampleInformation.xlsx")

# extract protein intensity data (all fields starting with Area)
c1<-seq(8,52)
protein_intensity_data<-PDO[, c1]

# identify the protein name from the ascension number

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

