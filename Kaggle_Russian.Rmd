---
title: "Russain Housing Market"
author: "Young Ho Lee"
date: "2017.05.20"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

# Basic Packages
library(ggplot2)
library(dplyr)
library(readr) # install.packages(data.table)
library(xgboost)
library(gridExtra)
library(caret)
library(randomForest)
library(reshape2)
library(stringr)

#setwd
knitr::opts_knit$set(root.dir = "D:/Kaggle/Sberbank_Russian_Housing_Market")
```

# 1.Data Import
```{r}
train <- read.csv("D:/Kaggle/Sberbank_Russian_Housing_Market/train.csv")
test <- read.csv("D:/Kaggle/Sberbank_Russian_Housing_Market/test.csv")
macro <- read.csv("D:/Kaggle/Sberbank_Russian_Housing_Market/macro.csv")

head(train)
str(train)
summary(train)

str(macro)
summary(macro)
# macro_2 <- macro_1[complete.cases(macro_1) == FALSE, ]
```

# 2. Variable Importance
```{r}
#Get complete cases of train
completes <- complete.cases(train)

# Set training control so that we only 1 run forest on the entire set of complete cases
trControl <- trainControl(method='none')

# Run random forest on complete cases of train. Exclude incineration_raion since it
# only has 1 factor level
set.seed(1234)
rfmod <- train(price_doc ~ . - id - timestamp - incineration_raion,
               method='rf',
               data = train[completes, ],
               trControl = trControl,
               tuneLength = 1,
               importance = TRUE)

varImp(rfmod)

varImp_value <- varImp(rfmod)
varImp_value[1]
ggplot(varImp_value, top = 35, mapping = aes(y = Importance))
```

# 3. Data Exploration
## 1) Column Explantion
```{r}
unique(train$full_sq)
unique(train$life_sq)
unique(train$state)
unique(train$sub_area)
```


## 2) Visualization
### 2-1) Price_doc
```{r}
train %>%
  ggplot(aes(x = price_doc)) + geom_density() -> g1

train %>%
  ggplot(aes(x =  log(price_doc)))  + geom_density() -> g2

grid.arrange(g1, g2)
```

### 2-2) Life Square
```{r}
train %>%
  na.omit(train_2) %>%
  filter(life_sq <= 300) %>%
  filter(full_sq <= 300) %>%
  ggplot(aes(x = life_sq, y = full_sq, color = factor(num_room))) +
  geom_point() +
  scale_color_discrete(name = "num_room")
```

```{r}
train %>%
  na.omit(train) %>%
  filter(life_sq <= 250) %>%
  ggplot(aes(x = factor(num_room), y = life_sq, fill = factor(num_room))) +
  geom_boxplot() + xlab("num_room") +
  scale_fill_discrete(name = "num_room")

train %>%
  na.omit(train$num_room) %>%
  group_by(num_room) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = factor(num_room), y = count, fill = factor(num_room))) +
  geom_col()
```

### 2-3) Metro_MIn_Walk
```{r}
train_metro <- train %>%
  select(price_doc, metro_min_avto, metro_km_avto, metro_min_walk, metro_km_walk)
summary(train_metro)

train_metro %>%
  group_by(metro_km_walk) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = metro_km_walk, y = count)) +
  geom_point()
```

```{r}
train_metro %>%
  na.omit(train_metro) %>%
  ggplot(aes(x = metro_min_walk, y = metro_km_walk)) +
  geom_point()
```

```{r}
train_metro %>%
  na.omit(train_metro) %>%
  ggplot(aes(x = metro_min_walk, y = metro_min_avto)) +
  geom_point(shape = 21) +
  geom_line() +
  geom_smooth(method = "lm") -> g1
train_metro %>%
  na.omit(train_metro) %>%
  ggplot(aes(x = metro_min_walk, y = metro_km_avto)) +
  geom_point(shape = 21) +
  geom_line() +
  geom_smooth(method = "lm") -> g2
grid.arrange(g1, g2, ncol = 2)
```


### 2-4) Product Type
```{r}
train %>%
  ggplot(aes(x = product_type, y = log(price_doc), fill = product_type)) +
  geom_jitter(color = 'grey', alpha = .2) +
  geom_violin(alpha = .7)
