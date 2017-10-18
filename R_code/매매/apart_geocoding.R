# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)
library(ggmap)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/apartment_2017")

# Import All files
list.files()
apart.flist.xlsx <- list.files()
fname.list <- substr(apart.flist.xlsx, 1, nchar(apart.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(apart.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

apart_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  apart_all <- rbind(apart_all, tmp)
}
## 58,493 rows

names(apart_all)[2] <- "SiGunGu"
names(apart_all)[3] <- "Number"

apart_all <- apart_all %>%
  mutate(address = paste0(SiGunGu, " ", Number)) %>%
  select(-시군구번지)

apart_all_1 <- apart_all[1:10000, ]
apart_all_2 <- apart_all[10001:20000, ]
apart_all_3 <- apart_all[20001:30000, ]
apart_all_4 <- apart_all[30001:40000, ]
apart_all_5 <- apart_all[40001:50000, ]
apart_all_6 <- apart_all[50001:58493, ]

write.xlsx(apart_all_1, "apart_all_1.xlsx", row.names = FALSE)
write.xlsx(apart_all_2, "apart_all_2.xlsx", row.names = FALSE)
write.xlsx(apart_all_3, "apart_all_3.xlsx", row.names = FALSE)
write.xlsx(apart_all_4, "apart_all_4.xlsx", row.names = FALSE)
write.xlsx(apart_all_5, "apart_all_5.xlsx", row.names = FALSE)
write.xlsx(apart_all_6, "apart_all_6.xlsx", row.names = FALSE)

# Geocoding
apart_all$address <- enc2utf8(apart_all$address)

apart_lonlat <- mutate_geocode(apart_all, address, source = 'google')
## Error: google restricts requests to 2500 requests a day for non-business use.