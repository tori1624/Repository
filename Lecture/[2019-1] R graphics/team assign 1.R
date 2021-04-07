# ------------------------------------------------------------------------------
# Team Assign 1 : Categorical Data
# 장지원, 이영호, 김태희
# 2019/04/16
# ------------------------------------------------------------------------------

library(dplyr)

# 1. 데이터 불러오기
data.path <- "D:/Study/2019/Rgraphics/assign/team1/accident/"
traffic2012_2014 <- read.csv(paste0(data.path, "2012_2014_교통사망사고.csv"))
traffic2015 <- read.csv(paste0(data.path, "2015_교통사망사고.csv"))
traffic2016 <- read.csv(paste0(data.path, "2016_교통사망사고.csv"))
traffic2017 <- read.csv(paste0(data.path, "2017_교통사망사고.csv"))

# 2. 데이터 전처리
# 2-1) 데이터 병합
traffic.df <- rbind(traffic2012_2014, traffic2015, traffic2016, traffic2017)

# 2-2) 결측치 처리 : 가해자의 단독사고일 경우, 피해자를 "없음"으로 통일
x1 <- which(traffic.df[, 22] == "0")
x2 <- which(traffic.df[, 22] == "00")
x3 <- which(traffic.df[, 22] == "")
x <- sort(unique(c(x1, x2, x3)))
traffic.df[x, 22] <- "없음"

y1 <- which(traffic.df[, 23] == "0")
y2 <- which(traffic.df[, 23] == "00")
y3 <- which(traffic.df[, 23] == "")
y <- sort(unique(c(y1, y2, y3)))
traffic.df[y, 23] <- "없음"

# 2-3) 자전거 관련 데이터 추출
bicycle.df <- subset(traffic.df, traffic.df[, 20] == "자전거" | 
                       traffic.df[, 22] == "자전거")

# 2-4) 시각화를 위한 데이터 전처리(전체 사고 & 자전거 사고 추세 파악)
# 발생건수, 연도
bicycle.accident <- c(13252, 13852, 17471, 18310, 15636, 14662)
total.accident <- c(223656, 215354, 223552, 232035, 220917, 216335)
years <- c(2012:2017)

# 전체건수
total.death.acc <- aggregate(요일 ~ 발생년, traffic.df, length)
bicycle.death.acc <- aggregate(요일 ~ 발생년, bicycle.df, length)

# 사망자수
total.death.toll <- aggregate(사망자수 ~ 발생년, traffic.df, sum)
bicycle.death.toll <- aggregate(사망자수 ~ 발생년, bicycle.df, sum)

# 치사율계산 = (교통사고사망자수/전체발생건수)*100
lethality.to <- c((total.death.toll/total.accident)*100)
lethality.bi <- c((bicycle.death.toll/bicycle.accident)*100)

# 병합
total.summary <- data.frame(years, total.accident, total.death.acc$요일,
                            total.death.toll$사망자수, lethality.to$사망자수)
bicycle.summary <- data.frame(years, bicycle.accident, bicycle.death.acc$요일,
                              bicycle.death.toll$사망자수, 
                              lethality.bi$사망자수)
names(total.summary) <- c("년도", "발생건수", "전체건수", "사망자수", "치사율")
names(bicycle.summary) <- c("년도", "발생건수", "전체건수", "사망자수", 
                            "치사율")

