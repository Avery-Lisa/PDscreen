#install.packages('usethis')
#install.packages('devtools')
#library(usethis)
#library(devtools)
#load_all()
# devtools::document()
#usethis::use_package('readxl')

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
