# playground script - try to look how kmeans would split trades into classes
library(tidyverse)
library(lubridate)

# basic trades import
file_path <- paste(Terminals[1, 2], "/", "OrdersResultsT", 1,".csv", sep = "")
DF_Stats <- read_csv(file = file_path, col_names = F)
DF_Stats$X3 <- ymd_hms(DF_Stats$X3)
DF_Stats$X4 <- ymd_hms(DF_Stats$X4)
DF_Stats <- DF_Stats %>%
  filter(X3 > "2017-09-30") %>% 
  group_by(X1) %>%
  summarise(PnL = sum(X5),
            NumTrades = n())

# before clustering
DF_Stats %>% 
  ggplot(aes(x = NumTrades, y = PnL)) + geom_point()

# kmeans with scaling
km_sc <- DF_Stats %>% 
  select(NumTrades, PnL) %>% 
  scale() %>%
  as.data.frame() %>%
    kmeans(centers = 3, nstart = 20)
# kmeans without scaling
km <- DF_Stats %>% 
  select(NumTrades, PnL) %>% 
    kmeans(centers = 3, nstart = 20)

# Non scaled result
vector <- as.data.frame.vector(km$cluster)
names(vector) <- "Clust"

DF_SUM <- DF_Stats %>% 
  # join clustering result
  bind_cols(vector) %>% 
  mutate(Clust = as.factor(Clust)) 

DF_SUM %>% 
  ggplot(aes(x = NumTrades, y = PnL, col = Clust)) + geom_point()+ggtitle("performance no scaling")

# Scaled result
vectorsc <- as.data.frame.vector(km_sc$cluster)
names(vectorsc) <- "Clust"

DF_SUM <- DF_Stats %>% 
  # join clustering result
  bind_cols(vectorsc) %>% 
  mutate(Clust = as.factor(Clust)) 

DF_SUM %>% 
  ggplot(aes(x = NumTrades, y = PnL, col = Clust)) + geom_point()+ggtitle("performance scaling")