```

```{r}
train %>%
  ggplot(aes(x = price_doc, color = factor(product_type), 
             fill = factor(product_type), alpha = .3)) +
  geom_density() + ggtitle("Price Doc Density / Product Type") +
  scale_fill_discrete(name = "produnt_type") -> g1
train %>%
  ggplot(aes(x = log(price_doc), color = factor(product_type), 
             fill = factor(product_type), alpha = .3)) +
  geom_density() + ggtitle("Log Price Doc Density / Product Type") +
  scale_fill_discrete(name = "produnt_type") -> g2
grid.arrange(g1, g2, nrow = 2)
```


### 2-5) State
```{r}
train %>%
  na.omit(train_1) %>%
  ggplot(aes(x = factor(state), y = log(price_doc), fill = factor(state))) +
  geom_jitter(color = 'grey', alpha = .2) +
  geom_violin(alpha = .7)

train %>%
  na.omit(train_1) %>%
  filter(build_year <= 2020, build_year >= 1500) %>%
  ggplot(aes(x = factor(state), y = build_year, fill = factor(state))) +
  geom_jitter(color = 'grey', alpha = .2) +
  geom_violin(alpha = .7)
```

```{r}
train %>%
  na.omit(train_1) %>%
  filter(state != "33") %>%
  ggplot(aes(x = factor(state), y = log(price_doc))) +
  geom_jitter(color = 'grey', alpha = .2) +
  geom_violin(fill = 'red', alpha = .7) +
  ggtitle('Log of Median Price by state of Home')
```


### 2-6) Cafe Average Price 1500
```{r}
train_cafe <- train %>%
  select(price_doc, cafe_avg_price_500, cafe_avg_price_1000, cafe_avg_price_1500,
         cafe_avg_price_2000, cafe_avg_price_3000, cafe_avg_price_5000)
summary(train_cafe)
```

```{r}
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_500)) +
  geom_point() -> g1
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_1000)) +
  geom_point() -> g2
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_1500)) +
  geom_point() -> g3
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_2000)) +
  geom_point() -> g4
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_3000)) +
  geom_point() -> g5
train_cafe %>%
  na.omit(train_cafe) %>%
  ggplot(aes(x = cafe_avg_price_1500, y = cafe_avg_price_5000)) +
  geom_point() -> g6
grid.arrange(g1, g2, g3, g4, g5, g6, ncol = 3)
```

### 2-7) Build Year
```{r}
train %>%
  ggplot(aes(x = factor(build_year), y = price_doc, fill = factor(build_year))) +
  geom_boxplot() + guides(fill = FALSE)
```

### 2-8) Culture Object Top 25
```{r}
train %>%
  group_by(culture_objects_top_25) %>%
  summarise(culture_mean = mean(price_doc),
            culture_median = median(price_doc))

train %>%
  select(culture_objects_top_25, price_doc) %>%
  filter(price_doc < 15059329) %>%
  ggplot(aes(x = culture_objects_top_25, y = price_doc, color = culture_objects_top_25)) +
  geom_point(position = "jitter", alpha = 0.1)
```

### 2-9) Total Gender Diff
```{r}
train %>%
    mutate(gender_diff = female_f - male_f,
           total_population = female_f + male_f) %>%
    group_by(sub_area,gender_diff, total_population) %>%
    summarise(Mean = mean(price_doc)) %>%
    ggplot(aes(x = gender_diff, y = Mean, color = sub_area)) +
    geom_point(aes(size = total_population)) +
    theme(legend.position="none")
```

```{r}
train %>%
    ggplot(aes(x = full_all)) +
    geom_density()
train %>%
    mutate(city_size = ifelse(full_all > 500000, "big", "small"),
           gender_diff = female_f - male_f,
           total_population = female_f + male_f) %>%
    group_by(sub_area,gender_diff, total_population, city_size) %>%
    summarise(Mean = mean(price_doc)) %>%
    ggplot(aes(x = gender_diff, y = Mean, color = sub_area)) +
    geom_point(aes(size = total_population)) +
    theme(legend.position="none") +
    facet_grid(~city_size)
