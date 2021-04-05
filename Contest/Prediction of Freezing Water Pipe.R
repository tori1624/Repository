# Basic packages
library(readr)
library(ggplot2)
library(dplyr)
library(openxlsx)

setwd("D:/Data/Public_data/waterpipe/")

# options("scipen" = 100)

# 1. Data Import
complaint <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/1. 동파(민원)/파주_민원현황(2010년~현재).csv")
watermeter <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/3. 수도미터 정보/파주-수도미터.csv")
piping_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/4. 급수관로/파주_수도미터_급수관로_매칭.csv")
piping_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/4. 급수관로/파주-급수관로.csv")

usage_2010 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2010년).csv")
usage_2011 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2011년).csv")
usage_2012_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2012년 상반기).csv")
usage_2012_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2012년 하반기).csv")
usage_2013_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2013년 상반기).csv")
usage_2013_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2013년 하반기).csv")
usage_2014_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2014년 상반기)_수정.csv")
usage_2014_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2014년 하반기)_수정.csv")
usage_2015_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2015년 상반기).csv")
usage_2015_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2015년 하반기).csv")
usage_2016_1 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2016년 상반기).csv")
usage_2016_2 <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/2017_공공_빅데이터_공모전_분석_부문_데이터/2. 수용가사용량/파주 사용량(2016년 하반기).csv")
usage_2017 <- read.xlsx("D:/Data/Public_data/waterpipe/row_2017.xlsx")

paju_temp <- read.csv("D:/Data/Public_data/waterpipe/paju_temp.csv")

names(complaint) 
# [1] "complaint_date" "complaint_type" "consumer_ID" "complaint_state" "complaint_text"

names(watermeter)
# [1] "consumer_ID"                     "number_address"                  "road_address"                   
# [4] "watersupply_state"               "business_type"                   "watermeter_number"              
# [7] "watermeter_manufacturing_number" "watermeter_caliber"              "watermeter_use"                 
# [10] "block_unit"                      "installation_date"               "start_date"                     
# [13] "freeze_protection_pack"

names(piping_1)
# [1] "consumer_ID"                           "supply_water_piping_management_number"
# [3] "x"                                     "y" 

names(piping_2)
# [1] "supply_water_piping_management_number" "pipe_type"                            
# [3] "pipe_diameter"                         "pipe_length"     



### names(watermeter)[1] <- "consumer_ID"

### watermeter$consumer_ID <- as.double(watermeter$consumer_ID)
### piping_1$consumer_ID <- as.double(piping_1$consumer_ID)

### watermeter <- watermeter[order(watermeter$consumer_ID), ]
### piping <- piping[order(piping$consumer_ID), ]


# 2. Data Handling
## 1) Complaint
### 1-1) For Merging
complaint <- complaint %>%
  mutate(complaint = 1)

complaint$consumer_ID <- as.character(complaint$consumer_ID)
complaint$consumer_ID <- gsub("-", "", complaint$consumer_ID)
complaint$consumer_ID <- as.numeric(complaint$consumer_ID)

complaint$complaint_date <- as.character(complaint$complaint_date)

split_year <- function(x){
  strsplit(x, split = '-')[[1]][1]
}

split_month <- function(x){
  strsplit(x, split = '-')[[1]][2]
}

complaint$year <- sapply(complaint$complaint_date, split_year)
complaint$month <- sapply(complaint$complaint_date, split_month)

complaint$year <- as.numeric(complaint$year)
complaint$month <- as.numeric(complaint$month)

complaint <- complaint[which(!is.na(complaint$consumer_ID)), ]

### 동파가 아닌 민원 제외
complaint_1  <- complaint[-which(grepl("동파", complaint$complaint_text) == FALSE 
                                 & grepl("동파", complaint$complaint_type) == FALSE 
                                 & complaint$month > 2 & complaint$month < 12), ]

complaint_2 <- complaint_1 %>%
  mutate(consumer_ID_Year = paste0(complaint_1$consumer_ID, complaint_1$year))

complaint_2[!duplicated(complaint_2$consumer_ID_Year),] %>%
  arrange(consumer_ID, complaint_type) -> complaint_3

complaint <- complaint_3

write.csv(complaint, "complaint.csv", row.names = FALSE)

## 2) Temperature
paju_temp$Date <- as.character(paju_temp$Date)

split_year <- function(x){
  strsplit(x, split = '-')[[1]][3]
}

split_month <- function(x){
  strsplit(x, split = '-')[[1]][2]
}

