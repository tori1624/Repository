# ------------------------------------------------------------------------------
# Team Assign 3 : World Happiness Report
# 이다영, 이영호, 이명훈
# 2020/10/12
# ------------------------------------------------------------------------------


# 1. 데이터 불러오기
data.path <- "D:/Study/2020/multivariate/team assign/assign3/data/"

data2015 <- read.csv(paste0(data.path, "2015.csv"))
data2016 <- read.csv(paste0(data.path, "2016.csv"))
data2017 <- read.csv(paste0(data.path, "2017.csv"))
data2018 <- read.csv(paste0(data.path, "2018.csv"))
data2019 <- read.csv(paste0(data.path, "2019.csv"))

# 2. 데이터 전처리
# (1) 대륙(지역) 데이터 생성 및 병합
region_df <- data2015[, 1:2]
names(data2019)[2] <- "Country"; names(data2018)[2] <- "Country"

data2017_2 <- merge(data2017, region_df, by = "Country")
data2018_2 <- merge(data2018, region_df, by = "Country")
data2019_2 <- merge(data2019, region_df, by = "Country")

# (2) 변수명 통일
names(data2015)[4] <- "Score"; names(data2016)[4] <- "Score"
names(data2017_2)[3] <- "Score"

# (3) 행복 지수 범주화
data_list <- c("data2015", "data2016", "data2017_2", "data2018_2", 
               "data2019_2")

for (i in 1:5) {
  tmp <- get(data_list[i])
  
  tmp$Score_class[tmp$Score < 4] <- "-4"
  tmp$Score_class[tmp$Score >= 4 & tmp$Score < 5] <- "4-5"
  tmp$Score_class[tmp$Score >= 5 & tmp$Score < 6] <- "5-6"
  tmp$Score_class[tmp$Score >= 6 & tmp$Score < 7] <- "6-7"
  tmp$Score_class[tmp$Score >= 7] <- "7-"
  
  assign(data_list[i], tmp)
}

# (4) 대륙(지역)과 행복 지수 간의 분할표 생성
table_2015 <- table(data2015$Region, data2015$Score_class)
table_2016 <- table(data2016$Region, data2016$Score_class)
table_2017 <- table(data2017_2$Region, data2017_2$Score_class)
table_2018 <- table(data2018_2$Region, data2018_2$Score_class)
table_2019 <- table(data2019_2$Region, data2019_2$Score_class)

# 3. 대응 분석
# (1) 카이 제곱 거리 계산 함수 생성
D <- function(x) {
  a <- t(t(x)/colSums(x))
  ret <- sqrt(colSums((a[,rep(1:ncol(x), ncol(x))] - 
                         a[, rep(1:ncol(x), rep(ncol(x), ncol(x)))])^2 * 
                        sum(x) / rowSums(x)))
  matrix(ret, ncol = ncol(x))
}

# (2) 2015년 열/행 거리 생성, 대응 분석 및 시각화
dcols2015 <- D(table_2015); drows2015 <- D(t(table_2015)) # 거리 생성

c1 <- cmdscale(dcols2015, eig = TRUE) # 대응 분석
r1 <- cmdscale(drows2015, eig = TRUE)

par(mar = c(5, 5, 5, 3)) # 시각화

plot.new()
plot.window(xlim = range(c1$points[,1], r1$points[,1]) * 1.5, 
            ylim = range(c1$points[,1], r1$points[,1]) * 1.5)
abline(h = 0, v = 0, lty = 2)

points(c1$points, pch = 16, col = "red"); points(r1$points, pch = 15)

text(c1$points, labels = colnames(table_2015), col = "red", pos = 3, 
     offset = 0.5)
text(r1$points[1, 1], r1$points[1, 2], labels = rownames(table_2015)[1], 
     pos = 3, offset = 0.5)
text(r1$points[2, 1], r1$points[2, 2], labels = rownames(table_2015)[2], 
     pos = 4, offset = 0.5)
text(r1$points[3, 1], r1$points[3, 2], labels = rownames(table_2015)[3], 
     pos = 2, offset = 0.5)
text(r1$points[4, 1], r1$points[4, 2], labels = rownames(table_2015)[4], 
    pos = 1, offset = 1)
