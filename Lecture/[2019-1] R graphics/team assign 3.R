# ------------------------------------------------------------------------------
# Team Assign 3 : Time series
# 장지원, 이영호, 김태희
# 2019/05/14
# ------------------------------------------------------------------------------

library(dplyr)
library(showtext)
showtext_auto()

font_add(family = "NanumGothic", 
         regular = "D:/Study/2019/Rgraphics/assign/team2/font/NanumGothic.ttf")

# 데이터 불러오기
data.path <- "D:/Study/2019/Rgraphics/assign/team3/data/"
all.df <- read.csv(paste0(data.path, "data_all.csv"), skip = 1)

# 데이터 전처리
column.names <- c("발생년도", "발생월", "도로형태",
                  unique(as.character(all.df[[3]]))[1:6])
firstRow <- c(0, 11, 16, 21)
roadtype <- c("합계", "터널안", "횡단보도", "교량위")
dfName <- c("all", "tunnel", "crosswalk", "bridge")

for (i in 1:4) {
  tmp.df <- t(all.df[(i+firstRow[i]):(i+firstRow[i]+5), 
                     -c(1:3, seq(4, 81, 13))])
  
  row.names(tmp.df) <- 1:72
  
  tmp.df <- as.data.frame(tmp.df) %>%
    mutate(year = rep(2012:2017, each = 12),
           month = rep(1:12, 6),
           roadtype = as.character(all.df[[2]][i+firstRow[i]])) %>%
    select(7:9, 1:6)
  
  names(tmp.df) <- column.names
  
  tmp.month <- tmp.df %>%
    mutate(치사율 = (사망자수/사고건수)*100) %>%
    group_by(발생월) %>%
    summarise(avg = mean(치사율))
 
  assign(dfName[i], tmp.month)
}

# 색 설정
mycol <- c(rgb(250, 200, 10, maxColorValue = 255),
           rgb(216, 39, 53, maxColorValue = 255),
           rgb(100, 171, 35, maxColorValue = 255),
           rgb(125, 60, 181, maxColorValue = 255))
mycol.bg <- rgb(216, 39, 53, 50, maxColorValue = 255)

# 데이터 시각화
par(mar = c(5, 5, 5, 1), family = "NanumGothic")

plot.new()
plot.window(xlim = c(1, 12), ylim = c(1, 9))

lines(all$avg, col = mycol[1], lwd = 2)
lines(tunnel$avg, col = mycol[2], lwd = 2)
lines(crosswalk$avg, col = mycol[3], lwd = 2)
lines(bridge$avg, col = mycol[4], lwd = 2)

rect(2.5, 0.5, 3.5, 9, border = NA, col = mycol.bg)

axis(side = 1, at = 1:12, cex.axis = 0.8)
axis(side = 2, at = 1:9, las = 2, cex.axis = 0.8)

legend.type <- c("전체", "터널안", "횡단보도", "교량위")
legend(10, 9, legend = legend.type, col = mycol, lty = 1, lwd = 2, bty = "n", 
       cex = 1, y.intersp = 1.5)

mtext("도로유형에 따른 월별 치사율 추이 (2012 - 2017)", 3, line = 2, cex = 1.3,
      adj = 0)
mtext("치사율(%)", 2, line = 3, cex = 1)
mtext("월", 1, line = 3, cex = 1)
mtext("치사율(%) = (사망자수/발생건수) X 100", 3, line = 0, cex = 0.8, adj = 1)
