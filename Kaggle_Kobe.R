---
title: "Kobe"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

# Basic Packages
library(ggplot2)
library(dplyr)
library(readr)
library(xgboost)

#setwd
knitr::opts_knit$set(root.dir = "H:/Kaggle/Kobe_Bryant_shot_selection")
```



# 1. Data Import
```{r}
kobe <- read.csv("H:/Kaggle/Kobe_Bryant_shot_selection/data.csv")
train <- kobe[!is.na(kobe$shot_made_flag), ]
test <- kobe[is.na(kobe$shot_made_flag), ]
head(train)
str(train)
summary(train)
```

# 2. Data Exploration(Visualizaion)
## 1) Dunk & No Dunk
```{r}
train %>%
    filter(combined_shot_type == "Dunk") %>%
    group_by(action_type, shot_made_flag) %>%
    summarise(count = n()) %>%
    mutate(made = (shot_made_flag * count) / sum(count)) %>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = action_type, y = made, fill = action_type)) +
    geom_col()  +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))

train %>%
    filter(combined_shot_type != "Dunk")%>%
    group_by(combined_shot_type, shot_made_flag)%>%
    summarise(count = n()) %>%
    mutate(made = (shot_made_flag * count)/sum(count)) %>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = combined_shot_type, y = made, fill = combined_shot_type)) +
    geom_col()
```


## 2) Season
```{r}
train %>%
    group_by(season, shot_made_flag) %>%
    summarise(count = n()) %>%
    mutate(full_count = sum(count), prop = count/full_count)%>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = season, y = full_count, fill = prop)) +
    geom_col() +
    scale_fill_gradient(low="firebrick1", high="deepskyblue") +
    theme(axis.text.x = element_text(angle = 45)) 
```


## 3) Shot Zone Area
```{r}
train %>%
    ggplot(aes(x = loc_x, y = loc_y, color = shot_zone_area)) +
    geom_point() + 
    facet_wrap(~ shot_made_flag) +
    theme_void() + # remove x,y-axis
    ggtitle("Shot Zone Area")

train %>%
    group_by(shot_zone_area, shot_made_flag) %>%
    summarise(count = n()) %>%
    mutate(full_count = sum(count), prop = count/full_count) %>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = shot_zone_area, y = full_count, fill = prop)) +
    geom_col() +
    scale_fill_gradient(low="firebrick1", high="deepskyblue") +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))
```

## 4) Shot Zone Basic
```{r}
train %>%
    ggplot(aes(x = loc_x, y = loc_y, color = shot_zone_basic)) +
    geom_point() + 
    facet_wrap(~ shot_made_flag) +
    theme_void() +
    ggtitle("Shot Zone Basic")

train %>%
    group_by(shot_zone_basic, shot_made_flag) %>%
    summarise(count = n()) %>%
    mutate(full_count = sum(count), prop = count/full_count) %>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = shot_zone_basic, y = full_count, fill = prop)) +
    geom_col() +
    scale_fill_gradient(low="firebrick1", high="deepskyblue") +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))
```

## 5) Shot Zone Range
```{r}
train %>%
    ggplot(aes(x = loc_x, y = loc_y, color = shot_zone_range)) +
    geom_point() + 
    facet_wrap(~ shot_made_flag) +
    theme_void() +
    ggtitle("Shot Zone Range")

train %>%
    group_by(shot_zone_range, shot_made_flag) %>%
    summarise(count = n()) %>%
    mutate(full_count = sum(count), prop = count/full_count) %>%
    filter(shot_made_flag == 1) %>%
    ggplot(aes(x = shot_zone_range, y = full_count, fill = prop)) +
    geom_col() +
    scale_fill_gradient(low="firebrick1", high="deepskyblue") +
    theme(axis.text.x = element_text(angle = 45, face = "italic", vjust = 1 ,hjust = 1))
```


# 3. Feature Engineering
## 1) Time remaining(Seconds)
```{r}
train <- train %>%
    mutate(time_remaining = minutes_remaining * 60 + seconds_remaining) %>%
    select(-minutes_remaining, - seconds_remaining)
