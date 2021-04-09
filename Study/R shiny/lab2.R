# packages
library(shiny)
library(rgdal)
library(classInt)
library(RColorBrewer)
library(ggplot2)

# data import
seoul.sp <- readOGR("D:/Study/2018/shiny/lab/lab2/data/hang.shp",
                    encoding = "UTF8")
seoul.wgs <- spTransform(seoul.sp, CRS("+proj=longlat +datum=WGS84 
                                       +no_defs +ellps=WGS84 +towgs84=0,0,0"))
seoul.df <- data.frame(seoul.wgs)

income <- read.csv("D:/Study/2018/shiny/lab/lab2/data/seoulincome2010.csv")

# arrange
nameOrder1 <- order(seoul.df$name)
seoul.wgs <- seoul.wgs[nameOrder1, ]

nameOrder2 <- order(income$dongName)
income <- income[nameOrder2, ]

# User interface ----
ui <- fluidPage(
  # App title ----
  titlePanel("Residential Segregation by income in Seoul"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      helpText("Create various maps / table with 
               information about income."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = c("income1", "income2", "income3", "income4",
                              "income5", "income6"),
                  selected = "income1")
      ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Tabset map, plot ----
      tabsetPanel(type = "tabs",
                  tabPanel("Map", plotOutput("map")),
                  tabPanel("Table", tableOutput("table")))
    )
  )
)

# Server logic ----
server <- function(input, output) {
  
  # Generate a map of the data ----
  output$map <- renderPlot({
    # class
    class1 <- classIntervals(income$income1, n = 5, style = "jenks")
    class2 <- classIntervals(income$income2, n = 5, style = "jenks")
    class3 <- classIntervals(income$income3, n = 5, style = "jenks")
    class4 <- classIntervals(income$income4, n = 5, style = "jenks")
    class5 <- classIntervals(income$income5, n = 5, style = "jenks")
    class6 <- classIntervals(income$income6, n = 5, style = "jenks")
    
    class <- switch(input$var, 
                    "income1" = class1, "income2" = class2, "income3" = class3,
                    "income4" = class4, "income5" = class5, "income6" = class6)
    
    # color
    purples <- brewer.pal(5, "Purples")
    
    # title
    title <- switch(input$var, 
                    "income1" = "Income1( ~ 100)", 
                    "income2" = "Income2(100 ~ 200)",
                    "income3" = "Income3(200 ~ 300)",
                    "income4" = "Income4(300 ~ 500)",
                    "income5" = "Income5(500 ~ 1000)",
                    "income6" = "Income6(1000 ~ )")
    
    # x, y axis
    x <- bbox(seoul.wgs)
    
    # plot
    plot(seoul.wgs, col = findColours(class, purples), border = FALSE,
         main = title)
    axis(1, at = seq(x[1], x[3], by = ((x[3] - x[1]) / 4)), 
         labels = parse(text = degreeLabelsEW(seq(x[1], x[3],
                                                  by = ((x[3] - x[1]) / 4)))))
    axis(2, at = seq(x[2], x[4], by = ((x[4] - x[2]) / 4)), 
         labels = parse(text = degreeLabelsNS(seq(x[2], x[4], 
                                                  by = ((x[4] - x[2]) / 4)))))
  })
  
  # Generate an HTML table view of the data ----
  output$table <- renderTable({
    # order
    order <- switch(input$var,
                    "income1" = order(income$income1, decreasing = TRUE), 
                    "income2" = order(income$income2, decreasing = TRUE),
                    "income3" = order(income$income3, decreasing = TRUE),
                    "income4" = order(income$income4, decreasing = TRUE),
                    "income5" = order(income$income5, decreasing = TRUE),
                    "income6" = order(income$income6, decreasing = TRUE))
    
    # table
    head(income[order, -c(1, 4)], 15)
  })
}

# Run app ----
shinyApp(ui, server)