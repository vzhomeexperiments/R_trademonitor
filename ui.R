
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


library(shiny)




pageWithSidebar(
  headerPanel('Systems performance evalutaiton'),
  sidebarPanel(
    selectInput(inputId = "TermNum", label = "Select Terminal Number",choices = 1:4),
    actionButton(inputId = "Refresh", label = "refresh"),
    selectInput(inputId = "MagicNum", label = "Select Magic Number", choices = 1:10),
    sliderInput(inputId = "filter", label = "Select Profit Levels", min = -10000, max = 10000, value = c(0, 10000)),
    dateInput(inputId = "filterDate", label = "Select Orders newer than...", value = "2017-02-01"),
    sliderInput(inputId = "nTrades", label = "Select Orders number greater than...", value = c(0, 100),min = 0, max = 100)
    ),
  
  mainPanel(
    plotOutput('plot1'), # overall visual representation of the terminal trades
    tableOutput('statistics'), # statistics of selected system
    plotOutput("plot2") # visual representation of selected system
  )
)