paju_temp$year <- paste0("20", paju_temp$year)

paju_temp$year <- sapply(paju_temp$Date, split_year)
paju_temp$month <- sapply(paju_temp$Date, split_month)

paju_temp$month <- as.numeric(paju_temp$month)

paju_temp <- paju_temp %>%
  select(-Date)

write.csv(paju_temp, "paju_temp.csv", row.names = FALSE)

## 3) usage_2017
names(usage_2017)[1] <- "consumer_ID"

# 3. Merge Data
## 1) Piping
piping <- merge(piping_1, piping_2, 
                by = c("supply_water_piping_management_number"))

## 2) Piping + Watermeter
PW <- merge(piping, watermeter, by = c("consumer_ID"))

### -> pipe_length에서 ','가 있는 데이터로 인해 숫자로 인식하지 못함
### ','를 가진 데이터가 2개 밖에 되지 않았으므로 엑셀로 ','를 지움

## 3) Usage
### 3-1) 사용량 상반기, 하반기 병합
for(i in 1:5){
  tmp <- merge(x = get(paste0("usage_", 2011 + i, "_1")),
               y = get(paste0("usage_", 2011 + i, "_2")),
               by = c("consumer_ID"), all = TRUE)
  assign(paste0("usage_", 2011 + i), tmp)
  message(paste0("usage_", 2011 + i), " has completed")
}

### 3-2) month_name 함수 생성
month_name <- function(x){
  for(i in 1:12){
    names(x)[i+1] <- i
  }
  return(x)
}

### 3-3) month_name 함수 적용 / "-" 제거
for(i in 1:8){
  tmp <- get(paste0("usage_", 2009 + i))
  # Year
  tmp <- tmp %>%
    mutate(year = 2009 + i)
  # Month Name
  tmp <- month_name(tmp)
  # Consumer_ID
  tmp[, "consumer_ID"] <- gsub("-", "", tmp$consumer_ID)
  assign(paste0("usage_", 2009 + i), tmp)
  message(paste0("usage_", 2009 + i), " has completed")
}

### 3-4) 모든 연도 사용량 데이터 병합
usage_all <- NULL  
for(i in 1:8){
  tmp <- get(paste0("usage_",2009+i))
  usage_all <- rbind(usage_all, tmp)
}
summary(usage_all)

## 6) The Final Merging(연도 구분)
for(i in 1:7){
  tmp <- merge(x = get(paste0("usage_", 2009 + i)), y = get("PWC"),
               by = c("consumer_ID"))
  assign(paste0("PWC_", 2009 + i), tmp)
  message(paste0("PWC_", 2009 + i), " has completed")
}

## 7) The Final Merging(총 사용량)
UseAll_PW <- merge(x = usage_all, y = PW, by = c("consumer_ID"))
UseAll_PWC <- merge(UseAll_PW, complaint, 
                    by = c("consumer_ID", "year"), all.x = TRUE)

## 8) 
UseAll_PWC_clean <- UseAll_PWC[complete.cases(UseAll_PWC[, c(3:14)]) == TRUE, ]

## <knn imputation>
### install.packages("VIM")
library(VIM)
data_1 <- kNN(data, variable = c(), k = ) 

# 4. Filtering(for Mapping)
complaint_location <- PWC %>%
  filter(complaint == 1) %>%
  select(consumer_ID, x, y, year, month)

write.csv(complaint_location, "complaint_location.csv", row.names = FALSE)

# 5. Modeling
## 1) Vanila
UseAll_PWC_clean_N <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/Prediction of Freezing Water Pipe_ooDoo/UseAll_PWC_clean_N.csv")

UseAll_PWC_clean_N$N_12[complete.cases(UseAll_PWC_clean_N$`N_12`) == FALSE] <- UseAll_PWC_clean_N$X12[complete.cases(UseAll_PWC_clean_N$`N_12`) == FALSE]  

split_year <- function(x){
  strsplit(x, split = '-')[[1]][1]
}

UseAll_PWC_clean_N %>%
  mutate(installation_year = sapply(as.character(UseAll_PWC_clean_N$installation_date), split_year)) %>%
  mutate(Winter_usage = (N_12 + X1 + X2)/3) %>%
  mutate(freeze_protection_pack = as.factor(ifelse(freeze_protection_pack == "설치", "설치",
                                                   ifelse(UseAll_PWC_clean_N$freeze_protection_pack == "미확인", "미설치",
                                                          ifelse(is.na(UseAll_PWC_clean_N$freeze_protection_pack) == TRUE, "미설치", NA)))))%>%
  mutate(complaint_type = ifelse(is.na(complaint_type) == TRUE, 0, 1)) %>%
  
  #delete unnecssary column
  dplyr::select(-c(supply_water_piping_management_number, number_address, x, y,
                   road_address, watermeter_number, watermeter_manufacturing_number,
                   watermeter_use, c(X1:X12), N_12, complaint_date, complaint_state, complaint_text, Month, 
                   installation_date, start_date)) -> UseAll_PWC_clean_1

