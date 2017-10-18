# Basic Packages
library(openxlsx)
library(dplyr)
library(stringr)
library(readr)
library(readxl)

# Setwd_1
setwd("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/dealing_geocoding/")

# 1. Import All files_1
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[",fname.list[i], "] has completed")
}

# Setwd_2
setwd("D:/Data/Public_data/real_transaction_price_2017/apartment_geocoding/")

# 2. Import All files_2
list.files()
flist.xls <- list.files()
fname.list <- substr(flist.xls, 1, nchar(flist.xls)-4)

for(i in 1:length(fname.list)){
  tmp.xls <- read_excel(flist.xls[i])
  names(tmp.xls)[3] <- "x"
  names(tmp.xls)[4] <- "y"
  assign(fname.list[i], tmp.xls)
  message("[",fname.list[i], "] has completed")
}

# 3. Merging
## 1) Villa
villa_all_geocoding <- rbind(villa_all_1_geocoding, villa_all_2_geocoding)

villa <- merge(villa_all, villa_all_geocoding, 
               by = c("시군구번지"), all.x = TRUE)
villa <- villa %>%
  select(시군구번지, '거래금액(만원)', x, y) %>%
  mutate(건물종류 = "연립/다세대")

## 2) Officehotel
officehotel <- merge(officehotel_all, officehotel_all_geocoding,
                     by = c("시군구번지"), all.x = TRUE)
officehotel <- officehotel %>%
  select(시군구번지, '거래금액(만원)', x, y) %>%
  mutate(건물종류 = "오피스텔")

## 3) Condominium
condo <- merge(condo_all, condo_all_geocoding,
               by = c("시군구번지"), all.x = TRUE)
condo <- condo %>%
  select(시군구번지, '거래금액(만원)', x, y) %>%
  mutate(건물종류 = "분양입주권")

## 4) Apartment
apart <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  apart <- rbind(apart, tmp)
}

apart <- apart %>%
  mutate(건물종류 = "아파트")

## 5) Multi
multi <- merge(multi_all, muti_geocoding,
               by = c("시군구"), all.x = TRUE)

multi <- multi %>%
  select(시군구, '거래금액(만원)', x, y) %>%
  mutate(건물종류 = "단독/다가구")

names(multi)[1] <- "시군구번지"

## 6) All
dealing <- rbind(apart, villa, officehotel, condo, multi)
dealing <- dealing %>%
  mutate(거래종류 = "매매", 가격_2 = NA)

names(dealing)[1] <- "주소"
names(dealing)[2] <- "가격_1"

dealing <- dealing %>%
  select(주소, x, y, 건물종류, 거래종류, 가격_1, 가격_2)

write.csv(dealing, "dealing.csv", row.names = FALSE)