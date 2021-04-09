# packages
library(rgdal)
library(spdep)

# data
korea.sp <- readOGR("D:/Study/2018/sptialstatistics/0329/data/BND_ADM_DONG_PG.shp")
korea.df <- data.frame(korea.sp)
seoul.sp <- korea.sp[substr(as.character(korea.sp$adm_dr_cd), 1, 2) == "11", ]
seoul.df <- data.frame(seoul.sp)

seoul.sp <- readOGR("D:/Data/map/shp/seoul_bub_hang/hang.shp", 
                    encoding = "UTF8")
seoul.df <- data.frame(seoul.sp)

seoulincome2010 <- read.csv("D:/Study/2018/sptialstatistics/0329/data/seoulincome2010.csv")

# arrange
nameOrder1 <- order(seoul.df$name)
seoul.sp <- seoul.sp[nameOrder1, ]

nameOrder2 <- order(seoulincome2010$dongName)
seoulincome2010 <- seoulincome2010[nameOrder2, ]

# function
spatialProximity <- function(x, data) {
  
  if (class(x)[1] == "SpatialPolygonsDataFrame" | 
      class(x)[1] == "SpatialPolygons") {
    # center points
    points.xy <- coordinates(x)
    
    # coordinate system
    cs.tm <- CRS("+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 
                 +ellps=bessel +units=m +no_defs")
    points.xy <- SpatialPoints(points.xy, proj4string = cs.tm)
  }
  if (ncol(data) > 2) {
    warning("'data' has more than two columns; only the first two are used",
            call. = FALSE)
    data <- data[, 1:2]
  }

  # distance
  d <- as.matrix(dist(data.frame(points.xy))) # euclidean(unit = m)
  d <- d / 1000
  c <- exp(-d)
  
  # Spatial Proximity calculation
  pxx <- vector()
  pyy <- vector()
  ptt <- vector()
  
  total <- apply(data, 1, sum)
  
  for(i in 1:nrow(data)) {
    for(j in 1:nrow(data)) {
      # Pxx
      xi <- data[i, 1]
      xj <- data[j, 1]
      cij <- c[i, j]
      pij.x <- (xi * xj * cij) 
      pxx <- sum(pxx, pij.x)
      
      # Pyy
      yi <- data[i, 2]
      yj <- data[j, 2]
      pij.y <- (yi * yj * cij) 
      pyy <- sum(pyy, pij.y)
      
      # Ptt
      ti <- total[i]
      tj <- total[j]
      pij.t <- (ti * tj * cij)
      ptt <- sum(ptt, pij.t)
    }
  }
  sp <- ((pxx / sum(data[, 1])) + (pyy / sum(data[, 2]))) / (ptt / sum(data))
  
  as.vector(sp)
}

# result
incomedata <- seoulincome2010[, 8:13]

spatialProximity(seoul.sp, incomedata[, c(1, 6)])

sp.m <- matrix(1, ncol = 6, nrow = 6)

for (i in 1:6) {
  for (j in 1:6) {
    data.x <- incomedata[, c(i, j)]
    sp.m[i, j] <- spatialProximity(seoul.sp, data.x)
  }
}

sp.m
#          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
# [1,] 1.000000 1.007685 1.012686 1.032740 1.117588 1.179724
# [2,] 1.007685 1.000000 1.006196 1.033265 1.118138 1.099418
# [3,] 1.012686 1.006196 1.000000 1.018375 1.083900 1.060223
# [4,] 1.032740 1.033265 1.018375 1.000000 1.033460 1.038005
# [5,] 1.117588 1.118138 1.083900 1.033460 1.000000 1.022615
# [6,] 1.179724 1.099418 1.060223 1.038005 1.022615 1.000000

# isp
points.xy <- coordinates(seoul.sp)
d <- as.matrix(dist(data.frame(points.xy))) / 1000

isp.m <- matrix(1, ncol = 6, nrow = 6)

for (i in 1:6) {
  for (j in 1:6) {
    data.x <- incomedata[, c(i, j)]
    isp.m[i, j] <- isp(seoul.sp, data.x, d)
  }
}

isp.m
#          [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
# [1,] 1.000000 1.001304 1.004497 1.019699 1.084601 1.120421
# [2,] 1.001304 1.000000 1.001914 1.020670 1.083571 1.065398
# [3,] 1.004497 1.001914 1.000000 1.011027 1.058346 1.038713
# [4,] 1.019699 1.020670 1.011027 1.000000 1.022642 1.023446
# [5,] 1.084601 1.083571 1.058346 1.022642 1.000000 1.010060
# [6,] 1.120421 1.065398 1.038713 1.023446 1.010060 1.000000

# ------------------------------------------------------------------------------
# 0.2461196(1, 2) /  0.07801364(1)
incomedata <- seoulincome2010[, 8:13]

income1 <- apply(incomedata[, c(1:2)], 1, sum)
income2 <- apply(incomedata[, -c(1:4)], 1, sum)
income <- data.frame(cbind(income1, income2))

spatialProximity(seoul.sp, income)

# 1.009944(1) / 1.014483(2) / 1.010651(3) / 1.009024(4) / 1.03492(5) / 1.01446(6)
# 1.025425(1~2, 3~6) / 1.047224(1~4, 5~6) / 1.128158(1~2, 5~6)