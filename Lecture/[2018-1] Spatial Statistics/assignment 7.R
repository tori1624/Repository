# packages
library(rgdal)
library(spdep)
library(spatstat)

# function
S <- function(sp, data, sigma) {
  # proportion
  total <- apply(data, 2, sum)
  ratio <- cbind(data[, 1] / total[1], data[, 2] / total[2])
  
  # area range
  range <- bbox(sp)
  
  # central point
  points.xy <- coordinates(sp)
  
  # transformation to 'ppp'
  data.ppp <- ppp(points.xy[, 1], points.xy[, 2], 
                  window = owin(c(range[1], range[3]), 
                                c(range[2], range[4])))
  
  # kernel
  if (!missing(sigma)) {
    ker1 <- density.ppp(data.ppp, weights = ratio[, 1], 
                        sigma = sigma)
    ker2 <- density.ppp(data.ppp, weights = ratio[, 2],
                        sigma = sigma)
  } else if(missing(sigma)) {
    sigma <- bw.diggle(data.ppp)
    ker1 <- density.ppp(data.ppp, weights = ratio[, 1], 
                        sigma = sigma)
    ker2 <- density.ppp(data.ppp, weights = ratio[, 2],
                        sigma = sigma)
  }
  
  sigma <- as.numeric(sigma)
  
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
  s <- 1 - (sum(inter) / sum(union))
  
  # class
  setClass("Sclass", slots = c(s = "numeric", data = "data.frame", 
                               kernel1 = "matrix", kernel2 = "matrix",
                               sigma = "numeric"))
  
  Sclass <- function(s, data, kernel1, kernel2, sigma) {
    new("Sclass", s = s, data = data, kernel1 = kernel1, kernel2 = kernel2, 
        sigma = sigma)
  }
  
  # result
  Sclass(s, data, v1, v2, sigma)
}

# segdata
library(seg)
## Load the sample data set into the current workspace
data(segdata)

## Create a 10-by-10 grid to display the data set
grd <- GridTopology(cellcentre.offset = c(0.5,0.5),
                    cellsize = c(1,1), cells.dim = c(10,10))
grd.sp <- as.SpatialPolygons.GridTopology(grd)

range <- bbox(grd.sp)
points.xy <- coordinates(grd.sp)
data.ppp <- ppp(points.xy[, 1], points.xy[, 2], 
                window = owin(c(range[1], range[3]), 
                              c(range[2], range[4])))

# result
x <- S(grd.sp, segdata[, 1:2])

# class
setClass("Sclass", slots = c(s = "numeric", data = "data.frame", 
                             kernel1 = "matrix", kernel2 = "matrix",
                             sigma = "numeric"))

Sclass <- function(s, data, kernel1, kernel2, sigma) {
  new("Sclass", s = s, data = data, kernel1 = kernel1, kernel2 = kernel2, 
      sigma = sigma)
}

# method
## show(S4)
setMethod("show", "Sclass", 
          function(object) {
            validObject(object)
            
            cat("The index of Spatial Segregation \n")
            print(slot(object, "s")) ; cat("\n")
            cat("Sigma :", slot(object, "sigma"), "\n") 
            cat("\n")
            cat("Data : \n")
            print(head(slot(object, "data"), n = 10))
          })

show(x)

## summary(S4)
setMethod("summary", "Sclass", 
          function(object) {
            validObject(object)
            
            
            cat("The index of Spatial Segregation \n")
            print(slot(object, "s")) ; cat("\n")
            cat("class : 'S' \n")
            cat("Number of points :", nrow(slot(object, "data")), "\n") 
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
            cat("Sigma :", slot(object, "sigma"), "\n")
            cat("\n")
            cat("Kernel1 : \n")
            cat("Min.   ", min(slot(object, "kernel1")), "\n")
            cat("Median ", median(slot(object, "kernel1")), "\n")
            cat("Mean   ", mean(slot(object, "kernel1")), "\n")
            cat("Max.   ", max(slot(object, "kernel1")), "\n")
            cat("Kernel2 : \n")
            cat("Min.   ", min(slot(object, "kernel2")), "\n")
            cat("Median ", median(slot(object, "kernel2")), "\n")
            cat("Mean   ", mean(slot(object, "kernel2")), "\n")
            cat("Max.   ", max(slot(object, "kernel2")), "\n")
          })

summary(x)

## as.list(S3)
setGeneric("as.list")
setMethod("as.list", "Sclass",
          function(x) {
            validObject(x)
            
            list(s = slot(x, "s"), Group = slot(x, "data"), 
                 kernel1 = slot(x, "kernel1"), 
                 kernel2 = slot(x, "kernel2"))
          })

as.list(x)

## print(S3)
setGeneric("print")
setMethod("print", "Sclass",
          function(x) {
            validObject(x)
            print(slot(x, "s"))
            cat("Sigma :", slot(x, "sigma"), "\n")
          })

print(x)

## updata(S3)
setGeneric("update")
setMethod("update", "Sclass",
          function(object, x, data, sigma) {
            if(missing(x)) {
              stop("argument 'x' is missing")
            }
            
            validObject(object)
            
            if (missing(data)) {data <- slot(object, "data")}
            if (missing(sigma)) {method <- slot(object, "sigma")}
            
            result <- S(x, data, sigma)
            return(result)
          })

update(x, grd.sp, segdata[, 1:2], bw.nrd0(coordinates(grd.sp)))