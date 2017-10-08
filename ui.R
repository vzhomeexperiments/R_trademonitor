# Project to create easy to use Trading Journal adapted to personal use
# Help to develop, demo-test Automated Trading Systems
#
# (C) 2017 Vladimir Zhbanko github: vzhomeexperiments/trademonitor

# ui.R
library(shinydashboard)

# 
dashboardPage(
  dashboardHeader(title = "fxtrams"),
  dashboardSidebar(
      # Elements on the Sidebar of the App
      selectInput(inputId = "TermNum", label = "Select Terminal Number",choices = 1:5),
      actionButton(inputId = "Refresh", label = "Refresh"),
      selectInput(inputId = "MagicNum", label = "Select Magic Number", choices = 1:10),
      sliderInput(inputId = "filter", label = "Select Profit Levels", min = -10000, max = 10000, value = c(0, 10000)),
      dateInput(inputId = "filterDate", label = "Select Orders newer than...", value = "2017-02-01"),
      sliderInput(inputId = "nTrades", label = "Select Orders number greater than...", value = c(0, 1000),min = 0, max = 1000)
  ),
  dashboardBody(
        
      mainPanel(
        # Elements of the Dashboard: header and tabset panel
        headerPanel("Trading Systems Graphical performance overview"),
          tabsetPanel(
            # Default chart visualizing the overall performance of the systems
            tabPanel("All Systems Plot", plotOutput('plot1')),
            # table and graph visualizing statistical performance and time-series graph
            tabPanel("Basic Statistics and Graph", 
                     checkboxInput(inputId = "StatErr", label = "Add Statistical Smoother?", value = FALSE, width = NULL),
                     tableOutput('statistics'), plotOutput("plot2"))
          )  
      )
  )
)
# end of ui.R