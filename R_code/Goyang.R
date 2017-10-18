# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)

Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Setwd_apart
setwd("D:/Data/Public_data/real_transaction_price_2017/Goyang/apartment/")

# Import files_apart
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[", fname.list[i], "] has completed")
}

# Merge data
apart_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  apart_all <- rbind(apart_all, tmp)
}

# Address column
apart_all <- apart_all %>%
  mutate(주소 = paste0(시군구, " ",번지))

# File for geocoding
apart_all_dup <- apart_all[!duplicated(apart_all$주소), ]
apart_all_dup <- apart_all_dup %>%
  select(주소)

# Save
write.xlsx(apart_all_dup, "apart_goyang.xlsx", row.names = FALSE)

# Setwd_multi
setwd("D:/Data/Public_data/real_transaction_price_2017/Goyang/multi/")

# Import files_multi
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[", fname.list[i], "] has completed")
}

# Merge data
multi_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  multi_all <- rbind(multi_all, tmp)
}

# File for geocoding
multi_all_dup <- multi_all[!duplicated(multi_all$시군구), ]
multi_all_dup <- multi_all_dup %>%
  select(시군구)

# Save
write.xlsx(multi_all_dup, "multi_goyang.xlsx", row.names = FALSE)

# Setwd_officehotel
setwd("D:/Data/Public_data/real_transaction_price_2017/Goyang/officehotel/")

# Import files_officehotel
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[", fname.list[i], "] has completed")
}

# Merge data
officehotel_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  officehotel_all <- rbind(officehotel_all, tmp)
}

# Address column
officehotel_all <- officehotel_all %>%
  mutate(주소 = paste0(시군구, " ",번지))

# File for geocoding
officehotel_all_dup <- officehotel_all[!duplicated(officehotel_all$주소), ]
officehotel_all_dup <- officehotel_all_dup %>%
  select(주소)

# Save
write.xlsx(officehotel_all_dup, "officehotel_goyang.xlsx", row.names = FALSE)

# Setwd_villa
setwd("D:/Data/Public_data/real_transaction_price_2017/Goyang/villa/")

# Import files_officehotel
list.files()
flist.xlsx <- list.files()
fname.list <- substr(flist.xlsx, 1, nchar(flist.xlsx)-5)

for(i in 1:length(fname.list)){
  tmp.xlsx <- read.xlsx(flist.xlsx[i])
  assign(fname.list[i], tmp.xlsx)
  message("[", fname.list[i], "] has completed")
}

# Merge data
villa_all <- NULL
for(i in 1:length(fname.list)){
  tmp <- get(fname.list[i])
  villa_all <- rbind(villa_all, tmp)
}

# Address column
villa_all <- villa_all %>%
  mutate(주소 = paste0(시군구, " ",번지))

# File for geocoding
villa_all_dup <- villa_all[!duplicated(villa_all$주소), ]
villa_all_dup <- villa_all_dup %>%
  select(주소)

# Save
write.xlsx(villa_all_dup, "villa_goyang.xlsx", row.names = FALSE)

# Merge Data(Geocoding)
apart_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Goyang/apart_goyang_g.csv")
officehotel_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Goyang/officehotel_goyang_g.csv")
villa_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Goyang/villa_goyang_g.csv")
multi_g <- read.csv("D:/Data/Public_data/real_transaction_price_2017/Goyang/multi_goyang_g.csv")

apart <- merge(apart_all, apart_g, by = c("주소"), all.x = TRUE)
officehotel <- merge(officehotel_all, officehotel_g, by = c("주소"), all.x = TRUE)
villa <- merge(villa_all, villa_g, by = c("주소"), all.x = TRUE)
multi <- merge(multi_all, multi_g, by = c("시군구"), all.x = TRUE)

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

goyang <- rbind(apart, villa, officehotel, multi)

goyang <- goyang %>%
  arrange(주소)

goyang$`전용면적(㎡)` <- as.numeric(goyang$`전용면적(㎡)`)
goyang$`대지면적(㎡)` <- as.numeric(goyang$`대지면적(㎡)`)
goyang$`거래금액(만원)` <- gsub(",", "", goyang$`거래금액(만원)`)
goyang$`거래금액(만원)` <- as.numeric(goyang$`거래금액(만원)`)

# Calculate price/square
goyang_1 <- goyang %>%
  filter(건물종류 == '아파트' | 건물종류 == '오피스텔' | 건물종류 == '연립/다세대') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `전용면적(㎡)`)

goyang_2 <- goyang %>%
  filter(건물종류 == '단독' | 건물종류 == '다가구') %>%
  mutate('거래금액/면적' = `거래금액(만원)` / `대지면적(㎡)`)

goyang <- rbind(goyang_1, goyang_2)

goyang <- goyang %>%
  arrange(주소)

write.xlsx(goyang, "고양_매매_최종.xlsx", row.names = FALSE)