```

### 2-10) Young Age
```{r}
train %>%
    mutate(young_gender_diff = young_female - young_male) %>%
    ggplot(aes(x = young_all, y = price_doc, color = young_gender_diff)) +
    geom_boxplot(aes(group = young_all), alpha = 0.5) +
    scale_colour_gradient(low="indianred1", high="deepskyblue1")

train%>%
    mutate(young_gender_diff = young_female - young_male) %>%
    group_by(sub_area, young_gender_diff, young_all) %>%
    summarise(Mean = mean(price_doc)) %>%
    ggplot(aes(x = young_gender_diff, y = Mean, color = sub_area)) +
    geom_point(aes(size = young_all)) +
    theme(legend.position="none")
```


# 4. Data Handling For NA (Test)
## 1) Life Square
```{r}
train %>%
  na.omit(train) %>%
  group_by(num_room) %>%
  summarise(mean = mean(life_sq))
```

```{r}
train[which(is.na(train$life_sq)), ] %>%
  group_by(num_room) %>%
  summarise(count = n())
```

```{r}
train[which(is.na(train$life_sq) & train$num_room == 0), "life_sq"] <- 18.00000
train[which(is.na(train$life_sq) & train$num_room == 1), "life_sq"] <- 21.30000
train[which(is.na(train$life_sq) & train$num_room == 2), "life_sq"] <- 30.79808
train[which(is.na(train$life_sq) & train$num_room == 3), "life_sq"] <- 47.68207
train[which(is.na(train$life_sq) & train$num_room == 4), "life_sq"] <- 68.45556
train[which(is.na(train$life_sq) & train$num_room == 5), "life_sq"] <- 78.17647
train[which(is.na(train$life_sq) & train$num_room == 6), "life_sq"] <- 87.50000
```


```{r}
test[which(is.na(test$life_sq)), ] %>%
  group_by(num_room) %>%
  summarise(count = n())
```

```{r}
test[which(is.na(test$life_sq) & test$num_room == 1), "life_sq"] <- 21.30000
test[which(is.na(test$life_sq) & test$num_room == 2), "life_sq"] <- 30.79808
test[which(is.na(test$life_sq) & test$num_room == 3), "life_sq"] <- 47.68207
test[which(is.na(test$life_sq) & test$num_room == 4), "life_sq"] <- 68.45556
```

### 1-1) TH
```{r}
# check mean value
test %>%
    na.omit(test) %>%
    group_by(num_room) %>%
    summarise(mean = mean(life_sq)) %>%
    ggplot(aes(x = num_room, y = mean, fill = factor(num_room))) +
    geom_col() +
    geom_text(aes(x=num_room,y=mean,label=round(mean,2)),vjust=0)
```

## 2) Metro Min Walk
```{r}
train %>%
  mutate(metro_km_avto_c = cut(metro_km_avto, breaks = seq(0, 75, by = 0.1))) %>%
  group_by(metro_km_avto_c) %>%
  summarise(count = n())
```

```{r}
train %>%
  na.omit(train) %>%
  mutate(metro_km_avto_c = cut(metro_km_avto, breaks = seq(0, 75, by = 0.1))) %>%
  group_by(metro_km_avto_c) %>%
  summarise(mean = mean(metro_min_walk))
```

```{r}
test[which(is.na(test$metro_min_walk)), ] %>%
  mutate(metro_km_avto_c = cut(metro_km_avto, breaks = seq(0, 75, by = 0.1))) %>%
  group_by(metro_km_avto_c) %>%
  summarise(count = n())
```

```{r}
test <- test %>%
  mutate(metro_km_avto_c = cut(metro_km_avto, breaks = seq(0, 75, by = 0.1)))

