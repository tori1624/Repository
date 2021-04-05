---
title: "Recreation_Tourism_Geography"
author: "Young Ho Lee"
date: "2017.05.10"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

# Basic Packages
library(ggplot2)
library(dplyr)
library(readr)
library(gridExtra)
library(caret)
library(e1071)

#setwd
knitr::opts_knit$set(root.dir = "D:/Data/KNTS/Database/Refined/individual_2")
```

# 1. Refined_1
## 1) Data Import
```{r}
data2011 <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Original/Individual/data2011.csv")
data2012 <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Original/Individual/data2012.csv")
data2013 <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Original/Individual/data2013.csv")
data2014 <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Original/Individual/data2014.csv")
data2015 <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Original/Individual/data2015.csv")
```

## 2) Extracting Necessary Question
```{r}
ColumnExtract11<- function(data){
  data %>%
    # Extracting Necessary Question
    select(PID_11, type1.1, month.1, q1.1, q3.1, q4_a.1, q5.1, q7_c.1, q10.1, q12_1.1, q12_2.1,
           q12_3.1, q12_4.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_10.1, q12_11.1, q12_12.1, 
           q12_13.1, q6_1.1.1, q6_1_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7.1.1, q6_8.1.1)
}
data2011_1 <- ColumnExtract11(data2011)

ColumnExtract12<- function(data){
  data %>%
    # Extracting Necessary Question
    select(PID_12, type1.1, month.1, q1.1, q3.1, q4_a.1, q5.1, q7_c.1, q10.1, q12_1.1, q12_2.1,
           q12_3.1, q12_4.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_10.1, q12_11.1, q12_12.1, 
           q12_13.1, q6_1.1.1, q6_1_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7.1.1, q6_8.1.1)
}
data2012_1 <- ColumnExtract12(data2012)

ColumnExtract13 <- function(data){
  data %>%
    # Extracting Necessary Question
    select(PID_13, type1.1, month.1, q1.1, q3.1, q4_a.1, q5.1, q7_c.1, q10.1, q12_1.1, q12_2.1,
           q12_3.1, q12_4.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_10.1, q12_11.1, q12_12.1, 
           q12_13.1, q6_1.1.1, q6_1_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7.1.1, q6_8.1.1)
}
data2013_1 <- ColumnExtract13(data2013)

ColumnExtract14 <- function(data){
  data %>%
    # Extracting Necessary Question
    select(PID_14, type1.1, month.1, q1.1, q3.1, q4_a.1, q5.1, q7_c.1, q10.1, q12_1.1, q12_2.1,
           q12_3.1, q12_4.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_9.1, q12_10.1, q12_11.1, 
           q12_12.1, q6_1.1, q6_1_1.1, q6_2_a.1, q6_3.1, q6_6.1, q6_7.1, q6_8.1)
}
data2014_1 <- ColumnExtract14(data2014)

ColumnExtract15 <- function(data){
  data %>%
    # Extracting Necessary Question
    select(PID_15, type1.1, month.1, q1.1, q3.1, q4_a.1, q5.1, q7_c.1, q10.1, q12_1.1, q12_2.1,
           q12_3.1, q12_4.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_9.1, q12_10.1, q12_11.1, 
           q12_12.1, q6_1.1.1, q6_1_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7.1.1, q6_8.1.1)
}
data2015_1 <- ColumnExtract15(data2015)
```

## 3) Saving Data
```{r}
write.csv(data2011_1, "data2011_1.csv", row.names = FALSE)
write.csv(data2012_1, "data2012_1.csv", row.names = FALSE)
write.csv(data2013_1, "data2013_1.csv", row.names = FALSE)
write.csv(data2014_1, "data2014_1.csv", row.names = FALSE)
write.csv(data2015_1, "data2015_1.csv", row.names = FALSE)
```

# 2. Refined_2
## 1) Data Import
```{r}
data2011_1 <- read.csv("c:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_1/data2011_1.csv")
data2012_1 <- read.csv("c:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_1/data2012_1.csv")
data2013_1 <- read.csv("c:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_1/data2013_1.csv")
data2014_1 <- read.csv("c:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_1/data2014_1.csv")
data2015_1 <- read.csv("c:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_1/data2015_1.csv")

data2011_c <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_Cht/idv_cht_11.csv")
data2012_c <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_Cht/idv_cht_12.csv")
data2013_c <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_Cht/idv_cht_13.csv")
data2014_c <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_Cht/idv_cht_14.csv")
data2015_c <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/Individual_Cht/idv_cht_15.csv")
```

## 2) Extracting Domestic Tourism
```{r}
RowExtract <- function(data){
  data %>%
    # Domestic Tourism
    filter(type1.1 == 1)
}

data2011_2 <- RowExtract(data2011_1)
data2012_2 <- RowExtract(data2012_1)
data2013_2 <- RowExtract(data2013_1)
data2014_2 <- RowExtract(data2014_1)
data2015_2 <- RowExtract(data2015_1)
```

## 3) Converting Dependent Variables
```{r}
Factoring1 <- function(data){
  data %>%
    mutate(q6_7 = ifelse(q6_7.1.1 > 3, 1,
                         ifelse(q6_7.1.1 <= 3, 0, NA))) %>%
    mutate(q6_8 = ifelse(q6_8.1.1 > 3, 1,
                         ifelse(q6_8.1.1 <= 3, 0, NA))) %>%
    select(-q6_7.1.1, -q6_8.1.1, -q5.1, -q12_4.1)
}

