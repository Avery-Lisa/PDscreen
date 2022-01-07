# Sample script to Wrangle Data
library(tidyverse)
library(readxl)

# Step 1 - import protein file -Make sure the file is in the working directory OR provide a full pathname
path='C:/Users/lisa/OneDrive - UHN/Teaching/Student Projects/Practicum 2021/PDscreen/'
protein_data <- readxl::read_xlsx(paste0(path,'file2_protein.xlsx'))

# Step 2 - import patient file - this is csv, the function should be able to detect and import either xlsx or csv
patient_data <- read.csv(paste0(path,'file1_sample.csv'))


# Step 3 - modify and merge

# Extract protein names from the Description file
protein_data <- protein_data %>%
  mutate(
    ProteinName = gsub(".*\\[","",Description), # This says to remove everything before the first '[', the backslashes are needed because this is a special character
    ProteinName = gsub("\\].*","",ProteinName), # This removes everything after the first ']'
    ProteinName = gsub("_HUMAN","",ProteinName) # Removes the _HUMAN suffix
  )
protein_data$ProteinName # These are what are useful to the researchers

# Make a long data file from the protein data
protein_long <- protein_data %>%
  pivot_longer(cols = ends_with('Area'), names_to = 'sample',values_to = 'Intensity')

# remove the Description column, because its long and ugly!
protein_long <- protein_long %>%
  dplyr::select(-Description)

#... next steps, make the sample column of protein_long something that can be matched to the  SampleName column of patient data and merge