test[which(is.na(test$metro_min_walk) & test$metro_km_avto_c == "(0.7,0.8]"), "metro_min_walk"] <- 8.8662625
test[which(is.na(test$metro_min_walk) & test$metro_km_avto_c == "(0.8,0.9]"), "metro_min_walk"] <- 9.7551744
test[which(is.na(test$metro_min_walk) & test$metro_km_avto_c == "(3.8,3.9]"), "metro_min_walk"] <- 44.6125428
test[which(is.na(test$metro_min_walk) & test$metro_km_avto_c == "(4.3,4.4]"), "metro_min_walk"] <- 49.6676977
```

### 2-1) TH
```{r}
length(test$metro_min_walk[is.na(test$metro_min_walk) == TRUE]) # 34 NA

test %>% 
    filter(is.na(metro_min_walk) == TRUE) %>%
    select(metro_min_walk, metro_km_walk, metro_km_avto, metro_min_avto)
test %>%
    ggplot(aes(x = metro_min_avto, y = metro_min_walk)) +
    geom_point() +
    geom_smooth(method = "lm")
```

```{r}
# TRAIN
## interpolate metro_min_walk
train$metro_min_walk[is.na(train$metro_min_walk) == TRUE] <- 0.9 * (train$metro_min_avto[is.na(train$metro_min_walk) == TRUE]) 

# TEST
## interpolate metro_min_walk
test$metro_min_walk[is.na(test$metro_min_walk) == TRUE] <- 0.9 * (test$metro_min_avto[is.na(test$metro_min_walk) == TRUE])
```

## 3) Product Type
```{r}
# Number of NA = 33

set.seed(1234)
test$product_type[which(is.na(test$product_type))] <- sample(c("Investment", "OwnerOccupier"))
```

### 3-1) TH
```{r}
length(test$product_type[is.na(test$product_type) == TRUE]) # 33 NA

test %>%
    filter(is.na(state) == FALSE, is.na(product_type) == FALSE) %>%
    group_by(state, product_type) %>%
    dplyr::summarise(count = n()) %>%
    ggplot(aes(x = state, y = count, fill = product_type))+
    geom_col(position = "dodge")

#if both varialble is all NA, just interpolate product_type's mode value
table(test$product_type)
table(test$state)
```

```{r}
# TRAIN
# interpolate product_type
train$product_type[is.na(train$product_type) == TRUE & is.na(train$state) == TRUE] <- "Investment"
train$product_type[is.na(train$product_type) == TRUE & train$state == 1] <- "OwnerOccupier"
train$product_type[is.na(train$product_type) == TRUE & train$state != 1] <- "Investment"

# TEST
# interpolate product_type
test$product_type[is.na(test$product_type) == TRUE & is.na(test$state) == TRUE] <- "Investment"
test$product_type[is.na(test$product_type) == TRUE & test$state == 1] <- "OwnerOccupier"
test$product_type[is.na(test$product_type) == TRUE & test$state != 1] <- "Investment"
```

## 4) State
```{r}
# kernels : Creating some useful additional features
train[which(train$build_year == 20052009), "build_year"] <- 2005
train[which(train$build_year == 0), "build_year"] <- NA
train[which(train$build_year == 1), "build_year"] <- NA
train[which(train$build_year == 3), "build_year"] <- NA
train[which(train$build_year == 71), "build_year"] <- NA
train[which(train$build_year == 4965), "build_year"] <- NA
train[which(train$build_year == 20), "build_year"] <- 2000
train[which(train$build_year == 215), "build_year"] <- 2015

train[which(train$state == 33), "state"] <- 3
```

```{r}
unique(test$build_year)

test[which(test$build_year == 0), "build_year"] <- NA
test[which(test$build_year == 1), "build_year"] <- NA
test[which(test$build_year == 2), "build_year"] <- NA
test[which(test$build_year == 215), "build_year"] <- 2015
```

### 4-1) TH
```{r}
length(test$state[is.na(test$state) == TRUE]) # 694 NA

test %>%
    filter(build_year > 500) %>%
    group_by(build_year, state, product_type) %>%
    dplyr::summarise(count = n()) %>%
    ggplot(aes(x = build_year, y = count, fill = factor(state)))+
    geom_col(position = "dodge") +
    facet_wrap(~state)

