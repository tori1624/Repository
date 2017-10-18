# Basic Packages
library(openxlsx)
library(dplyr)
library(stringr)
library(readr)

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/cm_geocoding/")

# 1. Import All files
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[",fname.list[i], "] has completed")
}

# 2. Merging
## 1) Villa
villa_geocoding <- rbind(villa_geocoding_1, villa_geocoding_2, villa_geocoding_3)

villa <- merge(villa_all, villa_geocoding, 
               by = c("시군구번지"), all.x = TRUE)

names(villa)[6] <- '단지(건물)명'

villa_chonsei <- villa[, -12] %>%
  filter(전월세구분 == '전세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "연립/다세대") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', 층, 건축년도, 
         도로명, x, y, 건물종류, 전월세구분)

villa_monthly <- villa %>%
  filter(전월세구분 == '월세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "연립/다세대") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', '월세(만원)',
         층, 건축년도, 도로명, x, y, 건물종류, 전월세구분)

## 2) Officehotel
officehotel <- merge(officehotel_all, officehotel_geocoding, 
               by = c("시군구번지"), all.x = TRUE)

names(officehotel)[6] <- '단지(건물)명'

officehotel_chonsei <- officehotel[, -12] %>%
  filter(전월세구분 == '전세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "오피스텔") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', 층, 건축년도, 
         도로명, x, y, 건물종류, 전월세구분)

officehotel_monthly <- officehotel %>%
  filter(전월세구분 == '월세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "오피스텔") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', '월세(만원)',
         층, 건축년도, 도로명, x, y, 건물종류, 전월세구분)

## 3) Apartment
apart <- merge(apart_all, apart_geocoding, 
               by = c("시군구번지"), all.x = TRUE)

names(apart)[6] <- '단지(건물)명'

apart_chonsei <- apart[, -12] %>%
  filter(전월세구분 == '전세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "아파트") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', 층, 건축년도, 
         도로명, x, y, 건물종류, 전월세구분)

apart_monthly <- apart %>%
  filter(전월세구분 == '월세') %>%
  mutate('계약면적(㎡)' = NA, 건물종류 = "아파트") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', '월세(만원)',
         층, 건축년도, 도로명, x, y, 건물종류, 전월세구분)

## 4) Multi
multi <- merge(multi_all, multi_geocoding,
               by = c("시군구"), all.x = TRUE)

multi_chonsei <- multi[, -7] %>%
  filter(전월세구분 == '전세') %>%
  mutate(시군구번지 = NA, 번지 = NA, 본번 = NA, 부번 = NA, 층 = NA,
         '단지(건물)명' = NA, '전용면적(㎡)' = NA, 
         건물종류 = "단독/다가구") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', 층, 건축년도, 
         도로명, x, y, 건물종류, 전월세구분)

multi_monthly <- multi %>%
  filter(전월세구분 == '월세') %>%
  mutate(시군구번지 = NA, 번지 = NA, 본번 = NA, 부번 = NA, 층 = NA,
         '단지(건물)명' = NA, '전용면적(㎡)' = NA, 
         건물종류 = "단독/다가구") %>%
  select(시군구번지, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
         '계약면적(㎡)', 계약년월, 계약일, '보증금(만원)', '월세(만원)',
         층, 건축년도, 도로명, x, y, 건물종류, 전월세구분)

## 5) Chonsei
chonsei <- rbind(apart_chonsei, villa_chonsei, officehotel_chonsei, multi_chonsei)

names(chonsei)[1] <- "주소"
names(chonsei)[18] <- "거래종류"

chonsei <- chonsei %>%
  arrange(주소)

write.xlsx(chonsei, "전세_최종.xlsx", row.names = FALSE)

## 6) Monthly
monthly <- rbind(apart_monthly, villa_monthly, officehotel_monthly, multi_monthly)

names(monthly)[1] <- "주소"
names(monthly)[19] <- "거래종류"

monthly <- monthly %>%
  arrange(주소)

write.xlsx(monthly, "월세_최종.xlsx", row.names = FALSE)