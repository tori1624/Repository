# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)
library(ggmap)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/condominium_2017")

# Import All files
list.files()
condo.flist.xlsx <- list.files()
fname.list <- substr(condo.flist.xlsx, 1, nchar(condo.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(condo.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

condo_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  condo_all <- rbind(condo_all, tmp)
}
## 6,163 rows

condo_all_dup <- condo_all[!duplicated(condo_all$시군구번지), ]

write.csv(condo_all_dup, "condo_all_dup.csv", row.names = FALSE)

# names(condo_all)[2] <- "SiGunGu"
# names(condo_all)[3] <- "Number"

# condo_all <- condo_all %>%
#   mutate(address = paste0(SiGunGu, " ", Number)) %>%
#   select(-시군구번지)

write.xlsx(condo_all, "condo_all.xlsx", row.names = FALSE)

# Geocoding
condo_all$address <- enc2utf8(condo_all$address)

condo_lonlat <- mutate_geocode(condo_all, address, source = 'google')
## Error: google restricts requests to 2500 requests a day for non-business use.