text(r1$points[5, 1], r1$points[5, 2], labels = rownames(table_2015)[5], 
     pos = 4, offset = 0.5)
text(r1$points[6, 1], r1$points[6, 2], labels = rownames(table_2015)[6], 
     pos = 1, offset = 0.5)
text(r1$points[7, 1], r1$points[7, 2], labels = rownames(table_2015)[7], 
     pos = 2, offset = 0.5)
text(r1$points[8, 1], r1$points[8, 2], labels = rownames(table_2015)[8], 
     pos = 4, offset = 0.5)
text(r1$points[9, 1], r1$points[9, 2], labels = rownames(table_2015)[9], 
     pos = 3, offset = 0.5)
text(r1$points[10, 1], r1$points[10, 2], labels = rownames(table_2015)[10], 
     pos = 4, offset = 0.5)

axis(side = 1, at = seq(-2, 4, 1), cex.axis = 1)
axis(side = 2, at = seq(-2, 4, 1), las = 2, cex.axis = 1)

mtext("Coordinate 1", 1, line = 3, cex = 1)
mtext("Coordinate 2", 2, line = 3, cex = 1)
mtext("2015", 3, line = 2, cex = 1.2)

legend(2.5, 4, pch = c(16, 15), col = c("red", "black"), bty = "n", cex = 1,
       legend = c("Happiness Score", "Region"))

# (3) 2016년 열/행 거리 생성, 대응 분석 및 시각화
dcols2016 <- D(table_2016); drows2016 <- D(t(table_2016)) # 거리 생성

c1 <- cmdscale(dcols2016, eig = TRUE) # 대응 분석
r1 <- cmdscale(drows2016, eig = TRUE)

par(mar = c(5, 5, 5, 3)) # 시각화

plot.new()
plot.window(xlim = range(c1$points[,1], r1$points[,1]) * 1.5, 
            ylim = range(c1$points[,1], r1$points[,1]) * 1.5)
abline(h = 0, v = 0, lty = 2)

points(c1$points, pch = 16, col = "red"); points(r1$points, pch = 15)

text(c1$points, labels = colnames(table_2016), col = "red", pos = 3, 
     offset = 0.5)
text(r1$points[1, 1], r1$points[1, 2], labels = rownames(table_2016)[1], 
     pos = 3, offset = 0.5)
text(r1$points[2, 1], r1$points[2, 2], labels = rownames(table_2016)[2], 
     pos = 4, offset = 0.5)
text(r1$points[3, 1], r1$points[3, 2], labels = rownames(table_2016)[3], 
     pos = 2, offset = 0.5)
text(r1$points[4, 1], r1$points[4, 2], labels = rownames(table_2016)[4], 
     pos = 1, offset = 1)
text(r1$points[5, 1], r1$points[5, 2], labels = rownames(table_2016)[5], 
     pos = 4, offset = 0.5)
text(r1$points[6, 1], r1$points[6, 2], labels = rownames(table_2016)[6], 
     pos = 1, offset = 0.5)
text(r1$points[7, 1], r1$points[7, 2], labels = rownames(table_2016)[7], 
     pos = 2, offset = 0.5)
text(r1$points[8, 1], r1$points[8, 2], labels = rownames(table_2016)[8], 
     pos = 4, offset = 0.5)
text(r1$points[9, 1], r1$points[9, 2], labels = rownames(table_2016)[9], 
     pos = 3, offset = 0.5)
text(r1$points[10, 1], r1$points[10, 2], labels = rownames(table_2016)[10], 
     pos = 4, offset = 0.5)

axis(side = 1, at = seq(-2, 4, 1), cex.axis = 1)
axis(side = 2, at = seq(-2, 4, 1), las = 2, cex.axis = 1)

mtext("Coordinate 1", 1, line = 3, cex = 1)
mtext("Coordinate 2", 2, line = 3, cex = 1)
mtext("2016", 3, line = 2, cex = 1.2)

legend(2.5, 4, pch = c(16, 15), col = c("red", "black"), bty = "n", cex = 1,
       legend = c("Happiness Score", "Region"))

# (4) 2017년 열/행 거리 생성, 대응 분석 및 시각화
dcols2017 <- D(table_2017); drows2017 <- D(t(table_2017)) # 거리 생성

