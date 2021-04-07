# ------------------------------------------------------------------------------
# Team Assign 2 : Breast Cancer Wisconsin (Diagnostic)
# 김강민, 이영호, 함정수
# 2020/09/29
# ------------------------------------------------------------------------------

library(factoextra)
library(caret)
library(corrplot)
library(e1071)

# 1. 데이터 불러오기
data_path <- "D:/Study/2020/multivariate/team assign/assign2/"
bcw_raw <- read.csv(paste0(data_path, "data.csv"))

# 2. 변수 간 상관관계 파악
par(mar = c(1, 1, 1, 1))
corrplot(cor(bcw_raw[, 3:32]), method = "color", tl.col = "black")

# 3. 주성분 분석에서의 공분산 행렬과 상관계수 행렬 비교
bcw_pcov <- prcomp(bcw_raw[, 3:32])
summary(bcw_pcov)

bcw_pcor <- prcomp(bcw_raw[, 3:32], scale = TRUE, center = TRUE)
summary(bcw_pcor)

bcw_raw$pc1 <- bcw_pcor$x[, 1]; bcw_raw$pc2 <- bcw_pcor$x[, 2]

# 4. 주성분 분석 개수 선택
# (1) 주성분의 분산 총합이 70-90%에 해당하는 주성분들을 선택
summary(bcw_pcor)

# (2) 주성분의 고유값들의 평균보다 큰 주성분들만을 선택
mean(bcw_pcor$sdev^2)
round(bcw_pcor$sdev^2, 4)

# (3) 주성분의 교유값이 0.7보다 작은 주성분들을 제외
round(bcw_pcor$sdev^2, 4)

# (4) Scree diagram (시각화)
par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(0, 30), ylim = c(0, 14))
abline(h = seq(0, 14, 2), v = seq(0, 30, 2), col = "grey", lty = 3)

lines(bcw_pcor$sdev^2, lwd = 3) 
segments(6.5, 0, 6.5, 14, col = "red", lwd = 2, lty = 3)

axis(side = 1, at = seq(0, 30, 4), cex.axis = 1)
axis(side = 2, at = seq(0, 14, 2), las = 2, cex.axis = 1)

mtext("Component Number", 1, line = 3, cex = 1)
mtext("Component Variance", 2, line = 3, cex = 1)
mtext("Scree Diagram", 3, line = 1, cex = 1.25)

# (5) Log-eigenvalue diagram (시각화)
par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(0, 30), ylim = c(-10, 4))
abline(h = seq(-10, 4, 2), v = seq(0, 30, 2), col = "grey", lty = 3)

lines(log(bcw_pcor$sdev^2), lwd = 3) 
segments(26.5, -10, 26.5, 4, col = "red", lwd = 2, lty = 3)

axis(side = 1, at = seq(0, 30, 4), cex.axis = 1)
axis(side = 2, at = seq(-10, 4, 2), las = 2, cex.axis = 1)

mtext("Component Number", 1, line = 3, cex = 1)
mtext("log(Component Variance)", 2, line = 3, cex = 1)
mtext("Log(eigenvalue) diagram", 3, line = 1, cex = 1.25)

# 5. Biplot 시각화
bcw_var <- names(bcw_raw)[3:32]

# (1) Mean
fviz_pca_biplot(bcw_pcor, select.var = list(names = bcw_var[1:10]),
                repel = TRUE, geom = "point",
                habillage = bcw_raw$diagnosis, col.var = "black") +
  labs(title = "Biplot (Mean)", x = "PC1", y = "PC2") + 
  scale_color_manual(values = c("#5B84B1FF", "#FC766AFF")) + 
  theme_minimal()

# (2) Standard Error
fviz_pca_biplot(bcw_pcor, select.var = list(names = bcw_var[11:20]),
                repel = TRUE, geom = "point",
                habillage = bcw_raw$diagnosis, col.var = "black") +
  labs(title = "Biplot (Standard Error)", x = "PC1", y = "PC2") + 
  scale_color_manual(values = c("#5B84B1FF", "#FC766AFF")) + 
  theme_minimal()

