Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/chonsei_monthly_2017/apartment/")

# Import All files
list.files()
apart.flist.xlsx <- list.files()
fname.list <- substr(apart.flist.xlsx, 1, nchar(apart.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(apart.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

# Merge
apart_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  apart_all <- rbind(apart_all, tmp)
}
## 77,640 rows

apart_all <- apart_all %>%
  mutate(시군구번지 = paste0(시군구, 번지))

write.csv(apart_all, "apart_all.csv", row.names = FALSE)

# Address
apart_all_dup <- apart_all[!duplicated(apart_all$시군구번지), ]

apart_address <- apart_all_dup %>%
  select(시군구번지)

write.csv(apart_address, "apart_address.csv", row.names = FALSE)