test %>%
    filter(build_year > 500,
           is.na(state) == TRUE) %>%
    group_by(state, product_type, build_year) %>%
    dplyr::summarise(count = n()) %>%
    ggplot(aes(x = build_year, y = count, fill = product_type))+
    geom_col() +
    facet_grid(~product_type)

test %>%
    filter(build_year > 500) %>%
    group_by(state, product_type) %>%
    dplyr::summarise(count = n()) %>%
    ggplot(aes(x = state, y = count, fill = product_type))+
    geom_col() +
    facet_grid(~product_type)
```

```{r}
# TRAIN
## interpolate state
train$state[is.na(train$state) == TRUE & train$product_type == "OwnerOccupier"] <- 1
train$state[is.na(train$state) == TRUE & train$product_type == "Investment" & train$build_year >= 1960 & train$build_year <= 1980] <- 2 
train$state[is.na(train$state) == TRUE & train$product_type == "Investment" & train$build_year < 1960] <- 3   
train$state[is.na(train$state) == TRUE & train$product_type == "Investment" & train$build_year > 1980] <- 3 

# TEST
## interpolate state
test$state[is.na(test$state) == TRUE & test$product_type == "OwnerOccupier"] <- 1
test$state[is.na(test$state) == TRUE & test$product_type == "Investment" & test$build_year >= 1960 & test$build_year <= 1980] <- 2 
test$state[is.na(test$state) == TRUE & test$product_type == "Investment" & test$build_year < 1960] <- 3   
test$state[is.na(test$state) == TRUE & test$product_type == "Investment" & test$build_year > 1980] <- 3 

length(test$state[is.na(test$state) == TRUE])

test$state[is.na(test$state) == TRUE] <- 2
```


## 5) Cafe Average Price 1500
```{r}
train %>%
  mutate(cafe_avg_price_5000_c = cut(cafe_avg_price_5000, breaks = seq(399, 2499, by = 100))) %>%
  group_by(cafe_avg_price_5000_c) %>%
  summarise(count = n())
```

```{r}
train[which(!is.na(train$cafe_avg_price_1500)), ] %>%
  mutate(cafe_avg_price_5000_c = cut(cafe_avg_price_5000, breaks = seq(399, 2499, by = 100))) %>%
  group_by(cafe_avg_price_5000_c) %>%
  summarise(mean = mean(cafe_avg_price_1500))
```

```{r}
test[which(is.na(test$cafe_avg_price_1500)), ] %>%
  mutate(cafe_avg_price_5000_c = cut(cafe_avg_price_5000, breaks = seq(399, 2449, by = 100))) %>%
  group_by(cafe_avg_price_5000_c) %>%
  summarise(count = n())
```

```{r}
# Train Interpolation
train <- train %>%
  mutate(cafe_avg_price_5000_c = cut(cafe_avg_price_5000, breaks = seq(399, 2449, by = 100)))

cafeavgp5000_value <- unique(train$cafe_avg_price_5000_c[is.na(train$cafe_avg_price_1500) == TRUE])
cafe_DF <- train[which(!is.na(train$cafe_avg_price_1500)), ] %>%
  group_by(cafe_avg_price_5000_c) %>%
  summarise(mean1500 = mean(cafe_avg_price_1500))
  
for(i in cafe_DF$cafe_avg_price_5000_c){
  if(i %in% cafeavgp5000_value == TRUE){
    train$cafe_avg_price_1500[is.na(train$cafe_avg_price_1500) == TRUE & train$cafe_avg_price_5000_c == i] <- cafe_DF$mean1500[cafe_DF$cafe_avg_price_5000_c == i]
  }
}

# Test Interpolation
test <- test %>%
  mutate(cafe_avg_price_5000_c = cut(cafe_avg_price_5000, breaks = seq(399, 2449, by = 100)))

cafeavgp5000_value <- unique(test$cafe_avg_price_5000_c[is.na(test$cafe_avg_price_1500) == TRUE])
cafe_DF <- test[which(!is.na(test$cafe_avg_price_1500)), ] %>%
  group_by(cafe_avg_price_5000_c) %>%
  summarise(mean1500 = mean(cafe_avg_price_1500))
  