c1 <- cmdscale(dcols2017, eig = TRUE) # 대응 분석
r1 <- cmdscale(drows2017, eig = TRUE)

par(mar = c(5, 5, 5, 3)) # 시각화

plot.new()
plot.window(xlim = range(c1$points[,1], r1$points[,1]) * 1.5, 
            ylim = range(c1$points[,1], r1$points[,1]) * 1.5)
abline(h = 0, v = 0, lty = 2)

points(c1$points, pch = 16, col = "red"); points(r1$points, pch = 15)

text(c1$points, labels = colnames(table_2017), col = "red", pos = 3, 
     offset = 0.5)
text(r1$points[1, 1], r1$points[1, 2], labels = rownames(table_2017)[1], 
     pos = 3, offset = 0.5)
text(r1$points[2, 1], r1$points[2, 2], labels = rownames(table_2017)[2], 
     pos = 4, offset = 0.5)
text(r1$points[3, 1], r1$points[3, 2], labels = rownames(table_2017)[3], 
     pos = 2, offset = 0.5)
text(r1$points[4, 1], r1$points[4, 2], labels = rownames(table_2017)[4], 
     pos = 3, offset = 0.5)
text(r1$points[5, 1], r1$points[5, 2], labels = rownames(table_2017)[5], 
     pos = 1, offset = 0.5)
text(r1$points[6, 1], r1$points[6, 2], labels = rownames(table_2017)[6], 
     pos = 1, offset = 0.5)
text(r1$points[7, 1], r1$points[7, 2], labels = rownames(table_2017)[7], 
     pos = 4, offset = 0.5)
text(r1$points[8, 1], r1$points[8, 2], labels = rownames(table_2017)[8], 
     pos = 3, offset = 0.5)
text(r1$points[9, 1], r1$points[9, 2], labels = rownames(table_2017)[9], 
     pos = 1, offset = 0.5)
text(r1$points[10, 1], r1$points[10, 2], labels = rownames(table_2017)[10], 
     pos = 3, offset = 0.5)

axis(side = 1, at = seq(-2, 4, 1), cex.axis = 1)
axis(side = 2, at = seq(-2, 4, 1), las = 2, cex.axis = 1)

mtext("Coordinate 1", 1, line = 3, cex = 1)
mtext("Coordinate 2", 2, line = 3, cex = 1)
mtext("2017", 3, line = 2, cex = 1.2)

legend(2.5, 4, pch = c(16, 15), col = c("red", "black"), bty = "n", cex = 1,
       legend = c("Happiness Score", "Region"))

# (5) 2018년 열/행 거리 생성, 대응 분석 및 시각화
dcols2018 <- D(table_2018); drows2018 <- D(t(table_2018)) # 거리 생성

c1 <- cmdscale(dcols2018, eig = TRUE) # 대응 분석
r1 <- cmdscale(drows2018, eig = TRUE)

par(mar = c(5, 5, 5, 3)) # 시각화

plot.new()
plot.window(xlim = range(c1$points[,1], r1$points[,1]) * 1.5, 
            ylim = range(c1$points[,1], r1$points[,1]) * 1.5)
abline(h = 0, v = 0, lty = 2)

points(c1$points, pch = 16, col = "red"); points(r1$points, pch = 15)

text(c1$points[-4, 1], c1$points[-4, 2], labels = colnames(table_2018)[-4], 
     col = "red", pos = 3, offset = 0.5)
text(c1$points[4, 1], c1$points[4, 2], labels = colnames(table_2018)[4], 
     col = "red", pos = 1, offset = 0.5)
text(r1$points[1, 1], r1$points[1, 2], labels = rownames(table_2018)[1], 
     pos = 3, offset = 0.5)
text(r1$points[2, 1], r1$points[2, 2], labels = rownames(table_2018)[2], 
     pos = 4, offset = 0.5)
text(r1$points[3, 1], r1$points[3, 2], labels = rownames(table_2018)[3], 
     pos = 1, offset = 0.5)
text(r1$points[4, 1], r1$points[4, 2], labels = "Latin America", 
     pos = 2, offset = 0.5)
