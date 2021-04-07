# ------------------------------------------------------------------------------
# Team Assign 4 : Countries of World
# 최창락, 이영호, 정예원, 홍혁진
# 2020/11/17
# ------------------------------------------------------------------------------

library(mclust)

# 1. 데이터 불러오기
data <- read.csv("d:/Study/2020/multivariate/team assign/assign5/data.csv")
summary(data)

# 2. 데이터 전처리
# (1) 변수 제거 및 결측치 처리
data2 <- data[, -15]

for (i in 1:nrow(data2)) {
  for (j in 1:ncol(data2)) {
    if (is.na(data2[i, j]) == TRUE) {
      data2[i, j] <- mean(na.omit(data2[data2$Region == data2[i, 2], j]))
    }
  }
}

# 3. 주성분 분석
pcor <- prcomp(data2[, -c(1, 2)], scale = TRUE, center = TRUE)
pcor

# (1) 주성분 개수 선택: 주성분의 분산 총합이 70-90%에 해당하는 주성분들을 선택
summary(pcor) # 5 ~ 8

# (2) 주성분 개수 선택: Kaiser's criterion
mean(pcor$sdev^2)
round(pcor$sdev^2, 4) # 5

# (3) 주성분 개수 선택: Scree diagram (시각화)
par(mar = c(5, 5, 5, 0)) # 2

plot.new()
plot.window(xlim = c(1, 17), ylim = c(0, 6))
abline(h = seq(0, 6, 1), v = seq(1, 17, 2), col = "grey", lty = 3)

lines(pcor$sdev^2, lwd = 3) 
segments(2, 0, 2, 6, col = "red", lwd = 2, lty = 3)

axis(side = 1, at = seq(1, 17, 2), cex.axis = 1)
axis(side = 2, at = seq(0, 6, 1), las = 2, cex.axis = 1)

mtext("Component Number", 1, line = 3, cex = 1)
mtext("Component Variance", 2, line = 3, cex = 1)
mtext("Scree Diagram", 3, line = 1, cex = 1.25)

# 4. 계층적 군집 분석
# (1) 계층적 군집 분석 방법별 결과 비교
plot(hclust(dist(pcor$x[, 1:5]), method = "single"), xlab = "")
plot(hclust(dist(pcor$x[, 1:5]), method = "complete"), xlab = "")
plot(hclust(dist(pcor$x[, 1:5]), method = "average"), xlab = "")
plot(hclust(dist(pcor$x[, 1:5]), method = "ward.D"), xlab = "")

# (2) ward 기반 계층적 군집 분석 및 결과 시각화
plot(hclust(dist(pcor$x[, 1:5]), method = "ward.D"), xlab = "")
abline(h = 35, col = "red", lty = 3)

hclust_result <- hclust(dist(pcor$x[, 1:5]), method = "ward.D")

label <- cutree(hclust_result, h = 35)

par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(-6, 6), ylim = c(-5, 10))
abline(h = seq(-5, 10, 3), v = seq(-6, 6, 3), col = "grey", lty = 3)

points(pcor$x[, 1:2], pch = 16, col = label, cex = 0.75)

axis(side = 1, at = seq(-6, 6, 3), cex.axis = 1)
axis(side = 2, at = seq(-5, 10, 3), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)
mtext("Hierarchical Cluatering Analysis", 3, line = 1, cex = 1.25)

legend(5, 10, pch = 16, col = 1:6, legend = 1:6)

# 5. K-means 군집 분석
# (1) 군집 개수 선택 : WGSS
wgss <- c()

set.seed(9999)
for (i in 1:10) {
  wgss[i] <- sum(kmeans(pcor$x[, 1:5], centers = i)$withinss)
}
  
plot(1:10, wgss, type = "b", xlab = "Number of groups", 
     ylab = "Within groups sum of squares")

par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(1, 10), ylim = c(0, 3000))
abline(h = seq(0, 3000, 500), v = seq(0, 10, 2), col = "grey", lty = 3)

lines(wgss, lwd = 3) 

axis(side = 1, at = seq(0, 10, 2), cex.axis = 1)
axis(side = 2, at = seq(0, 3000, 500), las = 2, cex.axis = 1)

mtext("Number of groups", 1, line = 3, cex = 1)
mtext("Within groups sum of squares", 2, line = 3, cex = 1)

# (2) K-means 군집 분석
kmeans_results <- kmeans(pcor$x[, 1:5], centers = 6)

par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(-6, 6), ylim = c(-5, 10))
abline(h = seq(-5, 10, 3), v = seq(-6, 6, 3), col = "grey", lty = 3)

points(pcor$x[, 1:2], pch = 16, col = kmeans_results$cluster, cex = 0.75)

axis(side = 1, at = seq(-6, 6, 3), cex.axis = 1)
axis(side = 2, at = seq(-5, 10, 3), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)
mtext("K-Means Cluatering Analysis", 3, line = 1, cex = 1.25)

legend(5, 10, pch = 16, col = 1:6, legend = 1:6)

# 6. Model-based 군집 분석
# (1) BIC 확인
plot(mclustBIC(pcor$x[, 1:5]))

# (2) Model-based 군집 분석
mclust_result <- Mclust(pcor$x[, 1:5])

plot(pcor$x[, c(1, 3)], col = mclust_result$classification)

par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(-6, 6), ylim = c(-8, 8))
abline(h = seq(-8, 8, 2), v = seq(-6, 6, 3), col = "grey", lty = 3)

points(pcor$x[, c(1, 3)], pch = 16, col = mclust_result$classification, 
       cex = 0.75)

axis(side = 1, at = seq(-6, 6, 3), cex.axis = 1)
axis(side = 2, at = seq(-8, 8, 2), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)
mtext("Model-Based Cluatering Analysis", 3, line = 1, cex = 1.25)

legend(5, 8, pch = 16, col = 1:6, legend = 1:6)

# 7. 결과 비교
# (1) 결과 비교를 위한 데이터 생성 
data_cluster <- data.frame(data[, 1:2], label, kmeans_results$cluster,
                           mclust_result$classification)
names(data_cluster)[3:5] <- c("hclust", "kmeans", "mclust")

# (2) 방법론별 군집과 지역 간의 분할표 생성
hclust_table <- table(data_cluster$Region, data_cluster$hclust)
kmeans_table <- table(data_cluster$Region, data_cluster$kmeans)
mclust_table <- table(data_cluster$Region, data_cluster$mclust)
