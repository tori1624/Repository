# ------------------------------------------------------------------------------
# Regularized Regression : Bike Sharing Demand Prediction
# Youngho Lee
# 2017/02/12
# ------------------------------------------------------------------------------

# basic library
library(readr)
library(ggplot2)
library(dplyr)
library(glmnet)
library(car)

# data import
train <- read.csv("H:/Data/Bike/train.csv")
test <- read.csv("H:/Data/Bike/test.csv")
head(train)
str(train)
summary(train)

# EDA
ggplot(data = train, aes(x = factor(year), y = cnt, fill = factor(year))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(year), y = casual, fill = factor(year))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(year), y = registered, fill = factor(year))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(month), y = cnt, fill = factor(month))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(month), y = casual, fill = factor(month))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(month), y = registered, fill = factor(month))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hour), y = cnt, fill = factor(hour))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hour), y = casual, fill = factor(hour))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hour), y = registered, fill = factor(hour))) +
    geom_boxplot()
ggplot(data = train, aes(x = weekdays, y = cnt, fill = weekdays)) +
    geom_boxplot()
ggplot(data = train, aes(x = weekdays, y = casual, fill = weekdays)) +
    geom_boxplot()
ggplot(data = train, aes(x = weekdays, y = registered, fill = weekdays)) +
    geom_boxplot()
ggplot(data = train, aes(x = season, y = cnt, fill = season)) +
    geom_boxplot()
ggplot(data = train, aes(x = season, y = casual, fill = season)) +
    geom_boxplot()
ggplot(data = train, aes(x = season, y = registered, fill = season)) +
    geom_boxplot()
ggplot(data = train, aes(x = workingday, y = cnt, fill = workingday)) +
    geom_boxplot()
ggplot(data = train, aes(x = workingday, y = casual, fill = workingday)) +
    geom_boxplot()
ggplot(data = train, aes(x = workingday, y = registered, fill = workingday)) +
    geom_boxplot()
ggplot(data = train, aes(x = holiday, y = cnt, fill = holiday)) +
    geom_boxplot()
ggplot(data = train, aes(x = holiday, y = casual, fill = holiday)) +
    geom_boxplot()
ggplot(data = train, aes(x = holiday, y = registered, fill = holiday)) +
    geom_boxplot()
ggplot(data = train, aes(x = weathersit, y = cnt, fill = weathersit)) +
    geom_boxplot()
ggplot(data = train, aes(x = weathersit, y = casual, fill = weathersit)) +
    geom_boxplot()
ggplot(data = train, aes(x = weathersit, y = registered, fill = weathersit)) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(temp), y = cnt, fill = factor(temp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(temp), y = casual, fill = factor(temp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(temp), y = registered, fill = factor(temp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(atemp), y = cnt, fill = factor(atemp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(atemp), y = casual, fill = factor(atemp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(atemp), y = registered, fill = factor(atemp))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hum), y = cnt, fill = factor(hum))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hum), y = casual, fill = factor(hum))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(hum), y = registered, fill = factor(hum))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(windspeed), y = cnt, fill = factor(windspeed))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(windspeed), y = casual, fill = factor(windspeed))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(windspeed), y = registered, fill = factor(windspeed))) +
    geom_boxplot()

# modeling (1)
rmsle <- function(pred, act) {
    if(sum(pred < 0) > 0)
        stop("예측값에 0보다 작은 값이 존재합니다. 해당 값을 0으로 만들어주세요.")
    
    if(length(pred) != length(act))
        stop("예측값과 실제값의 벡터 길이가 다릅니다. 예측값을 다시 확인해주세요.")
    
    pred <- log(pred + 1)
    act <- log(act + 1)
    msle <- mean((pred - act)^2)
    
    return(sqrt(msle))
}

train2 <- train %>%
    select(-datetime, -casual, -registered)
test2 <- test %>%
    select(-datetime)

cnt.train <- train$cnt
cnt.test <- test$cnt

