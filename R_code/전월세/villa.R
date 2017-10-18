Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/chonsei_monthly_2017/villa/")

# Import All files
list.files()
villa.flist.xlsx <- list.files()
fname.list <- substr(villa.flist.xlsx, 1, nchar(villa.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(villa.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

# Merge
villa_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  villa_all <- rbind(villa_all, tmp)
}
## 41,845 rows

villa_all <- villa_all %>%
  mutate(시군구번지 = paste0(시군구, 번지))

write.csv(villa_all, "villa_all.csv", row.names = FALSE)

# Address
villa_all_dup <- villa_all[!duplicated(villa_all$시군구번지), ]

villa_address_1 <- villa_all_dup[1:9999, ]
villa_address_2 <- villa_all_dup[10000:19998, ]
villa_address_3 <- villa_all_dup[19999:24958, ]

for(i in 1:3){
  tmp <- get(paste0("villa_address_", i))
  tmp_address <- tmp %>%
    select(시군구번지)
  assign(paste0("villa_address_", i), tmp_address)
}

write.csv(villa_address_1, "villa_address_1.csv", row.names = FALSE)
write.csv(villa_address_2, "villa_address_2.csv", row.names = FALSE)
write.csv(villa_address_3, "villa_address_3.csv", row.names = FALSE)