# (3) Worst
fviz_pca_biplot(bcw_pcor, select.var = list(names = bcw_var[21:30]),
                repel = TRUE, geom = "point",
                habillage = bcw_raw$diagnosis, col.var = "black") +
  labs(title = "Biplot (Worst)", x = "PC1", y = "PC2") + 
  scale_color_manual(values = c("#5B84B1FF", "#FC766AFF")) + 
  theme_minimal()

# 6. k-means clustering 분석
# (1) 전체 데이터를 통한 2단계 분류
set.seed(1234)
kmeans_model <- kmeans(bcw_raw[, 3:32], 2, iter.max = 10, nstart = 1)
print(kmeans_model)
bcw_raw$kmeans_raw2 <- kmeans_model$cluster

par(mar = c(5, 5, 5, 0)) # 시각화

plot.new()
plot.window(xlim = c(-20, 10), ylim = c(-15, 10))
abline(h = seq(-15, 10, 5), v = seq(-20, 10, 5), col = "grey", lty = 3)

points(bcw_raw[bcw_raw$kmeans_raw2 == 2, "pc1"], 
       bcw_raw[bcw_raw$kmeans_raw2 == 2, "pc2"], pch = 16, col = "#FC766AFF",
       cex = 0.75)
points(bcw_raw[bcw_raw$kmeans_raw2 == 1, "pc1"], 
       bcw_raw[bcw_raw$kmeans_raw2 == 1, "pc2"], pch = 16, col = "#5B84B1FF",
       cex = 0.75)

axis(side = 1, at = seq(-20, 10, 5), cex.axis = 1)
axis(side = 2, at = seq(-15, 10, 5), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)

legend(-20, 10, pch = 16, col = c("#5B84B1FF", "#FC766AFF"), 
       legend = c("B", "M"))

# (2) 주성분을 통한 2단계 분류
set.seed(1234)
kmeans_model <- kmeans(bcw_pcor$x[, 1:6], 2, iter.max = 10, nstart = 1)
print(kmeans_model)
bcw_raw$kmeans_pca2 <- kmeans_model$cluster

par(mar = c(5, 5, 5, 0)) # 시각화

plot.new()
plot.window(xlim = c(-20, 10), ylim = c(-15, 10))
abline(h = seq(-15, 10, 5), v = seq(-20, 10, 5), col = "grey", lty = 3)

points(bcw_raw[bcw_raw$kmeans_pca2 == 2, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca2 == 2, "pc2"], pch = 16, col = "#FC766AFF",
       cex = 0.75)
points(bcw_raw[bcw_raw$kmeans_pca2 == 1, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca2 == 1, "pc2"], pch = 16, col = "#5B84B1FF",
       cex = 0.75)

axis(side = 1, at = seq(-20, 10, 5), cex.axis = 1)
axis(side = 2, at = seq(-15, 10, 5), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)

legend(-20, 10, pch = 16, col = c("#5B84B1FF", "#FC766AFF"), 
       legend = c("B", "M"))

# (3) 정확도 비교
bcw_raw$diagnosis_n <- ifelse(bcw_raw$diagnosis == "M", 1, 2)

confusionMatrix(factor(bcw_raw$kmeans_raw2), factor(bcw_raw$diagnosis_n)) # 0.85
confusionMatrix(factor(bcw_raw$kmeans_pca2), factor(bcw_raw$diagnosis_n)) # 0.91

par(mar = c(5, 5, 5, 0)) # 실제값 시각화

plot.new()
plot.window(xlim = c(-20, 10), ylim = c(-15, 10))
abline(h = seq(-15, 10, 5), v = seq(-20, 10, 5), col = "grey", lty = 3)

