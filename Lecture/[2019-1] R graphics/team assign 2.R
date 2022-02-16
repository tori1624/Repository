# ------------------------------------------------------------------------------
# Team Assign 2 : Distributions
# ������, �̿�ȣ, ������
# 2019/04/23
# ------------------------------------------------------------------------------

library(dplyr)
library(showtext)
showtext_auto()

font_add(family = "NanumGothic", 
         regular = "D:/Study/2019/Rgraphics/assign/team2/font/NanumGothic.ttf")

# 1. ������ �ҷ�����
data.path <- "D:/Study/2019/Rgraphics/assign/team2/data/"
traffic2012_2014 <- read.csv(paste0(data.path, "2012_2014_���������.csv"))
traffic2015 <- read.csv(paste0(data.path, "2015_���������.csv"))
traffic2016 <- read.csv(paste0(data.path, "2016_���������.csv"))
traffic2017 <- read.csv(paste0(data.path, "2017_���������.csv"))

# 2. ������ ��ó��
# 2-1) ������ ����
traffic.df <- rbind(traffic2012_2014, traffic2015, traffic2016, traffic2017)

# 2-2) ���� ���� �� ������ ��ȯ
time.df <- traffic.df[, c(2:4, 6:9, 17)]

names(time.df)[1:8] <- c("date.time", "minute", "DN", "deaths", "casualties", 
                         "serious", "slight", "violation")

# 2-3) �ð����� ���� �� �ð����� ������ ���� ��ȯ
time.df <- time.df %>%
  mutate(year = substr(date.time, 1, 4),
         month = substr(date.time, 5, 6),
         day = substr(date.time, 7, 8),
         hour = substr(date.time, 9, 10)) %>%
  select(-date.time)

time.df$minute <- as.character(time.df$minute)
time.df[nchar(time.df$minute) == 1, 
        "minute"] <- paste0("0", time.df[nchar(time.df$minute) == 1, "minute"])

time.df <- time.df %>%
  mutate(hour.minute = paste0(hour, ":", minute))

time.df$hour.minute <- as.POSIXct(time.df$hour.minute, format = "%H:%M")

# 3. ������ �ð�ȭ
mycol = c(rgb(234, 189, 93, 175, maxColorValue = 255),
          rgb(203, 91, 90, 175, maxColorValue = 255),
          rgb(172, 85, 122, 175, maxColorValue = 255),
          rgb(107, 64, 110, 175, maxColorValue = 255),
          rgb(64, 50, 79, 175, maxColorValue = 255))

vio <- c("������ ��ȣ�ǹ� ����", "�������� �ǹ� ������", "��ȣ����", 
         "�߾Ӽ� ħ��", "����")

par(mar = c(2, 1, 3, 1), mfrow = c(5, 1), family = "NanumGothic")

## Graph1
hist1 <- hist(time.df$hour.minute, breaks = "hours", lty = "blank", 
              ylim = c(0, 0.00002), xlab = "", ylab = "", axes = F, 
              main = "")
polygon(density(as.numeric(time.df$hour.minute[time.df$violation == vio[1]])), 
        col = mycol[1], border = NA)
text(hist1$breaks[1], 0.000018, vio[1], cex = 1.3, col = "black")
mtext("�������ݿ� ���� �ð��뺰 ��������� ����", side = 3, line = 1, 
      cex = 1, font = 2, col = "black")
abline(v = as.numeric(as.POSIXct("19:00", format = "%H:%M")), col = "red", 
       lwd = 2, lty = 3)

## Graph2
hist2 <- hist(time.df$hour.minute, breaks = "hours", lty = "blank", 
              ylim = c(0, 0.0000175), xlab = "", ylab = "", axes = F, 
              main = "")
polygon(density(as.numeric(time.df$hour.minute[time.df$violation == vio[2]])), 
        col = mycol[2], border = NA)
text(hist2$breaks[3], 0.000016, vio[2], cex = 1.3, col = "black")
abline(v = as.numeric(as.POSIXct("19:00", format = "%H:%M")), col = "red", 
       lwd = 2, lty = 3)

## Graph3
hist3 <- hist(time.df$hour.minute, breaks = "hours", lty = "blank", 
              ylim = c(0, 0.0000175), xlab = "", ylab = "", axes = F, 
              main = "")
polygon(density(as.numeric(time.df$hour.minute[time.df$violation == vio[3]])), 
        col = mycol[3], border = NA)
text((hist3$breaks[1]+hist3$breaks[2])/2, 0.000016, vio[3], cex = 1.3, 
     col = "black")
abline(v = as.numeric(as.POSIXct("06:30", format = "%H:%M")), col = "red", 
       lwd = 2, lty = 3)

## Graph4
hist4 <- hist(time.df$hour.minute, breaks = "hours", lty = "blank", 
              ylim = c(0, 0.0000175), xlab = "", ylab = "", axes = F, 
              main = "")
polygon(density(as.numeric(time.df$hour.minute[time.df$violation == vio[4]])), 
        col = mycol[4], border = NA)
text(hist4$breaks[2], 0.000016, vio[4], cex = 1.3, col = "black")
abline(v = as.numeric(as.POSIXct("18:00", format = "%H:%M")), col = "red", 
       lwd = 2, lty = 3)

## Graph5
hist5 <- hist(time.df$hour.minute, breaks = "hours", lty = "blank", 
              ylim = c(0, 0.0000175), xlab = "", ylab = "", main = "", 
              cex.axis = 1.4, yaxt = "n")
polygon(density(as.numeric(time.df$hour.minute[time.df$violation == vio[5]])), 
        col = mycol[5], border = NA)
text(hist5$breaks[1], 0.000016, vio[5], cex = 1.3, col = "black")
abline(v = as.numeric(as.POSIXct("2:30", format = "%H:%M")), col = "red", 
       lwd = 2, lty = 3)