
#===============================
# PROFIT FACTOR FUNCTION
#===============================
# function that returns the profit factors of the systems
#
# x - column vector with profit or loss of the orders for one system
#     function should calculate profit factor for this vector and return one value also as vector
# require(magrittr)
# x <- read_rds('test_data.rds') %>% select(X5) %$% X5 
# x <- read_rds('test_data.rds') %>% filter(X5 > 0) %>% select(X5) %$% X5 
# x <- read_rds('test_data.rds') %>% filter(X5 < 0) %>% select(X5) %$% X5 

profit_factor <- function(x){
  
  sum(x[x>0])/(0.0001+sum(abs(x[x<0])))
  
  
  }
  
# test this function
# profit_factor(x)