for(i in cafe_DF$cafe_avg_price_5000_c){
  if(i %in% cafeavgp5000_value == TRUE){
    test$cafe_avg_price_1500[is.na(test$cafe_avg_price_1500) == TRUE & test$cafe_avg_price_5000_c == i] <- cafe_DF$mean1500[cafe_DF$cafe_avg_price_5000_c == i]
  }
}
test[which(is.na(test$cafe_avg_price_1500)), "cafe_avg_price_1500"] <- mean(train$cafe_avg_price_1500, na.rm = TRUE)
```

## 6) Build Year
```{r}
train %>%
  na.omit(train) %>%
  group_by(state) %>%
  summarise(mean = mean(build_year))
```

```{r}
train[which(is.na(train$build_year)), ] %>%
  group_by(state) %>%
  summarise(count = n())
```

```{r}
train[which(is.na(train$build_year) & train$state == 1), "build_year"] <- 2008
train[which(is.na(train$build_year) & train$state == 2), "build_year"] <- 1971
train[which(is.na(train$build_year) & train$state == 3), "build_year"] <- 1977
train[which(is.na(train$build_year) & train$state == 4), "build_year"] <- 1985
```


```{r}
test[which(is.na(test$build_year)), ] %>%
  group_by(state) %>%
  summarise(count = n())
```

```{r}
test[which(is.na(test$build_year) & test$state == 1), "build_year"] <- 2008
test[which(is.na(test$build_year) & test$state == 2), "build_year"] <- 1972
test[which(is.na(test$build_year) & test$state == 3), "build_year"] <- 1985
test[which(is.na(test$build_year) & is.na(test$state)), "build_year"] <- mean(train$build_year, na.rm = TRUE)
```

### 6-1) TH
```{r}
length(test$build_year[is.na(test$build_year) == TRUE]) # 1049 NA
length(unique(test$max_floor[is.na(test$build_year) == TRUE])) # there is 28 kind of value at max_floor which build year is NA

# Visulize the relation with maxfloor and build_year
test %>%
    filter(build_year > 1900) %>%
    group_by(max_floor) %>%
    dplyr::summarise(year_mean = round(mean(build_year)),
              year_median = round(median(build_year))) %>%
    melt(id.vars = "max_floor",
         value.name = "year") %>%
    ggplot(aes(x = year, y = max_floor, color = variable)) +
    geom_point() +
    geom_line(stat = "identity")
head(HM_test)
```

```{r}
# TRAIN
## making interpolation source : maxfloor_value, build_DF
maxfloor_value <- unique(train$max_floor[is.na(train$build_year) == TRUE]) # target
train %>%
    filter(build_year > 1900) %>%
    group_by(max_floor)%>%
    dplyr::summarise(year_mean = round(mean(build_year)),
              year_median = round(median(build_year)),
              diff = abs(year_median - year_mean),
              year = round((year_mean + year_median)/2)) -> build_DF #interpolation source
build_DF <- build_DF[ ,c("max_floor", "year")]
# Q. grep(i, build_DF$max_floor)

## interpolate_train
for(i in build_DF$max_floor){
    if(i %in% maxfloor_value == TRUE){
        train$build_year[is.na(train$build_year) == TRUE & train$max_floor == i] <- build_DF$year[build_DF$max_floor == i]
    }
}

# TEST
## making interpolation source : maxfloor_value, build_DF
maxfloor_value <- unique(test$max_floor[is.na(test$build_year) == TRUE]) # target
test %>%
    filter(build_year > 1900) %>%
    group_by(max_floor) %>%
    summarise(year_mean = round(mean(build_year)),
              year_median = round(median(build_year)),
              diff = abs(year_median - year_mean),
              year = round((year_mean + year_median)/2)) -> build_DF #interpolation source
build_DF <- build_DF[,c("max_floor", "year")]
# Q. grep(i, build_DF$max_floor)

# interpolate_test
for(i in build_DF$max_floor){
    if(i %in% maxfloor_value == TRUE){
        test$build_year[is.na(test$build_year) == TRUE & test$max_floor == i] <- build_DF$year[build_DF$max_floor == i]
    }
}

