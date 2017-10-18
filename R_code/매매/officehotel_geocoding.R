# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(stringr)
library(ggmap)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/officehotel_2017")

# Import All files
list.files()
officehotel.flist.xlsx <- list.files()
fname.list <- substr(officehotel.flist.xlsx, 1, nchar(officehotel.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(officehotel.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

officehotel_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  officehotel_all <- rbind(officehotel_all, tmp)
}
## 6,240 rows

officehotel_all_dup <- officehotel_all[!duplicated(officehotel_all$시군구번지), ]

write.csv(officehotel_all_dup, "officehotel_all_dup.csv", row.names = FALSE)

# names(officehotel_all)[2] <- "SiGunGu"
# names(officehotel_all)[3] <- "Number"

# officehotel_all <- officehotel_all %>%
#   mutate(address = paste0(SiGunGu, " ", Number)) %>%
#   select(-시군구번지)

write.xlsx(officehotel_all, "officehotel_all.xlsx", row.names = FALSE)

# Geocoding
officehotel_all$address <- enc2utf8(officehotel_all$address)

officehotel_lonlat <- mutate_geocode(officehotel_all, address, source = 'google')
## Error: google restricts requests to 2500 requests a day for non-business use.