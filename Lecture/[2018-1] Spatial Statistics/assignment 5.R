# packages
library(rgdal)
library(spdep)
library(spatstat)

# data import
seoul.sp <- readOGR("D:/Study/2018/shiny/lab/lab2/data/hang.shp",
                    encoding = "UTF8")
seoul.df <- data.frame(seoul.sp)

income <- read.csv("D:/Study/2018/shiny/lab/lab2/data/seoulincome2010.csv")

# data arrange
nameOrder1 <- order(seoul.df$name)
seoul.sp <- seoul.sp[nameOrder1, ]
seoul.df <- data.frame(seoul.sp)

nameOrder2 <- order(income$dongName)
income <- income[nameOrder2, ]

# function
S <- function(sp, data) {
  # proportion
  total <- apply(data, 2, sum)
  data[, 1] <- data[, 1] / total[1]
  data[, 2] <- data[, 2] / total[2]
  
  # area range
  range <- bbox(sp)
  
  # central point
  points.xy <- coordinates(sp)
  
  # coordinate system
  cs.tm <- CRS("+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 
               +ellps=bessel +units=m +no_defs")
  points.xy <- SpatialPoints(points.xy, proj4string = cs.tm)
  
  # calculation average distance
  d <- as.matrix(dist(data.frame(points.xy))) # euclidean(unit = m)
  d <- as.vector(d) / 1000 # km
  mean.d <- sum(d) / (length(d) - sqrt(length(d)))
  
  # transformation to 'ppp'
  xymatrix <- slot(points.xy, 'coords')
  data.ppp <- ppp(xymatrix[, 1], xymatrix[, 2], 
                  window = owin(c(range[1], range[3]), 
                                c(range[2], range[4])))
  
  # kernel
  ker1 <- density.ppp(data.ppp, weights = data[, 1], 
                      sigma = bw.diggle(data.ppp))
  ker2 <- density.ppp(data.ppp, weights = data[, 2],
                      sigma = bw.diggle(data.ppp))
  
  v1 <- ker1[["v"]]
  v2 <- ker2[["v"]]
  
  # matrix to vector
  KDE1 <- as.vector(v1)
  KDE2 <- as.vector(v2)
  
  output <- cbind(KDE1, KDE2)
  
  # calculation 'inter', 'union'
  inter <- apply(output, 1, min)
  union <- apply(output, 1, max)
  
  # calculation 'S'
  1 - (sum(inter) / sum(union)) 
}

# result
income.data <- income[, 8:13]
totalpop <- apply(income.data, 2, sum)
income1 <- income.data[, 1] / totalpop[1]
income2 <- income.data[, 2] / totalpop[2]
income3 <- income.data[, 3] / totalpop[3]
income4 <- income.data[, 4] / totalpop[4]
income5 <- income.data[, 5] / totalpop[5]
income6 <- income.data[, 6] / totalpop[6]
income.x <- apply(income.data[, -6], 1, sum) / sum(totalpop[-6])

income.z <- data.frame(cbind(income1, income2, income3, income4, income5, income6))

S(seoul.sp, data.frame(income3, income4))

# sp
# 1.009944(1) / 1.014483(2) / 1.010651(3) / 1.009024(4) / 1.03492(5) / 1.01446(6)
# 1.025425(1~2, 3~6) / 1.047224(1~4, 5~6) / 1.128158(1~2, 5~6)

# s
# 0.144215(1, else) / 0.115113(2, else) / 0.08586643(3, else) / 
# 0.07100357(4, else) / 0.2013631(5, else) / 0.2833587(6, else)
# 0.13913(1~2, 3~6) / 0.2203831(1~4, 5~6) / 0.2648117(1~2, 5~6)
# 0.3519134(1, 6) / 0.09411972(3, 4)

plot(density.ppp(data.ppp, weights = income[, 1], sigma = bw.diggle(data.ppp)))
plot(density.ppp(data.ppp, weights = income[, 1], sigma = bw.ppl(data.ppp)))
plot(density.ppp(data.ppp, weights = income[, 1], sigma = bw.scott(data.ppp)))