Factoring2 <- function(data){
  data %>%
    mutate(q6_7 = ifelse(q6_7.1 > 3, 1,
                         ifelse(q6_7.1 <= 3, 0, NA))) %>%
    mutate(q6_8 = ifelse(q6_8.1 > 3, 1,
                         ifelse(q6_8.1 <= 3, 0, NA))) %>%
    select(-q6_7.1, -q6_8.1, -q5.1, -q12_4.1)
}

data2011_3 <- Factoring1(data2011_2)
data2012_3 <- Factoring1(data2012_2)
data2013_3 <- Factoring1(data2013_2)
data2014_3 <- Factoring2(data2014_2)
data2015_3 <- Factoring1(data2015_2)
```

## 4) Changing Rownames For Rbind
```{r}
names(data2014_3)[names(data2014_3) == "q6_1_1.1"] <- c("q6_1_1.1.1")
names(data2014_3)[names(data2014_3) == "q6_1.1"] <- c("q6_1.1.1")
names(data2014_3)[names(data2014_3) == "q6_2_a.1"] <- c("q6_2_a.1.1")
names(data2014_3)[names(data2014_3) == "q6_3.1"] <- c("q6_3.1.1")
names(data2014_3)[names(data2014_3) == "q6_6.1"] <- c("q6_6.1.1")

names(data2011_3)[16] <- c("q12_9.1")
names(data2012_3)[16] <- c("q12_9.1")
names(data2013_3)[16] <- c("q12_9.1")

names(data2011_3)[17] <- c("q12_10.1")
names(data2012_3)[17] <- c("q12_10.1")
names(data2013_3)[17] <- c("q12_10.1")

names(data2011_3)[18] <- c("q12_11.1")
names(data2012_3)[18] <- c("q12_11.1")
names(data2013_3)[18] <- c("q12_11.1")

names(data2011_3)[19] <- c("q12_12.1")
names(data2012_3)[19] <- c("q12_12.1")
names(data2013_3)[19] <- c("q12_12.1")
```

## 5) Merging Ind & Cht
```{r}
data2011_4 <- merge(data2011_c, data2011_3, by.x = c("PID"), by.y = c("PID_11"))
data2012_4 <- merge(data2012_c, data2012_3, by.x = c("PID"), by.y = c("PID_12"))
data2013_4 <- merge(data2013_c, data2013_3, by.x = c("PID"), by.y = c("PID_13"))
data2014_4 <- merge(data2014_c, data2014_3, by.x = c("PID"), by.y = c("PID_14"))
data2015_4 <- merge(data2015_c, data2015_3, by.x = c("PID"), by.y = c("PID_15"))

names(data2011_4)[1] <- c("PID")
names(data2012_4)[1] <- c("PID")
names(data2013_4)[1] <- c("PID")
names(data2014_4)[1] <- c("PID")
names(data2015_4)[1] <- c("PID")
```

## 6) Rbind the Data & Saving Data
```{r}
train <- rbind(data2011_4, data2012_4, data2013_4, data2014_4)
test <- data2015_4

write.csv(train, "train.csv", row.names = FALSE)
write.csv(test, "test.csv", row.names = FALSE)
```

# 3. Logistic Regression(Satisfaction)
## 1) Data Import
```{r}
train <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/individual_2/train.csv")
test <- read.csv("C:/Users/YU.LEE/Desktop/KNTS/Database/Refined/individual_2/test.csv")

KNTS <- rbind(train, test)
KNTS_1 <- KNTS %>%
  select(PID, q12_1.1, q12_2.1, q12_3.1, q12_5.1, q12_6.1, q12_7.1, q12_8.1, q12_9.1, 
         q12_10.1, q12_11.1, q12_12.1, q6_6.1.1, q6_7, q6_8)
```

## 2) Logistic Regression Model
```{r}
logit_KNTS_1 <- glm(q6_7 ~ q12_1.1 + q12_2.1 + q12_3.1 + q12_5.1 + q12_6.1 + q12_7.1 +
                  q12_8.1 + q12_9.1 + q12_10.1 + q12_11.1 + q12_12.1, + q6_6.1.1,
                  data = KNTS_1, family = "binomial")
summary(logit_KNTS_1)
```

```{r}
logit_KNTS_2 <- glm(q6_8 ~ q12_1.1 + q12_2.1 + q12_3.1 + q12_5.1 + q12_6.1 + q12_7.1 +
                  q12_8.1 + q12_9.1 + q12_10.1 + q12_11.1 + q12_12.1, + q6_6.1.1,
                  data = KNTS_1, family = "binomial")
summary(logit_KNTS_2)
```

```{r}
lm_KNTS <- lm(q6_6.1.1 ~ q12_1.1 + q12_2.1 + q12_3.1 + q12_5.1 + q12_6.1 + q12_7.1 +
              q12_8.1 + q12_9.1 + q12_10.1 + q12_11.1 + q12_12.1, data = KNTS_1)
summary(lm_KNTS)
```

```{r}
lm_KNTS_2 <- lm(q6_7 ~ q6_6.1.1, data = KNTS_1)
summary(lm_KNTS_2)
```

```{r}
lm_KNTS_3 <- lm(q6_8 ~ q6_6.1.1, data = KNTS_1)
summary(lm_KNTS_3)
```

# 4. Logistic Regression(Machine Learning)
## 1) Data Import
```{r}
train <- read.csv("D:/Data/KNTS/Database/Refined/individual_2/train.csv")
test <- read.csv("D:/Data/KNTS/Database/Refined/individual_2/test.csv")

train_1 <- train %>%
  select(PID, sido, ara_size, sex, age, income2, month.1, q1.1, q3.1, q4_a.1, q7_c.1, q10.1,
         q6_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7)
