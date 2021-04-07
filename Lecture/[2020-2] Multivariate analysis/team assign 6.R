# ------------------------------------------------------------------------------
# Team Assign 6 : Wechsler Intelligence Scale for Children
# 최창락, 이영호, 오지은
# 2020/12/01
# ------------------------------------------------------------------------------

library(foreign)
library(lavaan)
library(semPlot)

options(scipen = 50)

# 1. 데이터 불러오기
data.path <- "D:/Study/2020/multivariate/team assign/assign6/"
data <- read.spss(paste0(data.path, "wiscsem.sav"), to.data.frame = TRUE)

# 2. 데이터 구분
data1 <- data[data$agemate == 1, -c(1:2)] # 집단 1
data2 <- data[data$agemate == 2, -c(1:2)] # 집단 2
data3 <- data[data$agemate == 3, -c(1:2)] # 집단 3

# 3.요인 수 결정 및 탐색적 요인분석
# (1) 요인 수 결정: Kaiser's criterion
wisc_pcor1 <- prcomp(data1, scale = TRUE, center = TRUE) # 집단 1
wisc_pcor2 <- prcomp(data2, scale = TRUE, center = TRUE) # 집단 2
wisc_pcor3 <- prcomp(data3, scale = TRUE, center = TRUE) # 집단 3

mean(wisc_pcor1$sdev^2) # 집단 1
round(wisc_pcor1$sdev^2, 4)
mean(wisc_pcor2$sdev^2) # 집단 2
round(wisc_pcor2$sdev^2, 4)
mean(wisc_pcor3$sdev^2) # 집단 3
round(wisc_pcor3$sdev^2, 4)

# (2) 탐색적 요인분석
factanal(data1, factors = 3, method = "mle", rotation = 'promax') # 집단 1
factanal(data2, factors = 3, method = "mle", rotation = 'promax') # 집단 2
factanal(data3, factors = 3, method = "mle", rotation = 'promax') # 집단 3

# 3. 확인적 요인분석
model1 <- 'a =~ info+comp+arith+vocab+digit 
         b =~ pictcomp+parang+block+object
         c =~ simil+coding' # 집단 1
model2 <- 'a =~ info+simil+vocab+digit
         b =~ comp+pictcomp+parang+block+object
         c =~ arith' # 집단 2
model3 <- 'a =~ info+comp+simil+vocab+pictcomp+block+object
         b =~ arith+digit+coding
         c =~ parang' # 집단 3

fit1 <- lavaan::sem(model1, data = data1) # 집단 1
summary(fit1, fit.measures=TRUE, standardized = TRUE)
fit2 <- lavaan::sem(model2, data = data2[, -11]) # 집단 2
summary(fit2, fit.measures=TRUE, standardized = TRUE)
fit3 <- lavaan::sem(model3, data = data3) # 집단 3
summary(fit3, fit.measures=TRUE, standardized = TRUE)

# 4. 결과 시각화
semPaths(fit1, whatLabels = "std", intercepts = F, style = "lisrel",
         nCharNodes = 0, nCharEdges = 0, curveAdjacent = T, title = T, 
         layout = "tree2", curvePivot = T) # 집단 1
semPaths(fit2, whatLabels = "std", intercepts = F, style = "lisrel",
         nCharNodes = 0, nCharEdges = 0, curveAdjacent = T, title = T, 
         layout = "tree2", curvePivot = T) # 집단 2
semPaths(fit3, whatLabels = "std", intercepts = F, style = "lisrel",
         nCharNodes = 0, nCharEdges = 0, curveAdjacent = T, title = T, 
         layout = "tree2", curvePivot = T) # 집단 3
