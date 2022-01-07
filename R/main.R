importData <- function(excelFile){
  require(readxl)
  data <- readxl::read_xlsx(path=excelFile)
  return(data)
}


#install.packages('usethis')
#install.packages('devtools')
install.packages("BlandAltmanLeh")
install.packages("ggExtra")
library(usethis)
library(devtools)
#devtools::document()
##usethis::use_package('readxl')
library(dplyr)
library(tidyverse)
library(BlandAltmanLeh)
library(ggExtra)
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
PDO<-importData("ProteomeDiscovererOutput.xlsx")
Name_Abb<-importData("Protein name and abbreviations.xlsx")
Sample_info<-importData("sampleInformation.xlsx")
#Sample_info<-read_csv("sampleInformation.csv")

# Wrangle the data


# 1. Remove the missing value "NA" in column Accession number in file PDO
PDO = PDO %>%
  filter(!is.na(Accession))

# 2. Filter the description name from PDO file and match to file Name_Abb and then we can extract the protein name
PDO=PDO%>%
  right_join(Name_Abb, by ="Description")%>%
  # extract the protein name from description
  mutate(Protein = str_extract_all(Description,'- \\[.+\\]$') %>% unlist()) %>%
  # remove the square bracket
  mutate(Protein = str_remove_all(Protein,'- \\[|\\]'))

# NumberOfAccessionsPerProtein <- PDO %>%
#   dplyr::select(Accession,Protein) %>%
#   distinct() %>%
#   group_by(Protein) %>%
#   summarise(count=n()) %>%
#   arrange(desc(count))

# 3.Remove the number after the capitalized letter since letter is the only important to mtach
Sample_info = Sample_info %>%
  mutate(SampleName = str_remove(SampleName,'[:digit:]'))

# Since there are repeat proteins, remove duplicate one
Proteins = unique(PDO$Protein)


#--- Jiayue read through this code
#--- Execute each step separately so that you understand what is going on in each step
#--- Look up the documentation for the transmute function
#--- Compare how long it takes to run this code to the for loop below.
#------------------------------------------------------------------------------
area_cols <- grep('Area',names(PDO),value=T)
UniqueProteins <-
  PDO %>%
  group_by(Protein)  %>%
  summarise(
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


result1<-result %>%
  #distinct()%>%
#  dplyr::select(Protein, Sample, Intensity)%>%
  na.omit() %>%  # Remove any missing intensity data
  tidyr::pivot_wider(id_cols=c(Protein,Participant), names_from=Sample, values_from=Intensity)

#------------------------------------------------------------------------------

# Loop for match every participant with each protein for 2 technical replicates.
# Create an empty list
result = list()
k = 1
for(i in 1:nrow(Sample_info)){
  temp_Participant = Sample_info$ID[i]
  temp_Sample = Sample_info$SampleID[i]

  for(j in 1:length(Proteins)){
    temp_Protein = Proteins[j]
    temp_Area = str_c(Sample_info$SampleName[i],'5: Area')
    Area_data = PDO %>% select(Protein,temp_Area)
    temp_Intensity = Area_data %>%
      filter(Protein==temp_Protein) %>%
      drop_na() %>%
      distinct() %>%
      .[1,2] %>%
      as.numeric()

    result[[k]] = data.frame(Protein = temp_Protein,
                             Participant = temp_Participant,
                             Sample = temp_Sample,
                             Intensity = temp_Intensity)
    k = k+1
  }

}

result = do.call(rbind,result)
result = result %>% arrange(Participant,Protein)
write.csv(result,'result.csv',row.names = F)

## Step 2
# Reliably Identify
# Bland Altman to detect if protein reliable

data = read.csv('result.csv')
# Recoding NA to zero
data = data %>%
  mutate(Intensity = ifelse(is.na(Intensity),0,Intensity))

# unique return a protein protein
temp_protein = unique(data$Protein)

diff_data = list()

# Check each protein
for(i in 1:length(temp_protein)){

  temp_data = data %>% filter(Protein==temp_protein[i])

  sample1 = temp_data %>%
    filter(Sample==1) %>%
    arrange(Participant) %>%
    select(Intensity) %>%
    unlist()

  sample2 = temp_data %>%
    filter(Sample==2) %>%
    arrange(Participant) %>%
    select(Intensity) %>%
    unlist()

  ba.stats = bland.altman.stats(sample1,sample2)
  D = ba.stats$diffs
  lower.limit = ba.stats$lower.limit
  upper.limit = ba.stats$upper.limit
  n = sum(D>upper.limit | D<lower.limit)
  diff_data[[i]] = data.frame(Protein = temp_protein[i],
                              n = n)
}

diff_data = do.call(rbind,diff_data)

diff_data %>%
  arrange(desc(n))

final_protein = diff_data %>%
  filter(n==0) %>%
  select(-n) %>%
  left_join(data,by = 'Protein')

write.csv(final_protein,'final_protein.csv',row.names = F)
unique(final_protein$Protein)

data1<-read.csv("final_protein.csv")
data1 <- data1 %>% filter(Intensity!=0)


## plot an example graph
sample1 = data %>%
  filter(Protein=='1433E_HUMAN',
         Sample==1) %>%
  arrange(Participant) %>%
  select(Intensity) %>%
  unlist()

sample2 = data %>%
  filter(Protein=='1433E_HUMAN',
         Sample==2) %>%
  arrange(Participant) %>%
  select(Intensity) %>%
  unlist()

print(ggMarginal(bland.altman.plot(sample1,sample2,graph.sys = 'ggplot2'),
                 type = 'histogram',
                 size = 4))

# interclass correlation
# pearson correlation
# absolute agreement

# try pearson correlation
# data1<-read.csv("final_protein.csv")

corr<-list()
for(i in 1:length(temp_protein)){

  temp_data = data %>% filter(Protein==temp_protein[i])

  sample1 = temp_data %>%
    filter(Sample==1) %>%
    arrange(Participant) %>%
    select(Intensity) %>%
    unlist()

  sample2 = temp_data %>%
    filter(Sample==2) %>%
    arrange(Participant) %>%
    select(Intensity) %>%
    unlist()

  res<- cor.test(sample1, sample2,
                 method = "pearson")
  corr[[i]] = data.frame(Protein = temp_protein[i],
                         n = res$estimate)

}
corr
corr = do.call(rbind,corr)

corr %>%
  arrange(desc(n))

final_protein1 = corr %>%
  filter(n < 0.7000000) %>%
  select(-n) %>%
  left_join(data,by = 'Protein')


write.csv(final_protein1,'final_protein1.csv',row.names = F)
unique(final_protein$Protein)

