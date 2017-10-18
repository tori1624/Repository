Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")

# Basic Packages
library(readr)
library(openxlsx)
library(dplyr)

# Setwd
setwd("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/")

# Data Import
near_distance <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/0909_near_distance.xlsx")

# Data split
near_1 <- near_distance %>%
  filter(NEAR_RANK == 1) %>%
  select(IN_FID, NEAR_DIST)

near_2 <- near_distance %>%
  filter(NEAR_RANK == 2) %>%
  select(IN_FID, NEAR_DIST)

# Data merge
near <- merge(near_1, near_2, by = c("IN_FID"))
names(near)[2] <- "NEAR_DIST_1" 
names(near)[3] <- "NEAR_DIST_2"

# Calculate Mean
near <- near %>%
  mutate(ND_mean = (NEAR_DIST_1 + NEAR_DIST_2) / 2)

write.xlsx(near, "ND_mean_0909.xlsx", row.names = FALSE)

# Data Import
near_distance <- read.xlsx("D:/Data/Public_data/real_transaction_price_2017/KOTI_refined/0915_near_distance.xlsx")

# Data split
near_1 <- near_distance[!duplicated(near_distance$IN_FID), ] %>%
  select(IN_FID, NEAR_DIST)
near_2 <- near_distance[duplicated(near_distance$IN_FID), ] %>%
  select(IN_FID, NEAR_DIST)

# Data merge
near <- merge(near_1, near_2, by = c("IN_FID"))
names(near)[2] <- "NEAR_DIST_1" 
names(near)[3] <- "NEAR_DIST_2"

# Calculate Mean
near <- near %>%
  mutate(ND_mean = (NEAR_DIST_1 + NEAR_DIST_2) / 2)

write.xlsx(near, "ND_mean_0915.xlsx", row.names = FALSE)