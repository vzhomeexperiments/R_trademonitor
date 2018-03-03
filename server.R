# (C) 2018 Vladimir Zhbanko 
# Shiny app to monitor statistics of the trading systems
# Course Lazy Trading Part 3: Set up your automated Trading Journal
# https://www.udemy.com/your-trading-journal/?couponCode=LAZYTRADE-GIT


library(shinydashboard)
library(tidyverse)
library(magrittr)
library(lubridate)
library(readxl)
library(DT)
library(xlsx)

#=============================================================
#========= FUNCTIONS AND VARIABLES============================
#=============================================================


# specifying the path to the 4x terminals used into the dataframe
Terminals <- data.frame(id = 1:5, TermPath = c("C:/Program Files (x86)/FxPro - Terminal1/MQL4/Files/",
                                               "C:/Program Files (x86)/FxPro - Terminal2/MQL4/Files/",
                                               "C:/Program Files (x86)/FxPro - Terminal3/MQL4/Files/",
                                               "C:/Program Files (x86)/FxPro - Terminal4/MQL4/Files/",
                                               "C:/Program Files (x86)/FxPro - Terminal5/MQL4/Files/"),
                        stringsAsFactors = F)

# -------------------------------
# load prices of 28 currencies
# if file is not found in the terminal sandbox, retrieve it from working directory
if(!file.exists(file.path(Terminals[2,2], "AI_CP15.csv"))){
  # retrieve the price data from working directory      
  prices <- read_csv("AI_CP15.csv", col_names = F)
  # otherwise get the fresh copy from the terminal sandbox
} else { prices <- read_csv(file.path(Terminals[2,2], "AI_CP15.csv"), col_names = F)}
# make the price having proper format
prices$X1 <- ymd_hms(prices$X1)

# Vector of currency pairs
Pairs = c("Date", "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY",
          "EURGBP", "EURJPY", "EURCHF", "EURNZD", "EURCAD", "EURAUD", "GBPAUD",
          "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "AUDCAD", "AUDCHF", "AUDJPY",
          "AUDNZD", "CADJPY", "CHFJPY", "NZDJPY", "NZDCAD", "NZDCHF", "CADCHF")   
# Rename the column?
names(prices) <- Pairs
# -------------------------------
# Load tables with trading strategies
Strategies <- read_excel("Strategies.xlsx",sheet = 1,col_names = TRUE)
Strategies$ID <- as.factor(Strategies$ID)
# -------------------------------
# function that write data to csv file 
storeData <- function(data, fileName) {
  
  # store only unique records
  # non duplicates
  nonDuplicate <- data[!duplicated(data), ]
  # Write the file to the local system
  write.csv(
    x = nonDuplicate,
    file = fileName, 
    row.names = FALSE, quote = FALSE, append = TRUE, col.names = FALSE
  )
}

# -------------------------------
# function that calculates profit factor from the vector
source("profit_factor.R")

# ============================================================