test <- test %>%
    mutate(time_remaining = minutes_remaining * 60 + seconds_remaining) %>%
    select(-minutes_remaining, - seconds_remaining)
```

## 2) Home & Away
```{r}
splitString <- function(x){
    strsplit(x, split = '[@]')[[1]][2]
}

train$matchup <- as.character(train$matchup)
train$Home <- sapply(train$matchup, FUN = splitString)
train$Home <- as.factor(train$Home)
train$Home <- ifelse(is.na(train$Home), 1, 0)
train <- train %>%
    select(-matchup)

test$matchup <- as.character(test$matchup)
test$Home <- sapply(test$matchup, FUN = splitString)
test$Home <- as.factor(test$Home)
test$Home <- ifelse(is.na(test$Home), 1, 0)
test <- test %>%
    select(-matchup)
```

## 3) Clutch / Slump Season
```{r}
train <- train %>%
    mutate(clutch = ifelse(time_remaining <= 5 & period >= 4, 1, 0),
           slump_season = ifelse(season == "2013-14" | season == "2014-15" | season == "2015-16", 1, 0))
test <- test %>%
    mutate(clutch = ifelse(time_remaining <= 5 & period >= 4, 1, 0),
           slump_season = ifelse(season == "2013-14" | season == "2014-15" | season == "2015-16", 1, 0))
```

## 4) Month
```{r}
# install.packages("lubridate")
library(lubridate)

train <- train %>%
    mutate(month = month(game_date),
           season_divide = ifelse(month == 10 | month == 11 | month == 12, "season_early",
                                    ifelse(month == 1 | month == 2 | month == 3,"season_mid",
                                        ifelse(month == 4 | month == 5 | month == 6,  "season_late", NA))))
test <- test %>%
    mutate(month = month(game_date),
           season_divide = ifelse(month == 10 | month == 11 | month == 12, "season_early",
                                    ifelse(month == 1 | month == 2 | month == 3,"season_mid",
                                        ifelse(month == 4 | month == 5 | month == 6,  "season_late", NA))))

train$season_divide <- as.factor(train$season_divide)
test$season_divide <- as.factor(test$season_divide)
```

```{r}
train$shot_made_flag <- as.factor(train$shot_made_flag)
test$shot_made_flag <- rep(0:1, 2500)
test$shot_made_flag <- as.factor(test$shot_made_flag)

train$period <- as.factor(train$period)
test$period <- as.factor(test$period)

train$playoffs <- as.factor(train$playoffs)
test$playoffs <- as.factor(test$playoffs)
```

```{r}
# XGBoost
train <- train %>%
    filter(loc_y <= 400) %>%
    select(-team_name, -game_event_id, -game_id, -team_id, -lat, -lon)
test <- test %>%
    select(-team_name, -game_event_id, -game_id, -team_id, -lat, -lon)
# Logistic
train <- train %>%
    select(-team_name, -game_event_id, -game_id, -team_id, -lat, -lon)
test <- test %>%
    select(-team_name, -game_event_id, -game_id, -team_id, -lat, -lon)
```

# 4. Boruta
```{r}
library(Boruta)

trainLabel <- as.numeric(train$shot_made_flag) - 1

set.seed(7)
bor.result <- Boruta(train, trainLabel, maxRuns = 20)
getSelectedAttributes(bor.result)

bor.result$finalDecision
head(bor.result$ImpHistory)
plot(bor.result)

train <- train[, getSelectedAttributes(bor.result)]
test <- test[, getSelectedAttributes(bor.result)]
```



# 5. XGBoost Model
```{r}
# trainLabel <- as.numeric(train$shot_made_flag) - 1
trainMat <- model.matrix(shot_made_flag ~ 0 + ., data = train)
testMat <- model.matrix(shot_made_flag ~ 0 + ., data = test)
```

```{r}
params <- list(eta = 0.3, max.depth = 5,
               gamma = 0, colsample_bytree = 1,
               subsample = 1,
               objective = "binary:logistic",
               eval_metric = "logloss")
