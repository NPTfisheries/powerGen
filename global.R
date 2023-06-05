library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)
library(viridis)

# data
load('./data/power_data.rda') 

projects = c('Lower Granite', 'Little Goose', 'Lower Monumental', 'Ice Harbor', 'Combined')

# plotly font sizes
main_title = 34
axis_titles = 26
axis_labels = 22