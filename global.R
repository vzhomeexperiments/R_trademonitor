# # global.R
# library(tidyverse)
# library(lubridate)
# prices <- read_csv("AI_CP15-14200.csv", col_names = F)
# # make the price having proper format
# prices$X1 <- ymd_hms(prices$X1)
# 
# # Vector of currency pairs
# Pairs = c("Date", "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY",
#           "EURGBP", "EURJPY", "EURCHF", "EURNZD", "EURCAD", "EURAUD", "GBPAUD",
#           "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "AUDCAD", "AUDCHF", "AUDJPY",
#           "AUDNZD", "CADJPY", "CHFJPY", "NZDJPY", "NZDCAD", "NZDCHF", "CADCHF")   
# # Rename the column?
# names(prices) <- Pairs