shinyServer(function(input, output, session) {

  #=============================================================
  #========= REACTIVE VALUES ===================================
  #=============================================================  
  
  #---------------------  
  # have a reactive value of terminal number selected
  file_path <- reactive({ file_path <- paste0(Terminals[input$TermNum, 2], "OrdersResultsT", input$TermNum,".csv") })
  #Debugging: file_path <- paste0(Terminals[4, 2], "OrdersResultsT", 4,".csv")
  # # No DSS? Uncomment and use this variable instead:
  # file_path <- reactive({ file_path <- paste0("OrdersResultsT", input$TermNum,".csv") })
  
  #---------------------
  # have a reactive value of the magic system selected
  system_analysed <- reactive({ system_analysed <- input$MagicNum })
  
  #---------------------
  # have a reactive value of the strategy type
  strategy_analysed <- reactive({ system_analysed() %>% substr(3,4) })
  
  #---------------------
  # cleaning data and creating relevant statistics also with profit factor
  DF_Stats <- reactive({ 
                        DF_Stats <- read_csv(file = file_path(), col_names = F)
                        #DF_Stats <- read_csv(file = file_path, col_names = F) #debugging
                        DF_Stats$X3 <- ymd_hms(DF_Stats$X3)
                        DF_Stats$X4 <- ymd_hms(DF_Stats$X4)
                        # removes duplicates
                        DF_Stats <- unique(DF_Stats)
                        
                        # extracting table with corresponding pairs
                        DF_Pairs <- DF_Stats %>% 
                          filter(X3 > as.POSIXct(input$filterDate)) %>% 
                          distinct(X1, X6)
                        
                        # sumarizing table
                        DF_Stats <- DF_Stats %>%
                        filter(X3 > as.POSIXct(input$filterDate)) %>% 
                        group_by(X1) %>%
                        summarise(PnL = sum(X5),
                                  NumTrades = n(),
                                  PrFact = profit_factor(X5)) %>% 
                          #join column with currency pairs
                          right_join(DF_Pairs, by = 'X1') %>%
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
    DF_Stats_PnL <- unique(DF_Stats_PnL)
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
  
  #---------------------
  # create dynamic value of currency pair for the logging purposes
  pair_analysed <- reactive({ DF_Stats() %>% filter(X1 == system_analysed()) %$% X6 })
  
  #---------------------
  # create dynamic value of profit factor for the logging purposes
  prof_fact <- reactive({ DF_Stats() %>% filter(X1 == system_analysed()) %$% PrFact })
  
  
  #---------------------
  # store record as reactive value
  DF <- reactive({ 
    
    DF <- data.frame(ID = strategy_analysed(),
                     Pair = pair_analysed(),
                     Date = as.character(Sys.Date()),
                     PrFact = prof_fact(),
                     Log = as.character(input$caption))
    
    })
  
  
  
  #=============================================================
  #========= REACTIVE EVENTS ===================================
  #=============================================================  
  # import the summary statistics on the beginning of the app, call the statistics on refresh button call
  observeEvent(input$Refresh, {

    # update the magic numbers selection
    updateSelectInput(session, inputId = "MagicNum", label = NULL, choices = unique(DF_Stats()$X1), selected = NULL)
    
      #try to read from file responses.csv first for the information that is already available
    DF <- try(read_csv(file = "responses.csv", col_types = "ccccc"),silent = T)
      
      if (class(DF)[3] == "data.frame") {    # get data from file to the responses
        responses <<- DF
      }
  })
  
  # add record to the log file and write that to the file back, delete content from the input text
  observeEvent(input$subm_rec, {
   
    #add record to log object
    # function that write data to global directory called "responses"
    saveDataGlobal <- function(data) {
      
      if (exists("responses")) {    # get data from global environment is it's exist there
        responses <<- rbind(responses, data)
      } else {
        responses <<- data                # <<- this saves to the global environment
      }
    }
    
    # save data to global directory
    saveDataGlobal(DF())
    
    #write to file (append)
    storeData(responses, "responses.csv") 
    #eraze what was written
    updateTextAreaInput(session, inputId = "caption", label = NULL, value = "")
    
  })
  
  
#=============================================================
#========= OUTPUTS ===========================================
#=============================================================
  
  # -------------------------------------------
  # generating plot 1 statistics of the terminal
  output$plot1 <- renderPlot({

    DF_Stats() %>% 
      #DF_Stats1 %>% #debugging
      ggplot(aes(x = PnL, y = as.factor(X1), size = NumTrades, col = as.factor(X6))) + geom_point()+ 
      ggtitle(label = "Plot indicating which systems are profitable", 
              subtitle = "Size of the point represent number of trades completed") +
      geom_vline(xintercept=0, linetype="dashed", color = "green") +
      geom_vline(xintercept = DF_Stats_PnL()$TotPnL, color = "red")

    })
  
  # -------------------------------------------
  # table with statistic of the system, P/L and Number of trades
  output$statistics <- renderTable({  DF_Stats() %>%  filter(X1 == system_analysed())   })
  
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
  
  # # -------------------------------------------
  # generating plot 3 price chart of pairs
  output$plot3 <- renderPlot({
    
    DF <- read_csv(file = file_path(), col_names = F)
    DF$X3 <- ymd_hms(DF$X3)
    DF$X4 <- ymd_hms(DF$X4)
    
    # find the oldest trade done
    DF1 <- DF %>% 
      # only show one system
      filter(X1 == system_analysed()) %>% 
      select(X4) %>% arrange() %>% head(1)
    FirstTrade <- DF1$X4
    
    # find the currency which is in trade
    DF2 <- DF %>% 
      # only show one system
      filter(X1 == system_analysed()) %>% 
      select(X6) %>% head(1)
    Currency <- DF2$X6
    
    # extract relevant price information...
    DF_Date <- subset(prices, select = Date)
    DF_Price <- subset(prices, select = Currency) %>% bind_cols(DF_Date)
    
    # rename otherwise ggplot did not work
    names(DF_Price) <- c("X1", "Date")
    
    # bring the plot...
    DF_Price %>% filter(Date > as.POSIXct(FirstTrade)) %>%
      select(Date, X1) %>% 
      ggplot(aes(Date, X1, col = "red")) + geom_line()
    
  })
  
  # generating strategy output
  output$strategy_text <- renderTable({ Strategy() })
  
  # function that visualizes the current table results if it's stored in GLobal Environment
  loadData <- function() {
    if (exists("responses")) {
      responses
    }
  }
  # writing logs of the records
  output$mytable <- DT::renderDataTable({
    
    input$subm_rec
    loadData()
  })
  
})