test_1 <- test %>%
  select(PID, sido, ara_size, sex, age, income2, month.1, q1.1, q3.1, q4_a.1, q7_c.1, q10.1,
         q6_1.1.1, q6_2_a.1.1, q6_3.1.1, q6_6.1.1, q6_7)

train_1 <- train_1 %>%
  filter(q6_1.1.1 != 929)
test_1 <- test_1 %>%
  filter(q6_1.1.1 != 929)

head(train_1)
str(train_1)
summary(train_1)
```

## 2) Data Exploration
### 2-1) Column EXplanation
```{r}
names(train_1)
unique(train_1$sido)
unique(train_1$ara_size)
unique(train_1$sex)
unique(train_1$age)
unique(train_1$month.1)
unique(train_1$q1.1)
unique(train_1$q3.1)
unique(train_1$q4_a.1)
unique(train_1$q10.1)
unique(train_1$q6_1.1.1)
unique(train_1$q6_1_1.1.1)
unique(train_1$q6_2_a.1.1)
unique(train_1$q6_3.1.1)
```

### 2-2) Visualization
#### 1) Sido
```{r}
train_1$sido <- as.factor(train_1$sido)
levels(train_1$sido) <- c("Seoul", "Busan", "Daegu", "Incheon", "Gwangju", "Daejeon", "Ulsan",
                          "Gyeonggi", "Gangwon", "Chungbuk", "Chungnam", "Jeonbuk", "Jeonnam",
                          "Gyeonbuk", "Gyeongnam", "Jeju")
test_1$sido <- as.factor(test_1$sido)
levels(test_1$sido) <- c("Seoul", "Busan", "Daegu", "Incheon", "Gwangju", "Daejeon", "Ulsan",
                          "Gyeonggi", "Gangwon", "Chungbuk", "Chungnam", "Jeonbuk", "Jeonnam",
                          "Gyeonbuk", "Gyeongnam", "Jeju")

train_1 %>%
  group_by(sido) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = sido, y = count, fill = sido)) +
  geom_col() + xlab("Sido") +
  scale_fill_discrete(name = "Sido") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))

train_1 %>%
  group_by(sido, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = reorder(sido, rate), y = rate, fill = rate)) +
  geom_col() + xlab("sido") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))
```

#### 2) Area Size / Sex
```{r}
train_1$ara_size <- as.factor(train_1$ara_size)
levels(train_1$ara_size) <- c("B_City", "M&S_City", "Village")
train_1$sex <- as.factor(train_1$sex)
levels(train_1$sex) <- c("Male", "Female")

train_1 %>%
  group_by(ara_size) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = ara_size, y = count, fill = ara_size)) +
  geom_col() + xlab("Area Size") +
  scale_fill_discrete(name = "Area Size") -> g1

train_1 %>%
  group_by(sex) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = sex, y = count, fill = sex)) +
  geom_col() -> g2

grid.arrange(g1, g2, ncol = 2)

train_1 %>%
  group_by(ara_size, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = factor(ara_size), y = rate, fill = rate)) +
  geom_col() + xlab("area size") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> g3

train_1 %>%
  group_by(sex, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = factor(sex), y = rate, fill = rate)) +
  geom_col() + xlab("Sex") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> g4

grid.arrange(g3, g4, ncol = 2)
```

#### 3) Age
```{r}
train_1 %>%
  mutate(age_category = factor(round(age, -1))) %>%
  group_by(age_category, q6_7) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = age_category, y = count, fill = age_category)) +
  geom_col() + xlab("Age") +
  scale_fill_discrete(name = "Age")

train_1 %>%
  mutate(age_category = factor(round(age, -1))) %>%
  group_by(age_category, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = age_category, y = rate, fill = rate)) +
  geom_col() + xlab("Age") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1")
```

#### 4) Income
```{r}
train_1 %>%
  group_by(income2, q6_7) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = income2, y = count)) +
  geom_point(shape = 21)

train_1 %>%
  group_by(income2, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = income2, y = rate, color = rate)) +
  geom_point(shape = 21) + geom_line() +
  scale_color_gradient(low = "deepskyblue1", high = "indianred1")
```

#### 5) Month
```{r}
train_1 %>%
  group_by(month.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = factor(month.1), y = count, fill = factor(month.1))) +
  geom_col() + xlab("Month") +
  scale_fill_discrete(name = "Month")

train_1 %>%
  group_by(month.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = factor(month.1), y = rate, fill = rate)) +
  geom_col() + xlab("Month") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1")
```

#### 6) A Day Trip or Overnight / Purpose of Travel
```{r}
train_1$q1.1 <- as.factor(train_1$q1.1)
levels(train_1$q1.1) <- c("A Day", "Overnight")
train_1$q3.1 <- as.factor(train_1$q3.1)
levels(train_1$q3.1) <- c("L_R_V", "Treatment", "Religion")

train_1 %>%
  group_by(q1.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q1.1, y = count, fill = q1.1)) +
  geom_col() + xlab("Trip") +
  scale_fill_discrete(name = "Trip") -> a1

train_1 %>%
  group_by(q3.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q3.1, y = count, fill = q3.1)) +
  geom_col() + xlab("Purpose") +
  scale_fill_discrete(name = "Purpose") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1)) -> a2

grid.arrange(a1, a2, ncol = 2)

train_1 %>%
  group_by(q1.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q1.1, y = rate, fill = rate)) +
  geom_col() + xlab("Trip") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> a3

train_1 %>%
  group_by(q3.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q3.1, y = rate, fill = rate)) +
  geom_col() + xlab("Purpose") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> a4

