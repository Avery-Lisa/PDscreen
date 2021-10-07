# Step 1 import the data
importData <- function(excelFile){
  require(readxl)
  data <- readxl::read_xlsx(path=excelFile)
  return(data)
}