train.mat <- model.matrix(cnt ~ ., data = train2)[, -1]
test.mat <- model.matrix(cnt ~ ., data = test2)[, -1]

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.ridge <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 0)
pred.ridge <- predict(cv.ridge, test.mat, s = cv.ridge$lambda.min)
pred.ridge <- exp(pred.ridge) - 1
pred.ridge <- ifelse(pred.ridge < 0, 0, pred.ridge)
rmsle(pred.ridge, cnt.test)

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.lasso <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 1)
pred.lasso <- predict(cv.lasso, test.mat, s = cv.lasso$lambda.min)
pred.lasso <- exp(pred.lasso) - 1
pred.lasso <- ifelse(pred.lasso < 0, 0, pred.lasso)
rmsle(pred.lasso, cnt.test)

rmsle_ridge1 <- rmsle(pred.ridge, cnt.test)
rmsle_lasso1 <- rmsle(pred.lasso, cnt.test)

# feature engineering
train2$season <- factor(train$season)
test2$season <- factor(test$season)
train2$holiday <- factor(train$holiday)
test2$holiday <- factor(test$holiday)
train2$workingday <- factor(train$workingday)
test2$workingday <- factor(test$workingday)
train2$weathersit <- factor(train$weathersit)
test2$weathersit <- factor(test$weathersit)

train2 <- train2 %>%
    mutate(hour1 = ifelse(hour < 6, hour, 0),
           hour2 = ifelse(hour >= 6 & hour < 10, hour, 0),
           hour3 = ifelse(hour >= 10 & hour < 16, hour, 0),
           hour4 = ifelse(hour >= 16 & hour < 20, hour, 0),
           hour5 = ifelse(hour >= 20, hour, 0)) %>%
    select(-hour)
test2 <- test2 %>%
    mutate(hour1 = ifelse(hour < 6, hour, 0),
           hour2 = ifelse(hour >= 6 & hour < 10, hour, 0),
           hour3 = ifelse(hour >= 10 & hour < 16, hour, 0),
           hour4 = ifelse(hour >= 16 & hour < 20, hour, 0),
           hour5 = ifelse(hour >= 20, hour, 0)) %>%
    select(-hour)

train2 <- train2 %>%
    mutate(day_off = ifelse(weekdays == "Saturday" | weekdays == "Sunday" | holiday == 1, 1, 0)) %>%
    select(-holiday)
test2 <- test2 %>%
    mutate(day_off = ifelse(weekdays == "Saturday" | weekdays == "Sunday" | holiday == 1, 1, 0)) %>%
    select(-holiday)

train2 <- train2 %>%
    mutate(atemp1 = ifelse(atemp < 0.1, atemp, 0),
           atemp2 = ifelse(atemp >=0.1 & atemp <0.2, atemp, 0),
           atemp3 = ifelse(atemp >=0.2 & atemp <0.3, atemp, 0),
           atemp4 = ifelse(atemp >=0.3 & atemp <0.4, atemp, 0),
           atemp5 = ifelse(atemp >=0.4 & atemp <0.5, atemp, 0),
           atemp6 = ifelse(atemp >=0.5 & atemp <0.6, atemp, 0),
           atemp7 = ifelse(atemp >=0.6 & atemp <0.7, atemp, 0),
           atemp8 = ifelse(atemp >=0.7 & atemp <0.8, atemp, 0),
           atemp9 = ifelse(atemp >=0.8 & atemp <0.9, atemp, 0),
           atemp10 = ifelse(atemp >=0.9, atemp, 0)) %>%
    select(-atemp)