grid.arrange(a3, a4, ncol = 2)
```

#### 7) Information about Travel
```{r}
train_1$q4_a.1 <- as.factor(train_1$q4_a.1)
levels(train_1$q4_a.1) <- c("Travel Agency", "Family", "Friend", "Internet", "Book", 
                            "News or TV Program", "Advertising", "Experience", "App",
                            "the others")

train_1 %>%
  group_by(q4_a.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q4_a.1, y = count, fill = q4_a.1)) +
  geom_col() + xlab("Information") +
  scale_fill_discrete(name = "Information") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))

train_1 %>%
  group_by(q4_a.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q4_a.1, y = rate, fill = rate)) +
  geom_col() + xlab("Information") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))
```


#### 8) Total Cost
```{r}
train_1 %>%
  group_by(q7_c.1, q6_7) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q7_c.1, y = count)) +
  geom_point(shape = 21)

train_1 %>%
  group_by(q7_c.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q7_c.1, y = rate, color = rate)) +
  geom_point(shape = 21) + geom_line() +
  scale_color_gradient(low = "deepskyblue1", high = "indianred1")
```

#### 9) Package Travel
```{r}
train_1$q10.1 <- as.factor(train_1$q10.1)
levels(train_1$q10.1) <- c("Yes", "No")

train_1 %>%
  group_by(q10.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q10.1, y = count, fill = q10.1)) +
  geom_col() + xlab("Package") +
  scale_fill_discrete(name = "Package") -> b1

train_1 %>%
  group_by(q10.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q10.1, y = rate, fill = rate)) +
  geom_col() + xlab("Package") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> b2

grid.arrange(b1, b2, ncol = 2)
```

#### 10) Destination(Sido)
```{r}
train_1$q6_1.1.1 <- as.factor(train_1$q6_1.1.1)
levels(train_1$q6_1.1.1) <- c("Seoul", "Busan", "Daegu", "Incheon", "Gwangju", "Daejeon", 
                              "Ulsan", "Gyeonggi", "Gangwon", "Chungbuk", "Chungnam", 
                              "Jeonbuk", "Jeonnam", "Gyeonbuk", "Gyeongnam", "Jeju")
test_1$q6_1.1.1 <- as.factor(test_1$q6_1.1.1)
levels(test_1$q6_1.1.1) <- c("Seoul", "Busan", "Daegu", "Incheon", "Gwangju", "Daejeon", 
                              "Ulsan", "Gyeonggi", "Gangwon", "Chungbuk", "Chungnam", 
                              "Jeonbuk", "Jeonnam", "Gyeonbuk", "Gyeongnam", "Jeju")



train_1 %>%
  group_by(q6_1.1.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q6_1.1.1, y = count, fill = q6_1.1.1)) +
  geom_col() + xlab("Destination") +
  scale_fill_discrete(name = "Destinaion") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))

train_1 %>%
  group_by(q6_1.1.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = reorder(q6_1.1.1, rate), y = rate, fill = rate)) +
  geom_col() + xlab("Destination") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))
```

#### 11) Reason for Selection
```{r}
train_1$q6_2_a.1.1 <- as.factor(train_1$q6_2_a.1.1)
levels(train_1$q6_2_a.1.1) <- c("Awareness", "Attraction", "Cheap Cost", "Distance", 
                                "Limited Time", "Accommodation", "Companion Type", "Shopping", 
                                "Food", "Transportation", "Experience Program",
                                "Recommendation", "Convenient Facilitiy", "Education", 
                                "the others")

train_1 %>%
  group_by(q6_2_a.1.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q6_2_a.1.1, y = count, fill = q6_2_a.1.1)) +
  geom_col() + xlab("Reason") +
  scale_fill_discrete(name = "Reason") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))

train_1 %>%
  group_by(q6_2_a.1.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q6_2_a.1.1, y = rate, fill = rate)) +
  geom_col() + xlab("Reason") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))
```

#### 12) Transportaion
```{r}
train_1$q6_3.1.1 <- as.factor(train_1$q6_3.1.1)
levels(train_1$q6_3.1.1) <- c("Car", "Train", "Flight", "Ship", "Subway", "Regular Bus", 
                              "Irregular Bus", "Rent", "Bicycle", "the others")

train_1 %>%
  group_by(q6_3.1.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = q6_3.1.1, y = count, fill = q6_3.1.1)) +
  geom_col() + xlab("Transportation") +
  scale_fill_discrete(name = "Transportation") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))

train_1 %>%
  group_by(q6_3.1.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = q6_3.1.1, y = rate, fill = rate)) +
  geom_col() + xlab("Transportation") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") +
  theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1, hjust = 1))
```

#### 13) Satisfaction
```{r}
train_1 %>%
  group_by(q6_6.1.1) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = factor(q6_6.1.1), y = count, fill = factor(q6_6.1.1))) +
  geom_col() + xlab("Satisfaction") +
  scale_fill_discrete(name = "Satisfaction") -> c1

train_1 %>%
  group_by(q6_6.1.1, q6_7) %>%
  summarise(count = n()) %>%
  mutate(rate = count / sum(count)) %>%
  filter(q6_7 == 1) %>%
  ggplot(aes(x = factor(q6_6.1.1), y = rate, fill = rate)) +
  geom_col() + xlab("Satisfaction") +
  scale_fill_gradient(low = "deepskyblue1", high = "indianred1") -> c2

