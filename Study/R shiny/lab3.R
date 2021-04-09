# packages
library(shiny)
library(rgdal)
library(classInt)
library(RColorBrewer)
library(ggplot2)

# data import
korea.sp <- readOGR("D:/Data/map/shp/nsdi/kostat/sigungu/sigungu.shp",
                    p4s = "+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 
                    +y_0=500000 +ellps=bessel +units=m +no_defs",
                    encoding = "UTF8")
final <- read.csv("D:/Data/contest/waste/final.csv")

# coordinate system
wgs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
korea.wgs <- spTransform(korea.sp, CRS(wgs))
korea.df <- data.frame(korea.wgs)

# User interface ----
ui <- fluidPage(
  # App title ----
  titlePanel("Wastes Occurr and Disposal"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      helpText("Create various maps / table with 
               information about Waste."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = c("collect count", "disposal count", "capacity", 
                              "collect amount", "disposal amount", 
                              "collect - disposal (amount)"),
                  selected = "collect count")
      ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Tabset map, plot ----
      plotOutput("map"),
      tableOutput("table")
    )
  )
)

# Server logic ----
server <- function(input, output) {
  
  # Generate a map of the data ----
  output$map <- renderPlot({
    # class
    class1 <- classIntervals(final$collect_count, n = 5, style = "quantile")
    class2 <- classIntervals(final$disposal_count, n = 5, style = "quantile")
    class3 <- classIntervals(final$capacity, n = 5, style = "quantile")
    class4 <- classIntervals(final$collect_15amount, n = 5, style = "quantile")
    class5 <- classIntervals(final$disposal_15amount, n = 5, style = "quantile")
    class6 <- classIntervals(final$index, n = 5, style = "quantile")
    
    class <- switch(input$var, 
                    "collect count" = class1, "disposal count" = class2, 
                    "capacity" = class3, "collect amount" = class4, 
                    "disposal amount" = class5, 
                    "collect - disposal (amount)" = class6)
    
    # color
    color <- switch(input$var,
                    "collect count" = brewer.pal(5, "Blues"), 
                    "disposal count" = brewer.pal(5, "Reds"),
                    "capacity" = brewer.pal(5, "Purples"),
                    "collect amount" = brewer.pal(5, "Blues"),
                    "disposal amount" = brewer.pal(5, "Reds"),
                    "collect - disposal (amount)" = brewer.pal(5, "RdYlBu"))
    purples <- brewer.pal(5, "Purples")
    
    # title
    title <- switch(input$var, 
                    "collect count" = "Collect Count", 
                    "disposal count" = "Disposal Count",
                    "capacity" = "Capacity",
                    "collect amount" = "Collect Amount",
                    "disposal amount" = "Disposal Amount",
                    "collect - disposal (amount)" = "Collect - Disposal (Amount)")
    
    # x, y axis
    x <- bbox(korea.wgs)
    
    # legend
    lg <- switch(input$var,
                 "collect count" = class1[[2]], 
                 "disposal count" = class2[[2]],
                 "capacity" = class3[[2]],
                 "collect amount" = class4[[2]],
                 "disposal amount" = class5[[2]],
                 "collect - disposal (amount)" = class6[[2]])
    
    # plot
    plot(korea.wgs, col = findColours(class, color), border = FALSE,
         main = title)
    axis(1, at = seq(x[1], x[3], by = ((x[3] - x[1]) / 4)), 
         labels = parse(text = degreeLabelsEW(seq(x[1], x[3],
                                                  by = ((x[3] - x[1]) / 4)))))
    axis(2, at = seq(x[2], x[4], by = ((x[4] - x[2]) / 4)), 
         labels = parse(text = degreeLabelsNS(seq(x[2], x[4], 
                                                  by = ((x[4] - x[2]) / 4)))))
    legend(131.20, 38.61, fill = color,
           legend = c(paste("Less than", lg[2]), paste(lg[2], "-", lg[3]), 
                      paste(lg[3], "-", lg[4]), paste(lg[4], "-", lg[5]),
                      paste("More than", lg[5])), cex = 1, bty = "n")
  })
  
  # Generate an HTML table view of the data ----
  output$table <- renderTable({
    # order
    order <- switch(input$var,
                    "collect count" = order(final$collect_count, 
                                            decreasing = TRUE), 
                    "disposal count" = order(final$disposal_count, 
                                             decreasing = TRUE),
                    "capacity" = order(final$capacity, decreasing = TRUE),
                    "collect amount" = order(final$collect_15amount, 
                                             decreasing = TRUE),
                    "disposal amount" = order(final$disposal_15amount, 
                                              decreasing = TRUE),
                    "collect - disposal (amount)" = order(final$index, 
                                                          decreasing = TRUE))
    
    # variable
    variable <- switch(input$var,
                       "collect count" = 7, 
                       "disposal count" = 9,
                       "capacity" = 11,
                       "collect amount" = 8,
                       "disposal amount" = 10,
                       "collect - disposal (amount)" = 12)
    
    # table
    head(final[order, c(6, 5, variable)], 8)
  })
}

# Run app ----
shinyApp(ui, server)