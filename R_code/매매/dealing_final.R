Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)
library(readxl)

# Setwd_apart
setwd("D:/Data/Public_data/real_transaction_price_2017/dealing_2017/apartment_2017/")

# Import All files_apart
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

# Setwd_apart_gedcoding
setwd("D:/Data/Public_data/real_transaction_price_2017/apartment_geocoding/")

# Import All files_apart_gedcoding
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

apart_gedcoding <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  apart_gedcoding <- rbind(apart_gedcoding, tmp)
}

apart_geocoding_dup <- apart_gedcoding[!duplicated(apart_gedcoding$시군구번지), ]

# Apart_merging
apart_all$시군구번지 <- substr(apart_all$시군구번지, 2, nchar(apart_all$시군구번지))

apart <- merge(apart_all, apart_geocoding_dup[, c("시군구번지", "x", "y")], 
               by = c("시군구번지"), all.x = TRUE)

names(apart)[6] <- "단지(건물)명"

apart <- apart %>%
  mutate(건물종류 = "아파트", '대지권면적(㎡)' = NA, '연면적(㎡)' = NA, 
         '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
         계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
         거래종류)

# Setwd_dealing
setwd("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/dealing_geocoding/")

# Import All files_dealing
list.files()
apart.flist.xlsx <- list.files()
fname.list <- substr(apart.flist.xlsx, 1, nchar(apart.flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(apart.flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message(fname.list[i], "has completed")
}

# Merging
## 1) Villa
villa_all_geocoding <- rbind(villa_all_1_geocoding, villa_all_2_geocoding)

villa <- merge(villa_all, villa_all_geocoding, 
               by = c("시군구번지"), all.x = TRUE)

names(villa)[6] <- "단지(건물)명"

villa <- villa %>%
  mutate(건물종류 = "연립/다세대", '연면적(㎡)' = NA, 
         '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

## 2) Officehotel
officehotel <- merge(officehotel_all, officehotel_all_geocoding,
                     by = c("시군구번지"), all.x = TRUE)

names(officehotel)[6] <- "단지(건물)명"

officehotel <- officehotel %>%
  mutate(건물종류 = "오피스텔", '대지권면적(㎡)' = NA, '연면적(㎡)' = NA, 
         '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

## 3) Multi
multi <- merge(multi_all, muti_geocoding,
               by = c("시군구"), all.x = TRUE)

names(multi)[2] <- "건물종류"

multi <- multi %>%
  mutate(시군구번지 = NA, 번지 = NA, 본번 = NA, 부번 = NA, 
         '단지(건물)명' = NA, '전용면적(㎡)' = NA, '대지권면적(㎡)' = NA,
         층 = NA, 거래종류 = "매매") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

## 4) Dealing
dealing <- rbind(apart, villa, officehotel, multi)

names(dealing)[1] <- "주소"

dealing <- dealing %>%
  arrange(주소)

write.xlsx(dealing, "매매_최종.xlsx", row.names = FALSE)

## 5) Additonal work
dealing <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/매매_최종.xlsx")

dealing_1 <- dealing %>%
  filter(건물종류 == '아파트' | 건물종류 == '오피스텔' | 건물종류 == '연립/다세대') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `전용면적(㎡)`)

dealing_2 <- dealing %>%
  filter(건물종류 == '단독' | 건물종류 == '다가구') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `대지면적(㎡)`)

dealing <- rbind(dealing_1, dealing_2)

dealing <- dealing %>%
  arrange(주소)

write.xlsx(dealing, "매매_최종_2.xlsx", row.names = FALSE)