grid.arrange(c1, c2, ncol = 2)
```

## 3) BenchMark Model
### 3-1) Modeling
```{r}
train_1$sido <- as.factor(train_1$sido)
train_1$ara_size <- as.factor(train_1$ara_size)
train_1$sex <- as.factor(train_1$sex)
train_1$sido <- as.factor(train_1$sido)
train_1$q1.1 <- as.factor(train_1$q1.1)
train_1$q3.1 <- as.factor(train_1$q3.1)
train_1$q4_a.1 <- as.factor(train_1$q4_a.1)
train_1$q10.1 <- as.factor(train_1$q10.1)
train_1$q6_1.1.1 <- as.factor(train_1$q6_1.1.1)
train_1$q6_2_a.1.1 <- as.factor(train_1$q6_2_a.1.1)
train_1$q6_3.1.1 <- as.factor(train_1$q6_3.1.1)

test_1$sido <- as.factor(test_1$sido)
test_1$ara_size <- as.factor(test_1$ara_size)
test_1$sex <- as.factor(test_1$sex)
test_1$sido <- as.factor(test_1$sido)
test_1$q1.1 <- as.factor(test_1$q1.1)
test_1$q3.1 <- as.factor(test_1$q3.1)
test_1$q4_a.1 <- as.factor(test_1$q4_a.1)
test_1$q10.1 <- as.factor(test_1$q10.1)
test_1$q6_1.1.1 <- as.factor(test_1$q6_1.1.1)
test_1$q6_2_a.1.1 <- as.factor(test_1$q6_2_a.1.1)
test_1$q6_3.1.1 <- as.factor(test_1$q6_3.1.1)

train_1 <- na.omit(train_1)
test_1 <- na.omit(test_1)

logit_benchmark <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                       q4_a.1 + q7_c.1 + q6_1.1.1 + q6_2_a.1.1 + q6_3.1.1 
                       + q6_6.1.1, data = train_1, family = "binomial")
summary(logit_benchmark)
```

### 3-2) BenchMark Model Evaluation(MUlti Logloss)
```{r}
MultiLogLoss <- function(act, pred) {
    if(length(pred) != length(act))
        stop("The length of two vectors are different")
    
    eps <- 1e-15
    pred <- pmin(pmax(pred, eps), 1 - eps)
    sum(act * log(pred) + (1 - act) * log(1 - pred)) * -1/NROW(act)
}
benchmark_pred <- predict(logit_benchmark, test_1, type = "response")

MultiLogLoss(test_1$q6_7, benchmark_pred)
MLL <- MultiLogLoss(test_1$q6_7, benchmark_pred)
```

### 3-3) BenchMark Model Evaluation(Accuracy)
```{r}
benchmark_binary <- ifelse(benchmark_pred > 0.5, 1, 0)
confusionMatrix(benchmark_binary, test_1$q6_7, positive = "1")
cfm <- confusionMatrix(benchmark_binary, test_1$q6_7, positive = "1")
cfm <- cfm$byClass[[11]]
```

## 4) Feature Engineering
```{r}
FeatureEngineering <- function(data){
  data %>%
    mutate(q4_a.1 = ifelse(q4_a.1 == 2 | q4_a.1 == 3, 1,
                           ifelse(q4_a.1 == 8, 2,
                                  ifelse(q4_a.1 == 1 | q4_a.1 == 4 | q4_a.1 == 5 | q4_a.1 == 6 |
                                         q4_a.1 == 7 | q4_a.1 == 9, 3,
                                         ifelse(q4_a.1 == 10, 4, NA))))) %>%
    mutate(q6_2_a.1.1 = ifelse(q6_2_a.1.1 == 1, 1,
                               ifelse(q6_2_a.1.1 == 3 | q6_2_a.1.1 == 4 | q6_2_a.1.1 == 5, 2,
                                      ifelse(q6_2_a.1.1 == 2 | q6_2_a.1.1 == 6 
                                             | q6_2_a.1.1 == 8 | q6_2_a.1.1 == 9
                                             | q6_2_a.1.1 == 10 | q6_2_a.1.1 == 11
                                             | q6_2_a.1.1 == 13, 3,
                                             ifelse(q6_2_a.1.1 == 7 | q6_2_a.1.1 == 12
                                                    | q6_2_a.1.1 == 14 | q6_2_a.1.1 == 15, 
                                                    4, NA))))) %>%
    mutate(q6_3.1.1 = ifelse(q6_3.1.1 == 1 | q6_3.1.1 == 7 | q6_3.1.1 == 8 | q6_3.1.1 == 9, 1,
                             ifelse(q6_3.1.1 == 2 | q6_3.1.1 == 3 | q6_3.1.1 == 4
                                    | q6_3.1.1 == 5 | q6_3.1.1 == 6, 2,
                                    ifelse(q6_3.1.1 == 10, 3, NA))))
}

train_2 <- FeatureEngineering(train_1)
test_2 <- FeatureEngineering(test_1)

train_2$q4_a.1 <- as.factor(train_2$q4_a.1)
train_2$q6_3.1.1 <- as.factor(train_2$q6_3.1.1)
train_2$q6_2_a.1.1 <- as.factor(train_2$q6_2_a.1.1)

test_2$q4_a.1 <- as.factor(test_2$q4_a.1)
test_2$q6_3.1.1 <- as.factor(test_2$q6_3.1.1)
test_2$q6_2_a.1.1 <- as.factor(test_2$q6_2_a.1.1)
```

### 4-1) 911
```{r}
train_911 <- train_2 %>%
  filter(q6_1.1.1 == 911)
test_911 <- test_2 %>%
  filter(q6_1.1.1 == 911)

logit_911 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_911, family = "binomial")

summary(logit_911)

pred_911 <- predict(logit_911, test_911, type = "response")

predd_911 <- data.frame(PID = test_911$PID, q6_7 = pred_911)

MultiLogLoss(test_911$q6_7, pred_911)
MLL_911 <- MultiLogLoss(test_911$q6_7, pred_911)