UseAll_PWC_clean_1$freeze_protection_pack[is.na(UseAll_PWC_clean_1$freeze_protection_pack) == TRUE] <- "미설치"

UseAll_PWC_clean_1$installation_year <- as.numeric(UseAll_PWC_clean_1$installation_year)
UseAll_PWC_clean_1$Year <- as.factor(UseAll_PWC_clean_1$Year)

## 2) Temperaure
temperature <- read.csv("D:/공모전/2017/공공 빅데이터 공모전/Prediction of Freezing Water Pipe_ooDoo/20170806115243.csv")
temperature <- temperature[,-c(1,6,10,11,14,16 )]
temperature %>%
  dplyr::rename(date = 일시,
                avg_tpt = 평균기온..C.,
                avg_ltpt = 평균최저기온..C., 
                ltpt = 최저기온..C.,
                snow_depth = 최심적설,
                snow_Ndepth = 최심신적설, 
                snow_Mdepth = 월적설량합,
                avg_Above_ground_ltpt = 평균.최저초상온도..C.,
                Above_ground_ltpt = 최저초상온도..C.,
                avg_Under_ground_ltpt = 평균지면온도..C.) -> temperature

#Year
tpt_Year_function <- function(data){
  data <- strsplit(as.character(data), "[-]")[[1]][2]
  
}
temperature$Year <- NULL
temperature$Year <- sapply(temperature$date, FUN = tpt_Year_function)

#Month
tpt_Month_function <- function(data){
  data <- strsplit(as.character(data), "[-]")[[1]][1]
  
}
temperature$Month <- NULL
temperature$Month <- sapply(temperature$date, FUN = tpt_Month_function)
temperature$Month <- c(1:12)[match(temperature$Month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))]
temperature$date <- NULL

temperature%>%
  filter(Month == 12 | Month == 1 | Month == 2)%>%
  select(-contains('snow'))%>%
  group_by(Year)%>%
  summarise(M_avg_tpt = mean(avg_tpt), 
            M_avg_ltpt = mean(avg_ltpt),
            M_ltpt = mean(ltpt),
            M_avg_Above_ground_ltpt = mean(avg_Above_ground_ltpt),
            M_Above_ground_ltpt = mean(Above_ground_ltpt),
            M_avg_Under_ground_ltpt = mean(avg_Under_ground_ltpt)) -> temperature

temperature$Year <- paste0("20", temperature$Year)

UseAll_PWC_clean_tpt <- merge(x = UseAll_PWC_clean_1, y = temperature,
                              by = "Year", all.x = TRUE)

## 3) Modeling_lm_vanila
set.seed(1234)
trainIdx <- sample(1:nrow(UseAll_PWC_clean_tpt), size = 0.7 * nrow(UseAll_PWC_clean_tpt))
train <- UseAll_PWC_clean_tpt[trainIdx, ]
test <- UseAll_PWC_clean_tpt[-trainIdx, ]
freeze <- test$complaint_type
test$complaint_type <- NULL

train_1 <- train[, c(1:12)]
test_1 <- test[, c(1:11)]

freeze_vanila_1 <- lm(complaint_type ~ .-consumer_ID, data = train_1) 

summary(freeze_vanila_1)
predict_freeze_vanila_1 <- predict(freeze_vanila_1, test_1)

## 4) Modeling_glm_vanila
freeze_vanila_2 <- glm(complaint_type ~ .-consumer_ID, data = train,
                       family = "binomial") 

summary(freeze_vanila_2)
predict_freeze_vanila_2 <- predict(freeze_vanila_2, test)

plot(predict_freeze_vanila_2)

## 5) Verifiction
rmse <- function(actual, predict){
  if(length(actual) != length(predict))
    stop("실제값과 예측값의 길이가 다릅니다.\n")
  length <- length(actual)
  errorSum <- sum((actual - predict)^2)
  return(sqrt(errorSum / length))
}

rmse1 <- rmse(freeze, predict_freeze_vanila_1) # 0.1284279