# 2-5) 시각화를 위한 데이터 전처리(사고유형별 자전거 사고 사망자수)
# 사고유형 통일
## 전도, 전복 -> 전도전복
bicycle.df$사고유형_중분류 <- gsub("전도전복", "1", bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("전도", "1", bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("전복", "1", bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("1", "전도전복", bicycle.df$사고유형_중분류)
## 철길건널목, 후진중충돌 -> 기타
bicycle.df$사고유형_중분류 <- gsub("철길건널목", "기타", 
                                   bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("후진중충돌", "기타", 
                                   bicycle.df$사고유형_중분류)
## 길가장자리구역통행중, 보도통행중, 차도통행중, 횡단중 -> 통행중
bicycle.df$사고유형_중분류 <- gsub("길가장자리구역통행중", "2", 
                                   bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("보도통행중", "2", 
                                   bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("차도통행중", "2", 
                                   bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("횡단중", "2", bicycle.df$사고유형_중분류)
bicycle.df$사고유형_중분류 <- gsub("2", "통행중", bicycle.df$사고유형_중분류)
## 대분류에서 철길건널목 -> 차대차
bicycle.df$사고유형_대분류 <- gsub("철길건널목", "차대차", 
                                   bicycle.df$사고유형_대분류)


# 사고유형별 데이터 추출
cartocar <- subset(bicycle.df, subset = (사고유형_대분류 == "차대차"), 
                   select = c(사망자수, 사상자수, 사고유형_대분류, 
                              사고유형_중분류, 당사자종별_1당_대분류, 
                              당사자종별_1당, 당사자종별_2당_대분류, 
                              당사자종별_2당))
cartoped <- subset(bicycle.df, subset = (사고유형_대분류 == "차대사람"), 
                   select = c(사망자수, 사상자수, 사고유형_대분류, 
                              사고유형_중분류, 당사자종별_1당_대분류, 
                              당사자종별_1당, 당사자종별_2당_대분류, 
                              당사자종별_2당))
onlycar <- subset(bicycle.df, subset = (사고유형_대분류 == "차량단독"), 
                  select = c(사망자수, 사상자수, 사고유형_대분류, 
                             사고유형_중분류, 당사자종별_1당_대분류, 
                             당사자종별_1당, 당사자종별_2당_대분류, 
                             당사자종별_2당))
total <- subset(bicycle.df, select = c(사망자수, 사상자수,사고유형_대분류, 
                                       사고유형_중분류, 당사자종별_1당_대분류, 
                                       당사자종별_1당, 당사자종별_2당_대분류, 
                                       당사자종별_2당))

# 사고유형별 자전거 사고 사망자수 총합 계산
ctoc <- aggregate(사망자수 ~ 사고유형_중분류, cartocar, sum)
ctop <- aggregate(사망자수 ~ 사고유형_중분류, cartoped, sum)
onlyc <- aggregate(사망자수 ~ 사고유형_중분류, onlycar, sum)
all <- aggregate(사망자수 ~ 사고유형_대분류, total, sum)

# 2-6) 시각화를 위한 데이터 전처리(도로유형별 자전거 사고 사망자수)
roadtype <- bicycle.df %>%
  group_by(도로형태) %>%
  summarise(사망자수 = sum(사망자수)) %>%
  arrange(사망자수) %>%
  mutate(tmp_var = c("기타/불명", "기타/불명", "기타/불명", "기타/불명", 
                     "기타/불명", "기타/불명", "기타/불명", "횡단보도부근",
                     "교차로횡단보도내", "횡단보도상", "교차로부근", "교차로내",
                     "기타단일로")) %>%
  group_by(tmp_var) %>%
  summarise(사망자수 = sum(사망자수)) %>%
  arrange(사망자수)

# 3. 데이터 시각화
# 3-1) 색 설정
mycol <- c(col = rgb(201, 76, 68, maxColorValue = 255), 
           col = rgb(136, 107, 104, maxColorValue = 255), 
           col = rgb(96, 176, 160, maxColorValue = 255),
           col =  rgb(239, 161, 70, maxColorValue = 255))
mycolbg <- c(col = rgb(201, 76, 68, 80, maxColorValue = 255), 
             col = rgb(136, 107, 104, 80, maxColorValue = 255), 
             col = rgb(96, 176, 160, 80, maxColorValue = 255))

# 3-2) 전체 사고 & 자전거 사고 추세 파악
time.label <- c('2012', '2013', '2014', '2015', '2016', '2017')
yaxis.value <- c('0','50k','100k','150k','200k','250k','300k','350k')
zaxis.value <- c('1.0','1.5','2.0','2.5')

## Graph1
par(mar = c(4, 5, 2, 5), family = 'sans')
bar1 <- barplot(total.summary$발생건수, names.arg = time.label, beside = T, 
                col = mycol[4], border = NA, ylim = c(0, 350000), axes = F, 
                font.axis = 2, cex.main = 2,
                main = "Total Traffic Accident & Bicycle Accident, 2012-2017")
bar2 <- barplot(bicycle.summary$발생건수, beside = T, col = mycol[2], 
                border = NA, ylim = c(0, 350000), axes = F, add = T)

## x, y axis
mtext("Years",side = 1, line = 2.5, cex = 1.25, font = 2, col = "black")
mtext("The number of traffic accident", side = 2, line = 3, cex = 1.25, 
      font = 2, col = "black")

yvalue.seq <- seq(0, 350000, 50000)
axis(2, at = yvalue.seq, label = yaxis.value, hadj = 0.8, las = 1)

## Graph2
par(new = T, mar = c(4, 8.5, 2, 8.5), family = 'sans')
plot1 <- plot(time.label, total.summary$치사율, type = "o", pch = 15, 
              col = mycol[1], ylim = c(1, 2.5), axes = F, xlab = "", 
              ylab = "", cex = 1.3)
par(new = T, mar = c(4, 8.5, 2, 8.5), family = 'sans')
plot2 <- plot(time.label, bicycle.summary$치사율, type = "o", pch = 17, 
              col = mycol[1], ylim = c(1, 2.5), axes = F, xlab = "", 
              ylab = "", cex = 1.3)

## z axis
par(mar = c(4, 6, 2, 5), family ='sans')
mtext("Lethality (%)", side = 4, line = 2.5, cex = 1.25, font = 2, 
      col = "black") 

zvalue.seq <- seq(1, 2.5, 0.5)
axis(4, at = zvalue.seq, labels = zaxis.value, hadj = 0.4, las = 1)

## Legend
legend(2015, 2.45, legend = c("Total accident", "Bicycle accident"),
       col = c(mycol[4], mycol[2]), bty = "n", cex = 1, pch = c(15, 15), 
       title = "Accident")
legend(2016.2, 2.45, legend = c("Total accident lethality", 
                                "Bicycle lethality"),
       col = c(mycol[1], mycol[1]), bty = "n", cex = 1, pch = c(15, 17), 
       title = "Lethality")

# 3-3) 사교유형별 자전거 사고 사망자수
par(oma = c(5, 10, 3, 3), mai = c(4, 4, 0, 0), mar = c(0, 0, 0, 0), 
    family = "sans")
lf <- layout(matrix(1:3), heights = c(1, 0.4, 0.8))
layout.show(lf)

## Graph1(Bicycle(Car) to Bicycle(Car))
car <- barplot(ctoc$사망자수, space = 0.1, horiz = T, col = mycol[1], 
               border = NA, xlab = "", ylab = "", xlim = c(0, 580), axes = F)
axis(2, at = car, labels = ctoc$사고유형_중분류, tck = 0, lty = 0, adj = 0, 
     hadj = 0.85, las = 1, cex.axis = 1.3)
for (i in 1:length(ctoc$사고유형_중분류)) {
  text(ctoc$사망자수[i], car[i], labels = ctoc$사망자수[i], adj = -0.3, 
       cex = 1.1, col = "black")
}
par(new = T) # background
car2 <- barplot(580, space = 0, horiz = T, col = mycolbg[1], border = NA,
                xlab = "", ylab = "", xlim = c(0, 580), axes = F, xpd = T)

## Graph2(Car to Pedestrians)
pedestrian <- barplot(ctop$사망자수, space = 0.1, horiz = T, col = mycol[2], 
                      border = NA, xlab = "", ylab = "", xlim = c(0, 580),
                      axes = F)
axis(2, at = pedestrian, labels = ctop$사고유형_중분류, tck = 0, lty = 0, 
     adj = 0, hadj = 0.8, las = 1, cex.axis = 1.3)
for (i in 1:length(ctop$사망자수)) {
  text(ctop$사망자수[i], pedestrian[i], labels = ctop$사망자수[i], 
       adj = -0.3, cex = 1.1, col = "black")
}
par(new = T) # background
ped2 <- barplot(580, space = 0, horiz = T, col = mycolbg[2], border = NA, 
                xlab = "", ylab = "", xlim = c(0, 580), axes = F, xpd = T)

## Graph3(Only Car)
only <- barplot(onlyc$사망자수, space = 0.1, horiz = T, col = mycol[3], 
                border = NA, xlab = "", ylab = "", xlim = c(0, 580), axes = F)
axis(2, at = only, labels = onlyc$사고유형_중분류, tck = 0, lty = 0, adj = 0,
     hadj = 0.8, las = 1, cex.axis = 1.3)
for (i in 1:length(onlyc$사망자수)) {
  text(onlyc$사망자수[i], only[i], labels = onlyc$사망자수[i], adj = -0.3, 
       cex = 1.1, col = "black")
}
par(new = T) # background
only2 <- barplot(580, space = 0, horiz = T, col = mycolbg[3], border = NA,
                 xlab = "", ylab = "", axes = F, xlim = c(0, 580), xpd = T)

## x axis
xlabel <- seq(0, 550, by = 50)
axis(side = 1, at = xlabel, labels = T, tck = 0, pos = 0, lty = 0, adj = 1, 
     padj = -1, outer = T, cex.axis = 1.3)

## title / x, y lab
mtext("The Number Of Deaths By Accident Type", side = 3, line = 1, outer = T, 
      cex = 1.5, font = 2)
mtext("The accident type", side = 2, line = 6, outer = T, cex = 1.25, font = 2)
mtext("The death toll", side = 1, line = 3, outer = T, padj = -0.5, cex = 1.3, 
      font = 2)

## legend
legend <- c("Bicycle(Car) to Bicycle(Car)", "Bicycle to pedestrian", 
            "Only Bicycle")
legend("bottomright", inset = c(0.02, 0.06), legend = legend, col = mycol, 
       pch = c(15, 15, 15), cex = 1.4, 
       bg = rgb(255, 255, 255, 100, maxColorValue = 255))

# 3-4) 도로유형별 자전거 사고 사망자수
par(omi = c(0.5, 0.5, 0.5, 0.5),
    mar = c(1, 5.5, 0.25, 1), mfrow = c(1, 1), family = "sans")

## Graph
bg <- barplot(1000, space = 0, horiz = T, col = mycolbg[1], border = NA, 
              xlab = "", ylab = "", xlim = c(0, 900), axes = F, xpd = T)
par(new = T)
bar <- barplot(roadtype$사망자수, horiz = T, col = c(rep(mycol[2], 6), mycol[1]), 
               border = NA, xlab = "", ylab = "", xlim = c(0, 900), axes = F, 
               cex.names = 1, family = "sans")

## x, y axis / title / other elements
axis(1, at = seq(0, 900, by = 100), labels = T, tck = 0, pos = 0, lty = 0,
    outer = T, adj = 1, padj = -1, cex = 1)
axis(2, at = c(0.7 ,1.9, 3.1, 4.3, 5.5, 6.7, 7.9), labels = roadtype$tmp_var, 
     tck = 0, lty = 0, adj = 0, hadj = 0.85, las = 1)

mtext("The Number of Deaths by Road Type", side = 3, line = 1, outer = T, 
      cex = 1.5, font = 2)
mtext("The road type", side = 2, line = 1, cex = 1.25, font = 2, outer = T)
mtext("The death toll", side = 1, line = 1, cex = 1.25, font = 2, outer = T)

for (i in 1:length(roadtype$tmp_var)) {
  text(roadtype$사망자수[i], bar[i], labels = roadtype$사망자수[i], adj = -0.3, 
       cex = 0.9, col = "black")
}