# check    
test%>%
    filter(is.na(build_year) == TRUE)
```

# 5. Feature Selection
```{r}
train_2 <- train[, c("price_doc", "id", "timestamp","full_sq", "life_sq", "num_room", "kitch_sq","build_year", "max_floor", "product_type", "state", "ts_km", "big_road2_km", "park_km", "preschool_km", "floor", "cemetery_km", "stadium_km", "university_km", "big_market_km", "railroad_km", "power_transmission_line_km", "prom_part_1500", "green_part_500", "nuclear_reactor_km", "metro_min_walk", "cafe_avg_price_1500", "green_part_500", "railroad_station_avto_min", "office_count_1500", "detention_facility_km", "water_km", "museum_km", "sub_area", "university_top_20_raion")]
test_2 <- test[, c("id", "timestamp","full_sq", "life_sq", "num_room", "kitch_sq","build_year", "max_floor", "product_type", "state", "ts_km", "big_road2_km", "park_km", "preschool_km", "floor", "cemetery_km", "stadium_km", "university_km", "big_market_km", "railroad_km", "power_transmission_line_km", "prom_part_1500", "green_part_500", "nuclear_reactor_km", "metro_min_walk", "cafe_avg_price_1500", "green_part_500", "railroad_station_avto_min", "office_count_1500", "detention_facility_km", "water_km", "museum_km", "sub_area", "university_top_20_raion")]

macro_1 <- macro %>%
  select(timestamp, balance_trade_growth, eurrub, average_provision_of_build_contract, micex_rgbi_tr, micex_cbi_tr, mortgage_value, mortgage_rate, rent_price_4.room_bus, balance_trade)
```

(+ total_gender_diff / university_top_20_raion / sub_area)

```{r}
train_2 <- merge(train_1, macro_1, by.x = c("timestamp"), by.y = c("timestamp"))
test_2 <- merge(test_1, macro_1, by.x = c("timestamp"), by.y = c("timestamp"))

summary(train_2)
summary(test_2)
# test_3 <- na.omit(test_2)
```

# 6. Feature Selection For macro
## 6-1) Random Forest
```{r}
train_2[, names(train_2)[c(36:44)]] -> df
df$price_doc <- train_2$price_doc
df <- df[complete.cases(df) == TRUE, ]

set.seed(1234)
trControl <- trainControl(method='none') # Set training control so that we only 1 run forest on the entire set of complete cases

# Run random forest on complete cases of HM_train. Exclude incineration_raion since it
# only has 1 factor level
macro_rfmod <- train(price_doc ~ .,
                     method='rf',
                     data=df,
                     trControl=trControl,
                     tuneLength=1,
                     importance=TRUE)    

varImp_value <- varImp(macro_rfmod)
```

## 6-2) Visualization
```{r}
#MAKE DATA FRAME FOR VISUALLIZATION
# value list
imp_value <- varImp_value[[1]][1]$Overall
# names list
varImp_value[[1]]
var_name <- row.names(varImp_value[[1]])
# DATA FRAME
varImp_df <- data.frame(Var = var_name, Value = imp_value)
```

```{r}
# BASIC PLOT
ggplot(varImp_value, top = 9, mapping = aes(y = Importance))

# ADVANCED PLOT
varImp_df %>%
    arrange(-Value)%>%
    ggplot(aes(x = reorder(Var,-Value), y = Value, fill = Value)) +
    geom_col() +
    theme(legend.position="none",
          axis.text.x = element_text(angle = 45, vjust = 0.3))
```

## 6-3) Select only Important column in Macro
```{r}
# select unimportant column
varImp_df %>%
    arrange(-Value) %>%
    filter(Value < 20) -> varUnImp_name
varUnImp_name <- varUnImp_name[[1]]
varUnImp_name <- as.character(varUnImp_name)
```

```{r}
# remove unimportant column
train_3 <- train_2[, !(names(train_2) %in% varUnImp_name)]
test_3 <- test_2[, !(names(test_2) %in% varUnImp_name)]
```

# 7. Addiing Data column[Year]
```{r}
year_func <- function(data){
    factor(str_split(data, "[-]")[[1]][1])
}
month_func <- function(data){
    factor(stringr::str_split(data, "[-]")[[1]][2])
}

