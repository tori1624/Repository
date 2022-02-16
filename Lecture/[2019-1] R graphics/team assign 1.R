# ------------------------------------------------------------------------------
# Team Assign 1 : Categorical Data
# ������, �̿�ȣ, ������
# 2019/04/16
# ------------------------------------------------------------------------------

library(dplyr)

# 1. ������ �ҷ�����
data.path <- "D:/Study/2019/Rgraphics/assign/team1/accident/"
traffic2012_2014 <- read.csv(paste0(data.path, "2012_2014_���������.csv"))
traffic2015 <- read.csv(paste0(data.path, "2015_���������.csv"))
traffic2016 <- read.csv(paste0(data.path, "2016_���������.csv"))
traffic2017 <- read.csv(paste0(data.path, "2017_���������.csv"))

# 2. ������ ��ó��
# 2-1) ������ ����
traffic.df <- rbind(traffic2012_2014, traffic2015, traffic2016, traffic2017)

# 2-2) ����ġ ó�� : �������� �ܵ������ ���, �����ڸ� "����"���� ����
x1 <- which(traffic.df[, 22] == "0")
x2 <- which(traffic.df[, 22] == "00")
x3 <- which(traffic.df[, 22] == "")
x <- sort(unique(c(x1, x2, x3)))
traffic.df[x, 22] <- "����"

y1 <- which(traffic.df[, 23] == "0")
y2 <- which(traffic.df[, 23] == "00")
y3 <- which(traffic.df[, 23] == "")
y <- sort(unique(c(y1, y2, y3)))
traffic.df[y, 23] <- "����"

# 2-3) ������ ���� ������ ����
bicycle.df <- subset(traffic.df, traffic.df[, 20] == "������" | 
                       traffic.df[, 22] == "������")

# 2-4) �ð�ȭ�� ���� ������ ��ó��(��ü ��� & ������ ��� �߼� �ľ�)
# �߻��Ǽ�, ����
bicycle.accident <- c(13252, 13852, 17471, 18310, 15636, 14662)
total.accident <- c(223656, 215354, 223552, 232035, 220917, 216335)
years <- c(2012:2017)

# ��ü�Ǽ�
total.death.acc <- aggregate(���� ~ �߻���, traffic.df, length)
bicycle.death.acc <- aggregate(���� ~ �߻���, bicycle.df, length)

# ����ڼ�
total.death.toll <- aggregate(����ڼ� ~ �߻���, traffic.df, sum)
bicycle.death.toll <- aggregate(����ڼ� ~ �߻���, bicycle.df, sum)

# ġ������� = (����������ڼ�/��ü�߻��Ǽ�)*100
lethality.to <- c((total.death.toll/total.accident)*100)
lethality.bi <- c((bicycle.death.toll/bicycle.accident)*100)

# ����
total.summary <- data.frame(years, total.accident, total.death.acc$����,
                            total.death.toll$����ڼ�, lethality.to$����ڼ�)
bicycle.summary <- data.frame(years, bicycle.accident, bicycle.death.acc$����,
                              bicycle.death.toll$����ڼ�, 
                              lethality.bi$����ڼ�)
names(total.summary) <- c("�⵵", "�߻��Ǽ�", "��ü�Ǽ�", "����ڼ�", "ġ����")
names(bicycle.summary) <- c("�⵵", "�߻��Ǽ�", "��ü�Ǽ�", "����ڼ�", 
                            "ġ����")