points(bcw_raw[bcw_raw$diagnosis == "M", "pc1"], 
       bcw_raw[bcw_raw$diagnosis == "M", "pc2"], pch = 16, col = "#FC766AFF",
       cex = 0.75)
points(bcw_raw[bcw_raw$diagnosis == "B", "pc1"], 
       bcw_raw[bcw_raw$diagnosis == "B", "pc2"], pch = 16, col = "#5B84B1FF",
       cex = 0.75)

axis(side = 1, at = seq(-20, 10, 5), cex.axis = 1)
axis(side = 2, at = seq(-15, 10, 5), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)

legend(-20, 10, pch = 16, col = c("#5B84B1FF", "#FC766AFF"), 
       legend = c("B", "M"))

# (4) 주성분을 통한 4단계 분류
set.seed(1234)
kmeans_model <- kmeans(bcw_pcor$x[, 1:6], 4, iter.max = 10, nstart = 1)
print(kmeans_model)
bcw_raw$kmeans_pca4 <- kmeans_model$cluster

mycol1 <- c(rgb(47, 93, 140, 255, maxColorValue = 255), # 시각화
            rgb(170, 19, 66, 255, maxColorValue = 255),
            rgb(221, 178, 71, 255, maxColorValue = 255),
            rgb(60, 140, 76, 255, maxColorValue = 255)) 

par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(-20, 10), ylim = c(-15, 10))
abline(h = seq(-15, 10, 5), v = seq(-20, 10, 5), col = "grey", lty = 3)

points(bcw_raw[bcw_raw$kmeans_pca4 == 1, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca4 == 1, "pc2"], pch = 16, col = mycol1[1],
       cex = 0.75)
points(bcw_raw[bcw_raw$kmeans_pca4 == 2, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca4 == 2, "pc2"], pch = 16, col = mycol1[2],
       cex = 0.75)
points(bcw_raw[bcw_raw$kmeans_pca4 == 3, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca4 == 3, "pc2"], pch = 16, col = mycol1[3],
       cex = 0.75)
points(bcw_raw[bcw_raw$kmeans_pca4 == 4, "pc1"], 
       bcw_raw[bcw_raw$kmeans_pca4 == 4, "pc2"], pch = 16, col = mycol1[4],
       cex = 0.75)

axis(side = 1, at = seq(-20, 10, 5), cex.axis = 1)
axis(side = 2, at = seq(-15, 10, 5), las = 2, cex.axis = 1)

mtext("PC1", 1, line = 3, cex = 1)
mtext("PC2", 2, line = 3, cex = 1)

legend(-20, 10, pch = 16, col = mycol1, legend = c(1:4))

# (5) Radius 변수의 Boxplot 시각화를 통한 결과 해석
mycol2 <- c(rgb(47, 93, 140, 150, maxColorValue = 255),
            rgb(170, 19, 66, 150, maxColorValue = 255),
            rgb(221, 178, 71, 150, maxColorValue = 255),
            rgb(60, 140, 76, 150, maxColorValue = 255)) 

# 1) Mean
par(mar = c(5, 5, 0, 0))

boxplot(radius_mean ~ kmeans_pca4, data = bcw_raw, axes = F, col = mycol2)

axis(1); axis(2)

mtext("Group", 1, line = 3, cex = 1)
mtext("Radius-Mean", 2, line = 3, cex = 1)

# 2) Standard Error 
par(mar = c(5, 5, 0, 0))

boxplot(radius_se ~ kmeans_pca4, data = bcw_raw, axes = F, col = mycol2)

axis(1); axis(2)

mtext("Group", 1, line = 3, cex = 1)
mtext("Radius-Standard Error", 2, line = 3, cex = 1)

# 3) Largest
par(mar = c(5, 5, 0, 0))

boxplot(radius_worst ~ kmeans_pca4, data = bcw_raw, axes = F, col = mycol2)

axis(1); axis(2)

mtext("Group", 1, line = 3, cex = 1)
mtext("Largest Radius", 2, line = 3, cex = 1)
