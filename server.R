
# (C) 2017 Vladimir Zhbanko 
# Shiny app to monitor statistics of the trading systems
# Version 1
#

library(shinydashboard)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

# specifying the path to the 4x terminals used into the dataframe
Terminals <- data.frame(id = 1:5, TermPath = c("C:/Program Files (x86)/FxPro - Terminal1/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal2/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal3/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal4/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal5/MQL4/Files"),
                        stringsAsFactors = F)

shinyServer(function(input, output, session) {
  
  # have a reactive value of terminal number selected
  file_path <- reactive({ file_path <- paste(Terminals[input$TermNum, 2], "/", "OrdersResultsT", input$TermNum,".csv", sep = "") })
  #file_path <- paste(Terminals[1, 2], "/", "OrdersResultsT", 1,".csv", sep = "")
  # have a reactive value of the magic system selected
  system_analysed <- reactive({ system_analysed <- input$MagicNum })
  
  # cleaning data and creating relevant statistics
  DF_Stats <- reactive({ 
    DF_Stats <- read_csv(file = file_path(), col_names = F)
    #DF_Stats <- read_csv(file = file_path, col_names = F)
    DF_Stats$X3 <- ymd_hms(DF_Stats$X3)
  DF_Stats$X4 <- ymd_hms(DF_Stats$X4)
  DF_Stats <- DF_Stats %>%
    filter(X3 > as.POSIXct(input$filterDate)) %>% 
    group_by(X1) %>%
    summarise(PnL = sum(X5),
              NumTrades = n()) %>% 
    filter(NumTrades > input$nTrades[1], NumTrades < input$nTrades) %>% 
    filter(PnL > input$filter[1], PnL < input$filter[2])   })
  
  # import the summary statistics on the beginning of the app, call the statistics on refresh button call
  observeEvent(input$Refresh, {
    
    # DF <- read_csv(file = file_path(), col_names = F)
    # DF$X3 <- ymd_hms(DF$X3)
    # DF$X4 <- ymd_hms(DF$X4)
    # DF <- DF %>% arrange(X1)
    
    # update the magic numbers selection
    updateSelectInput(session, inputId = "MagicNum", label = NULL, choices = unique(DF_Stats()$X1), selected = NULL)
    
  })
  

  # generating plot 1 statistics of the terminals
  output$plot1 <- renderPlot({

    DF_Stats() %>% 
      
      ggplot(aes(x = PnL, y = as.factor(X1), size = NumTrades)) + geom_point()+ 
      geom_vline(xintercept=0, linetype="dashed", color = "green")

    })
  
  # table with statistic of the system, P/L and Number of trades
  output$statistics <- renderTable({

    DF_Stats() %>%
      filter(X1 == system_analysed()) 
    
  })
  
  
  # generating plot 2 statistics of the system
  output$plot2 <- renderPlot({
    
    DF <- read_csv(file = file_path(), col_names = F)
    DF$X3 <- ymd_hms(DF$X3)
    DF$X4 <- ymd_hms(DF$X4)
    DF %>%
      filter(X1 == system_analysed()) %>%
      # bring the plot...
      ggplot(aes(x = X4, y = X5, col = as.factor(X7), shape = as.factor(X6))) + geom_point()+ 
      # this is just a line separating profit and loss :)
      geom_hline(yintercept=0, linetype="dashed", color = "red")+
      # adding a simple line summarising points, user can select if apply stat.error filter
      geom_smooth(method = "lm", se = input$StatErr)
    
  })
  
})