# 2-5) �ð�ȭ�� ���� ������ ��ó��(��������� ������ ��� ����ڼ�)
# ������� ����
## ����, ���� -> ��������
bicycle.df$�������_�ߺз� <- gsub("��������", "1", bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("����", "1", bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("����", "1", bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("1", "��������", bicycle.df$�������_�ߺз�)
## ö��ǳθ�, �������浹 -> ��Ÿ
bicycle.df$�������_�ߺз� <- gsub("ö��ǳθ�", "��Ÿ", 
                                   bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("�������浹", "��Ÿ", 
                                   bicycle.df$�������_�ߺз�)
## �氡���ڸ�����������, ����������, ����������, Ⱦ���� -> ������
bicycle.df$�������_�ߺз� <- gsub("�氡���ڸ�����������", "2", 
                                   bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("����������", "2", 
                                   bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("����������", "2", 
                                   bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("Ⱦ����", "2", bicycle.df$�������_�ߺз�)
bicycle.df$�������_�ߺз� <- gsub("2", "������", bicycle.df$�������_�ߺз�)
## ��з����� ö��ǳθ� -> ������
bicycle.df$�������_��з� <- gsub("ö��ǳθ�", "������", 
                                   bicycle.df$�������_��з�)


# ��������� ������ ����
cartocar <- subset(bicycle.df, subset = (�������_��з� == "������"), 
                   select = c(����ڼ�, ����ڼ�, �������_��з�, 
                              �������_�ߺз�, ���������_1��_��з�, 
                              ���������_1��, ���������_2��_��з�, 
                              ���������_2��))
cartoped <- subset(bicycle.df, subset = (�������_��з� == "������"), 
                   select = c(����ڼ�, ����ڼ�, �������_��з�, 
                              �������_�ߺз�, ���������_1��_��з�, 
                              ���������_1��, ���������_2��_��з�, 
                              ���������_2��))
onlycar <- subset(bicycle.df, subset = (�������_��з� == "�����ܵ�"), 
                  select = c(����ڼ�, ����ڼ�, �������_��з�, 
                             �������_�ߺз�, ���������_1��_��з�, 
                             ���������_1��, ���������_2��_��з�, 
                             ���������_2��))
total <- subset(bicycle.df, select = c(����ڼ�, ����ڼ�,�������_��з�, 
                                       �������_�ߺз�, ���������_1��_��з�, 
                                       ���������_1��, ���������_2��_��з�, 
                                       ���������_2��))

# ��������� ������ ��� ����ڼ� ���� ���
ctoc <- aggregate(����ڼ� ~ �������_�ߺз�, cartocar, sum)
ctop <- aggregate(����ڼ� ~ �������_�ߺз�, cartoped, sum)
onlyc <- aggregate(����ڼ� ~ �������_�ߺз�, onlycar, sum)
all <- aggregate(����ڼ� ~ �������_��з�, total, sum)

# 2-6) �ð�ȭ�� ���� ������ ��ó��(���������� ������ ��� ����ڼ�)
roadtype <- bicycle.df %>%
  group_by(��������) %>%
  summarise(����ڼ� = sum(����ڼ�)) %>%
  arrange(����ڼ�) %>%
  mutate(tmp_var = c("��Ÿ/�Ҹ�", "��Ÿ/�Ҹ�", "��Ÿ/�Ҹ�", "��Ÿ/�Ҹ�", 
                     "��Ÿ/�Ҹ�", "��Ÿ/�Ҹ�", "��Ÿ/�Ҹ�", "Ⱦ�ܺ����α�",
                     "������Ⱦ�ܺ�����", "Ⱦ�ܺ�����", "�����κα�", "�����γ�",
                     "��Ÿ���Ϸ�")) %>%
  group_by(tmp_var) %>%
  summarise(����ڼ� = sum(����ڼ�)) %>%
  arrange(����ڼ�)

# 3. ������ �ð�ȭ
# 3-1) �� ����
mycol <- c(col = rgb(201, 76, 68, maxColorValue = 255), 
           col = rgb(136, 107, 104, maxColorValue = 255), 
           col = rgb(96, 176, 160, maxColorValue = 255),
           col =  rgb(239, 161, 70, maxColorValue = 255))
mycolbg <- c(col = rgb(201, 76, 68, 80, maxColorValue = 255), 
             col = rgb(136, 107, 104, 80, maxColorValue = 255), 
             col = rgb(96, 176, 160, 80, maxColorValue = 255))

# 3-2) ��ü ��� & ������ ��� �߼� �ľ�
time.label <- c('2012', '2013', '2014', '2015', '2016', '2017')
yaxis.value <- c('0','50k','100k','150k','200k','250k','300k','350k')
zaxis.value <- c('1.0','1.5','2.0','2.5')

## Graph1
par(mar = c(4, 5, 2, 5), family = 'sans')
bar1 <- barplot(total.summary$�߻��Ǽ�, names.arg = time.label, beside = T, 
                col = mycol[4], border = NA, ylim = c(0, 350000), axes = F, 
                font.axis = 2, cex.main = 2,
                main = "Total Traffic Accident & Bicycle Accident, 2012-2017")
bar2 <- barplot(bicycle.summary$�߻��Ǽ�, beside = T, col = mycol[2], 
                border = NA, ylim = c(0, 350000), axes = F, add = T)

## x, y axis
mtext("Years",side = 1, line = 2.5, cex = 1.25, font = 2, col = "black")
mtext("The number of traffic accident", side = 2, line = 3, cex = 1.25, 
      font = 2, col = "black")

yvalue.seq <- seq(0, 350000, 50000)
axis(2, at = yvalue.seq, label = yaxis.value, hadj = 0.8, las = 1)

## Graph2
par(new = T, mar = c(4, 8.5, 2, 8.5), family = 'sans')
plot1 <- plot(time.label, total.summary$ġ����, type = "o", pch = 15, 
              col = mycol[1], ylim = c(1, 2.5), axes = F, xlab = "", 
              ylab = "", cex = 1.3)
par(new = T, mar = c(4, 8.5, 2, 8.5), family = 'sans')
plot2 <- plot(time.label, bicycle.summary$ġ����, type = "o", pch = 17, 
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

# 3-3) �米������ ������ ��� ����ڼ�
par(oma = c(5, 10, 3, 3), mai = c(4, 4, 0, 0), mar = c(0, 0, 0, 0), 
    family = "sans")
lf <- layout(matrix(1:3), heights = c(1, 0.4, 0.8))
layout.show(lf)

## Graph1(Bicycle(Car) to Bicycle(Car))
car <- barplot(ctoc$����ڼ�, space = 0.1, horiz = T, col = mycol[1], 
               border = NA, xlab = "", ylab = "", xlim = c(0, 580), axes = F)
axis(2, at = car, labels = ctoc$�������_�ߺз�, tck = 0, lty = 0, adj = 0, 
     hadj = 0.85, las = 1, cex.axis = 1.3)
for (i in 1:length(ctoc$�������_�ߺз�)) {
  text(ctoc$����ڼ�[i], car[i], labels = ctoc$����ڼ�[i], adj = -0.3, 
       cex = 1.1, col = "black")
}
par(new = T) # background
car2 <- barplot(580, space = 0, horiz = T, col = mycolbg[1], border = NA,
                xlab = "", ylab = "", xlim = c(0, 580), axes = F, xpd = T)

## Graph2(Car to Pedestrians)
pedestrian <- barplot(ctop$����ڼ�, space = 0.1, horiz = T, col = mycol[2], 
                      border = NA, xlab = "", ylab = "", xlim = c(0, 580),
                      axes = F)
axis(2, at = pedestrian, labels = ctop$�������_�ߺз�, tck = 0, lty = 0, 
     adj = 0, hadj = 0.8, las = 1, cex.axis = 1.3)
for (i in 1:length(ctop$����ڼ�)) {
  text(ctop$����ڼ�[i], pedestrian[i], labels = ctop$����ڼ�[i], 
       adj = -0.3, cex = 1.1, col = "black")
}
par(new = T) # background
ped2 <- barplot(580, space = 0, horiz = T, col = mycolbg[2], border = NA, 
                xlab = "", ylab = "", xlim = c(0, 580), axes = F, xpd = T)

## Graph3(Only Car)
only <- barplot(onlyc$����ڼ�, space = 0.1, horiz = T, col = mycol[3], 
                border = NA, xlab = "", ylab = "", xlim = c(0, 580), axes = F)
axis(2, at = only, labels = onlyc$�������_�ߺз�, tck = 0, lty = 0, adj = 0,
     hadj = 0.8, las = 1, cex.axis = 1.3)
for (i in 1:length(onlyc$����ڼ�)) {
  text(onlyc$����ڼ�[i], only[i], labels = onlyc$����ڼ�[i], adj = -0.3, 
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

# 3-4) ���������� ������ ��� ����ڼ�
par(omi = c(0.5, 0.5, 0.5, 0.5),
    mar = c(1, 5.5, 0.25, 1), mfrow = c(1, 1), family = "sans")

## Graph
bg <- barplot(1000, space = 0, horiz = T, col = mycolbg[1], border = NA, 
              xlab = "", ylab = "", xlim = c(0, 900), axes = F, xpd = T)
par(new = T)
bar <- barplot(roadtype$����ڼ�, horiz = T, col = c(rep(mycol[2], 6), mycol[1]), 
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
  text(roadtype$����ڼ�[i], bar[i], labels = roadtype$����ڼ�[i], adj = -0.3, 
       cex = 0.9, col = "black")
}