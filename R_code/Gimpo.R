# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/Gimpo/")

# Import files
apart <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/Gimpo/dealing/아파트(매매)_실거래가_2017김포.xlsx")
officehotel <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/Gimpo/dealing/오피스텔(매매)_실거래가_2017김포.xlsx")
villa <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/Gimpo/dealing/연립다세대(매매)_실거래가_2017김포.xlsx")
multi <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/Gimpo/dealing/단독다가구(매매)_실거래가_2017김포.xlsx")

# Address column
apart <- apart %>%
  mutate(주소 = paste0(시군구, " ",번지))
officehotel <- officehotel %>%
  mutate(주소 = paste0(시군구, " ",번지))
villa <- villa %>%
  mutate(주소 = paste0(시군구, " ",번지))

# File for geocoding
apart_dup <- apart[!duplicated(apart$주소), ]
apart_dup <- apart_dup %>%
  select(주소)

officehotel_dup <- officehotel[!duplicated(officehotel$주소), ]
officehotel_dup <- officehotel_dup %>%
  select(주소)

villa_dup <- villa[!duplicated(villa$주소), ]
villa_dup <- villa_dup %>%
  select(주소)

multi_dup <- multi[!duplicated(multi$시군구), ]
multi_dup <- multi_dup %>%
  select(시군구)

# Save
write.xlsx(apart_dup, "apart_gimpo.xlsx", row.names = FALSE)
write.xlsx(officehotel_dup, "officehotel_gimpo.xlsx", row.names = FALSE)
write.xlsx(villa_dup, "villa_gimpo.xlsx", row.names = FALSE)
write.xlsx(multi_dup, "multi_gimpo.xlsx", row.names = FALSE)

# Merge Data(Geocoding)
apart_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Gimpo/apart_gimpo_g.csv")
officehotel_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Gimpo/officehotel_gimpo_g.csv")
villa_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Gimpo/villa_gimpo_g.csv")
multi_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Gimpo/multi_gimpo_g.csv")

apart <- merge(apart, apart_g, by = c("주소"), all.x = TRUE)
officehotel <- merge(officehotel, officehotel_g, by = c("주소"), all.x = TRUE)
villa <- merge(villa, villa_g, by = c("주소"), all.x = TRUE)
multi <- merge(multi, multi_g, by = c("시군구"), all.x = TRUE)

# Merge Data(All)
names(apart)[6] <- "단지(건물)명"

apart <- apart %>%
  mutate(건물종류 = "아파트", '대지권면적(㎡)' = NA, '연면적(㎡)' = NA, 
             '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(주소, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

names(villa)[6] <- "단지(건물)명"

villa <- villa %>%
  mutate(건물종류 = "연립/다세대", '연면적(㎡)' = NA, 
             '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(주소, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

names(officehotel)[6] <- "단지(건물)명"

officehotel <- officehotel %>%
  mutate(건물종류 = "오피스텔", '대지권면적(㎡)' = NA, '연면적(㎡)' = NA, 
             '대지면적(㎡)' = NA, 거래종류 = "매매") %>%
  select(주소, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

names(multi)[2] <- "건물종류"

multi <- multi %>%
  mutate(주소 = NA, 번지 = NA, 본번 = NA, 부번 = NA, 
              '단지(건물)명' = NA, '전용면적(㎡)' = NA, '대지권면적(㎡)' = NA,
              층 = NA, 거래종류 = "매매") %>%
  select(주소, 시군구, 번지, 본번, 부번, '단지(건물)명', '전용면적(㎡)', 
              '대지권면적(㎡)', '연면적(㎡)', '대지면적(㎡)', 계약년월, 
              계약일, '거래금액(만원)', 층, 건축년도, 도로명, x, y, 건물종류,
              거래종류)

gimpo <- rbind(apart, villa, officehotel, multi)

gimpo <- gimpo %>%
  arrange(주소)

gimpo$`전용면적(㎡)` <- as.numeric(gimpo$`전용면적(㎡)`)
gimpo$`대지면적(㎡)` <- as.numeric(gimpo$`대지면적(㎡)`)
gimpo$`거래금액(만원)` <- gsub(",", "", gimpo$`거래금액(만원)`)
gimpo$`거래금액(만원)` <- as.numeric(gimpo$`거래금액(만원)`)

# Calculate price/square
gimpo_1 <- gimpo %>%
  filter(건물종류 == '아파트' | 건물종류 == '오피스텔' | 건물종류 == '연립/다세대') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `전용면적(㎡)`)

gimpo_2 <- gimpo %>%
  filter(건물종류 == '단독' | 건물종류 == '다가구') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `대지면적(㎡)`)

gimpo <- rbind(gimpo_1, gimpo_2)

gimpo <- gimpo %>%
  arrange(주소)

write.xlsx(gimpo, "김포_매매_최종.xlsx", row.names = FALSE)