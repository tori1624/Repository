# ------------------------------------------------------------------------------
# Team Assign 4 : Scatter plot
# 장지원, 이영호, 김태희
# 2019/06/11
# ------------------------------------------------------------------------------

library(dplyr)
library(showtext)
library(classInt)
showtext_auto()

font_add(family = "NanumGothic", 
         regular = "D:/Study/2019/Rgraphics/assign/team2/font/NanumGothic.ttf")

# 1. 데이터 불러오기
data.path <- "D:/Study/2019/Rgraphics/assign/team4/data/"
dust.df <- read.csv(paste0(data.path, "2017_dust.csv"))
tms.df <- read.csv(paste0(data.path, "2017_tms.csv"))
people.df <- read.csv(paste0(data.path, "2017_people.csv"))

# 2. 데이터 전처리
# (1) 데이터별 지역 이름 정렬
region.order1 <- order(dust.df[, 1])
dust.df <- dust.df[region.order1, ]
region.order2 <- order(tms.df[, 1])
tms.df <- tms.df[region.order2, ]
region.order3 <- order(people.df[, 1])
people.df <- people.df[region.order3, ]

# (2) 최종 데이터 생성
dust.df$dust <- apply(dust.df[, 2:13], 1, mean)
tms.df$tms_ratio <- (tms.df[, 2]/sum(tms.df[, 2])*100)
people.df$vulnerable_ratio <- people.df[, 5]*100

final.df <- data.frame(dust.df[, 1], dust.df[, 14], tms.df[, 3], people.df[, 6])
names(final.df) <- c("region", "dust", "tms_ratio", "vulnerable_ratio")
vul.class <- classIntervals(final.df$vulnerable_ratio, n = 4, 
                            style = "quantile")
final.df$class <- cut(final.df$vulnerable_ratio, c(0, vul.class[[2]][2], 
                                                   vul.class[[2]][3], 
                                                   vul.class[[2]][4], 
                                                   vul.class[[2]][5]))
final.df$class <- as.numeric(final.df$class)
final.df1 <- final.df[final.df$class == 1, ]
final.df2 <- final.df[final.df$class == 2, ]
final.df3 <- final.df[final.df$class == 3, ]
final.df4 <- final.df[final.df$class == 4, ]

# 3. 데이터 시각화
mycol1 <- c(rgb(114, 0, 38, 150, maxColorValue = 255),
            rgb(206, 66, 87, 150, maxColorValue = 255),
            rgb(255, 155, 84, 150, maxColorValue = 255),
            rgb(253, 182, 50, 150, maxColorValue = 255))
mycol2 <- c(rgb(82, 81, 116, 150, maxColorValue = 255),
            rgb(52, 138, 167, 150, maxColorValue = 255),
            rgb(93, 211, 158, 150, maxColorValue = 255),
            rgb(188, 231, 132, 150, maxColorValue = 255))

par(mar = c(4, 4, 4, 0), family = "NanumGothic")

plot(final.df4$dust, final.df4$tms_ratio, col = mycol1[1], pch = 16, cex = 10.5,
     axes = F, xlim = c(35, 55), ylim = c(-1, 27), xlab = "", ylab = "")
points(final.df3$dust, final.df3$tms_ratio, col = mycol1[2], pch = 16, cex = 9)
points(final.df2$dust, final.df2$tms_ratio, col = mycol1[3], pch = 16, cex = 7)
points(final.df1$dust, final.df1$tms_ratio, col = mycol1[4], pch = 16, cex = 5)

axis(1, lwd.ticks = 0.5, cex.axis = 0.7, tck = -0.015)
axis(2, lwd.ticks = 0.5, cex.axis = 0.7, tck = -0.015)

legend.class1 <- round(vul.class[[2]], 2)
legend.class2 <- c(paste(legend.class1[4], "-", legend.class1[5]),
                   paste(legend.class1[3], "-", legend.class1[4]),
                   paste(legend.class1[2], "-", legend.class1[3]),
                   paste("24.32 -", legend.class1[2]))
legend(51, 26, legend = legend.class2, col = mycol1, pch = 16, bty = "n", 
       cex = 1, pt.cex = c(3, 2.5, 2, 1.5), y.intersp = 1.5, 
       title = "취약계층 비율")

text(final.df4$dust, final.df4$tms_ratio, final.df4$region, cex = 0.8, pos = 3, 
     offset = 2.25)
text(final.df3$dust[final.df3$region != "세종특별자치시"], 
     final.df3$tms_ratio[final.df3$region != "세종특별자치시"], 
     final.df3$region[final.df3$region != "세종특별자치시"], 
     cex = 0.8, pos = 3, offset = 2)
text(final.df3$dust[final.df3$region == "세종특별자치시"], 
     final.df3$tms_ratio[final.df3$region == "세종특별자치시"]-0.7, 
     "세종특별자치시", cex = 0.8, pos = 4, offset = 1.75)
text(final.df2$dust, final.df2$tms_ratio, final.df2$region, cex = 0.8, pos = 3, 
     offset = 1.75)
text(final.df1$dust[final.df1$region != "서울특별시"], 
     final.df1$tms_ratio[final.df1$region != "서울특별시"], 
     final.df1$region[final.df1$region != "서울특별시"], cex = 0.8, pos = 3, 
     offset = 1.25)
text(final.df1$dust[final.df1$region == "서울특별시"], 
     final.df1$tms_ratio[final.df1$region == "서울특별시"]-1, "서울특별시", 
     cex = 0.8, pos = 2, offset = 1.4)

mtext("연평균 미세먼지 농도 (PM 10)", 1, line = 3, cex = 0.9)
mtext("대기오염 배출량 비율 (해당 지역 배출량 / 전국 배출량)", 2, line = 3, 
      cex = 0.9)
mtext("지역별 미세먼지 농도, 대기오염 배출량 및 취약계층 분포", 3, line = 2, 
      cex = 1.2, adj = 0)
mtext("(취약계층 : 영유아, 어린이, 노인)", 3, line = 0, cex = 0.8, adj = 1)