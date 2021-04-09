# set working directory
setwd("C:/Users/JeongChangSeong/Desktop/keywords/")

# Packages
library(bibliometrix)
library(igraph)

# ------------------------------------------------------------------------------
# GIS 2019
# Data import
data <- read.csv("data/gis2019.csv")

# Data handling
names(data)[1] <- "ID"
data$ID <- as.character(data$ID)

# Make a biblionetwork from data
NetMatrix <- biblioNetwork(data, analysis = "co-occurrences",
                           network = "keywords", sep = ";")

# Extract matrix from biblionetwork
keywords.mat <- as.matrix(NetMatrix); keywords.freq <- diag(keywords.mat)
keywords.mat[row(keywords.mat) == col(keywords.mat)] <- 0

# Assign 1 to any edge greater than 1
keywords.adj <- keywords.mat
keywords.adj[keywords.adj > 1] <- 1

# Make an igraph from adjacency matrix.
# With "Weighted = TRUE", multiple edges are created between two nodes.
# Use "weighted = NULL" to make a signgle-edge between two nodes.
gis2019.igraph <- graph_from_adjacency_matrix(keywords.adj, mode = "undirected", 
                                              weighted = NULL)

# Attach node attribute (nodeFrequency)
V(gis2019.igraph)$nodeFrequency <- keywords.freq

# Attach node attribute (degreeCentrality, i.e. singleEdgeDegCentrality, 
# from the single-edge graph)
singleEdgeDegCentrality <- centr_degree(gis2019.igraph, mode = "all")$res
V(gis2019.igraph)$singleEdgeDegCentrality <- singleEdgeDegCentrality

# Attach node attribute (eigenVectorCentrality, i.e. 
# singleEdgeEigenvectorCentrality, from the single-edge graph)
singleEdgeEigenvectorCentrality <- eigen_centrality(gis2019.igraph)$vector
V(gis2019.igraph)$singleEdgeEigenvectorCentrality <- singleEdgeEigenvectorCentrality

# Attach edge attribute (frequency)
tmp.igraph <- graph_from_adjacency_matrix(keywords.mat, mode = "undirected", 
                                          weighted = TRUE)
E(gis2019.igraph)$frequency <- E(tmp.igraph)$weight

