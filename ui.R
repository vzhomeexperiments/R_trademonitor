# Project to create easy to use Trading Journal adapted to personal use
# Help to develop, demo-test Automated Trading Systems
#
# (C) 2017 Vladimir Zhbanko github: vzhomeexperiments/trademonitor

# ui.R
library(shinydashboard)
library(shiny)
# 
dashboardPage(
  dashboardHeader(title = "Trading Systems performance evalutaiton"),
  dashboardSidebar(),
  dashboardBody(
    fluidRow(
      column(1, selectInput(inputId = "TermNum", label = "Select Terminal Number",choices = 1:4)),
      column(1, actionButton(inputId = "Refresh", label = "refresh")),
      column(1, selectInput(inputId = "MagicNum", label = "Select Magic Number", choices = 1:10)),
      column(2, sliderInput(inputId = "filter", label = "Select Profit Levels", min = -10000, max = 10000, value = c(0, 10000))),
      column(1, dateInput(inputId = "filterDate", label = "Select Orders newer than...", value = "2017-02-01")),
      column(1, sliderInput(inputId = "nTrades", label = "Select Orders number greater than...", value = c(0, 100),min = 0, max = 100))
    ),
    hr(),
    mainPanel(
        tabsetPanel(
          tabPanel("All Systems Plot", plotOutput('plot1')),
          tabPanel("Basic Statistics", tableOutput('statistics')),
          tabPanel("Visuals of Selected System", plotOutput("plot2"))
        )  
    )
  )
)


# 
# pageWithSidebar(
#   headerPanel('Systems performance evalutaiton'),
#   sidebarPanel(
#     selectInput(inputId = "TermNum", label = "Select Terminal Number",choices = 1:4),
#     actionButton(inputId = "Refresh", label = "refresh"),
#     selectInput(inputId = "MagicNum", label = "Select Magic Number", choices = 1:10),
#     sliderInput(inputId = "filter", label = "Select Profit Levels", min = -10000, max = 10000, value = c(0, 10000)),
#     dateInput(inputId = "filterDate", label = "Select Orders newer than...", value = "2017-02-01"),
#     sliderInput(inputId = "nTrades", label = "Select Orders number greater than...", value = c(0, 100),min = 0, max = 100)
#     ),
#   
#   mainPanel(
#     plotOutput('plot1'), # overall visual representation of the terminal trades
#     tableOutput('statistics'), # statistics of selected system
#     plotOutput("plot2") # visual representation of selected system
#   )
# )