```

```{r}
set.seed(1)
xgbcv <- xgb.cv(params = params,
                nrounds = 50,
                nfold = 10,
                metrics = "logloss",
                data = trainMat,
                label = trainLabel,
                verbose = 1)
xgb.best <- arrange(xgbcv$evaluation_log, test_logloss_mean)[1, ]
xgb.best
# 18(time, dunk, action, home) / 16(time, dunk, action, home, clutch, slump)
# 16(time, action, home, clutch, slump) / 26 (time, home, clutch, slump)
# (time, home, clutch, slump, month, season_divided, distance_category)
```

```{r}
set.seed(1)
kobe_xgboost <- xgboost(params = params,
                          data = trainMat,
                          label = trainLabel,
                          nrounds = xgb.best$iter,
                          verbose = 1)
xgb_pred <- predict(kobe_xgboost, testMat)

submission <- data.frame(shot_id = test$shot_id, shot_made_flag = xgb_pred)
write.csv(submission, "submission10.csv", row.names = FALSE)
```

# 6. Logistic Regression
```{r}
train <- train %>%
    select(-combined_shot_type, -shot_zone_range)
test <- test %>%
    select(-combined_shot_type, -shot_zone_range)

logit_kobe <- glm(shot_made_flag ~ ., family = "binomial", data = train)
summary(logit_kobe)

logit_pred <- predict(logit_kobe, test)

submission <- data.frame(shot_id = test$shot_id, shot_made_flag = logit_pred)
write.csv(submission, "submission11.csv", row.names = FALSE)
```


# Variable Not Included
## 1) Dunk & No Dunk
```{r}
train <- train %>%
    mutate(Dunk = ifelse(combined_shot_type == "Dunk", 1, 0))
test <- test %>%
    mutate(Dunk = ifelse(combined_shot_type == "Dunk", 1, 0))
```

## 2) Action Type
```{r}
splitString <- function(x){
    strsplit(x, split = '[ ]')[[1]][1]
}

train$action_type <- as.character(train$action_type)
train$action_type <- sapply(train$action_type, FUN = splitString)
train$action_type <- as.factor(train$action_type)

test$action_type <- as.character(test$action_type)
test$action_type <- sapply(test$action_type, FUN = splitString)
test$action_type <- as.factor(test$action_type)
```

## 3) Shot Distance
```{r}
train <- train %>%
    mutate(shot_distance_category = ifelse(shot_distance < 10, "shot_distance_category1",
                                           ifelse(shot_distance >= 10 & shot_distance < 20, "shot_distance_category2",
                                                  ifelse(shot_distance >= 20 & shot_distance < 30, "shot_distance_category3",
                                                         ifelse(shot_distance >= 30 & shot_distance < 40, "shot_distance_category4",
                                                                ifelse(shot_distance >= 40 & shot_distance < 50, "shot_distance_category5",
                                                                       ifelse(shot_distance >= 50 & shot_distance < 60, "shot_distance_category6",
                                                                              ifelse(shot_distance >= 60 & shot_distance < 70, "shot_distance_category7",
                                                                                     ifelse(shot_distance >= 70, "shot_distance_category8", NA))))))))) %>%
    select(-shot_distance)
test <- test %>%
    mutate(shot_distance_category = ifelse(shot_distance < 10, "shot_distance_category1",
                                           ifelse(shot_distance >= 10 & shot_distance < 20, "shot_distance_category2",
                                                  ifelse(shot_distance >= 20 & shot_distance < 30, "shot_distance_category3",
                                                         ifelse(shot_distance >= 30 & shot_distance < 40, "shot_distance_category4",
                                                                ifelse(shot_distance >= 40 & shot_distance < 50, "shot_distance_category5",
                                                                       ifelse(shot_distance >= 50 & shot_distance < 60, "shot_distance_category6",
                                                                              ifelse(shot_distance >= 60 & shot_distance < 70, "shot_distance_category7",
                                                                                     ifelse(shot_distance >= 70, "shot_distance_category8", NA))))))))) %>%
    select(-shot_distance)

train$shot_distance_category <- as.factor(train$shot_distance_category)
test$shot_distance_category <- as.factor(test$shot_distance_category)
```
