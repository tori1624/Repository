# ------------------------------------------------------------------------------
# Team Assign 1 : Visualizing the Pokemon Data
# 이다영, 이영호, 황수연
# 2020/09/15
# ------------------------------------------------------------------------------

library(lattice)
options(scipen = 50)

# 1. 데이터 불러오기
data_path <- "D:/Study/2020/multivariate/team assign/assign1/data/"
pokemon_raw <- read.csv(paste0(data_path, "pokemon.csv"))

# 2. 데이터 전처리
# 2-1) 변수 추출 및 이상치 제거
pokemon_df <- pokemon_raw[-774, c("name", "type1", "capture_rate", "speed", 
                                  "attack", "defense")]

# 2-2) 데이터형 변환 및 변수 생성
pokemon_df$capture_rate <- as.numeric(as.character(pokemon_df$capture_rate))
pokemon_df$capture_class <- ifelse(pokemon_df$capture_rate <= 45, "3-Hard",
                                   ifelse(pokemon_df$capture_rate > 45 &
                                            pokemon_df$capture_rate <= 170, 
                                          "2-Normal",
                                          ifelse(pokemon_df$capture_rate > 170, 
                                                 "1-Easy", NA)))

# 2-3) 타입(type1)별 빈도 데이터 생성 및 정렬
type_df <- data.frame(table(pokemon_df$type1))
names(type_df) <- c('Type', 'Frequency')
type_df <- type_df[order(type_df$Frequency, decreasing = T), ]

# 3. 데이터 시각화
# 3-1) 타입별 빈도 시각화
par(mar = c(5, 5, 3, 3))
bar <- barplot(type_df$Frequency, names.arg = type_df$Type, beside = T, 
               col = c(rep(rgb(206, 66, 87, 255, maxColorValue = 255), 4), 
                       rep("grey70", 14)), ylab = "Frequency", ylim = c(0, 130), 
               las = 2, cex.names = 1, cex.axis = 1, cex.lab = 1)
text(bar, type_df$Frequency, type_df$Frequency, cex = 1, pos = 3, offset = 1)

# 3-2) 채집 난이도와 개체 유형에 따른 개체값(공격력/방어력/속력) 간의 관계 시각화
## 시각화를 위한 주요 타입 포켓몬 데이터 추출
pokemon_majorT <- subset.data.frame(pokemon_df, type1 == "water" | 
                                      type1 == "normal" |
                                      type1 == "bug" |
                                      type1 == "grass")
pokemon_majorT$type1 <- as.factor(as.character(pokemon_majorT$type1))

## 개체값 범위 설정
speed_lim <- c(0, max(pokemon_majorT$speed)+5)
attack_lim <- c(0, max(pokemon_majorT$attack)+5)
defense_lim <- c(0, max(pokemon_majorT$defense)+5)

## 색상 설정
mycol = c(rgb(186, 149, 109, 255, maxColorValue = 255),
          rgb(115, 198, 113, 255, maxColorValue = 255),
          rgb(241, 148, 138, 255, maxColorValue = 255),
          rgb(169, 204, 227, 255, maxColorValue = 255))

# 3-2-1) 공격력과 방어력 간의 관계 시각화
## 타입별 구분
xyplot(attack ~ defense | capture_class * type1, groups = type1,
       data = pokemon_majorT, xlim = defense_lim, ylim = attack_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)))
## 전체
xyplot(attack ~ defense | capture_class, data = pokemon_majorT, groups = type1, 
       xlim = defense_lim, ylim = attack_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)),
       auto.key = list(space = "top", columns = 4))

# 3-2-2) 속도와 방어력 간의 관계 시각화
## 타입별 구분
xyplot(speed ~ defense | capture_class * type1, groups = type1,
       data = pokemon_majorT, xlim = defense_lim, ylim = speed_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)))
## 전체
xyplot(speed ~ defense | capture_class, data = pokemon_majorT, groups = type1, 
       xlim = defense_lim, ylim = speed_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)),
       auto.key = list(space = "top", columns = 4))

# 3-2-3) 속도와 공격력 간의 관계 시각화
## 타입별 구분
xyplot(speed ~ attack | capture_class * type1, groups = type1,
       data = pokemon_majorT, xlim = attack_lim, ylim = speed_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)))
## 전체
xyplot(speed ~ attack | capture_class, data = pokemon_majorT, groups = type1, 
       xlim = attack_lim, ylim = speed_lim,
       par.settings = list(superpose.symbol = list(pch = 16, cex = 1, 
                                                   col = mycol)),
       auto.key = list(space = "top", columns = 4))

# 4. 각 그래프별 상관분석
type <- c("water", "normal", "bug", "grass")
capture_class <- c("1-Easy", "2-Normal", "3-Hard")

# 4-1) 공격력과 방어력 간의 분석
AD_result <- data.frame()

for (i in 1:length(type)) {
  for (j in 1:length(capture_class)) {
    tmp_data <- pokemon_majorT[pokemon_majorT$type1 == type[i] &
                                 pokemon_majorT$capture_class == capture_class[j],
                               ]
    cor_tmp <- cor.test(tmp_data$attack, tmp_data$defense)
    result_tmp <- data.frame(attr = paste0(type[i], "_", capture_class[j]),
                             cor_value = cor_tmp$estimate,
                             pvalue = cor_tmp$p.value)
    AD_result <- rbind(AD_result, result_tmp)
  }
}

# 4-2) 속력과 방어력 간의 분석
SD_result <- data.frame()

for (i in 1:length(type)) {
  for (j in 1:length(capture_class)) {
    tmp_data <- pokemon_majorT[pokemon_majorT$type1 == type[i] &
                                 pokemon_majorT$capture_class == capture_class[j],
                               ]
    cor_tmp <- cor.test(tmp_data$speed, tmp_data$defense)
    result_tmp <- data.frame(attr = paste0(type[i], "_", capture_class[j]),
                             cor_value = cor_tmp$estimate,
                             pvalue = cor_tmp$p.value)
    SD_result <- rbind(SD_result, result_tmp)
  }
}

# 4-3) 속력과 공격력 간의 분석
SA_result <- data.frame()

for (i in 1:length(type)) {
  for (j in 1:length(capture_class)) {
    tmp_data <- pokemon_majorT[pokemon_majorT$type1 == type[i] &
                                 pokemon_majorT$capture_class == capture_class[j],
                               ]
    cor_tmp <- cor.test(tmp_data$speed, tmp_data$attack)
    result_tmp <- data.frame(attr = paste0(type[i], "_", capture_class[j]),
                             cor_value = cor_tmp$estimate,
                             pvalue = cor_tmp$p.value)
    SA_result <- rbind(SA_result, result_tmp)
  }
}