# packages
library(rgdal)

# data import
auck.sp <- readOGR("F:/data/auck.shp")
auck.df <- read.csv("F:/data/auck_pop.csv")

# function
seg.new3 <- function(data, nb) {
  
  result <- matrix(1, ncol = ncol(data), nrow = ncol(data))
  
  # 세 개 이상의 집단도 고려하기 위한 for() 구문
  for(i in 1:ncol(data)) {
    for (j in 1:ncol(data)) {
      
      data.x <- data[, c(i, j)]
      
      if (any(data.x < 0))
        stop("negative value(s) in 'data'", call. = FALSE)
      colsum <- apply(data.x, 2, sum)
      if (any(colsum <= 0))
        stop("the sum of each column in 'data' must be > 0", call. = FALSE)
      
      # Duncan and Duncan's index of dissimilarity
      b <- data.x[,1]/sum(data.x[,1])     # Blacks
      w <- data.x[,2]/sum(data.x[,2])     # Whites
      d <- sum(abs(b-w))/2
      result[i, j] <- d
      
      if (!missing(nb)) {     # If information on geographic distance between
                              # spatial units is provided:
        
        suppressMessages(library(spdep))

        if (i == ncol(data) & j == ncol(data)) { # 마지막 for()를 실행할 때만,
                                                 # 에러나 경고 메시지 출력
          tryCatch({    # nb 객체에 오류가 있다면, nb를 고려하지 않고 결과 출력
            if (class(nb)[1] == "SpatialPolygonsDataFrame" | 
                class(nb)[1] == "SpatialPolygons") {
              nb <- poly2nb(nb)
              nb <- nb2mat(nb, zero.policy = TRUE)
              nb <- nb / sum(nb)
            } else if (class(nb)[1] == "nb" & !is.matrix(nb)) {
              nb <- nb2mat(nb, zero.policy = TRUE)
              nb <- nb / sum(nb)
            } else if (nrow(nb) != ncol(nb))
              stop("'nb' must be a square matrix", call. = FALSE)
            else if (nrow(nb) != nrow(data.x))
              stop("nrow(nb) must match nrow(data)", call. = FALSE)
            
            if (sum(nb) != 1)
              warning("the sum of all elements in 'nb' does not equal 1", 
                      call. = FALSE)
            
            rowsum <- apply(data.x, 1, sum)
            removeID <- which(rowsum == 0)
            removeL <- length(removeID)
            if (removeL > 0) {
              warning("remove ", removeL, " rows with no population", 
                      call. = FALSE)
              rowsum <- rowsum[-removeID]
              data.x <- data.x[-removeID,]
              nb <- nb[-removeID, -removeID]
            }
            
            # Black proportions in census tracts
            z <- data.x[,1] / rowsum
            # Additional spatial component value
            spstr <- 0
            nbvec <- as.vector(nb)
            INDEX <- which(nbvec != 0)
            for (k in 1:length(INDEX)) {
              rowID <- INDEX[k] %% nrow(nb)
              colID <- INDEX[k] %/% nrow(nb)
              if (rowID == 0)
                rowID <- nrow(nb)
              else
                colID <- colID + 1
              spstr <- spstr + (abs(z[colID] - z[rowID]) * nbvec[INDEX[i]])
            }
            result[i, j] <- d - spstr
          }, error = function(e) {
            cat(paste(e, "\nThe result was calculated without considering 'nb'\n\n"))
          }, warning = function(w) {
            cat(paste(w, "\nThe result was calculated without considering 'nb'\n\n"))
          })
        } else { # 마지막 for()를 실행하기 이전에는 모든 메시지 무시
          try({
            if (class(nb)[1] == "SpatialPolygonsDataFrame" | 
                class(nb)[1] == "SpatialPolygons") {
              nb <- poly2nb(nb)
              nb <- nb2mat(nb, zero.policy = TRUE)
              nb <- nb / sum(nb)
            } else if (class(nb)[1] == "nb" & !is.matrix(nb)) {
              nb <- nb2mat(nb, zero.policy = TRUE)
              nb <- nb / sum(nb)
            } else if (nrow(nb) != ncol(nb))
              stop("'nb' must be a square matrix", call. = FALSE)
            else if (nrow(nb) != nrow(data.x))
              stop("nrow(nb) must match nrow(data)", call. = FALSE)
            
            if (sum(nb) != 1)
              warning("the sum of all elements in '
                    nb' does not equal 1", call. = FALSE)
            
            rowsum <- apply(data.x, 1, sum)
            removeID <- which(rowsum == 0)
            removeL <- length(removeID)
            if (removeL > 0) {
              warning("remove ", removeL, " rows with no population", 
                      call. = FALSE)
              rowsum <- rowsum[-removeID]
              data.x <- data.x[-removeID,]
              nb <- nb[-removeID, -removeID]
            }
            
            # Black proportions in census tracts
            z <- data.x[,1] / rowsum
            # Additional spatial component value
            spstr <- 0
            nbvec <- as.vector(nb)
            INDEX <- which(nbvec != 0)
            for (k in 1:length(INDEX)) {
              rowID <- INDEX[k] %% nrow(nb)
              colID <- INDEX[k] %/% nrow(nb)
              if (rowID == 0)
                rowID <- nrow(nb)
              else
                colID <- colID + 1
              spstr <- spstr + (abs(z[colID] - z[rowID]) * nbvec[INDEX[i]])
            }
            result[i, j] <- d - spstr
          }, silent = TRUE)
        }
      }
    }
  }
  result
}

# result
seg.new3(auck.df[, c(34, 37)])
seg.new3(auck.df[, 34:37])
seg.new3(auck.df[, 34:37], auck.sp)
seg.new3(auck.df[, 34:37], auck.df)