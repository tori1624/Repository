# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/chonsei_monthly_2017/multi/")

# Import All files
list.files()
multi.flist.xlsx <- list.files()
fname.list <- substr(multi.flist.xlsx, 1, nchar(multi.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(multi.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

multi_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  multi_all <- rbind(multi_all, tmp)
}
## 56,884 rows

write.csv(multi_all, "multi_all.csv", row.names = FALSE)

multi_all_dup <- multi_all[!duplicated(multi_all$½Ã±º±¸), ]

write.csv(multi_all_dup, "multi_all_dup.csv", row.names = FALSE)