test2 <- test2 %>%
    mutate(atemp1 = ifelse(atemp < 0.1, atemp, 0),
           atemp2 = ifelse(atemp >=0.1 & atemp <0.2, atemp, 0),
           atemp3 = ifelse(atemp >=0.2 & atemp <0.3, atemp, 0),
           atemp4 = ifelse(atemp >=0.3 & atemp <0.4, atemp, 0),
           atemp5 = ifelse(atemp >=0.4 & atemp <0.5, atemp, 0),
           atemp6 = ifelse(atemp >=0.5 & atemp <0.6, atemp, 0),
           atemp7 = ifelse(atemp >=0.6 & atemp <0.7, atemp, 0),
           atemp8 = ifelse(atemp >=0.7 & atemp <0.8, atemp, 0),
           atemp9 = ifelse(atemp >=0.8 & atemp <0.9, atemp, 0),
           atemp10 = ifelse(atemp >=0.9, atemp, 0)) %>%
    select(-atemp)

# modeling (2)
train.mat <- model.matrix(cnt ~ ., data = train2)[, -1]
test.mat <- model.matrix(cnt ~ ., data = test2)[, -1]

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.ridge <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 0)
cv.ridge$lambda.min
grid <- seq(0.2, 0, length.out = 200)
set.seed(1)
cv.ridge <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 0, lambda = grid)
cv.ridge$lambda.min
pred.ridge <- predict(cv.ridge, test.mat, s = cv.ridge$lambda.min)
pred.ridge <- exp(pred.ridge) - 1
pred.ridge <- ifelse(pred.ridge < 0, 0, pred.ridge)
rmsle(pred.ridge, cnt.test)

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.lasso <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 1)
cv.lasso$lambda.min
grid <- seq(0.002, 0, length.out = 200)
set.seed(1)
cv.lasso <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 1, lambda = grid)
cv.lasso$lambda.min
pred.lasso <- predict(cv.lasso, test.mat, s = cv.lasso$lambda.min)
pred.lasso <- exp(pred.lasso) - 1
pred.lasso <- ifelse(pred.lasso < 0, 0, pred.lasso)
rmsle(pred.lasso, cnt.test)

rmsle_ridge2 <- rmsle(pred.ridge, cnt.test)
rmsle_lasso2 <- rmsle(pred.lasso, cnt.test)

# multicollinearity
cnt_model <- lm(cnt ~ ., data = train2)
summary(cnt_model) #day_off : NA

train2 <- train2 %>%
    select(-day_off)
test2 <- test2 %>%
    select(-day_off)
cnt_model <- lm(cnt ~ ., data = train2)
summary(cnt_model)


vif(cnt_model) #month, temp를 제거

train2 <- train2 %>%
    select(-month, -temp)
test2 <- test2 %>%
    select(-month, -temp)
cnt_model <- lm(cnt ~ ., data = train2)
summary(cnt_model)

vif(cnt_model)

# modeling (3)
train.mat <- model.matrix(cnt ~ ., data = train2)[, -1]
test.mat <- model.matrix(cnt ~ ., data = test2)[, -1]

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.ridge <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 0)
cv.ridge$lambda.min
grid <- seq(0.2, 0, length.out = 200)
set.seed(1)
cv.ridge <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 0, lambda = grid)
cv.ridge$lambda.min
pred.ridge <- predict(cv.ridge, test.mat, s = cv.ridge$lambda.min)
pred.ridge <- exp(pred.ridge) - 1
pred.ridge <- ifelse(pred.ridge < 0, 0, pred.ridge)
rmsle(pred.ridge, cnt.test)

log.cnt.train <- log(cnt.train + 1)
set.seed(1)
cv.lasso <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 1)
cv.lasso$lambda.min
grid <- seq(0.002, 0, length.out = 200)
set.seed(1)
cv.lasso <- cv.glmnet(x = train.mat, y = log.cnt.train, alpha = 1, lambda = grid)
cv.lasso$lambda.min
pred.lasso <- predict(cv.lasso, test.mat, s = cv.lasso$lambda.min)
pred.lasso <- exp(pred.lasso) - 1
pred.lasso <- ifelse(pred.lasso < 0, 0, pred.lasso)
rmsle(pred.lasso, cnt.test)

rmsle_ridge3 <- rmsle(pred.ridge, cnt.test)
rmsle_lasso3 <- rmsle(pred.lasso, cnt.test)