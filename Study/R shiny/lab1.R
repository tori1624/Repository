# packages
library(shiny)
library(rgdal)
library(classInt)
library(RColorBrewer)

# data import
seoul.sp <- readOGR("D:/Study/2018/shiny/lab/lab1/data/Seoul_dong.shp")
seoul.wgs <- spTransform(seoul.sp, CRS("+proj=longlat +datum=WGS84 
                                       +no_defs +ellps=WGS84 +towgs84=0,0,0"))
seoul.heat <- read.csv("D:/Study/2018/shiny/lab/lab1/data/seoul_heat.csv")

# User interface ----
ui <- fluidPage(
  titlePanel("Vulnerable Area of Heat Wave"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create various maps with 
               information about heat wave."),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = c("Heat Wave Days", 
                              "Population density of the elderly",
                              "Number of recipients", "Green area"),
                  selected = "Heat Wave Days")
      ),
    
    mainPanel(plotOutput("map"))
  )
)

# Server logic ----
server <- function(input, output) {
  output$map <- renderPlot({
    # class
    heatclass <- classIntervals(seoul.heat$heat_wave, n = 5, style = "jenks")
    elderclass <- classIntervals(seoul.heat$elder_dens, n = 5, style = "jenks")
    recipientclass <- classIntervals(seoul.heat$receiver, n = 5, 
                                     style = "jenks")
    greenclass <- classIntervals(seoul.heat$green_area, n = 5, style = "jenks")
    
    class <- switch(input$var, 
                    "Heat Wave Days" = heatclass,
                    "Population density of the elderly" = elderclass,
                    "Number of recipients" = recipientclass,
                    "Green area" = greenclass)
    
    # color
    reds <- brewer.pal(5, "Reds")
    brown <- brewer.pal(5, "YlOrBr")
    blues <- brewer.pal(5, "Blues")
    greens <- brewer.pal(5, "Greens")
    
    color <- switch(input$var, 
                    "Heat Wave Days" = reds,
                    "Population density of the elderly" = brown,
                    "Number of recipients" = blues,
                    "Green area" = greens)
    
    # title
    title <- switch(input$var, 
                    "Heat Wave Days" = "Heat Wave Days",
                    "Population density of the elderly" = "Population density of the elderly",
                    "Number of recipients" = "Number of recipients",
                    "Green area" = "Green area")
    
    # x, y axis
    x <- bbox(seoul.wgs)
    
    # plot
    plot(seoul.wgs, col = findColours(class, color), border = FALSE,
         main = title)
    axis(1, at = seq(x[1], x[3], by = ((x[3] - x[1]) / 4)), 
         labels = parse(text = degreeLabelsEW(seq(x[1], x[3],
                                                  by = ((x[3] - x[1]) / 4)))))
    axis(2, at = seq(x[2], x[4], by = ((x[4] - x[2]) / 4)), 
         labels = parse(text = degreeLabelsNS(seq(x[2], x[4], 
                                                  by = ((x[4] - x[2]) / 4)))))
  })
}

# Run app ----
shinyApp(ui, server)