#install.packages('usethis')
#install.packages('devtools')
#install.packages("BlandAltmanLeh")
#install.packages("ggExtra")
library(usethis)
library(devtools)
#devtools::document()
##usethis::use_package('readxl')
library(dplyr)
library(tidyverse)
library(BlandAltmanLeh)
library(ggExtra)
library(plyr)

# A little changed comment

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

## Step 1. Import & wrangle the data

# Import the excel data
PDO<-importData("data/ProteomeDiscovererOutput.xlsx")
Name_Abb<-importData("data/Protein name and abbreviations.xlsx")
Sample_info<-importData("data/sampleInformation.csv")

# Wrangle the data

# 1. Remove the missing value "NA" in column Accession number in file PDO
PDO = PDO %>%
  filter(!is.na(Accession))
PDO$Accession[1]

# 2. Filter the description name from PDO file and match to file Name_Abb and then we can extract the protein name
PDO=PDO%>%
  right_join(Name_Abb, by ="Description")%>%
  # extract the protein name from description
  mutate(Protein = str_extract_all(Description,'- \\[.+\\]$') %>% unlist()) %>%
  # remove the square bracket
  mutate(Protein = str_remove_all(Protein,'- \\[|\\]'))

# 3.Remove the number after the capitalized letter since letter is the only important to mtach
Sample_info = Sample_info %>%
  mutate(SampleName = str_remove(SampleName,'[:digit:]'))

# Since there are repeat proteins, remove duplicate one
Proteins = unique(PDO$Protein)


NumberOfAccessionsPerProtein <- PDO %>%
  dplyr::select(Accession,Protein) %>%
  distinct() %>%
  group_by(Protein) %>%
  summarise(count=n()) %>%
  arrange(desc(count))


## Lisa code
# extract all area column
area_cols <- grep('Area',names(PDO),value=T)

UniqueProteins <-
  PDO %>%
  dplyr::group_by(Protein)  %>%
  dplyr::summarise(
    FirstAccession = Accession[1]
  )


result <- PDO %>%
  filter(Accession %in% UniqueProteins$FirstAccession) %>%
  dplyr::select(Protein,area_cols) %>%
  tidyr::pivot_longer(cols=area_cols,names_to = 'columnName',values_to = 'Intensity') %>%
  mutate(
    Protein = gsub('_HUMAN','',Protein),
    SampleName = gsub('5: Area','',columnName)
  ) %>%
  full_join(Sample_info) %>%
  transmute(
    Protein=Protein,
    Participant = ID,
    Sample=SampleID,
    Intensity=Intensity
  )

result

result1<-result %>%
  na.omit() %>%  # Remove any missing intensity data
  tidyr::pivot_wider(id_cols=c(Protein,Participant), names_from=Sample, values_from=Intensity)


result_nest <- result1 %>%
  na.omit()%>%
  group_by(Protein) %>%
  nest()

corr_coef <- map(.x = result_nest$data, .f = ~cor(as.numeric(.x$`1`),as.numeric(.x$`2`) ))

result_nest <- result_nest %>%
  mutate(corr_coef= map(.x = data, .f = ~cor(as.numeric(.x$`1`),as.numeric(.x$`2`) )))

result_nest %>%
  unnest(corr_coef)%>%
  filter(corr_coef > 0.75)%>%
  select(Protein)