# Attach node attribute (cluster) & Calculate modularity and time by clusters
# Edge betweenness
start_time <- Sys.time()
EB <- cluster_edge_betweenness(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
EB_time <- end_time - start_time
EB_modularity <- modularity(tmp.igraph, EB)
V(gis2019.igraph)$EB <- EB

# Fast greedy
start_time <- Sys.time()
FG <- cluster_fast_greedy(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
FG_time <- end_time - start_time
FG_modularity <- modularity(tmp.igraph, FG)
V(gis2019.igraph)$FG <- FG

# Infomap
start_time <- Sys.time()
infomap <- cluster_infomap(tmp.igraph, e.weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
infomap_time <- end_time - start_time
infomap_modularity <- modularity(tmp.igraph, infomap)
V(gis2019.igraph)$infomap <- infomap

# Label propagation
start_time <- Sys.time()
LP <- cluster_label_prop(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LP_time <- end_time - start_time
LP_modularity <- modularity(tmp.igraph, LP)
V(gis2019.igraph)$LP <- LP

# Leading eigenvector
start_time <- Sys.time()
LE <- cluster_leading_eigen(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LE_time <- end_time - start_time
LE_modularity <- modularity(tmp.igraph, LE)
V(gis2019.igraph)$LE <- LE

# Louvain
start_time <- Sys.time()
louvain <- cluster_louvain(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
louvain_time <- end_time - start_time
louvain_modularity <- modularity(tmp.igraph, louvain)
V(gis2019.igraph)$louvain <- louvain

# Walktrap
start_time <- Sys.time()
walktrap <- cluster_walktrap(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
walktrap_time <- end_time - start_time
walktrap_modularity <- modularity(tmp.igraph, walktrap)
V(gis2019.igraph)$walktrap <- walktrap

# Make a data frame
result.df <- data.frame(algorithm = c("Edge betweenness", "Fast greedy", 
                                      "Infomap", "Label propagation", 
                                      "Leading eigenvector", "Louvain",
                                      "Walktrap"),
                        modularity = c(EB_modularity, FG_modularity, 
                                       infomap_modularity, LP_modularity,
                                       LE_modularity, louvain_modularity,
                                       walktrap_modularity),
                        time = c(as.numeric(EB_time),
                                 as.numeric(FG_time), 
                                 as.numeric(infomap_time), 
                                 as.numeric(LP_time), as.numeric(LE_time), 
                                 as.numeric(louvain_time), 
                                 as.numeric(walktrap_time)),
                        number = c(length(unique(EB)),
                                   length(unique(FG)), length(unique(infomap)),
                                   length(unique(LP)), length(unique(LE)), 
                                   length(unique(louvain)),
                                   length(unique(walktrap))))

write.csv(result.df, "gis2019_result.csv", row.names = FALSE)

gis2019.df <- data.frame(nodeFrequency = keywords.freq, 
                         singleEdgeDegCentrality = singleEdgeDegCentrality,
                         singleEdgeEigenvectorCentrality = singleEdgeEigenvectorCentrality,
                         EB = EB, FG = FG, infomap = infomap, LP = LP, LE = LE,
                         louvain = louvain, walktrap = walktrap)

write.csv(gis2019.df, "gis2019cluster_info.csv", row.names = T)

# Convert to graphml
write.graph(gis2019.igraph, "gis2019.graphml", format = "graphml")
# ------------------------------------------------------------------------------
# AAG 1999
# Data import
data <- read.csv("data/keywords1999_2.csv")

# Data handling
names(data)[1] <- "ID"
data$ID <- as.character(data$ID)

# Make a biblionetwork from data
NetMatrix <- biblioNetwork(data, analysis = "co-occurrences",
                           network = "keywords", sep = ";")

# Extract matrix from biblionetwork
keywords.mat <- as.matrix(NetMatrix); keywords.freq <- diag(keywords.mat)
keywords.mat[row(keywords.mat) == col(keywords.mat)] <- 0

# Assign 1 to any edge greater than 1
keywords.adj <- keywords.mat
keywords.adj[keywords.adj > 1] <- 1

# Make an igraph from adjacency matrix.
# With "Weighted = TRUE", multiple edges are created between two nodes.
# Use "weighted = NULL" to make a signgle-edge between two nodes.
k1999.igraph <- graph_from_adjacency_matrix(keywords.adj, mode = "undirected", 
                                            weighted = NULL)

# Attach node attribute (nodeFrequency)
V(k1999.igraph)$nodeFrequency <- keywords.freq

# Attach node attribute (degreeCentrality, i.e. singleEdgeDegCentrality, 
# from the single-edge graph)
singleEdgeDegCentrality <- centr_degree(k1999.igraph, mode = "all")$res
V(k1999.igraph)$singleEdgeDegCentrality <- singleEdgeDegCentrality

# Attach node attribute (eigenVectorCentrality, i.e. 
# singleEdgeEigenvectorCentrality, from the single-edge graph)
singleEdgeEigenvectorCentrality <- eigen_centrality(k1999.igraph)$vector
V(k1999.igraph)$singleEdgeEigenvectorCentrality <- singleEdgeEigenvectorCentrality

# Attach edge attribute (frequency)
tmp.igraph <- graph_from_adjacency_matrix(keywords.mat, mode = "undirected", 
                                          weighted = TRUE)
E(k1999.igraph)$frequency <- E(tmp.igraph)$weight

# Attach node attribute (cluster) & Calculate modularity and time by clusters
# Edge betweenness
start_time <- Sys.time()
EB <- cluster_edge_betweenness(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
EB_time <- end_time - start_time
EB_modularity <- modularity(tmp.igraph, EB)
V(k1999.igraph)$EB <- EB

# Fast greedy
start_time <- Sys.time()
FG <- cluster_fast_greedy(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
FG_time <- end_time - start_time
FG_modularity <- modularity(tmp.igraph, FG)
V(k1999.igraph)$FG <- FG

# Infomap
start_time <- Sys.time()
infomap <- cluster_infomap(tmp.igraph, e.weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
infomap_time <- end_time - start_time
infomap_modularity <- modularity(tmp.igraph, infomap)
V(k1999.igraph)$infomap <- infomap

# Label propagation
start_time <- Sys.time()
LP <- cluster_label_prop(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LP_time <- end_time - start_time
LP_modularity <- modularity(tmp.igraph, LP)
V(k1999.igraph)$LP <- LP

# Leading eigenvector
start_time <- Sys.time()
LE <- cluster_leading_eigen(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LE_time <- end_time - start_time
LE_modularity <- modularity(tmp.igraph, LE)
V(k1999.igraph)$LE <- LE

# Louvain
start_time <- Sys.time()
louvain <- cluster_louvain(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
louvain_time <- end_time - start_time
louvain_modularity <- modularity(tmp.igraph, louvain)
V(k1999.igraph)$louvain <- louvain

# Walktrap
start_time <- Sys.time()
walktrap <- cluster_walktrap(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
walktrap_time <- end_time - start_time
walktrap_modularity <- modularity(tmp.igraph, walktrap)
V(k1999.igraph)$walktrap <- walktrap

# Make a data frame
result.df <- data.frame(algorithm = c("Edge betweenness", "Fast greedy", 
                                      "Infomap", "Label propagation", 
                                      "Leading eigenvector", "Louvain",
                                      "Walktrap"),
                        modularity = c(EB_modularity, FG_modularity, 
                                       infomap_modularity, LP_modularity,
                                       LE_modularity, louvain_modularity,
                                       walktrap_modularity),
                        time = c(as.numeric(EB_time),
                                 as.numeric(FG_time), 
                                 as.numeric(infomap_time), 
                                 as.numeric(LP_time), as.numeric(LE_time), 
                                 as.numeric(louvain_time), 
                                 as.numeric(walktrap_time)),
                        number = c(length(unique(EB)),
                                   length(unique(FG)), length(unique(infomap)),
                                   length(unique(LP)), length(unique(LE)), 
                                   length(unique(louvain)),
                                   length(unique(walktrap))))

write.csv(result.df, "k1999_result.csv", row.names = FALSE)

k1999.df <- data.frame(nodeFrequency = keywords.freq, 
                       singleEdgeDegCentrality = singleEdgeDegCentrality,
                       singleEdgeEigenvectorCentrality = singleEdgeEigenvectorCentrality,
                       EB = EB, FG = FG, infomap = infomap, LP = LP, LE = LE,
                       louvain = louvain, walktrap = walktrap)

write.csv(k1999.df, "k1999cluster_info.csv", row.names = T)

# Convert to graphml
write.graph(k1999.igraph, "k1999.graphml", format = "graphml")
# ------------------------------------------------------------------------------
# AAG 2009
# Data import
data <- read.csv("data/keywords2009_2.csv")

# Data handling
names(data)[1] <- "ID"
data$ID <- as.character(data$ID)

# Make a biblionetwork from data
NetMatrix <- biblioNetwork(data, analysis = "co-occurrences",
                           network = "keywords", sep = ";")

# Extract matrix from biblionetwork
keywords.mat <- as.matrix(NetMatrix); keywords.freq <- diag(keywords.mat)
keywords.mat[row(keywords.mat) == col(keywords.mat)] <- 0

# Assign 1 to any edge greater than 1
keywords.adj <- keywords.mat
keywords.adj[keywords.adj > 1] <- 1

# Make an igraph from adjacency matrix.
# With "Weighted = TRUE", multiple edges are created between two nodes.
# Use "weighted = NULL" to make a signgle-edge between two nodes.
k2009.igraph <- graph_from_adjacency_matrix(keywords.adj, mode = "undirected", 
                                            weighted = NULL)

# Attach node attribute (nodeFrequency)
V(k2009.igraph)$nodeFrequency <- keywords.freq

# Attach node attribute (degreeCentrality, i.e. singleEdgeDegCentrality, 
# from the single-edge graph)
singleEdgeDegCentrality <- centr_degree(k2009.igraph, mode = "all")$res
V(k2009.igraph)$singleEdgeDegCentrality <- singleEdgeDegCentrality

# Attach node attribute (eigenVectorCentrality, i.e. 
# singleEdgeEigenvectorCentrality, from the single-edge graph)
singleEdgeEigenvectorCentrality <- eigen_centrality(k2009.igraph)$vector
V(k2009.igraph)$singleEdgeEigenvectorCentrality <- singleEdgeEigenvectorCentrality

# Attach edge attribute (frequency)
tmp.igraph <- graph_from_adjacency_matrix(keywords.mat, mode = "undirected", 
                                          weighted = TRUE)
E(k2009.igraph)$frequency <- E(tmp.igraph)$weight

# Attach node attribute (cluster) & Calculate modularity and time by clusters
# Edge betweenness
start_time <- Sys.time()
EB <- cluster_edge_betweenness(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
EB_time <- end_time - start_time
EB_modularity <- modularity(tmp.igraph, EB)
V(k2009.igraph)$EB <- EB

# Fast greedy
start_time <- Sys.time()
FG <- cluster_fast_greedy(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
FG_time <- end_time - start_time
FG_modularity <- modularity(tmp.igraph, FG)
V(k2009.igraph)$FG <- FG

# Infomap
start_time <- Sys.time()
infomap <- cluster_infomap(tmp.igraph, e.weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
infomap_time <- end_time - start_time
infomap_modularity <- modularity(tmp.igraph, infomap)
V(k2009.igraph)$infomap <- infomap

# Label propagation
start_time <- Sys.time()
LP <- cluster_label_prop(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LP_time <- end_time - start_time
LP_modularity <- modularity(tmp.igraph, LP)
V(k2009.igraph)$LP <- LP

# Leading eigenvector
start_time <- Sys.time()
LE <- cluster_leading_eigen(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LE_time <- end_time - start_time
LE_modularity <- modularity(tmp.igraph, LE)
V(k2009.igraph)$LE <- LE

# Louvain
start_time <- Sys.time()
louvain <- cluster_louvain(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
louvain_time <- end_time - start_time
louvain_modularity <- modularity(tmp.igraph, louvain)
V(k2009.igraph)$louvain <- louvain

# Walktrap
start_time <- Sys.time()
walktrap <- cluster_walktrap(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
walktrap_time <- end_time - start_time
walktrap_modularity <- modularity(tmp.igraph, walktrap)
V(k2009.igraph)$walktrap <- walktrap

# Make a data frame
result.df <- data.frame(algorithm = c("Edge betweenness", "Fast greedy", 
                                      "Infomap", "Label propagation", 
                                      "Leading eigenvector", "Louvain",
                                      "Walktrap"),
                        modularity = c(EB_modularity, FG_modularity, 
                                       infomap_modularity, LP_modularity,
                                       LE_modularity, louvain_modularity,
                                       walktrap_modularity),
                        time = c(as.numeric(EB_time),
                                 as.numeric(FG_time), 
                                 as.numeric(infomap_time), 
                                 as.numeric(LP_time), as.numeric(LE_time), 
                                 as.numeric(louvain_time), 
                                 as.numeric(walktrap_time)),
                        number = c(length(unique(EB)),
                                   length(unique(FG)), length(unique(infomap)),
                                   length(unique(LP)), length(unique(LE)), 
                                   length(unique(louvain)),
                                   length(unique(walktrap))))

write.csv(result.df, "k2009_result.csv", row.names = FALSE)

k2009.df <- data.frame(nodeFrequency = keywords.freq, 
                         singleEdgeDegCentrality = singleEdgeDegCentrality,
                         singleEdgeEigenvectorCentrality = singleEdgeEigenvectorCentrality,
                         EB = EB, FG = FG, infomap = infomap, LP = LP, LE = LE,
                         louvain = louvain, walktrap = walktrap)

write.csv(k2009.df, "k2009cluster_info.csv", row.names = T)

# Convert to graphml
write.graph(k2009.igraph, "k2009.graphml", format = "graphml")
# ------------------------------------------------------------------------------
# AAG 15-19
# Data import
data <- read.csv("data/keywords1519_2.csv")

# Data handling
names(data)[1] <- "ID"
data$ID <- as.character(data$ID)

# Make a biblionetwork from data
NetMatrix <- biblioNetwork(data, analysis = "co-occurrences",
                           network = "keywords", sep = ";")

# Extract matrix from biblionetwork
keywords.mat <- as.matrix(NetMatrix); keywords.freq <- diag(keywords.mat)
keywords.mat[row(keywords.mat) == col(keywords.mat)] <- 0

# Assign 1 to any edge greater than 1
keywords.adj <- keywords.mat
keywords.adj[keywords.adj > 1] <- 1

# Make an igraph from adjacency matrix.
# With "Weighted = TRUE", multiple edges are created between two nodes.
# Use "weighted = NULL" to make a signgle-edge between two nodes.
k1519.igraph <- graph_from_adjacency_matrix(keywords.adj, mode = "undirected", 
                                            weighted = NULL)

# Attach node attribute (nodeFrequency)
V(k1519.igraph)$nodeFrequency <- keywords.freq

# Attach node attribute (degreeCentrality, i.e. singleEdgeDegCentrality, 
# from the single-edge graph)
singleEdgeDegCentrality <- centr_degree(k1519.igraph, mode = "all")$res
V(k1519.igraph)$singleEdgeDegCentrality <- singleEdgeDegCentrality

# Attach node attribute (eigenVectorCentrality, i.e. 
# singleEdgeEigenvectorCentrality, from the single-edge graph)
singleEdgeEigenvectorCentrality <- eigen_centrality(k1519.igraph)$vector
V(k1519.igraph)$singleEdgeEigenvectorCentrality <- singleEdgeEigenvectorCentrality

# Attach edge attribute (frequency)
tmp.igraph <- graph_from_adjacency_matrix(keywords.mat, mode = "undirected", 
                                          weighted = TRUE)
E(k1519.igraph)$frequency <- E(tmp.igraph)$weight

# Attach node attribute (cluster) & Calculate modularity and time by clusters
# Edge betweenness
start_time <- Sys.time()
EB <- cluster_edge_betweenness(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
EB_time <- end_time - start_time
EB_modularity <- modularity(tmp.igraph, EB)
V(k1519.igraph)$EB <- EB

# Fast greedy
start_time <- Sys.time()
FG <- cluster_fast_greedy(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
FG_time <- end_time - start_time
FG_modularity <- modularity(tmp.igraph, FG)
V(k1519.igraph)$FG <- FG

# Infomap
start_time <- Sys.time()
infomap <- cluster_infomap(tmp.igraph, e.weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
infomap_time <- end_time - start_time
infomap_modularity <- modularity(tmp.igraph, infomap)
V(k1519.igraph)$infomap <- infomap

# Label propagation
start_time <- Sys.time()
LP <- cluster_label_prop(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LP_time <- end_time - start_time
LP_modularity <- modularity(tmp.igraph, LP)
V(k1519.igraph)$LP <- LP

# Leading eigenvector
start_time <- Sys.time()
LE <- cluster_leading_eigen(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
LE_time <- end_time - start_time
LE_modularity <- modularity(tmp.igraph, LE)
V(k1519.igraph)$LE <- LE

# Louvain
start_time <- Sys.time()
louvain <- cluster_louvain(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
louvain_time <- end_time - start_time
louvain_modularity <- modularity(tmp.igraph, louvain)
V(k1519.igraph)$louvain <- louvain

# Walktrap
start_time <- Sys.time()
walktrap <- cluster_walktrap(tmp.igraph, weights = E(tmp.igraph)$weight)$membership
end_time <- Sys.time()
walktrap_time <- end_time - start_time
walktrap_modularity <- modularity(tmp.igraph, walktrap)
V(k1519.igraph)$walktrap <- walktrap

# Make a data frame
result.df <- data.frame(algorithm = c("Edge betweenness", "Fast greedy", 
                                      "Infomap", "Label propagation", 
                                      "Leading eigenvector", "Louvain",
                                      "Walktrap"),
                        modularity = c(EB_modularity, FG_modularity, 
                                       infomap_modularity, LP_modularity,
                                       LE_modularity, louvain_modularity,
                                       walktrap_modularity),
                        time = c(as.numeric(EB_time),
                                 as.numeric(FG_time), 
                                 as.numeric(infomap_time), 
                                 as.numeric(LP_time), as.numeric(LE_time), 
                                 as.numeric(louvain_time), 
                                 as.numeric(walktrap_time)),
                        number = c(length(unique(EB)),
                                   length(unique(FG)), length(unique(infomap)),
                                   length(unique(LP)), length(unique(LE)), 
                                   length(unique(louvain)),
                                   length(unique(walktrap))))

write.csv(result.df, "k1519_result.csv", row.names = FALSE)

k1519.df <- data.frame(nodeFrequency = keywords.freq, 
                       singleEdgeDegCentrality = singleEdgeDegCentrality,
                       singleEdgeEigenvectorCentrality = singleEdgeEigenvectorCentrality,
                       EB = EB, FG = FG, infomap = infomap, LP = LP, LE = LE,
                       louvain = louvain, walktrap = walktrap)

write.csv(k1519.df, "k1519cluster_info.csv", row.names = T)

# Convert to graphml
write.graph(k1519.igraph, "k1519.graphml", format = "graphml")