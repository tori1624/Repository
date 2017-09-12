---
title: "MMLM2017"
author: "Young Ho Lee"
date: "2017.03.10"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

# Basic Packages
library(readr)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(xgboost)
library(reshape2)

#setwd
knitr::opts_knit$set(root.dir = "D:/Kaggle/March_Machine_Learnig_Mania_2017")
```

# 1. Data Import
```{r}
RS_det <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/RegularSeasonDetailedResults.csv")
seasons <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/Seasons.csv")
teams <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/Teams.csv")
T_det <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/TourneyDetailedResults.csv")
seeds <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/TourneySeeds.csv")
submission <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/SampleSubmission.csv")
```

## 1-1) Data Handling for Averages
```{r}
W.team_rs <- RS_det[ ,c("Season","Wteam","Daynum","Wscore","Numot","Wfgm","Wfga","Wfgm3","Wfga3","Wftm","Wfta","Wor","Wdr","Wast","Wto","Wstl","Wblk","Wpf")]
W.team_rs$Victory <- 1
L.team_rs <- RS_det[ ,c("Season","Lteam","Daynum","Lscore","Numot","Lfgm","Lfga","Lfgm3","Lfga3","Lftm","Lfta","Lor","Ldr","Last","Lto","Lstl","Lblk","Lpf")]
L.team_rs$Victory <- 0

W.team_t <- T_det[ ,c("Season","Wteam","Daynum","Wscore","Numot","Wfgm","Wfga","Wfgm3","Wfga3","Wftm","Wfta","Wor","Wdr","Wast","Wto","Wstl","Wblk","Wpf")]
W.team_t$Victory <- 1
L.team_t <- T_det[ ,c("Season","Lteam","Daynum","Lscore","Numot","Lfgm","Lfga","Lfgm3","Lfga3","Lftm","Lfta","Lor","Ldr","Last","Lto","Lstl","Lblk","Lpf")]
L.team_t$Victory <- 0

names(W.team_rs) <- c("season","team","daynum","score","numot","fgmade","fgattempt","fgm3","fga3","ftmade","ftattempt","offreb","defreb","ast","turnover","steal","block","pfoul","victory")
names(L.team_rs) <- c("season","team","daynum","score","numot","fgmade","fgattempt","fgm3","fga3","ftmade","ftattempt","offreb","defreb","ast","turnover","steal","block","pfoul","victory")

names(W.team_t) <- c("season","team","daynum","score","numot","fgmade","fgattempt","fgm3","fga3","ftmade","ftattempt","offreb","defreb","ast","turnover","steal","block","pfoul","victory")
names(L.team_t) <- c("season","team","daynum","score","numot","fgmade","fgattempt","fgm3","fga3","ftmade","ftattempt","offreb","defreb","ast","turnover","steal","block","pfoul","victory")

team <- rbind(W.team_rs, W.team_t, L.team_rs, L.team_t)
```

```{r}
team_avg <- NULL
for(i in unique(team$season)){
  
  team %>%
    filter(season == i) -> DF
  
  DF <- aggregate(DF, by = list(DF$team), FUN = mean, na.rm = T)
  
  assign(paste0("team_avg_", i), DF)
  
  team_avg <- rbind(team_avg, DF)
  
print(paste0("season",i,"is done"))
}
```

```{r}
team2003 <- team %>%
  filter(season == 2003)

team_avg03 <- aggregate(team2003, by = list(team2003$team), FUN = mean, na.rm = T)

team2004 <- team %>%
  filter(season == 2004)

team_avg04 <- aggregate(team2004, by = list(team2004$team), FUN = mean, na.rm = T)

team2005 <- team %>%
  filter(season == 2005)

team_avg05 <- aggregate(team2005, by = list(team2005$team), FUN = mean, na.rm = T)

team2006 <- team %>%
  filter(season == 2006)

team_avg06 <- aggregate(team2006, by = list(team2006$team), FUN = mean, na.rm = T)

team2007 <- team %>%
  filter(season == 2007)

team_avg07 <- aggregate(team2007, by = list(team2007$team), FUN = mean, na.rm = T)

team2008 <- team %>%
  filter(season == 2008)

team_avg08 <- aggregate(team2008, by = list(team2008$team), FUN = mean, na.rm = T)

team2009 <- team %>%
  filter(season == 2009)

team_avg09 <- aggregate(team2009, by = list(team2009$team), FUN = mean, na.rm = T)

team2010 <- team %>%
  filter(season == 2010)

team_avg10 <- aggregate(team2010, by = list(team2010$team), FUN = mean, na.rm = T)

team2011 <- team %>%
  filter(season == 2011)

team_avg11 <- aggregate(team2011, by = list(team2011$team), FUN = mean, na.rm = T)

team2012 <- team %>%
  filter(season == 2012)

team_avg12 <- aggregate(team2012, by = list(team2012$team), FUN = mean, na.rm = T)

team2013 <- team %>%
  filter(season == 2013)

team_avg13 <- aggregate(team2013, by = list(team2013$team), FUN = mean, na.rm = T)

team2014 <- team %>%
  filter(season == 2014)

team_avg14 <- aggregate(team2014, by = list(team2014$team), FUN = mean, na.rm = T)

team2015 <- team %>%
  filter(season == 2015)

team_avg15 <- aggregate(team2015, by = list(team2015$team), FUN = mean, na.rm = T)

team2016 <- team %>%
  filter(season == 2016)

team_avg16 <- aggregate(team2016, by = list(team2016$team), FUN = mean, na.rm = T)
```


## 1-2) Train Data
```{r}
train_rs <- data.frame(RS_det$Season, RS_det$Wteam, RS_det$Lteam)
train_t <- data.frame(T_det$Season, T_det$Wteam, T_det$Lteam)

names(train_rs) <- c("Season", "Wteam", "Lteam")
names(train_t) <- c("Season", "Wteam", "Lteam")

