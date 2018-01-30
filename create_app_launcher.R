# (C) 2018 Vladimir Zhbanko github: vzhomeexperiments/R_trademonitor
# Course Lazy Trading Part 3: Set up your automated Trading Journal
#
# https://www.udemy.com/your-trading-journal/?couponCode=LAZYTRADE-GIT

# # Run this app from R-Studio or use this link:
# https://stackoverflow.com/questions/18606665/run-web-applications-without-opening-r-studio

#install.packages("RInno")
library(RInno)

# install windows program Inno Setup
RInno::install_inno()

create_app(app_name = "TradingJournal", dir_out = "C:/Users/fxtrams/Desktop/TJ")
compile_iss()

# not finalized:

# app is opening first time but does not opens second time...
