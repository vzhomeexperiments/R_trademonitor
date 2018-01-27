
#===============================
# PROFIT FACTOR FUNCTION
#===============================
# function that returns the profit factors of the systems
#
# x - column vector with profit or loss of the orders for one system
#     function should calculate profit factor for this vector and return one value also as vector
# x <- read_rds('test_data.rds') %>% select(X5) %$% X5 
# x <- read_rds('test_data.rds') %>% filter(X5 > 0) %>% select(X5) %$% X5 
# x <- read_rds('test_data.rds') %>% filter(X5 < 0) %>% select(X5) %$% X5 

profit_factor <- function(x){
  require(magrittr)
  x <- x %>% as.data.frame()
    names(x) <- 'trade_result'
    # only profits
    DF_P <- x %>%
      filter(trade_result > 0) %>% 
      summarise(Gain = sum(trade_result))
    
    # get losses, join profits, calculate profit factor, extract it, convert to vector...
    res <- x %>%
      filter(trade_result < 0) %>% 
      summarise(Loss = abs(sum(trade_result))) %>% 
      bind_cols(DF_P) %>% 
      mutate(Profit_Factor = Gain/(0.00001+Loss)) %$% 
      #convert back to vector
      Profit_Factor 
  
    return(res)  
    
  }
  
# test this function
# profit_factor(x)