train <- rbind(train_rs, train_t)
```

```{r}
train$FirstTeam <- pmin(train$Wteam, train$Lteam)
train$SecondTeam <- pmax(train$Wteam, train$Lteam)
train$FirstTeamWin <- 0
train$FirstTeamWin[train$Wteam == train$FirstTeam] <- 1
```

```{r}
train <- merge(train[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg16[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train)[4:18] <- paste("FirstTeam_avg_", names(train)[4:18], sep = "")

train <- merge(train, team_avg16[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train)[19:33] <- paste("SecondTeam_avg_", names(train)[19:33], sep = "")

train$scoredif <- train$FirstTeam_avg_score - train$SecondTeam_avg_score
train$fgmadedif <- train$FirstTeam_avg_fgmade - train$SecondTeam_avg_fgmade
train$fgattemptdif <- train$FirstTeam_avg_fgattempt - train$SecondTeam_avg_fgattempt
train$fgm3dif <- train$FirstTeam_avg_fgm3 - train$SecondTeam_avg_fgm3
train$fga3dif <- train$FirstTeam_avg_fga3 - train$SecondTeam_avg_fga3
train$ftmadedif <- train$FirstTeam_avg_ftmade - train$SecondTeam_avg_ftmade
train$ftattemptdif <- train$FirstTeam_avg_ftattempt - train$SecondTeam_avg_ftattempt
train$offrebdif <- train$FirstTeam_avg_offreb - train$SecondTeam_avg_offreb
train$defrebdif <- train$FirstTeam_avg_defreb - train$SecondTeam_avg_defreb
train$astdif <- train$FirstTeam_avg_ast - train$SecondTeam_avg_ast
train$turnoverdif <- train$FirstTeam_avg_turnover - train$SecondTeam_avg_turnover
train$stealdif <- train$FirstTeam_avg_steal - train$SecondTeam_avg_steal
train$blockdif <- train$FirstTeam_avg_block - train$SecondTeam_avg_block
train$pfouldif <- train$FirstTeam_avg_pfoul - train$SecondTeam_avg_pfoul
train$victorydif <- train$FirstTeam_avg_victory - train$SecondTeam_avg_victory
```





```{r}
train_season <- NULL
for(i in unique(team$season)){
  
  train_s <- train %>%
    filter(Season == i)
  
  team_avg_s <- team_avg %>%
    filter(season == i)
  
  train_s <- merge(train_s[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg_s[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train_s)[4:18] <- paste("FirstTeam_avg_", names(train_s)[4:18], sep = "")

  train_s <- merge(train_s, team_avg_s[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train_s)[19:33] <- paste("SecondTeam_avg_", names(train_s)[19:33], sep = "")

  train_s <- train_s %>%
    mutate(scoredif = FirstTeam_avg_score - SecondTeam_avg_score,
           fgmadedif = FirstTeam_avg_fgmade - SecondTeam_avg_fgmade,
           fgattemptdif = FirstTeam_avg_fgattempt - SecondTeam_avg_fgattempt,
           fgm3dif = FirstTeam_avg_fgm3 - SecondTeam_avg_fgm3,
           fga3dif = FirstTeam_avg_fga3 - SecondTeam_avg_fga3,
           ftmadedif = FirstTeam_avg_ftmade - SecondTeam_avg_ftmade,
           ftattemptdif = FirstTeam_avg_ftattempt - SecondTeam_avg_ftattempt,
           offrebdif = FirstTeam_avg_offreb - SecondTeam_avg_offreb,
           defrebdif = FirstTeam_avg_defreb - SecondTeam_avg_defreb,
           astdif = FirstTeam_avg_ast - SecondTeam_avg_ast,
           turnoverdif = FirstTeam_avg_turnover - SecondTeam_avg_turnover,
           stealdif = FirstTeam_avg_steal - SecondTeam_avg_steal,
           blockdif = FirstTeam_avg_block - SecondTeam_avg_block,
           pfouldif = FirstTeam_avg_pfoul - SecondTeam_avg_pfoul,
           victorydif = FirstTeam_avg_victory - SecondTeam_avg_victory)
  
  assign(paste0("train_", i), train_s)
  
  train_season <- rbind(train_season, train_s)
  
print(paste0("season",i,"is done"))
}
```


## 1-2-1) 2003
```{r}
train03 <- train %>%
  filter(Season == 2003)

train03 <- merge(train03[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg03[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train03)[4:18] <- paste("FirstTeam_avg_", names(train03)[4:18], sep = "")

train03 <- merge(train03, team_avg03[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train03)[19:33] <- paste("SecondTeam_avg_", names(train03)[19:33], sep = "")

train03$scoredif <- train03$FirstTeam_avg_score - train03$SecondTeam_avg_score
train03$fgmadedif <- train03$FirstTeam_avg_fgmade - train03$SecondTeam_avg_fgmade
train03$fgattemptdif <- train03$FirstTeam_avg_fgattempt - train03$SecondTeam_avg_fgattempt
train03$fgm3dif <- train03$FirstTeam_avg_fgm3 - train03$SecondTeam_avg_fgm3
train03$fga3dif <- train03$FirstTeam_avg_fga3 - train03$SecondTeam_avg_fga3
train03$ftmadedif <- train03$FirstTeam_avg_ftmade - train03$SecondTeam_avg_ftmade
train03$ftattemptdif <- train03$FirstTeam_avg_ftattempt - train03$SecondTeam_avg_ftattempt
train03$offrebdif <- train03$FirstTeam_avg_offreb - train03$SecondTeam_avg_offreb
train03$defrebdif <- train03$FirstTeam_avg_defreb - train03$SecondTeam_avg_defreb
train03$astdif <- train03$FirstTeam_avg_ast - train03$SecondTeam_avg_ast
train03$turnoverdif <- train03$FirstTeam_avg_turnover - train03$SecondTeam_avg_turnover
train03$stealdif <- train03$FirstTeam_avg_steal - train03$SecondTeam_avg_steal
train03$blockdif <- train03$FirstTeam_avg_block - train03$SecondTeam_avg_block
train03$pfouldif <- train03$FirstTeam_avg_pfoul - train03$SecondTeam_avg_pfoul
train03$victorydif <- train03$FirstTeam_avg_victory - train03$SecondTeam_avg_victory
```

## 1-2-2) 2004
```{r}
train04 <- train %>%
  filter(Season == 2004)

train04 <- merge(train04[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg04[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train04)[4:18] <- paste("FirstTeam_avg_", names(train04)[4:18], sep = "")

train04 <- merge(train04, team_avg04[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train04)[19:33] <- paste("SecondTeam_avg_", names(train04)[19:33], sep = "")

train04$scoredif <- train04$FirstTeam_avg_score - train04$SecondTeam_avg_score
train04$fgmadedif <- train04$FirstTeam_avg_fgmade - train04$SecondTeam_avg_fgmade
train04$fgattemptdif <- train04$FirstTeam_avg_fgattempt - train04$SecondTeam_avg_fgattempt
train04$fgm3dif <- train04$FirstTeam_avg_fgm3 - train04$SecondTeam_avg_fgm3
train04$fga3dif <- train04$FirstTeam_avg_fga3 - train04$SecondTeam_avg_fga3
train04$ftmadedif <- train04$FirstTeam_avg_ftmade - train04$SecondTeam_avg_ftmade
train04$ftattemptdif <- train04$FirstTeam_avg_ftattempt - train04$SecondTeam_avg_ftattempt
train04$offrebdif <- train04$FirstTeam_avg_offreb - train04$SecondTeam_avg_offreb
train04$defrebdif <- train04$FirstTeam_avg_defreb - train04$SecondTeam_avg_defreb
train04$astdif <- train04$FirstTeam_avg_ast - train04$SecondTeam_avg_ast
train04$turnoverdif <- train04$FirstTeam_avg_turnover - train04$SecondTeam_avg_turnover
train04$stealdif <- train04$FirstTeam_avg_steal - train04$SecondTeam_avg_steal
train04$blockdif <- train04$FirstTeam_avg_block - train04$SecondTeam_avg_block
train04$pfouldif <- train04$FirstTeam_avg_pfoul - train04$SecondTeam_avg_pfoul
train04$victorydif <- train04$FirstTeam_avg_victory - train04$SecondTeam_avg_victory
```

## 1-2-3) 2005
```{r}
train05 <- train %>%
  filter(Season == 2005)

train05 <- merge(train05[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg05[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train05)[4:18] <- paste("FirstTeam_avg_", names(train05)[4:18], sep = "")

train05 <- merge(train05, team_avg05[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train05)[19:33] <- paste("SecondTeam_avg_", names(train05)[19:33], sep = "")

train05$scoredif <- train05$FirstTeam_avg_score - train05$SecondTeam_avg_score
train05$fgmadedif <- train05$FirstTeam_avg_fgmade - train05$SecondTeam_avg_fgmade
train05$fgattemptdif <- train05$FirstTeam_avg_fgattempt - train05$SecondTeam_avg_fgattempt
train05$fgm3dif <- train05$FirstTeam_avg_fgm3 - train05$SecondTeam_avg_fgm3
train05$fga3dif <- train05$FirstTeam_avg_fga3 - train05$SecondTeam_avg_fga3
train05$ftmadedif <- train05$FirstTeam_avg_ftmade - train05$SecondTeam_avg_ftmade
train05$ftattemptdif <- train05$FirstTeam_avg_ftattempt - train05$SecondTeam_avg_ftattempt
train05$offrebdif <- train05$FirstTeam_avg_offreb - train05$SecondTeam_avg_offreb
train05$defrebdif <- train05$FirstTeam_avg_defreb - train05$SecondTeam_avg_defreb
train05$astdif <- train05$FirstTeam_avg_ast - train05$SecondTeam_avg_ast
train05$turnoverdif <- train05$FirstTeam_avg_turnover - train05$SecondTeam_avg_turnover
train05$stealdif <- train05$FirstTeam_avg_steal - train05$SecondTeam_avg_steal
train05$blockdif <- train05$FirstTeam_avg_block - train05$SecondTeam_avg_block
train05$pfouldif <- train05$FirstTeam_avg_pfoul - train05$SecondTeam_avg_pfoul
train05$victorydif <- train05$FirstTeam_avg_victory - train05$SecondTeam_avg_victory
```

## 1-2-4) 2006
```{r}
train06 <- train %>%
  filter(Season == 2006)

train06 <- merge(train06[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg06[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train06)[4:18] <- paste("FirstTeam_avg_", names(train06)[4:18], sep = "")

train06 <- merge(train06, team_avg06[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train06)[19:33] <- paste("SecondTeam_avg_", names(train06)[19:33], sep = "")

train06$scoredif <- train06$FirstTeam_avg_score - train06$SecondTeam_avg_score
train06$fgmadedif <- train06$FirstTeam_avg_fgmade - train06$SecondTeam_avg_fgmade
train06$fgattemptdif <- train06$FirstTeam_avg_fgattempt - train06$SecondTeam_avg_fgattempt
train06$fgm3dif <- train06$FirstTeam_avg_fgm3 - train06$SecondTeam_avg_fgm3
train06$fga3dif <- train06$FirstTeam_avg_fga3 - train06$SecondTeam_avg_fga3
train06$ftmadedif <- train06$FirstTeam_avg_ftmade - train06$SecondTeam_avg_ftmade
train06$ftattemptdif <- train06$FirstTeam_avg_ftattempt - train06$SecondTeam_avg_ftattempt
train06$offrebdif <- train06$FirstTeam_avg_offreb - train06$SecondTeam_avg_offreb
train06$defrebdif <- train06$FirstTeam_avg_defreb - train06$SecondTeam_avg_defreb
train06$astdif <- train06$FirstTeam_avg_ast - train06$SecondTeam_avg_ast
train06$turnoverdif <- train06$FirstTeam_avg_turnover - train06$SecondTeam_avg_turnover
train06$stealdif <- train06$FirstTeam_avg_steal - train06$SecondTeam_avg_steal
train06$blockdif <- train06$FirstTeam_avg_block - train06$SecondTeam_avg_block
train06$pfouldif <- train06$FirstTeam_avg_pfoul - train06$SecondTeam_avg_pfoul
train06$victorydif <- train06$FirstTeam_avg_victory - train06$SecondTeam_avg_victory
```

## 1-2-5) 2007
```{r}
train07 <- train %>%
  filter(Season == 2007)

train07 <- merge(train07[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg07[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train07)[4:18] <- paste("FirstTeam_avg_", names(train07)[4:18], sep = "")

train07 <- merge(train07, team_avg07[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train07)[19:33] <- paste("SecondTeam_avg_", names(train07)[19:33], sep = "")

train07$scoredif <- train07$FirstTeam_avg_score - train07$SecondTeam_avg_score
train07$fgmadedif <- train07$FirstTeam_avg_fgmade - train07$SecondTeam_avg_fgmade
train07$fgattemptdif <- train07$FirstTeam_avg_fgattempt - train07$SecondTeam_avg_fgattempt
train07$fgm3dif <- train07$FirstTeam_avg_fgm3 - train07$SecondTeam_avg_fgm3
train07$fga3dif <- train07$FirstTeam_avg_fga3 - train07$SecondTeam_avg_fga3
train07$ftmadedif <- train07$FirstTeam_avg_ftmade - train07$SecondTeam_avg_ftmade
train07$ftattemptdif <- train07$FirstTeam_avg_ftattempt - train07$SecondTeam_avg_ftattempt
train07$offrebdif <- train07$FirstTeam_avg_offreb - train07$SecondTeam_avg_offreb
train07$defrebdif <- train07$FirstTeam_avg_defreb - train07$SecondTeam_avg_defreb
train07$astdif <- train07$FirstTeam_avg_ast - train07$SecondTeam_avg_ast
train07$turnoverdif <- train07$FirstTeam_avg_turnover - train07$SecondTeam_avg_turnover
train07$stealdif <- train07$FirstTeam_avg_steal - train07$SecondTeam_avg_steal
train07$blockdif <- train07$FirstTeam_avg_block - train07$SecondTeam_avg_block
train07$pfouldif <- train07$FirstTeam_avg_pfoul - train07$SecondTeam_avg_pfoul
train07$victorydif <- train07$FirstTeam_avg_victory - train07$SecondTeam_avg_victory
```

## 1-2-6) 2008
```{r}
train08 <- train %>%
  filter(Season == 2008)

train08 <- merge(train08[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg08[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train08)[4:18] <- paste("FirstTeam_avg_", names(train08)[4:18], sep = "")

train08 <- merge(train08, team_avg08[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train08)[19:33] <- paste("SecondTeam_avg_", names(train08)[19:33], sep = "")

train08$scoredif <- train08$FirstTeam_avg_score - train08$SecondTeam_avg_score
train08$fgmadedif <- train08$FirstTeam_avg_fgmade - train08$SecondTeam_avg_fgmade
train08$fgattemptdif <- train08$FirstTeam_avg_fgattempt - train08$SecondTeam_avg_fgattempt
train08$fgm3dif <- train08$FirstTeam_avg_fgm3 - train08$SecondTeam_avg_fgm3
train08$fga3dif <- train08$FirstTeam_avg_fga3 - train08$SecondTeam_avg_fga3
train08$ftmadedif <- train08$FirstTeam_avg_ftmade - train08$SecondTeam_avg_ftmade
train08$ftattemptdif <- train08$FirstTeam_avg_ftattempt - train08$SecondTeam_avg_ftattempt
train08$offrebdif <- train08$FirstTeam_avg_offreb - train08$SecondTeam_avg_offreb
train08$defrebdif <- train08$FirstTeam_avg_defreb - train08$SecondTeam_avg_defreb
train08$astdif <- train08$FirstTeam_avg_ast - train08$SecondTeam_avg_ast
train08$turnoverdif <- train08$FirstTeam_avg_turnover - train08$SecondTeam_avg_turnover
train08$stealdif <- train08$FirstTeam_avg_steal - train08$SecondTeam_avg_steal
train08$blockdif <- train08$FirstTeam_avg_block - train08$SecondTeam_avg_block
train08$pfouldif <- train08$FirstTeam_avg_pfoul - train08$SecondTeam_avg_pfoul
train08$victorydif <- train08$FirstTeam_avg_victory - train08$SecondTeam_avg_victory
```

## 1-2-7) 2009
```{r}
train09 <- train %>%
  filter(Season == 2009)

train09 <- merge(train09[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg09[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train09)[4:18] <- paste("FirstTeam_avg_", names(train09)[4:18], sep = "")

train09 <- merge(train09, team_avg09[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train09)[19:33] <- paste("SecondTeam_avg_", names(train09)[19:33], sep = "")

train09$scoredif <- train09$FirstTeam_avg_score - train09$SecondTeam_avg_score
train09$fgmadedif <- train09$FirstTeam_avg_fgmade - train09$SecondTeam_avg_fgmade
train09$fgattemptdif <- train09$FirstTeam_avg_fgattempt - train09$SecondTeam_avg_fgattempt
train09$fgm3dif <- train09$FirstTeam_avg_fgm3 - train09$SecondTeam_avg_fgm3
train09$fga3dif <- train09$FirstTeam_avg_fga3 - train09$SecondTeam_avg_fga3
train09$ftmadedif <- train09$FirstTeam_avg_ftmade - train09$SecondTeam_avg_ftmade
train09$ftattemptdif <- train09$FirstTeam_avg_ftattempt - train09$SecondTeam_avg_ftattempt
train09$offrebdif <- train09$FirstTeam_avg_offreb - train09$SecondTeam_avg_offreb
train09$defrebdif <- train09$FirstTeam_avg_defreb - train09$SecondTeam_avg_defreb
train09$astdif <- train09$FirstTeam_avg_ast - train09$SecondTeam_avg_ast
train09$turnoverdif <- train09$FirstTeam_avg_turnover - train09$SecondTeam_avg_turnover
train09$stealdif <- train09$FirstTeam_avg_steal - train09$SecondTeam_avg_steal
train09$blockdif <- train09$FirstTeam_avg_block - train09$SecondTeam_avg_block
train09$pfouldif <- train09$FirstTeam_avg_pfoul - train09$SecondTeam_avg_pfoul
train09$victorydif <- train09$FirstTeam_avg_victory - train09$SecondTeam_avg_victory
```

## 1-2-8) 2010
```{r}
train10 <- train %>%
  filter(Season == 2010)

train10 <- merge(train10[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg10[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train10)[4:18] <- paste("FirstTeam_avg_", names(train10)[4:18], sep = "")

train10 <- merge(train10, team_avg10[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train10)[19:33] <- paste("SecondTeam_avg_", names(train10)[19:33], sep = "")

train10$scoredif <- train10$FirstTeam_avg_score - train10$SecondTeam_avg_score
train10$fgmadedif <- train10$FirstTeam_avg_fgmade - train10$SecondTeam_avg_fgmade
train10$fgattemptdif <- train10$FirstTeam_avg_fgattempt - train10$SecondTeam_avg_fgattempt
train10$fgm3dif <- train10$FirstTeam_avg_fgm3 - train10$SecondTeam_avg_fgm3
train10$fga3dif <- train10$FirstTeam_avg_fga3 - train10$SecondTeam_avg_fga3
train10$ftmadedif <- train10$FirstTeam_avg_ftmade - train10$SecondTeam_avg_ftmade
train10$ftattemptdif <- train10$FirstTeam_avg_ftattempt - train10$SecondTeam_avg_ftattempt
train10$offrebdif <- train10$FirstTeam_avg_offreb - train10$SecondTeam_avg_offreb
train10$defrebdif <- train10$FirstTeam_avg_defreb - train10$SecondTeam_avg_defreb
train10$astdif <- train10$FirstTeam_avg_ast - train10$SecondTeam_avg_ast
train10$turnoverdif <- train10$FirstTeam_avg_turnover - train10$SecondTeam_avg_turnover
train10$stealdif <- train10$FirstTeam_avg_steal - train10$SecondTeam_avg_steal
train10$blockdif <- train10$FirstTeam_avg_block - train10$SecondTeam_avg_block
train10$pfouldif <- train10$FirstTeam_avg_pfoul - train10$SecondTeam_avg_pfoul
train10$victorydif <- train10$FirstTeam_avg_victory - train10$SecondTeam_avg_victory
```

## 1-2-9) 2011
```{r}
train11 <- train %>%
  filter(Season == 2011)

train11 <- merge(train11[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg11[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train11)[4:18] <- paste("FirstTeam_avg_", names(train11)[4:18], sep = "")

train11 <- merge(train11, team_avg11[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train11)[19:33] <- paste("SecondTeam_avg_", names(train11)[19:33], sep = "")

train11$scoredif <- train11$FirstTeam_avg_score - train11$SecondTeam_avg_score
train11$fgmadedif <- train11$FirstTeam_avg_fgmade - train11$SecondTeam_avg_fgmade
train11$fgattemptdif <- train11$FirstTeam_avg_fgattempt - train11$SecondTeam_avg_fgattempt
train11$fgm3dif <- train11$FirstTeam_avg_fgm3 - train11$SecondTeam_avg_fgm3
train11$fga3dif <- train11$FirstTeam_avg_fga3 - train11$SecondTeam_avg_fga3
train11$ftmadedif <- train11$FirstTeam_avg_ftmade - train11$SecondTeam_avg_ftmade
train11$ftattemptdif <- train11$FirstTeam_avg_ftattempt - train11$SecondTeam_avg_ftattempt
train11$offrebdif <- train11$FirstTeam_avg_offreb - train11$SecondTeam_avg_offreb
train11$defrebdif <- train11$FirstTeam_avg_defreb - train11$SecondTeam_avg_defreb
train11$astdif <- train11$FirstTeam_avg_ast - train11$SecondTeam_avg_ast
train11$turnoverdif <- train11$FirstTeam_avg_turnover - train11$SecondTeam_avg_turnover
train11$stealdif <- train11$FirstTeam_avg_steal - train11$SecondTeam_avg_steal
train11$blockdif <- train11$FirstTeam_avg_block - train11$SecondTeam_avg_block
train11$pfouldif <- train11$FirstTeam_avg_pfoul - train11$SecondTeam_avg_pfoul
train11$victorydif <- train11$FirstTeam_avg_victory - train11$SecondTeam_avg_victory
```

## 1-2-10) 2012
```{r}
train12 <- train %>%
  filter(Season == 2012)

train12 <- merge(train12[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg12[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train12)[4:18] <- paste("FirstTeam_avg_", names(train12)[4:18], sep = "")

train12 <- merge(train12, team_avg12[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train12)[19:33] <- paste("SecondTeam_avg_", names(train12)[19:33], sep = "")

train12$scoredif <- train12$FirstTeam_avg_score - train12$SecondTeam_avg_score
train12$fgmadedif <- train12$FirstTeam_avg_fgmade - train12$SecondTeam_avg_fgmade
train12$fgattemptdif <- train12$FirstTeam_avg_fgattempt - train12$SecondTeam_avg_fgattempt
train12$fgm3dif <- train12$FirstTeam_avg_fgm3 - train12$SecondTeam_avg_fgm3
train12$fga3dif <- train12$FirstTeam_avg_fga3 - train12$SecondTeam_avg_fga3
train12$ftmadedif <- train12$FirstTeam_avg_ftmade - train12$SecondTeam_avg_ftmade
train12$ftattemptdif <- train12$FirstTeam_avg_ftattempt - train12$SecondTeam_avg_ftattempt
train12$offrebdif <- train12$FirstTeam_avg_offreb - train12$SecondTeam_avg_offreb
train12$defrebdif <- train12$FirstTeam_avg_defreb - train12$SecondTeam_avg_defreb
train12$astdif <- train12$FirstTeam_avg_ast - train12$SecondTeam_avg_ast
train12$turnoverdif <- train12$FirstTeam_avg_turnover - train12$SecondTeam_avg_turnover
train12$stealdif <- train12$FirstTeam_avg_steal - train12$SecondTeam_avg_steal
train12$blockdif <- train12$FirstTeam_avg_block - train12$SecondTeam_avg_block
train12$pfouldif <- train12$FirstTeam_avg_pfoul - train12$SecondTeam_avg_pfoul
train12$victorydif <- train12$FirstTeam_avg_victory - train12$SecondTeam_avg_victory
```

## 1-2-11) 2013
```{r}
train13 <- train %>%
  filter(Season == 2013)

train13 <- merge(train13[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg13[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train13)[4:18] <- paste("FirstTeam_avg_", names(train13)[4:18], sep = "")

train13 <- merge(train13, team_avg13[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train13)[19:33] <- paste("SecondTeam_avg_", names(train13)[19:33], sep = "")

train13$scoredif <- train13$FirstTeam_avg_score - train13$SecondTeam_avg_score
train13$fgmadedif <- train13$FirstTeam_avg_fgmade - train13$SecondTeam_avg_fgmade
train13$fgattemptdif <- train13$FirstTeam_avg_fgattempt - train13$SecondTeam_avg_fgattempt
train13$fgm3dif <- train13$FirstTeam_avg_fgm3 - train13$SecondTeam_avg_fgm3
train13$fga3dif <- train13$FirstTeam_avg_fga3 - train13$SecondTeam_avg_fga3
train13$ftmadedif <- train13$FirstTeam_avg_ftmade - train13$SecondTeam_avg_ftmade
train13$ftattemptdif <- train13$FirstTeam_avg_ftattempt - train13$SecondTeam_avg_ftattempt
train13$offrebdif <- train13$FirstTeam_avg_offreb - train13$SecondTeam_avg_offreb
train13$defrebdif <- train13$FirstTeam_avg_defreb - train13$SecondTeam_avg_defreb
train13$astdif <- train13$FirstTeam_avg_ast - train13$SecondTeam_avg_ast
train13$turnoverdif <- train13$FirstTeam_avg_turnover - train13$SecondTeam_avg_turnover
train13$stealdif <- train13$FirstTeam_avg_steal - train13$SecondTeam_avg_steal
train13$blockdif <- train13$FirstTeam_avg_block - train13$SecondTeam_avg_block
train13$pfouldif <- train13$FirstTeam_avg_pfoul - train13$SecondTeam_avg_pfoul
train13$victorydif <- train13$FirstTeam_avg_victory - train13$SecondTeam_avg_victory
```

## 1-2-12) 2014
```{r}
train14 <- train %>%
  filter(Season == 2014)

train14 <- merge(train14[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg14[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train14)[4:18] <- paste("FirstTeam_avg_", names(train14)[4:18], sep = "")

train14 <- merge(train14, team_avg14[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train14)[19:33] <- paste("SecondTeam_avg_", names(train14)[19:33], sep = "")

train14$scoredif <- train14$FirstTeam_avg_score - train14$SecondTeam_avg_score
train14$fgmadedif <- train14$FirstTeam_avg_fgmade - train14$SecondTeam_avg_fgmade
train14$fgattemptdif <- train14$FirstTeam_avg_fgattempt - train14$SecondTeam_avg_fgattempt
train14$fgm3dif <- train14$FirstTeam_avg_fgm3 - train14$SecondTeam_avg_fgm3
train14$fga3dif <- train14$FirstTeam_avg_fga3 - train14$SecondTeam_avg_fga3
train14$ftmadedif <- train14$FirstTeam_avg_ftmade - train14$SecondTeam_avg_ftmade
train14$ftattemptdif <- train14$FirstTeam_avg_ftattempt - train14$SecondTeam_avg_ftattempt
train14$offrebdif <- train14$FirstTeam_avg_offreb - train14$SecondTeam_avg_offreb
train14$defrebdif <- train14$FirstTeam_avg_defreb - train14$SecondTeam_avg_defreb
train14$astdif <- train14$FirstTeam_avg_ast - train14$SecondTeam_avg_ast
train14$turnoverdif <- train14$FirstTeam_avg_turnover - train14$SecondTeam_avg_turnover
train14$stealdif <- train14$FirstTeam_avg_steal - train14$SecondTeam_avg_steal
train14$blockdif <- train14$FirstTeam_avg_block - train14$SecondTeam_avg_block
train14$pfouldif <- train14$FirstTeam_avg_pfoul - train14$SecondTeam_avg_pfoul
train14$victorydif <- train14$FirstTeam_avg_victory - train14$SecondTeam_avg_victory
```

## 1-2-13) 2015
```{r}
train15 <- train %>%
  filter(Season == 2015)

train15 <- merge(train15[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg15[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train15)[4:18] <- paste("FirstTeam_avg_", names(train15)[4:18], sep = "")

train15 <- merge(train15, team_avg15[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train15)[19:33] <- paste("SecondTeam_avg_", names(train15)[19:33], sep = "")

train15$scoredif <- train15$FirstTeam_avg_score - train15$SecondTeam_avg_score
train15$fgmadedif <- train15$FirstTeam_avg_fgmade - train15$SecondTeam_avg_fgmade
train15$fgattemptdif <- train15$FirstTeam_avg_fgattempt - train15$SecondTeam_avg_fgattempt
train15$fgm3dif <- train15$FirstTeam_avg_fgm3 - train15$SecondTeam_avg_fgm3
train15$fga3dif <- train15$FirstTeam_avg_fga3 - train15$SecondTeam_avg_fga3
train15$ftmadedif <- train15$FirstTeam_avg_ftmade - train15$SecondTeam_avg_ftmade
train15$ftattemptdif <- train15$FirstTeam_avg_ftattempt - train15$SecondTeam_avg_ftattempt
train15$offrebdif <- train15$FirstTeam_avg_offreb - train15$SecondTeam_avg_offreb
train15$defrebdif <- train15$FirstTeam_avg_defreb - train15$SecondTeam_avg_defreb
train15$astdif <- train15$FirstTeam_avg_ast - train15$SecondTeam_avg_ast
train15$turnoverdif <- train15$FirstTeam_avg_turnover - train15$SecondTeam_avg_turnover
train15$stealdif <- train15$FirstTeam_avg_steal - train15$SecondTeam_avg_steal
train15$blockdif <- train15$FirstTeam_avg_block - train15$SecondTeam_avg_block
train15$pfouldif <- train15$FirstTeam_avg_pfoul - train15$SecondTeam_avg_pfoul
train15$victorydif <- train15$FirstTeam_avg_victory - train15$SecondTeam_avg_victory
```

## 1-2-15) 2016
```{r}
train16 <- train %>%
  filter(Season == 2016)

train16 <- merge(train16[, c("FirstTeam", "SecondTeam", "FirstTeamWin")], team_avg16[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team"))
names(train16)[4:18] <- paste("FirstTeam_avg_", names(train16)[4:18], sep = "")

train16 <- merge(train16, team_avg16[, c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(train16)[19:33] <- paste("SecondTeam_avg_", names(train16)[19:33], sep = "")

train16$scoredif <- train16$FirstTeam_avg_score - train16$SecondTeam_avg_score
train16$fgmadedif <- train16$FirstTeam_avg_fgmade - train16$SecondTeam_avg_fgmade
train16$fgattemptdif <- train16$FirstTeam_avg_fgattempt - train16$SecondTeam_avg_fgattempt
train16$fgm3dif <- train16$FirstTeam_avg_fgm3 - train16$SecondTeam_avg_fgm3
train16$fga3dif <- train16$FirstTeam_avg_fga3 - train16$SecondTeam_avg_fga3
train16$ftmadedif <- train16$FirstTeam_avg_ftmade - train16$SecondTeam_avg_ftmade
train16$ftattemptdif <- train16$FirstTeam_avg_ftattempt - train16$SecondTeam_avg_ftattempt
train16$offrebdif <- train16$FirstTeam_avg_offreb - train16$SecondTeam_avg_offreb
train16$defrebdif <- train16$FirstTeam_avg_defreb - train16$SecondTeam_avg_defreb
train16$astdif <- train16$FirstTeam_avg_ast - train16$SecondTeam_avg_ast
train16$turnoverdif <- train16$FirstTeam_avg_turnover - train16$SecondTeam_avg_turnover
train16$stealdif <- train16$FirstTeam_avg_steal - train16$SecondTeam_avg_steal
train16$blockdif <- train16$FirstTeam_avg_block - train16$SecondTeam_avg_block
train16$pfouldif <- train16$FirstTeam_avg_pfoul - train16$SecondTeam_avg_pfoul
train16$victorydif <- train16$FirstTeam_avg_victory - train16$SecondTeam_avg_victory
```

```{r}
train <- rbind(train03, train04, train05, train06, train07, train08, train09, train10, train11, train12, train13, train14, train15, train16)
```


## 1-3) Sum(Score / Rebound)
```{r}
team_sum <- aggregate(team2016, by = list(team2016$team), FUN = sum, na.rm = T)
team_sum <- team_sum %>%
  mutate(reb = offreb + defreb) %>%
  select(-offreb, -defreb)

train <- merge(train, team_sum[, c("Group.1", "score" ,"reb", "pfoul")], by.x = c("FirstTeam"), by.y = c("Group.1"))
names(train)[49:51] <- paste("FirstTeam_sum_", names(train)[49:51], sep = "")

train <- merge(train, team_sum[, c("Group.1", "score","reb", "pfoul")], by.x = c("SecondTeam"), by.y = c("Group.1"))
names(train)[52:54] <- paste("SecondTeam_sum_", names(train)[52:54], sep = "")

train$sum_scoredif <- train$FirstTeam_sum_score - train$SecondTeam_sum_score
train$sum_rebdif <- train$FirstTeam_sum_reb - train$SecondTeam_sum_reb
train$sum_pfouldif <- train$FirstTeam_sum_pfoul - train$SecondTeam_sum_pfoul
```


## 1-4) Prob
```{r}
train$FirstTeam_fgprob <- train$FirstTeam_avg_fgmade / train$FirstTeam_avg_fgattempt
train$SecondTeam_fgprob <- train$SecondTeam_avg_fgmade / train$SecondTeam_avg_fgattempt
train$FirstTeam_fg3prob <- train$FirstTeam_avg_fgm3 / train$FirstTeam_avg_fga3
train$SecondTeam_fg3prob <- train$SecondTeam_avg_fgm3 / train$SecondTeam_avg_fga3

train$prob_fgdif <- train$FirstTeam_fgprob - train$SecondTeam_fgprob
train$prob_fg3dif <- train$FirstTeam_fg3prob - train$SecondTeam_fg3prob
```

## 1-5) Seed
```{r}
unique(seeds$Season)
seeds$pureSeed <- as.numeric(substr(seeds$Seed, 2, 3)) # Extract the substring form the 'seed' value starting with the second character and going to the third character, then convert to a numeric and stroe as new variable "pureSeed"
seeds$region <- as.character(substr(seeds$Seed, 1, 1)) # Extract the region as well, which we'll need fo calcualting dates of games later
head(seeds)
```

```{r}
team2016 %>%
    left_join(y = seeds[,c("Season", "Team", "pureSeed")], by = c("season" = "Season", "team" = "Team")) %>%
    arrange(team) -> seed16
#Team_History_16_Seed$pureSeed[is.na(Team_History_16_Seed$pureSeed) == TRUE] <- 20
```

```{r}
# Calculate Winning_Rate  
# NO Seed
seed16 %>% 
    filter(is.na(seed16$pureSeed) == TRUE) %>%
    group_by(team, victory) %>%
    summarise(Count = n()) %>% 
    mutate(Winning_Rate = Count / sum(Count)) %>%
    filter(victory == 1) %>%
    arrange(-Winning_Rate) %>%
    ungroup() %>%
    mutate(pureSeed = c(rep(17:86, each = 4), c(rep(87,3)))) %>%
    dplyr::select(team, pureSeed) -> Seed_No

#Yes Seed 
seed16 %>% 
    filter(is.na(seed16$pureSeed) == FALSE) %>%
    group_by(team, pureSeed)%>%
    summarise(Count = n()) %>%
    dplyr::select(team, pureSeed) %>%
    ungroup() %>%
    arrange(pureSeed) -> Seed_Yes

#rbind Each Seed Data
Team_History_16_Seed_intp <- NULL
Team_History_16_Seed_intp <- rbind(Seed_Yes, Seed_No)

#Assemble Team_History Data
train <- merge(train,  
               Team_History_16_Seed_intp, 
               by.x = c("FirstTeam"), by.y = c("team"))
names(train)[49] <- paste("FirstTeam_", names(train)[49], sep = "")
train <- merge(train,  
               Team_History_16_Seed_intp, 
               by.x = c("SecondTeam"), by.y = c("team"))
names(train)[50] <- paste("SecondTeam_", names(train)[50], sep = "")

train$seeddif <- train$FirstTeam_pureSeed - train$SecondTeam_pureSeed
```


## 1-6) Test Data
```{r}
test <- cbind(submission$Id, colsplit(submission$Id, "_", names = c("Season", "FirstTeam", "SecondTeam")))

test <- merge(test, team_avg16[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("FirstTeam"), by.y = c("team")) 
names(test)[5:19] <- paste("FirstTeam_avg_", names(test)[5:19], sep = "")

test <- merge(test, team_avg16[ ,c("team", "score", "fgmade", "fgattempt", "fgm3", "fga3", "ftmade", "ftattempt", "offreb", "defreb", "ast", "turnover", "steal", "block", "pfoul", "victory")], by.x = c("SecondTeam"), by.y = c("team"))
names(test)[20:34] <- paste("SecondTeam_avg_", names(test)[20:34], sep = "")
```

```{r}
test$scoredif <- test$FirstTeam_avg_score - test$SecondTeam_avg_score
test$fgmadedif <- test$FirstTeam_avg_fgmade - test$SecondTeam_avg_fgmade
test$fgattemptdif <- test$FirstTeam_avg_fgattempt - test$SecondTeam_avg_fgattempt
test$fgm3dif <- test$FirstTeam_avg_fgm3 - test$SecondTeam_avg_fgm3
test$fga3dif <- test$FirstTeam_avg_fga3 - test$SecondTeam_avg_fga3
test$ftmadedif <- test$FirstTeam_avg_ftmade - test$SecondTeam_avg_ftmade
test$ftattemptdif <- test$FirstTeam_avg_ftattempt - test$SecondTeam_avg_ftattempt
test$offrebdif <- test$FirstTeam_avg_offreb - test$SecondTeam_avg_offreb
test$defrebdif <- test$FirstTeam_avg_defreb - test$SecondTeam_avg_defreb
test$astdif <- test$FirstTeam_avg_ast - test$SecondTeam_avg_ast
test$turnoverdif <- test$FirstTeam_avg_turnover - test$SecondTeam_avg_turnover
test$stealdif <- test$FirstTeam_avg_steal - test$SecondTeam_avg_steal
test$blockdif <- test$FirstTeam_avg_block - test$SecondTeam_avg_block
test$pfouldif <- test$FirstTeam_avg_pfoul - test$SecondTeam_avg_pfoul
test$victorydif <- test$FirstTeam_avg_victory - test$SecondTeam_avg_victory
```

```{r}
test <- merge(test, team_sum[, c("Group.1", "score", "reb", "pfoul")], by.x = c("FirstTeam"), by.y = c("Group.1"))
names(test)[50:52] <- paste("FirstTeam_sum_", names(test)[50:52], sep = "")

test <- merge(test, team_sum[, c("Group.1", "score", "reb", "pfoul")], by.x = c("SecondTeam"), by.y = c("Group.1"))
names(test)[53:55] <- paste("SecondTeam_sum_", names(test)[53:55], sep = "")

test$sum_scoredif <- test$FirstTeam_sum_score - test$SecondTeam_sum_score
test$sum_rebdif <- test$FirstTeam_sum_reb - test$SecondTeam_sum_reb
test$sum_pfouldif <- test$FirstTeam_sum_pfoul - test$SecondTeam_sum_pfoul
```

```{r}
test$FirstTeam_fgprob <- test$FirstTeam_avg_fgmade / test$FirstTeam_avg_fgattempt
test$SecondTeam_fgprob <- test$SecondTeam_avg_fgmade / test$SecondTeam_avg_fgattempt
test$FirstTeam_fg3prob <- test$FirstTeam_avg_fgm3 / test$FirstTeam_avg_fga3
test$SecondTeam_fg3prob <- test$SecondTeam_avg_fgm3 / test$SecondTeam_avg_fga3

test$prob_fgdif <- test$FirstTeam_fgprob - test$SecondTeam_fgprob
test$prob_fg3dif <- test$FirstTeam_fg3prob - test$SecondTeam_fg3prob
```

```{r}
test <- merge(test,  
               Team_History_16_Seed_intp, 
               by.x = c("FirstTeam"), by.y = c("team"))
names(test)[50] <- paste("FirstTeam_", names(test)[50], sep = "")
test <- merge(test,  
               Team_History_16_Seed_intp, 
               by.x = c("SecondTeam"), by.y = c("team"))
names(test)[51] <- paste("SecondTeam_", names(test)[51], sep = "")

test$seeddif <- test$FirstTeam_pureSeed - test$SecondTeam_pureSeed
```


# 2. XGBoost Model
```{r}
test$FirstTeamWin <- rep(0:1, 1139)

train$FirstTeamWin <- as.factor(train$FirstTeamWin)
test$FirstTeamWin <- as.factor(test$FirstTeamWin)

trainLabel <- as.numeric(train$FirstTeamWin) - 1
```

```{r}
trainMat <- model.matrix(FirstTeamWin ~ scoredif + fgmadedif + fgattemptdif + fgm3dif + fga3dif + ftattemptdif + offrebdif + defrebdif + astdif + turnoverdif + stealdif +blockdif + pfouldif + victorydif + sum_scoredif + sum_rebdif + sum_pfouldif, data = train)
testMat <- model.matrix(FirstTeamWin ~ scoredif + fgmadedif + fgattemptdif + fgm3dif + fga3dif + ftattemptdif + offrebdif + defrebdif + astdif + turnoverdif + stealdif +blockdif + pfouldif + victorydif + sum_scoredif + sum_rebdif + sum_pfouldif, data = test)
```

```{r}
trainMat <- model.matrix(FirstTeamWin ~ victorydif + defrebdif + stealdif + prob_fg3dif + seeddif, data = train)
testMat <- model.matrix(FirstTeamWin ~ victorydif + defrebdif + stealdif + prob_fg3dif + seeddif, data = test)
```

```{r}
trainMat <- model.matrix(FirstTeamWin ~ victorydif, data = train)
testMat <- model.matrix(FirstTeamWin ~ victorydif, data = test)
```


```{r}
params <- list(eta = 0.3, max.depth = 1,
               gamma = 0, colsample_bytree = 1,
               subsample = 1,
               objective = "binary:logistic",
               eval_metric = "logloss")
```

```{r}
set.seed(1234)
xgbcv <- xgb.cv(params = params,
                nrounds = 40,
                nfold = 10,
                metrics = "logloss",
                data = trainMat,
                label = trainLabel,
                verbose = 1)
xgb.best <- arrange(xgbcv$evaluation_log, test_logloss_mean)[1, ]
xgb.best
```

```{r}
set.seed(1)
MMLM_xgboost <- xgboost(params = params,
                          data = trainMat,
                          label = trainLabel,
                          nrounds = 0,
                          verbose = 1)
xgb_pred <- predict(MMLM_xgboost, testMat)

#xgb.best$iter

submission <- data.frame(Id = test$'submission$Id', Pred = xgb_pred)
write.csv(submission, "submission_vic16_n0_d1.csv", row.names = FALSE)
```

# 3. Logistic Regression Model
```{r}
MMLM_logic <- glm(FirstTeamWin ~ victorydif, data = train, family = "binomial")
summary(MMLM_logic)
```

```{r}
logic_pred <- predict(MMLM_logic, test, type = "response")

submission <- data.frame(Id = test$'submission$Id', Pred = logic_pred)
write.csv(submission, "submissionlogic.csv", row.names = FALSE)
```

# 4. Real Game
```{r}
Final_submission <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/submission_vic16_n0_d1.csv")
teams <- read.csv("D:/Kaggle/March_Machine_Learnig_Mania_2017/Teams.csv")

Final_submission$FirstTeamWin <- ifelse(Final_submission$Pred > 0.5, 1, 0)
Final_submission$FirstTeamWin <- as.factor(Final_submission$FirstTeamWin)

Final_submission <- cbind(Final_submission, colsplit(Final_submission$Id, "_", names = c("Season", "FirstTeam", "SecondTeam")))

Final_submission <- merge(Final_submission, teams, by.x = c("FirstTeam"), by.y = c("Team_Id"))
names(Final_submission)[7] <- paste("First", names(Final_submission)[7], sep = "")

Final_submission <- merge(Final_submission, teams, by.x = c("SecondTeam"), by.y = c("Team_Id"))
names(Final_submission)[8] <- paste("Second", names(Final_submission)[8], sep = "")

Final_submission <- Final_submission[c("Season", "FirstTeam_Name", "SecondTeam_Name", "FirstTeamWin")]

write.csv(Final_submission, "Final_submission.csv", row.names = FALSE)
```