train_2$Year <- NULL
train_2$Year <- sapply(train_2$timestamp, FUN = year_func)
train_2$Month <- NULL
train_2$Month <- sapply(train_2$timestamp, FUN = month_func)

train_2 %>%
  select(timestamp,Year, Month)

test_2$Year <- NULL
test_2$Year <- sapply(test_2$timestamp, FUN = year_func)
test_2$Month <- NULL
test_2$Month <- sapply(test_2$timestamp, FUN = month_func)

test_2 %>%
  select(timestamp,Year, Month)
```


# 8. XGBoost Model
```{r}
test_2$price_doc <- mean(train$price_doc)

train_3 <- train_2 %>%
  select(-id, -timestamp, -Month, -state)
train_3 <- na.omit(train_3)

test_3 <- test_2 %>%
  select(-id, -timestamp, -Month, -state)

trainLabel <- train_3$price_doc
```

```{r}
trainMat <- model.matrix(price_doc ~ ., data = train_3)
testMat <- model.matrix(price_doc ~ ., data = test_3)
```

```{r}
params <- list(eta = 0.3, max.depth = 5,
               gamma = 0, colsample_bytree = 1,
               subsample = 1,
               objective = "reg:linear",
               eval_metric = "rmse")

set.seed(1234)
xgbcv <- xgb.cv(params = params,
                nrounds = 200,
                nfold = 10,
                metrics = "rmse",
                data = trainMat,
                label = trainLabel,  
                verbose = 0)

xgb.best <- arrange(xgbcv$evaluation_log, test_rmse_mean)[1, ] 
xgb.best
```

```{r}
RHM_xgboost <- xgboost(params = params,
                       data = trainMat,
                       label = trainLabel,
                       nrounds = xgb.best$iter,
                       verbose = 1)
```

```{r}
xgb_pred <- predict(RHM_xgboost, testMat)
# xgb_pred <- exp(xgb_pred)
xgb_pred <- ifelse(xgb_pred < 0, 0, xgb_pred)

submission <- data.frame(id = test$id, price_doc = xgb_pred)
submission %>%
    ggplot(aes(x = id, y = price_doc)) +
    geom_point()
write.csv(submission, "submission_11.csv", row.names = FALSE)
```
submission_1(0.36177) : state(x) / (cafe_avg_price_1500, build_year) NA <- mean
submission_2(0.41522) : state(x) / (cafe_avg_price_1500, build_year) NA <- mean 
                       + train : 16365 / log(price)
submission_3(0.35470) : TH's interpolation
submission_4(0.37541) : feature selection for macro by random forest
*submission_5(0.34399) : submission_3 + Year
submission_6(0.36894) : submission_5 + healthcare
submission_7(0.80753) : submission_5 + oil chemistry km
submission_8(0.37066) : submission_5 + hospicem morgue + thermal power plant
submission_9(0.36530) : submission_5 - ("detention_facility_km", "water_km", "museum_km")
submission_10(0.48587) : submission_5 + state
*submission_11(0.34916) : submission_5 - macro
                       
# 9. Linear Regression
```{r}
house_model <- lm(log(price_doc) ~ ., data = train_4)
summary(house_model)
```

```{r}
train_5 <- train_4 %>%
  select(-sub_area, -green_part_500.1)
test_5 <- test_4 %>%
  select(-sub_area, -green_part_500.1)

house_model <- lm(price_doc ~ ., data = train_5)
summary(house_model)
```


```{r}
lm_pred <- predict(house_model, test_5)
lm_pred <- exp(lm_pred)
lm_pred <- ifelse(lm_pred < 0, 0, lm_pred)

submission <- data.frame(id = test$id, price_doc = lm_pred)
submission %>%
    ggplot(aes(x = id, y = price_doc)) +
    geom_point()
write.csv(submission, "submission_lm_2.csv", row.names = FALSE)
```
submission_lm_1(1.90857) : submission_2 + log(price_doc)
submission_lm_2(0.36882) : submission_2 + price_doc