binary_911 <- ifelse(pred_911 > 0.5, 1, 0)
confusionMatrix(binary_911, test_911$q6_7, positive = "1")
cfm_911 <- confusionMatrix(binary_911, test_911$q6_7, positive = "1")
cfm_911 <- cfm_911$byClass[[11]]
```

### 4-2) 921
```{r}
train_921 <- train_2 %>%
  filter(q6_1.1.1 == 921)
test_921 <- test_2 %>%
  filter(q6_1.1.1 == 921)

logit_921 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_921, family = "binomial")

summary(logit_921)

pred_921 <- predict(logit_921, test_921, type = "response")

predd_921 <- data.frame(PID = test_921$PID, q6_7 = pred_921)

MultiLogLoss(test_921$q6_7, pred_921)
MLL_921 <- MultiLogLoss(test_921$q6_7, pred_921)

binary_921 <- ifelse(pred_921 > 0.5, 1, 0)
confusionMatrix(binary_921, test_921$q6_7, positive = "1")
cfm_921 <- confusionMatrix(binary_921, test_921$q6_7, positive = "1")
cfm_921 <- cfm_921$byClass[[11]]
```

### 4-3) 922
```{r}
train_922 <- train_2 %>%
  filter(q6_1.1.1 == 922)
test_922 <- test_2 %>%
  filter(q6_1.1.1 == 922)

logit_922 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_922, family = "binomial")

summary(logit_922)

pred_922 <- predict(logit_922, test_922, type = "response")

predd_922 <- data.frame(PID = test_922$PID, q6_7 = pred_922)

MultiLogLoss(test_922$q6_7, pred_922)
MLL_922 <- MultiLogLoss(test_922$q6_7, pred_922)

binary_922 <- ifelse(pred_922 > 0.5, 1, 0)
confusionMatrix(binary_922, test_922$q6_7, positive = "1")
cfm_922 <- confusionMatrix(binary_922, test_922$q6_7, positive = "1")
cfm_922 <- cfm_922$byClass[[11]]
```

### 4-4) 923
```{r}
train_923 <- train_2 %>%
  filter(q6_1.1.1 == 923)
test_923 <- test_2 %>%
  filter(q6_1.1.1 == 923)

logit_923 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q10.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_923, family = "binomial")

summary(logit_923)

pred_923 <- predict(logit_923, test_923, type = "response")

predd_923 <- data.frame(PID = test_923$PID, q6_7 = pred_923)

MultiLogLoss(test_923$q6_7, pred_923)
MLL_923 <- MultiLogLoss(test_923$q6_7, pred_923)

binary_923 <- ifelse(pred_923 > 0.5, 1, 0)
confusionMatrix(binary_923, test_923$q6_7, positive = "1")
cfm_923 <- confusionMatrix(binary_923, test_923$q6_7, positive = "1")
cfm_923 <- cfm_923$byClass[[11]]
```

### 4-5) 924
```{r}
train_924 <- train_2 %>%
  filter(q6_1.1.1 == 924)
test_924 <- test_2 %>%
  filter(q6_1.1.1 == 924)

# sido x
logit_924 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_924, family = "binomial")

summary(logit_924)

pred_924 <- predict(logit_924, test_924, type = "response")

predd_924 <- data.frame(PID = test_924$PID, q6_7 = pred_924)

MultiLogLoss(test_924$q6_7, pred_924)
MLL_924 <- MultiLogLoss(test_924$q6_7, pred_924)

binary_924 <- ifelse(pred_924 > 0.5, 1, 0)
confusionMatrix(binary_924, test_924$q6_7, positive = "1")
cfm_924 <- confusionMatrix(binary_924, test_924$q6_7, positive = "1")
cfm_924 <- cfm_924$byClass[[11]]
```

### 4-6) 925
```{r}
train_925 <- train_2 %>%
  filter(q6_1.1.1 == 925)
test_925 <- test_2 %>%
  filter(q6_1.1.1 == 925)

logit_925 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_925, family = "binomial")

summary(logit_925)

pred_925 <- predict(logit_925, test_925, type = "response")

predd_925 <- data.frame(PID = test_925$PID, q6_7 = pred_925)

MultiLogLoss(test_925$q6_7, pred_925)
MLL_925 <- MultiLogLoss(test_925$q6_7, pred_925)

binary_925 <- ifelse(pred_925 > 0.5, 1, 0)
confusionMatrix(binary_925, test_925$q6_7, positive = "1")
cfm_925 <- confusionMatrix(binary_925, test_925$q6_7, positive = "1")
cfm_925 <- cfm_925$byClass[[11]]
```

### 4-7) 926
```{r}
train_926 <- train_2 %>%
  filter(q6_1.1.1 == 926)
test_926 <- test_2 %>%
  filter(q6_1.1.1 == 926)

# sido x
logit_926 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_926, family = "binomial")

summary(logit_926)

pred_926 <- predict(logit_926, test_926, type = "response")

predd_926 <- data.frame(PID = test_926$PID, q6_7 = pred_926)

MultiLogLoss(test_926$q6_7, pred_926)
MLL_926 <- MultiLogLoss(test_926$q6_7, pred_926)

binary_926 <- ifelse(pred_926 > 0.5, 1, 0)
confusionMatrix(binary_926, test_926$q6_7, positive = "1")
cfm_926 <- confusionMatrix(binary_926, test_926$q6_7, positive = "1")
cfm_926 <- cfm_926$byClass[[11]]
```

### 4-8) 931
```{r}
train_931 <- train_2 %>%
  filter(q6_1.1.1 == 931)
