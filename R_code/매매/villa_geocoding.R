# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)
library(ggmap)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/villa_2017")

# Import All files
list.files()
villa.flist.xlsx <- list.files()
fname.list <- substr(villa.flist.xlsx, 1, nchar(villa.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(villa.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

villa_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  villa_all <- rbind(villa_all, tmp)
}
## 29,381 rows

villa_all_dup <- villa_all[!duplicated(villa_all$시군구번지), ]

villa_all_dup_1 <- villa_all_dup[1:9999, ]
villa_all_dup_2 <- villa_all_dup[10000:18604, ]

write.csv(villa_all_dup_1, "villa_all_dup_1.csv", row.names = FALSE)
write.csv(villa_all_dup_2, "villa_all_dup_2.csv", row.names = FALSE)

# names(villa_all)[2] <- "SiGunGu"
# names(villa_all)[3] <- "Number"

# villa_all <- villa_all %>%
#   mutate(address = paste0(SiGunGu, " ", Number)) %>%
#   select(-시군구번지)

write.xlsx(villa_all, "villa_all.xlsx", row.names = FALSE)

# Geocoding
villa_all$address <- enc2utf8(villa_all$address)

villa_lonlat <- mutate_geocode(villa_all, address, source = 'google')
## Error: google restricts requests to 2500 requests a day for non-business use.