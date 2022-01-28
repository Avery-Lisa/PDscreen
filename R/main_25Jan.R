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
#library(plyr)

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
Sample_info<-read_csv("data/sampleInformation.csv")

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

# 3.Remove the number after the capitalized letter since letter is the only important to match
Sample_info = Sample_info %>%
  mutate(SampleName = str_remove(SampleName,'[:digit:]'))

# Since there are repeat proteins, remove duplicate one
Proteins = unique(PDO$Protein)
length(Proteins)

NumberOfAccessionsPerProtein <- PDO %>%
  dplyr::select(Accession,Protein) %>%
  distinct() %>%
  group_by(Protein) %>%
  dplyr::summarize(count = n()) %>%
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

# proteins with Area=0 are treated as 0

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

# proteins with Area=0 are treated as missing value
result[result==0]<-NA
result

result2<-result %>%
  na.omit() %>%  # Remove any missing intensity data
  tidyr::pivot_wider(id_cols=c(Protein,Participant), names_from=Sample, values_from=Intensity)

result_nest1 <- result2 %>%
  na.omit()%>%
  group_by(Protein) %>%
  nest()

corr_coef1 <- map(.x = result_nest1$data, .f = ~cor(as.numeric(.x$`1`),as.numeric(.x$`2`) ))

result_nest1 <- result_nest1 %>%
  mutate(corr_coef= map(.x = data, .f = ~cor(as.numeric(.x$`1`),as.numeric(.x$`2`) )))

Final_Protein <- result_nest1 %>%
  unnest(corr_coef)%>%
  filter(corr_coef > 0.75)%>%
  select(Protein)

## Treated as missing value left with 317 Proteins, Treated as 0 left with 315 protein.
## Not much different

# T-test
# Null: no different between mean
# Alternative: different between mean

# get my final protein list by using with Area=0 are treated as missing value
Final_Protein <- result_nest1 %>%
  unnest(corr_coef)%>%
  filter(corr_coef > 0.75)

# unnest my protein list, so that I have all protein name with its C and MS groups

Final_Protein<-Final_Protein%>%
  unnest(data)

# delete the column for second techniqucal replicates and the correlation coefficient
new_data <-select(Final_Protein, -c('2',corr_coef))

# extract the Participant only with the group letter C and MS
new_data$group=gsub("[[:digit:]]","",new_data$Participant )
new_data


# Log transformation for new_data
new_data_log=new_data %>%
  ungroup() %>% # The new_data set is still grouped by Protein, we need to ungroup before applying mutate
  mutate(raw_t = as.numeric(new_data$`1`),
           log_t = log(as.numeric(new_data$`1`)),
         log2_t = log(as.numeric(new_data$`1`)))  # This is almost the same as log, but more common in proteomics (just by convention)

# Take a look at these, notice how much the variance has been reduced, this is for all proteins, you can filter to look at just one
p1 <- new_data_log %>%
#  filter(Protein=='IGKC') %>%
  ggplot(aes(x=log_t)) + geom_histogram()
p2 <- new_data_log %>%
#  filter(Protein=='IGKC') %>%
  ggplot(aes(x=log2_t)) + geom_histogram()
p3 <- new_data_log %>%
#  filter(Protein=='IGKC') %>%
  ggplot(aes(x=raw_t)) + geom_histogram()
#install.packages('ggpubr')
ggpubr::ggarrange(p1,p2,p3,ncol=1)

#------------------------------------------------------
# try to calculate t-test with the one Protein
testProtein<-new_data_log%>%  # use the data frame with numeric variables
  filter(Protein=='IGKC')

# ggplot for new_data with original intensity for intensity IGKC
# You need to tell ggplot what to plot - points, lines, histogram, boxplot etc
# See here: https://r4ds.had.co.nz/data-visualisation.html or here: https://rpubs.com/arvindpdmn/ggplot2-basics
testProtein %>%
  ggplot(aes(raw_t, group))  # because you start with the dataframe, you don't need to use it again here, just the variable names
# but you do need to tell it what to plot!

# You don't need to remove the participant column
testProtein<-testProtein%>%
  select(-c(Participant))


nested<-testProtein%>%
  group_by(Protein)%>%
  nest()

output<-t.test(as.numeric(testProtein$`1`)~ testProtein$group)

output1 <- wilcox.test(as.numeric(testProtein$`1`) ~ testProtein$group)



#------------------------------------------------------------------------------

# With the whole protein set

new_data<-new_data%>%
  select(-c(Participant))

nested_new<-new_data%>%
  group_by(Protein)%>%
  nest()

# This function works with two vectors - to use it in mapply you need a function that accepts a data fame
t_out<- function(vector1, vector2){
  out<- t.test(as.numeric(vector1) ~ vector2, var.equal = TRUE)
  return(out)
}

# Your nested_new has only two columns, one for proteins, and then a column that contains a data frame for each protein 
names(nested_new)

# This will fail, becase t_out is expecting two vectors, not a vector and a data frame
t_test<-mapply(t_out, nested_new$Protein, nested_new$data)

# You need to write a new function, similar to t_out that will accept a data frame
# This is going to be difficult with the apply functions

# start by extracting the first data element
data=nested_new$data[1]
data

# notice to get a data frame you need to take the first list element of data
df <- data[[1]]
df

# now we need a t-test on the columns of df, and the intensity needs to be numeric
df$Value <- as.numeric(df$`1`)
out <- t.test(df$Value~df$group)

# Now you can put those steps into a function

t_out2 <- function(data){
  df <- data[[1]]
  df$Value <- as.numeric(df$`1`)
  out <- t.test(df$Value~df$group)
  return(out)
}

# this works
t_out2(nested_new$data[1])

# but this fails, because of the nested structure of nested_new$data
lapply(nested_new$data,t_out2)

# If we modify our function a little
t_out3 <- function(data){
  #df <- data[[1]]
  df$Value <- as.numeric(df$`1`)
  out <- t.test(df$Value~df$group)
  return(out)
}
# Then we get what we want
lapply(nested_new$data,t_out3)

# The other function is the map function (from the purr library)
map(nested_new$data,t_out3)

# log transformation

# create new column for log intensity into new_data
# have look at protein has significant different using one test transformed vs untransformed
# ggplot for a subset of original intensity

# write a function for group protein
b<-new_data %>%
  group_by(Protein) %>%
  summarise(out = list(tidy(pairwise.t.test(value, Protein))))%>%
  unnest(c(out))

Final_Protein<-Final_Protein%>%
  unnest(data)

Final_Protein$`1`

#mapply
#pmap()

# write function for t test extract just p-value
# compare p-value
# high discard
# low plot



