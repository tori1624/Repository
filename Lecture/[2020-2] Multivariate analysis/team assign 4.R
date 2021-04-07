# ------------------------------------------------------------------------------
# Team Assign 4 : National Merit Twins
# 진수정, 이영호, 황수연
# 2020/11/03
# ------------------------------------------------------------------------------

# 1. 데이터 불러오기
data <- read.csv("D:/Study/2020/multivariate/team assign/assign4/data.csv")

# 2. 데이터 전처리
# (1) 결측치 제거
data <- na.omit(data)

# (2) 과목별 차이 평균 변수 생성
eng_dif <- c(); math_dif <- c(); socsci_dif <- c(); natsci_dif <- c()
vocab_dif <- c()


for (i in 1:(nrow(data)/2)) { # 과목별 차이 계산
  i <- i*2-1
  
  # english difference
  eng_dif <- c(eng_dif, abs((data[i, 7]-data[i+1, 7])))
  
  # math difference
  math_dif <- c(math_dif, abs((data[i, 8]-data[i+1, 8])))
  
  # social science difference
  socsci_dif <- c(socsci_dif, abs((data[i, 9]-data[i+1, 9])))
  
  # natural science difference
  natsci_dif <- c(natsci_dif, abs((data[i, 10]-data[i+1, 10])))
  
  # vocabulary difference
  vocab_dif <- c(vocab_dif, abs((data[i, 11]-data[i+1, 11])))
}

dif_df <- data.frame(eng_dif, math_dif, socsci_dif, natsci_dif, vocab_dif)

data$dif_mean <- rep(apply(dif_df, 1, mean), each = 2) # 과목별 차이 평균 변수 생성

# (3) 유전 & 가정환경 & 과목별 차이 데이터 프레임 생성 (2번 자료)

sex <- c(); zygosity <- c(); moed <- c(); faed <- c(); faminc <- c()

for (i in 1:(nrow(data)/2)) {
  i <- i*2-1
  
  # sex
  if (data[i, 2] != data[i+1, 2]) {
    sex <- c(sex, 3)
  } else if (data[i, 2] == data[i+1, 2] & data[i, 2] == 1) {
    sex <- c(sex, 1)
  } else if (data[i, 2] == data[i+1, 2] & data[i, 2] == 2) {
    sex <- c(sex, 2)
  }
  
  # zygosity
  zygosity <- c(zygosity, data[i, 3])
  
  # mother's education level
  moed <- c(moed, data[i, 4])
  
  # father's education level
  faed <- c(faed, data[i, 5])
  
  # family income level
  faminc <- c(faminc, data[i, 6])
}

new_data <- data.frame(sex, zygosity, moed, faed, faminc, eng_dif, math_dif,
                       socsci_dif, natsci_dif, vocab_dif)

# 3. 1번 자료 요인 수 결정
# (1) Kaiser's criterion - 4개
nmt_pcor <- prcomp(data[, -1], scale = TRUE, center = TRUE)

mean(nmt_pcor$sdev^2) # 1
round(nmt_pcor$sdev^2, 4) # 4

# (2) Scree Diagram - 2개
par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(1, 11), ylim = c(0, 4))
abline(h = seq(0, 4, 1), v = seq(0, 11, 1), col = "grey", lty = 3)

lines(nmt_pcor$sdev^2, lwd = 3) 
segments(2, 0, 2, 4, col = "red", lwd = 2, lty = 3)

axis(side = 1, at = seq(1, 11, 1), cex.axis = 1)
axis(side = 2, at = seq(0, 4, 1), las = 2, cex.axis = 1)

mtext("Factor Number", 1, line = 3, cex = 1)
mtext("Factor Variance", 2, line = 3, cex = 1)
mtext("Scree Diagram", 3, line = 1, cex = 1.25)

# (3) 카이제곱 반복검정 - 6개
sapply(1:6, function(nf)
  factanal(data[, -1], factors = nf, method = "mle", rotation = 'promax')$PVAL)

# 4. 2번 자료 요인 수 결정
# (1) Kaiser's criterion - 3개
nmt_pcor2 <- prcomp(new_data, scale = TRUE, center = TRUE)

mean(nmt_pcor2$sdev^2) # 1
round(nmt_pcor2$sdev^2, 4) # 3

# (2) Scree Diagram - 3개
par(mar = c(5, 5, 5, 0))

plot.new()
plot.window(xlim = c(1, 10), ylim = c(0, 3))
abline(h = seq(0, 3, 1), v = seq(0, 10, 1), col = "grey", lty = 3)
lines(nmt_pcor2$sdev^2, lwd = 3) 
segments(3, 0, 3, 3, col = "red", lwd = 2, lty = 3)

axis(side = 1, at = seq(1, 10, 1), cex.axis = 1)
axis(side = 2, at = seq(0, 3, 1), las = 2, cex.axis = 1)

mtext("Factor Number", 1, line = 3, cex = 1)
mtext("Factor Variance", 2, line = 3, cex = 1)
mtext("Scree Diagram", 3, line = 1, cex = 1.25)

# (3) 카이제곱 반복검정 - 2개
sapply(1:5, function(nf)
  factanal(new_data, factors = nf, method = "mle")$PVAL)

# 5. 탐색적 요인 분석 (1번 자료)
# 요인 수가 4일 때
factanal(data[, -1], factors = 4, method = "mle", rotation = 'promax')

# 6. 탐색적 요인 분석 (2번 자료)
# (1) 요인 수가 2일 때
factanal(new_data, factors = 2, method = "mle", rotation = 'promax')

# (2) 요인 수가 3일 때
factanal(new_data, factors = 3, method = "mle", rotation = 'promax')

# 7. 데이터 탐색
# (1) 쌍둥이 유형별 전체 과목의차이
mean(data[data$zygosity == '1', 'dif_mean']) # 2.797436
mean(data[data$zygosity == '2', 'dif_mean']) # 3.851333

# (2) 쌍둥이 유형에 따른 과목별 차이
mean(new_data[new_data$zygosity == '1', 'eng_dif']) # 2.553419
mean(new_data[new_data$zygosity == '2', 'eng_dif']) # 3.4
mean(new_data[new_data$zygosity == '1', 'math_dif']) # 3.461538
mean(new_data[new_data$zygosity == '2', 'math_dif']) # 4.883333
mean(new_data[new_data$zygosity == '1', 'socsci_dif']) # 2.574786
mean(new_data[new_data$zygosity == '2', 'socsci_dif']) # 3.863333
mean(new_data[new_data$zygosity == '1', 'natsci_dif']) # 3.448718
mean(new_data[new_data$zygosity == '2', 'natsci_dif']) # 4.116667
mean(new_data[new_data$zygosity == '1', 'vocab_dif']) # 1.948718
mean(new_data[new_data$zygosity == '2', 'vocab_dif']) # 2.993333
