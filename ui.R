# Project to create easy to use Trading Journal adapted to personal use
# Help to develop, demo-test Automated Trading Systems
#
# (C) 2018 Vladimir Zhbanko github: vzhomeexperiments/R_trademonitor
# Course Lazy Trading Part 3: Set up your automated Trading Journal
#
# https://www.udemy.com/your-trading-journal/?couponCode=LAZYTRADE-GIT
#
# Run this app from R-Studio or use this link:
# https://stackoverflow.com/questions/18606665/run-web-applications-without-opening-r-studio

# ui.R
library(shinydashboard)
library(DT)

# 
dashboardPage(
  dashboardHeader(title = "Lazy Trading"),
  dashboardSidebar(
      # Elements on the Sidebar of the App
      selectInput(inputId = "TermNum", label = "Select Terminal Number",choices = 1:5),
      actionButton(inputId = "Refresh", label = "Refresh"),
      selectInput(inputId = "MagicNum", label = "Select Magic Number", choices = 1:10),
      sliderInput(inputId = "filter", label = "Select Profit Levels", min = -10000, max = 10000, value = c(-10000, 10000)),
      dateInput(inputId = "filterDate", label = "Select Orders newer than...", value = Sys.Date()-30),
      sliderInput(inputId = "nTrades", label = "Select Orders number greater than...", value = c(0, 1000),min = 0, max = 1000)
  ),
  dashboardBody(
      mainPanel(
        # Elements of the Dashboard: header and tabset panel
        headerPanel("Trading Systems Graphical performance overview"),
        tabsetPanel(
            # Default chart and statistics summary visualizing the overall performance of the systems
            tabPanel("All Systems Plot", tableOutput('summary'), plotOutput('plot1')),
            # table and graph visualizing statistical performance and time-series graph of single system
            tabPanel("Basic Statistics and Graph", 
                     checkboxInput(inputId = "StatErr", label = "Add Statistical Smoother?", value = FALSE, width = NULL),
                     fluidRow(column(5, tableOutput('statistics')),
                              column(4, textAreaInput("caption", "Notes", "", width = '100%')),
                              column(1, actionButton("subm_rec", label = "Go!", icon = icon("check")))),
                     tableOutput("strategy_text"),
                     plotOutput("plot2"),
                     plotOutput("plot3")
                     
                     ),
            # datatable with records of thoughts... write persistently to csv file, records should be visualized by date
            tabPanel("Log", DT::dataTableOutput("mytable"))
          )  
      )
  )
)
# end of ui.R