text(r1$points[5, 1], r1$points[5, 2], labels = rownames(table_2018)[5], 
     pos = 4, offset = 0.5)
text(r1$points[6, 1], r1$points[6, 2], labels = rownames(table_2018)[6], 
     pos = 4, offset = 0.5)
text(r1$points[7, 1], r1$points[7, 2], labels = rownames(table_2018)[7], 
     pos = 4, offset = 0.5)
text(r1$points[8, 1], r1$points[8, 2], labels = rownames(table_2018)[8], 
     pos = 4, offset = 0.5)
text(r1$points[9, 1], r1$points[9, 2], labels = rownames(table_2018)[9], 
     pos = 3, offset = 0.5)
text(r1$points[10, 1], r1$points[10, 2], labels = rownames(table_2018)[10], 
     pos = 1, offset = 1)

axis(side = 1, at = seq(-2, 4, 1), cex.axis = 1)
axis(side = 2, at = seq(-2, 4, 1), las = 2, cex.axis = 1)

mtext("Coordinate 1", 1, line = 3, cex = 1)
mtext("Coordinate 2", 2, line = 3, cex = 1)
mtext("2018", 3, line = 2, cex = 1.2)

legend(2.5, 4, pch = c(16, 15), col = c("red", "black"), bty = "n", cex = 1,
       legend = c("Happiness Score", "Region"))

# (6) 2019년 열/행 거리 생성, 대응 분석 및 시각화
dcols2019 <- D(table_2019); drows2019 <- D(t(table_2019)) # 거리 생성

c1 <- cmdscale(dcols2019, eig = TRUE) # 대응 분석
r1 <- cmdscale(drows2019, eig = TRUE)

par(mar = c(5, 5, 5, 3)) # 시각화

plot.new()
plot.window(xlim = range(c1$points[,1], r1$points[,1]) * 1.5, 
            ylim = range(c1$points[,1], r1$points[,1]) * 1.5)
abline(h = 0, v = 0, lty = 2)

points(c1$points, pch = 16, col = "red"); points(r1$points, pch = 15)

text(c1$points[-1, 1], c1$points[-1, 2], labels = colnames(table_2019)[-1], 
     col = "red", pos = 3, offset = 0.5)
text(c1$points[1, 1], c1$points[1, 2], labels = colnames(table_2019)[1], 
     col = "red", pos = 2, offset = 0.5)
text(r1$points[1, 1], r1$points[1, 2], labels = rownames(table_2019)[1], 
     pos = 3, offset = 0.5)
text(r1$points[2, 1], r1$points[2, 2], labels = rownames(table_2019)[2], 
     pos = 4, offset = 0.5)
text(r1$points[3, 1], r1$points[3, 2], labels = rownames(table_2019)[3], 
     pos = 3, offset = 0.5)
text(r1$points[4, 1], r1$points[4, 2], labels = "Latin America", 
     pos = 3, offset = 0.5)
text(r1$points[5, 1], r1$points[5, 2], labels = rownames(table_2019)[5], 
     pos = 1, offset = 0.5)
text(r1$points[6, 1], r1$points[6, 2], labels = rownames(table_2019)[6], 
     pos = 3, offset = 0.5)
text(r1$points[7, 1], r1$points[7, 2], labels = rownames(table_2019)[7], 
     pos = 4, offset = 0.5)
text(r1$points[8, 1], r1$points[8, 2], labels = rownames(table_2019)[8], 
     pos = 3, offset = 0.5)
text(r1$points[9, 1], r1$points[9, 2], labels = rownames(table_2019)[9], 
     pos = 1, offset = 0.5)
text(r1$points[10, 1], r1$points[10, 2], labels = rownames(table_2019)[10], 
     pos = 4, offset = 0.5)

axis(side = 1, at = seq(-2, 4, 1), cex.axis = 1)
axis(side = 2, at = seq(-2, 4, 1), las = 2, cex.axis = 1)

mtext("Coordinate 1", 1, line = 3, cex = 1)
mtext("Coordinate 2", 2, line = 3, cex = 1)
mtext("2019", 3, line = 2, cex = 1.2)

legend(2.5, 4, pch = c(16, 15), col = c("red", "black"), bty = "n", cex = 1,
       legend = c("Happiness Score", "Region"))