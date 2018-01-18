
# (C) 2018 Vladimir Zhbanko 
# Shiny app to monitor statistics of the trading systems
# Course Lazy Trading Part 3: Set up your automated Trading Journal


library(shinydashboard)
library(tidyverse)
library(lubridate)
library(readxl)


#=============================================================
#========= FUNCTIONS AND VARIABLES============================
#=============================================================


# specifying the path to the 4x terminals used into the dataframe
Terminals <- data.frame(id = 1:5, TermPath = c("C:/Program Files (x86)/FxPro - Terminal1/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal2/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal3/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal4/MQL4/Files",
                                               "C:/Program Files (x86)/FxPro - Terminal5/MQL4/Files"),
                        stringsAsFactors = F)

# load prices of 28 currencies
prices <- read_csv(file.path(Terminals[2,2], "AI_CP15.csv"), col_names = F)
prices$X1 <- ymd_hms(prices$X1)

# Vector of currency pairs
Pairs = c("Date", "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY",
          "EURGBP", "EURJPY", "EURCHF", "EURNZD", "EURCAD", "EURAUD", "GBPAUD",
          "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "AUDCAD", "AUDCHF", "AUDJPY",
          "AUDNZD", "CADJPY", "CHFJPY", "NZDJPY", "NZDCAD", "NZDCHF", "CADCHF")   

# Rename the column?
names(prices) <- Pairs


Strategies <- read_excel("Strategies.xlsx",sheet = 1,col_names = TRUE)
Strategies$ID <- as.factor(Strategies$ID)
logs <- read_excel("Strategies.xlsx",sheet = 2,col_names = TRUE)

# ============================================================

shinyServer(function(input, output, session) {

  #=============================================================
  #========= REACTIVE VALUES ===================================
  #=============================================================  
  
  #---------------------  
  # have a reactive value of terminal number selected
  file_path <- reactive({ file_path <- paste(Terminals[input$TermNum, 2], "/", "OrdersResultsT", input$TermNum,".csv", sep = "") })
  #Debugging: file_path <- paste(Terminals[1, 2], "/", "OrdersResultsT", 1,".csv", sep = "")
  
  #---------------------
  # have a reactive value of the magic system selected
  system_analysed <- reactive({ system_analysed <- input$MagicNum })
  
  #---------------------
  # have a reactive value of the strategy type
  strategy_analysed <- reactive({ system_analysed() %>% substr(3,4) })
  
  #---------------------
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
                          arrange(X1) %>% 
                        filter(NumTrades > input$nTrades[1], NumTrades < input$nTrades[2]) %>% 
                        filter(PnL > input$filter[1], PnL < input$filter[2])   
                      })
  
  #---------------------
  # make summary statistics of all systems PnL
  DF_Stats_PnL <- reactive({ 
    DF_Stats_PnL <- read_csv(file = file_path(), col_names = F)
    #DF_Stats_PnL <- read_csv(file = file_path, col_names = F)
    DF_Stats_PnL$X3 <- ymd_hms(DF_Stats_PnL$X3)
    DF_Stats_PnL$X4 <- ymd_hms(DF_Stats_PnL$X4)
    DF_Stats_PnL <- DF_Stats_PnL %>%
      filter(X3 > as.POSIXct(input$filterDate)) %>% 
      group_by(X1) %>%
      summarise(PnL = sum(X5),
                NumTrades = n()) %>% 
      arrange(X1) %>% 
      filter(NumTrades > input$nTrades[1], NumTrades < input$nTrades[2]) %>% 
      filter(PnL > input$filter[1], PnL < input$filter[2]) %>% 
      summarise(TotPnL = sum(PnL),
                NumTrades = sum(NumTrades))
  })
  
  #---------------------
  # make strategy table (to derive it from magic number)
  Strategy <- reactive({ Strategies %>% filter(ID == strategy_analysed()) })
  
  #=============================================================
  #========= REACTIVE EVENTS ===================================
  #=============================================================  
  # import the summary statistics on the beginning of the app, call the statistics on refresh button call
  observeEvent(input$Refresh, {
    
    # DF <- read_csv(file = file_path(), col_names = F)
    # DF$X3 <- ymd_hms(DF$X3)
    # DF$X4 <- ymd_hms(DF$X4)
    # DF <- DF %>% arrange(X1)
    
    # update the magic numbers selection
    updateSelectInput(session, inputId = "MagicNum", label = NULL, choices = unique(DF_Stats()$X1), selected = NULL)
    
  })
  
#=============================================================
#========= OUTPUTS ===========================================
#=============================================================
  
  # -------------------------------------------
  # generating plot 1 statistics of the terminal
  output$plot1 <- renderPlot({

    DF_Stats() %>% 
      
      ggplot(aes(x = PnL, y = as.factor(X1), size = NumTrades)) + geom_point()+ 
      ggtitle(label = "Plot indicating which systems are profitable", 
              subtitle = "Size of the point represent number of trades completed") +
      geom_vline(xintercept=0, linetype="dashed", color = "green") +
      geom_vline(xintercept = DF_Stats_PnL()$TotPnL, color = "red")

    })
  
  # -------------------------------------------
  # table with statistic of the system, P/L and Number of trades
  output$statistics <- renderTable({

    DF_Stats() %>%
      filter(X1 == system_analysed()) 
    
  })
  
  # -------------------------------------------
  # table with statistic of the system, Sum PnL and N trades
  output$summary <- renderTable({   DF_Stats_PnL()  })
  
  # -------------------------------------------
  # generating plot 2 statistics of the system
  output$plot2 <- renderPlot({
    
    DF <- read_csv(file = file_path(), col_names = F)
    DF$X3 <- ymd_hms(DF$X3)
    DF$X4 <- ymd_hms(DF$X4)
    DF %>%
      # only show one system
      filter(X1 == system_analysed()) %>%
      # filter by date, this allows to see trends better!!!
      filter(X4 > as.POSIXct(input$filterDate)) %>% 
      # bring the plot...
      ggplot(aes(x = X4, y = X5, col = as.factor(X7), shape = as.factor(X6))) + geom_point()+ 
      # this is just a line separating profit and loss :)
      geom_hline(yintercept=0, linetype="dashed", color = "red")+
      # adding a simple line summarising points, user can select if apply stat.error filter
      geom_smooth(method = "lm", se = input$StatErr)
    
  })
  
  # generating strategy output
  output$strategy_text <- renderTable({ Strategy() })
  
})
