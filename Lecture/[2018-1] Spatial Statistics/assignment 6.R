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

# center points
points.xy <- coordinates(seoul.sp)

cs.tm <- CRS("+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 
                 +ellps=bessel +units=m +no_defs")
points.xy <- SpatialPoints(points.xy, proj4string = cs.tm)

# distance
d <- as.matrix(dist(data.frame(points.xy)))
d <- d / 1000


# class
setClass("SP", slots = c(sp = "numeric", data = "data.frame", 
                         distance = "matrix", method = "character"))

SP <- function(sp, data, distance, method) {
  new("SP", sp = sp, data = data, distance = distance, method = method)
}

# method
## show(S4)
setMethod("show", "SP", 
          function(object) {
            validObject(object)
            
            dis <- as.vector(slot(object, "distance"))
            dis <- dis[dis != 0]
            
            print(slot(object, "sp"))
            cat("Average distance (km) :", mean(dis), "\n")
            cat("Distance method :", slot(object, "method"), "\n"); cat("\n")
            cat("Data : \n")
            print(head(slot(object, "data"), n = 10))
          })

## summary(S4)
setMethod("summary", "SP", 
          function(object) {
            validObject(object)
            
            dis <- as.vector(slot(object, "distance"))
            dis <- dis[dis != 0]
            
            cat("The index of Spatial Proximity \n")
            cat("class : 'SP' \n")
            cat("Number of points :", nrow(slot(object, "distance")), "\n") 
            cat("\n")
            cat("Group : \n")
            cat("        Group1  Group2 \n")
            cat("count  ", sum(slot(object, "data")[1]), " ", 
                sum(slot(object, "data")[2]), "\n")
            cat("ratio  ", 
                round(sum(slot(object, "data")[1]) / sum(slot(object, "data")), 
                      2),
                "  ", 
                round(sum(slot(object, "data")[2]) / sum(slot(object, "data")), 
                      2),"\n")
            cat("\n")
            cat("Distance method :", slot(object, "method"), "\n"); cat("\n")
            cat("Distance (km) : \n")
            cat("Min.   ", min(dis), "\n")
            cat("Median ", median(dis), "\n")
            cat("Mean   ", mean(dis), "\n")
            cat("Max.   ", max(dis), "\n")
          })

## update(S3)
setGeneric("update")
setMethod("update", "SP",
          function(object, x, data, method) {
            if(missing(x)) {
              stop("argument 'x' is missing")
            }
            
            validObject(object)
            
            if (missing(data)) {data <- slot(object, "data")}
            if (missing(method)) {method <- slot(object, "method")}
            
            result <- spatialProximity(x, data, method)
            return(result)
          })

update.SP <- function(object, x, data, method) {
  if(missing(x)) {
    stop("argument 'x' is missing")
  }
  
  validObject(object)
  
  if (missing(data)) {data <- slot(object, "data")}
  if (missing(method)) {method <- slot(object, "method")}
  
  result <- spatialProximity(x, data, method)
  return(result)
}

## as.list(S3)
setGeneric("as.list")
setMethod("as.list", "SP",
          function(x) {
            validObject(x)
            
            list(sp = slot(x, "sp"), Group = slot(x, "data"), 
                 Distance = slot(x, "distance"))
          })

as.list.SP <- function(object) {
  list(sp = slot(object, "sp"), Group = slot(object, "data"), 
       Distance = slot(object, "distance"))
}

## print(S3)
setGeneric("print")
setMethod("print", "SP",
          function(x) {
            validObject(x)
            
            print(slot(x, "sp"))
            cat("Average distance (km) :", mean(slot(x, "distance")), "\n")
            cat("Distance method :", slot(x, "method"), "\n")
          })

showMethods(print)

print.SP <- function(object) {
  print(slot(object, "sp"))
  cat("Average distance (km) :", mean(slot(object, "distance")), "\n")
  cat("Distance method :", slot(object, "method"), "\n")
}



# example
x <- SP(0.5, seoulincome2010[, c(8:13)], d, "euclidean")

a <- spatialProximity(seoul.sp, seoulincome2010[, c(8, 13)], "euclidean")
b <- spatialProximity(seoul.sp, seoulincome2010[, c(8, 13)], "manhattan")