MultiLogLoss <- function(act, pred){
  eps <- 1e-15
  pred <- pmin(pmax(pred, eps), 1 - eps)
  sum(act * log(pred) + (1 - act) * log(1 - pred)) * -1/NROW(act)
}

MLL1 <- MultiLogLoss(freeze, predict_freeze_vanila_2) # 0.5850553

## 6) Improvement_1
### 6-1) lm
freeze_weather <- lm(complaint_type ~ .-consumer_ID, data = train)

summary(freeze_weather)
predict_freeze_weather <- predict(freeze_weather, test)

rmse2 <- rmse(freeze, predict_freeze_weather) # 0.1283489

### 6-2) glm
freeze_weather_glm <- glm(complaint_type ~ .-consumer_ID, data = train,
                          family = "binomial")

summary(freeze_weather_glm)
predict_weather_glm <- predict(freeze_weather_glm, test)

MLL2 <- MultiLogLoss(freeze, predict_weather_glm) # 0.5850553

## 7) XGBoost
library(xgboost)

train_1_mat <- model.matrix( ~ ., train_1)[, -c(1, 3)]
test_1_mat <- model.matrix( ~ ., test_1 )[, -c(1,3)]

train_1_label <- train_1$complaint_type
table(train_1_label)

params <- list(eta = 0.05,
               max.depth = 5,
               gamma = 0,
               colsample_bytree = 1,
               subsample = 1,
               objective = "binary:logistic",
               eval_metric = "logloss")

set.seed(1234)
xgbcv <- xgb.cv(params = params,
                nrounds = 400,
                nfold = 10,
                metrics = "logloss",
                data = train_1_mat,
                label = train_1_label,  
                verbose = 0)

xgb.best <- arrange(xgbcv$evaluation_log, test_logloss_mean)[1, ] 
xgb.best

freeze_xgboost <- xgboost(param = params,
                        data = train_1_mat,
                        label = train_1_label,  
                        nrounds = xgb.best$iter,
                        verbose = 1
)

freeze_xgb_pred <- predict(freeze_xgboost, test_1_mat)

MLL3 <- MultiLogLoss(freeze, freeze_xgb_pred) # 7.347693 (eta = 0.3) 
MLL4 <- MultiLogLoss(freeze, freeze_xgb_pred) # 7.307099 (eta = 0.05)
MLL5 <- MultiLogLoss(freeze, freeze_xgb_pred) # 7.196246

## 8) XGBoost_1
set.seed(1234)
ind <- 1:nrow(UseAll_PWC_clean_1)
data1 <- cbind(UseAll_PWC_clean_1,ind)
data2 <- na.omit(data1)
library(doBy)
## sampleBy(~target,frac= sampling percent,replace = T/F,data= data)
train <- sampleBy(complaint_type ~ ., frac = 0.7, replace = FALSE, data = data1)
test <- data1[!data1$ind %in% train$ind,]
## Remove the 'ind' 
train <- train[, -14]
test <- test[, -14]
freeze <- test$complaint_type
test$complaint_type <- NULL

## Check the complaint_type ratic
print(table(train$complaint_type)/sum(table(train$complaint_type)))
print(table(test$complaint_type)/sum(table(test$complaint_type)))

# dtrain <- xgb.DMatrix(data = train, label = train$complaint_type)
# dtest <- xgb.DMatrix(data = test, label = test$complaint_type)

train_mat <- model.matrix( ~ ., train)[, -1]
test_mat <- model.matrix( ~ ., test)[, -1]

train_label <- train$complaint_type

# watchlist <- list(train = train, test = test)

set.seed(1234)

params <- list(eta = 0.05,
               max.depth = 5,
               gamma = 0,
               colsample_bytree = 1,
               subsample = 1,
               objective = "binary:logistic",
               eval_metric = "logloss")

xgbcv <- xgb.cv(params = params,
                nrounds = 400,
                nfold = 10,
                metrics = "logloss",
                data = train_mat,
                label = train_label,  
                verbose = 0)

xgb.best <- arrange(xgbcv$evaluation_log, test_logloss_mean)[1, ] 
xgb.best

freeze_xgboost <- xgboost(param = params,
                          data = train_mat,
                          label = train_label,  
                          nrounds = xgb.best$iter,
                          verbose = 1
)

freeze_xgb_pred <- predict(freeze_xgboost, test_mat)

plot(freeze_xgb_pred)

MLL6 <- MultiLogLoss(freeze, freeze_xgb_pred) # 0.198362 (+ x, y, installation_year)
