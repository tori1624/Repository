options("scipen" = 100)

# Before runnig this code, install 'Rtools'
Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip") # write.xlsx()

library(readr)
library(dplyr)
library(openxlsx)
library(WriteXLS) # Write Xls

setwd("D:/Data/Public_data/landprice/landprice_SCM/")

landprice <- read.csv("D:/Data/Public_data/landprice/landprice_2017.csv")
SCM_seoul <- read.xlsx("D:/Data/map/SCM_seoul/LSMD_CONT_LDREG_11_201707.xlsx")

Database <- merge(SCM_seoul, landprice, 
                  by.x = c("PNU"), by.y = c("LAND_CD"), all.x = TRUE)

code.list <- unique(Database$COL_ADM_SE)

for(i in 1:length(code.list)){
  Database %>%
    filter(COL_ADM_SE == code.list[i]) -> tmp
  assign(paste0("Database_", code.list[i]), tmp)
  message(code.list[i], "has completed")
}

for(i in 1:25){
  tmp <- get(paste0("Database_", code.list[i]))
  write.xlsx(tmp, paste0("Database", code.list[i], ".xlsx"), row.names = FALSE)
  message(code.list[i], "has completed")
}

write.xlsx(Database, "Database.xlsx", row.names = FALSE)
# WriteXLS(Database, "Database.xls", row.names = FALSE)
## -> Error in WriteXLS(Database, "Database.xls", row.names = FALSE) : 
##    One or more of the data frames named in 'x' exceeds 65,535 rows or 256 columns
