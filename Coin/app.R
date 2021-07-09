library(shiny)

# Define UI ----
ui <- fluidPage(
  
  titlePanel("Let's make a Shiny App!"),
  
  sidebarLayout(## Lots of layout types. 
    sidebarPanel(h3("Coin properties:"), 
                 sliderInput("probSlider", h5("Probability of heads"),
                             min = 0, max = 1, value = 0.5),
                ),
    mainPanel(h3("Results"), 
              textOutput("prob"),
              br(),
              br(),
              textOutput("numHeads"))
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$prob <- renderText({ 
    paste("You have selected", input$probSlider)
  })
  
  
  
  output$numHeads <- renderText({ 
    heads = rbinom(1,100,input$probSlider)
    paste("After 100 coin flips, we had ", heads, " total heads." )
  })
  
  
}

# Run the app ----
shinyApp(ui = ui, server = server)