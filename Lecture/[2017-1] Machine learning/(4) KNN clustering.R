# ------------------------------------------------------------------------------
# KNN Clustering : Titanic
# Youngho Lee
# 2017/02/16
# ------------------------------------------------------------------------------

# basic library
library(readr)
library(ggplot2)
library(dplyr)
library(kknn)
library(caret)
library(e1071)

# data import
train <- read.csv("H:/Data/Titanic/train.csv")
test <- read.csv("H:/Data/Titanic/test.csv")
head(train)
str(train)
summary(train)

# EDA
table(train$Pclass, train$Survived)
table(train$Sex, train$Survived)
ggplot(data = train, aes(x = factor(Survived), y = Age, fill = factor(Survived))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(Survived), y = SibSp, fill = factor(Survived))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(SibSp))) +
    geom_bar()
ggplot(data = train, aes(x = factor(Survived), y = Parch, fill = factor(Survived))) +
    geom_boxplot()
ggplot(data = train, aes(x = factor(Parch))) +
    geom_bar()
ggplot(data = train, aes(x = factor(Survived), y = Fare, fill = factor(Survived))) +
    geom_boxplot()
table(train$Embarked, train$Survived)

# feature engineering
train$Survived <- as.factor(train$Survived)
test$Survived <- as.factor(test$Survived)

train.Mr <- train[grep("Mr. ", train$Name), ]
summary(train.Mr)
train.Mr$Age[is.na(train.Mr$Age)] <- median(train.Mr$Age, na.rm = TRUE)
test.Mr <- test[grep("Mr. ", test$Name), ]
summary(test.Mr)
test.Mr$Age[is.na(test.Mr$Age)] <- median(test.Mr$Age, na.rm = TRUE)

train.Mrs <- train[grep("Mrs. ", train$Name), ]
summary(train.Mrs)
train.Mrs$Age[is.na(train.Mrs$Age)] <- median(train.Mrs$Age, na.rm = TRUE)
test.Mrs <- test[grep("Mrs. ", test$Name), ]
summary(test.Mrs)
test.Mrs$Age[is.na(test.Mrs$Age)] <- median(test.Mrs$Age, na.rm = TRUE)

train.Miss <- train[grep("Miss. ", train$Name), ]
summary(train.Miss)
train.Miss$Age[is.na(train.Miss$Age)] <- median(train.Miss$Age, na.rm = TRUE)
test.Miss <- test[grep("Miss. ", test$Name), ]
summary(test.Miss)
test.Miss$Age[is.na(test.Miss$Age)] <- median(test.Miss$Age, na.rm = TRUE)

train.Master <- train[grep("Master. ", train$Name), ]
summary(train.Master)
train.Master$Age[is.na(train.Master$Age)] <- median(train.Master$Age, na.rm = TRUE)
test.Master <- test[grep("Master. ", test$Name), ]
summary(test.Master)
test.Master$Age[is.na(test.Master$Age)] <- median(test.Master$Age, na.rm = TRUE)

train.Dr <- train[grep("Dr. ", train$Name), ]
summary(train.Dr)
test.Dr <- test[grep("Dr. ", test$Name), ]
summary(test.Dr)
test.Dr$Age[is.na(test.Dr$Age)] <- median(test.Dr$Age, na.rm = TRUE)

train.Major <- train[grep("Major. ", train$Name), ]
train.Mlle <- train[grep("Mlle. ", train$Name), ]
train.Rev <- train[grep("Rev. ", train$Name), ]
train.Col <- train[grep("Col. ", train$Name), ]
train.Sir <- train[grep("Sir. ", train$Name), ]
train.Lady <- train[grep("Lady. ", train$Name), ]
train.Dona <- train[grep("Dona. ", train$Name), ]
train.Jonkheer <- train[grep("Jonkheer. ", train$Name), ]
train.the_Countess <- train[grep("the Countess. ", train$Name), ]
train.Don <- train[grep("Don. ", train$Name), ]
test.Major <- test[grep("Major. ", test$Name), ]
test.Mlle <- test[grep("Mlle. ", test$Name), ]
test.Rev <- test[grep("Rev. ", test$Name), ]
test.Col <- test[grep("Col. ", test$Name), ]
    # NA가 없는 호칭

train <- rbind(train.Mr, train.Mrs, train.Miss, train.Master, train.Dr, train.Major, train.Mlle, train.Rev, 
               train.Col, train.Sir, train.Lady, train.Dona, train.Jonkheer, train.the_Countess, train.Don)
test <- rbind(test.Mr, test.Mrs, test.Miss, test.Master, test.Dr, test.Major, test.Mlle, test.Rev, test.Col)

train <- train %>%
    mutate(Age_category = factor(round(Age, -1)))
test <- test %>%
    mutate(Age_category = factor(round(Age, -1)))

train <- train %>%
    mutate(Par_Ch = ifelse(Parch > 0, 1, 0))
test <- test %>%
    mutate(Par_Ch = ifelse(Parch > 0, 1, 0))

train <- train %>%
    mutate(Sib_Sp = ifelse(SibSp > 0, 1, 0))
test <- test %>%
    mutate(Sib_Sp = ifelse(SibSp > 0, 1, 0))

trainIdx <- 1:nrow(train)
titanic <- rbind(train, test)
titanic$Sex <- as.factor(titanic$Sex)
titanic$Embarked <- as.factor(titanic$Embarked)
summary(titanic)

titanic$Fare[is.na(titanic$Fare)] <- 8.05 
    # Fare에서 NA가 속한 행이 하나였으며, 그 행의 Pclass가 3이었으므로 pclass 3의 Fare의 median인 8.05 대입
titanic$Embarked[is.na(titanic$Embarked)] <- "S"
    # Emarked에서 가장 빈도수가 높은 "S" 대입

# modeling
train <- titanic[trainIdx, ]
test <- titanic[-trainIdx, ]

titanic.cv2 <- train.kknn(Survived ~ Pclass + Sex + Age_category + Sib_Sp + Par_Ch + Fare + Embarked,
                         data = train,
                         ks = seq(1, 40, by = 2),
                         scale = TRUE)
titanic.cv2
titanic.knn2 <- kknn(Survived ~ Pclass + Sex + Age_category + Sib_Sp + Par_Ch + Fare + Embarked,
                    train = train, test = test,
                    k = titanic.cv2$best.parameters$k,
                    scale = TRUE)
titanic.pred2 <- titanic.knn2$fitted.values

confusionMatrix(titanic.pred2, test$Survived, positive = "1")

cfM2 <- confusionMatrix(titanic.pred2, test$Survived, positive = "1")