Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/chonsei_monthly_2017/officehotel/")

# Import All files
list.files()
office.flist.xlsx <- list.files()
fname.list <- substr(office.flist.xlsx, 1, nchar(office.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(office.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

# Merge
officehotel_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  officehotel_all <- rbind(officehotel_all, tmp)
}
## 17,430 rows

officehotel_all <- officehotel_all %>%
  mutate(시군구번지 = paste0(시군구, 번지))

write.csv(officehotel_all, "officehotel_all.csv", row.names = FALSE)

# Address
officehotel_all_dup <- officehotel_all[!duplicated(officehotel_all$시군구번지), ]

officehotel_address <- officehotel_all_dup %>%
  select(시군구번지)

write.csv(officehotel_address, "officehotel_address.csv", row.names = FALSE)