test_931 <- test_2 %>%
  filter(q6_1.1.1 == 931)

logit_931 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_931, family = "binomial")

summary(logit_931)

pred_931 <- predict(logit_931, test_931, type = "response")

predd_931 <- data.frame(PID = test_931$PID, q6_7 = pred_931)

MultiLogLoss(test_931$q6_7, pred_931)
MLL_931 <- MultiLogLoss(test_931$q6_7, pred_931)

binary_931 <- ifelse(pred_931 > 0.5, 1, 0)
confusionMatrix(binary_931, test_931$q6_7, positive = "1")
cfm_931 <- confusionMatrix(binary_931, test_931$q6_7, positive = "1")
cfm_931 <- cfm_931$byClass[[11]]
```

### 4-9) 932
```{r}
train_932 <- train_2 %>%
  filter(q6_1.1.1 == 932)
test_932 <- test_2 %>%
  filter(q6_1.1.1 == 932)

# q3.1 x
logit_932 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 +  
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_932, family = "binomial")

summary(logit_932)

pred_932 <- predict(logit_932, test_932, type = "response")

predd_932 <- data.frame(PID = test_932$PID, q6_7 = pred_932)

MultiLogLoss(test_932$q6_7, pred_932)
MLL_932 <- MultiLogLoss(test_932$q6_7, pred_932)

binary_932 <- ifelse(pred_932 > 0.5, 1, 0)
confusionMatrix(binary_932, test_932$q6_7, positive = "1")
cfm_932 <- confusionMatrix(binary_932, test_932$q6_7, positive = "1")
cfm_932 <- cfm_932$byClass[[11]]
```

### 4-10) 933
```{r}
train_933 <- train_2 %>%
  filter(q6_1.1.1 == 933)
test_933 <- test_2 %>%
  filter(q6_1.1.1 == 933)

logit_933 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_933, family = "binomial")

summary(logit_933)

pred_933 <- predict(logit_933, test_933, type = "response")

predd_933 <- data.frame(PID = test_933$PID, q6_7 = pred_933)

MultiLogLoss(test_933$q6_7, pred_933)
MLL_933 <- MultiLogLoss(test_933$q6_7, pred_933)

binary_933 <- ifelse(pred_933 > 0.5, 1, 0)
confusionMatrix(binary_933, test_933$q6_7, positive = "1")
cfm_933 <- confusionMatrix(binary_933, test_933$q6_7, positive = "1")
cfm_933 <- cfm_933$byClass[[11]]
```

### 4-11) 934
```{r}
train_934 <- train_2 %>%
  filter(q6_1.1.1 == 934)
test_934 <- test_2 %>%
  filter(q6_1.1.1 == 934)

logit_934 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_934, family = "binomial")

summary(logit_934)

pred_934 <- predict(logit_934, test_934, type = "response")

predd_934 <- data.frame(PID = test_934$PID, q6_7 = pred_934)

MultiLogLoss(test_934$q6_7, pred_934)
MLL_934 <- MultiLogLoss(test_934$q6_7, pred_934)

binary_934 <- ifelse(pred_934 > 0.5, 1, 0)
confusionMatrix(binary_934, test_934$q6_7, positive = "1")
cfm_934 <- confusionMatrix(binary_934, test_934$q6_7, positive = "1")
cfm_934 <- cfm_934$byClass[[11]]
```

### 4-12) 935
```{r}
train_935 <- train_2 %>%
  filter(q6_1.1.1 == 935)
test_935 <- test_2 %>%
  filter(q6_1.1.1 == 935)

logit_935 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_935, family = "binomial")

summary(logit_935)

pred_935 <- predict(logit_935, test_935, type = "response")

predd_935 <- data.frame(PID = test_935$PID, q6_7 = pred_935)

MultiLogLoss(test_935$q6_7, pred_935)
MLL_935 <- MultiLogLoss(test_935$q6_7, pred_935)

binary_935 <- ifelse(pred_935 > 0.5, 1, 0)
confusionMatrix(binary_935, test_935$q6_7, positive = "1")
cfm_935 <- confusionMatrix(binary_935, test_935$q6_7, positive = "1")
cfm_935 <- cfm_935$byClass[[11]]
```

### 4-13) 936
```{r}
train_936 <- train_2 %>%
  filter(q6_1.1.1 == 936)
test_936 <- test_2 %>%
  filter(q6_1.1.1 == 936)

logit_936 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_936, family = "binomial")

summary(logit_936)

pred_936 <- predict(logit_936, test_936, type = "response")

predd_936 <- data.frame(PID = test_936$PID, q6_7 = pred_936)

MultiLogLoss(test_936$q6_7, pred_936)
MLL_936 <- MultiLogLoss(test_936$q6_7, pred_936)

binary_936 <- ifelse(pred_936 > 0.5, 1, 0)
confusionMatrix(binary_936, test_936$q6_7, positive = "1")
cfm_936 <- confusionMatrix(binary_936, test_936$q6_7, positive = "1")
cfm_936 <- cfm_936$byClass[[11]]
```

### 4-14) 937
```{r}
train_937 <- train_2 %>%
  filter(q6_1.1.1 == 937)
test_937 <- test_2 %>%
  filter(q6_1.1.1 == 937)

logit_937 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_937, family = "binomial")

summary(logit_937)

pred_937 <- predict(logit_937, test_937, type = "response")

predd_937 <- data.frame(PID = test_937$PID, q6_7 = pred_937)

MultiLogLoss(test_937$q6_7, pred_937)
MLL_937 <- MultiLogLoss(test_937$q6_7, pred_937)

