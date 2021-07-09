#Access an app like this at
##########################################
# https://rr1964.shinyapps.io
##########################################

library(shiny)

if(!require("RColorBrewer"))
{
  install.packages("RColorBrewer")
}

library(RColorBrewer)


ourRed = colorRampPalette(brewer.pal(9,"Reds"))(6)
ourBlue = colorRampPalette(brewer.pal(9,"Blues"))(6)

ui <- fluidPage(
  
  # Application title
  titlePanel("Nice Two Meat You"),
  
  
  sidebarLayout(
    sidebarPanel(h3("Beef or Fish?"),
      sliderInput(inputId = "age",
                  label = h4("Age:"),
                  min = 18,
                  max = 100,
                  value = 30),
      sliderInput(inputId = "hot",
                  label = h4("Spice Tolerance:"),
                  min = 1,
                  max = 10,
                  value = 5),
      radioButtons("meat", h4("Meat Choice:"),
                   choices = list("Beef" = 1, "Fish" = 2),selected = 1),
      checkboxInput(inputId = "sauce",
                    label ="Pour on special sauce:", 
                    value = FALSE), ##Start off with sauce option not checked. 
      
      
      span(textOutput("checkSauce"), style = "color:red"), ##This means the output text will be red.
      ##There are many ways (such as using CSS or something) to obtain red output text.
      ##I feel this is the simplest way to do such. 
      
      actionButton("goButton", "Submit Order") ###input name, display text.
      
    ),
    
    
    mainPanel(
      h4(textOutput("ageRange"), align = "middle"),
      h5(textOutput("sauceApplied"), align = "middle", style = paste0("color:",ourBlue[4])),###You can use h1, h2, h3, h4....as they are used in HTML.
      plotOutput("opinion")
      
      
      
    )
  )
)


server <- function(input, output) {
  
  
  ageRangeB<-function(yourAge , sauceAllowed)
  {
    lowBound = (sqrt(yourAge + 5)-9/11)^2 - (sauceAllowed*input$sauce)*(yourAge/2 -7)
    upBound = (sqrt(yourAge + 3)+2/23)^2
    interval = c(lowBound, upBound)
    return(interval)
  }
  
  ageRangeF<-function(yourAge , sauceAllowed)
  {
    lowBound = (sqrt(yourAge - 1)-1/19)^2 
    upBound = (sqrt(yourAge + 5) + 3/23)^2 + (sauceAllowed*input$sauce)*(yourAge/2 -2)
    interval = c(lowBound, upBound)
    return(interval)
  }
  
  
  output$checkSauce <- renderText({
    
    if(input$sauce & ((input$age < 40 & input$meat == 2) | (input$age <25  & input$meat == 1)))
    { 
      ##The sauce option can only be selected for fish if the user is over age 40
      ##The sauce option can only be selected for beef if they are between age 25 and 56 (inclusive)
      return("You are too young to check the special sauce option.") 
    } 
    
    else if(input$sauce & input$meat ==1 & input$age >56)
      
    {return("You are too old to select the sauce option for beef.")}
    
    
    
    return("")
  })    
  
  output$ageRange <- renderText({
    
    input$goButton
    
    isolate({
      
      if(input$sauce & ((input$age < 40 & input$meat == 2) |
                          (input$age <25  & input$meat == 1) |
                          (input$age >56  & input$meat == 1)))
      {
        sauceAllowed = FALSE
      }
      else{sauceAllowed = TRUE}
      
      if(input$meat == 1)
      {
        compAges = round(ageRangeF(input$age, sauceAllowed), digits = 2)
      }
      else if(input$meat == 2)
      {
        compAges = round(ageRangeB(input$age, sauceAllowed), digits = 2)
      }
      
      
      return(paste("Your customer age range is:", compAges[1],"years to ", compAges[2], " years."))
    })##End of Isolate.   
  })
  
  output$sauceApplied <- renderText({
    
    input$goButton
    
    isolate({
      
      if(input$sauce & ((input$age < 40 & input$meat == 2) |
                          (input$age <25  & input$meat == 1) |
                          (input$age >56  & input$meat == 1)))
      {
        
        return("You cannot have the special sauce.")
      }
      else if(input$sauce)
      {
        return("You will get the special sauce.")
      }
      
      
      
      
    })##End of Isolate.
    
    
  })
  
  
  output$opinion <- renderPlot({
    
    ####ourRed = colorRampPalette(brewer.pal(9,"Reds"))(6)
    
    input$goButton
    isolate({
      if(input$sauce & ((input$age < 40 & input$meat == 2) |
                          (input$age <25  & input$meat == 1) |
                          (input$age >56  & input$meat == 1)))
      {
        sauceAllowed = FALSE
      }
      else{sauceAllowed = TRUE}
      
      
      if(input$meat == 2)
      {
        ages = round(ageRangeF(input$age, sauceAllowed), digits = 2)
        spice = input$hot
        #sample(1:10, 1, prob = c(0.05, 0.05, 0.05, 0.1, 0.15, 0.2, 0.15, 0.15, 0.05, 0.05))
        
        
        
        randAges = runif(400, min = ages[1], max = ages[2])
        randHot = runif(400, min = spice-1.5, max = spice + 1.5) + rnorm(400, mean = 0, sd = 0.25)
        ##we add the rnorm part to avoid the strict boundaries. 
        
        
        flavor = -0.025*randAges + randHot + rnorm(400, sd = 0.85)
        
        
        plot(x = abs(randHot), y = abs(flavor), xlim = c(-0.5, 10.5), ylim = c(-0.5, 10.5),
             main = "400 randomly sampled \n people in your age range", col = ourRed[5],
             pch = 1, cex=.85, xlab = "Spice Tolerance", ylab = "Flavor Rating")
      }
      
      if(input$meat == 1)
      {
        ages = round(ageRangeB(input$age, sauceAllowed), digits = 2)
        spice = input$hot
        #sample(1:10, 1, prob = c(0.05, 0.05, 0.05, 0.1, 0.15, 0.2, 0.15, 0.15, 0.05, 0.05))
        
        
        
        randAges = runif(400, min = ages[1], max = ages[2])
        randHot = runif(400, min = spice-1.5, max = spice + 1.5) + rnorm(400, mean = 0, sd = 0.25)
        ##we add the rnorm part to avoid the strict boundaries. 
        
        
        oz = -0.015*randAges + randHot + rnorm(400, sd = 0.85)
      
        
        plot(x = abs(randHot), y = abs(oz), xlim = c(-0.5, 10.5), ylim = c(-0.5, 10.5),
             main = "400 randomly sampled \n people in your age range", col = ourRed[5],
             pch = 1, cex=.85, xlab = "Spice Tolerance", ylab = "Ounces Consumed")
        
      }
    })###End of isolate()   
  })
  
  
  
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