binary_937 <- ifelse(pred_937 > 0.5, 1, 0)
confusionMatrix(binary_937, test_937$q6_7, positive = "1")
cfm_937 <- confusionMatrix(binary_937, test_937$q6_7, positive = "1")
cfm_937 <- cfm_937$byClass[[11]]
```

### 4-15) 938
```{r}
train_938 <- train_2 %>%
  filter(q6_1.1.1 == 938)
test_938 <- test_2 %>%
  filter(q6_1.1.1 == 938)

logit_938 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_938, family = "binomial")

summary(logit_938)

pred_938 <- predict(logit_938, test_938, type = "response")

predd_938 <- data.frame(PID = test_938$PID, q6_7 = pred_938)

MultiLogLoss(test_938$q6_7, pred_938)
MLL_938 <- MultiLogLoss(test_938$q6_7, pred_938)

binary_938 <- ifelse(pred_938 > 0.5, 1, 0)
confusionMatrix(binary_938, test_938$q6_7, positive = "1")
cfm_938 <- confusionMatrix(binary_938, test_938$q6_7, positive = "1")
cfm_938 <- cfm_938$byClass[[11]]
```

### 4-16) 939
```{r}
train_939 <- train_2 %>%
  filter(q6_1.1.1 == 939)
test_939 <- test_2 %>%
  filter(q6_1.1.1 == 939)

logit_939 <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                   q4_a.1 + q7_c.1 + q6_2_a.1.1 + q6_3.1.1 +
                   q6_6.1.1, data = train_939, family = "binomial")

summary(logit_939)

pred_939 <- predict(logit_939, test_939, type = "response")

predd_939 <- data.frame(PID = test_939$PID, q6_7 = pred_939)

MultiLogLoss(test_939$q6_7, pred_939)
MLL_939 <- MultiLogLoss(test_939$q6_7, pred_939)

binary_939 <- ifelse(pred_939 > 0.5, 1, 0)
confusionMatrix(binary_939, test_939$q6_7, positive = "1")
cfm_939 <- confusionMatrix(binary_939, test_939$q6_7, positive = "1")
cfm_939 <- cfm_939$byClass[[11]]
```

### 4-17) visualization
```{r}
result_df <- data.frame(Destination = factor(c("Korea ","Seoul", "Busan", "Daegu", "Incheon", 
                                        "Gwangju", "Daejeon", "Ulsan", "Gyeonggi", "Gangwon", 
                                        "Chungbuk", "Chungnam", "Jeonbuk", "Jeonnam", 
                                        "Gyeonbuk", "Gyeongnam", "Jeju")),
                        MultiLogLoss = c(MLL, MLL_911, MLL_921, MLL_922, MLL_923, MLL_924,
                                         MLL_925, MLL_926, MLL_931, MLL_932, MLL_933, MLL_934,
                                         MLL_935, MLL_936, MLL_937, MLL_938, MLL_939),
                        BalancedAccuracy = c(cfm, cfm_911, cfm_921, cfm_922, cfm_923, cfm_924,
                                             cfm_925, cfm_926, cfm_931, cfm_932, cfm_933,
                                             cfm_934, cfm_935, cfm_936, cfm_937, cfm_938,
                                             cfm_939))

result_df %>%
  ggplot(aes(x = Destination, y = MultiLogLoss, color = Destination)) +
    geom_line(group = 1, color = "black", alpha = 0.5) +
    geom_point(size = 3) +
    geom_vline(xintercept = 12, linetype = "dashed", alpha = 0.5 ) +
    geom_vline(xintercept = 7, linetype = "dashed", alpha = 0.5 ) +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))

result_df %>%
  ggplot(aes(x = Destination, y = BalancedAccuracy, color = Destination)) +
    geom_line(group = 1, color = "black", alpha = 0.5) +
    geom_point(size = 3) +
    geom_vline(xintercept = 12, linetype = "dashed", alpha = 0.5 ) +
    geom_vline(xintercept = 7, linetype = "dashed", alpha = 0.5 ) +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))
```


## 5) Des_Logit Model Evaluation
```{r}
des_pred <- rbind(predd_911, predd_921, predd_922, predd_923, predd_924, predd_925, predd_926, 
                  predd_931, predd_932, predd_933, predd_934, predd_935, predd_936, predd_937, 
                  predd_938, predd_939)
des_pred_1 <- arrange(des_pred, PID)

MultiLogLoss(test_1$q6_7, des_pred_1$q6_7)
```

```{r}
des_binary <- ifelse(des_pred_1$q6_7 > 0.5, 1, 0)
confusionMatrix(des_binary, test_1$q6_7, positive = "1")
```

## 6) Model Improvment & Evaluation
```{r}
FeatureEngineering2 <- function(data){
  
  data %>%
    mutate(Near = ifelse(sido == q6_1.1.1, 1, 0))
}

train_3 <- FeatureEngineering2(train_2)
test_3 <- FeatureEngineering2(test_2)

train_3$Near <- as.factor(train_3$Near)
test_3$Near <- as.factor(test_3$Near)
```


```{r}
logit_imp <- glm(q6_7 ~ age + income2 + month.1 + q1.1 + q3.1 + 
                       q4_a.1 + q7_c.1 + q6_1.1.1 + q6_2_a.1.1 + q6_3.1.1 
                       + q6_6.1.1 + Near, data = train_3, family = "binomial")
summary(logit_imp)
```

```{r}
imp_pred <- predict(logit_imp, test_3, type = "response")

MultiLogLoss(test_3$q6_7, imp_pred)
```

```{r}
imp_binary <- ifelse(imp_pred > 0.5, 1, 0)
confusionMatrix(imp_binary, test_3$q6_7, positive = "1")
```

