# Query date from USACE for Jay's usage.
# This creates the dataframe needed for the powerGen app.
# https://nptfisheries.shinyapps.io/power-generation/

library(tidyverse)
library(lubridate)
library(fisheR)

# desired date range
start_date <- '01/01/2000'
end_date <- gsub('-', '/', paste(substr(Sys.Date(), 6, 10), substr(Sys.Date(), 1, 4), sep='-'))

# https://www.nwd-wc.usace.army.mil/dd/common/dataquery/www/

# Notes from Jay's email:
# cat('Datasets that I need will be:\n',
#     '1)	Daily min hourly generation at Ice Harbor, Lower Monumental, Little Goose, and Lower Granite (and hourly minimum when all four projects summed for a given hour).\n' ,
#     '2)	Daily average hourly generation at Ice Harbor, Lower Monumental, Little Goose, and Lower Granite (and hourly average when all four projects summed for a given hour). \n',
#     '3)	Daily max hourly generation at Ice Harbor, Lower Monumental, Little Goose, and Lower Granite (and hourly maximum when all four projects summed for a given hour).\n',
#     'I would like to be able to generate these summaries for annual (calendar year) periods.')

# query names
queries <- c(
  'IHR.Power.Total.1Hour.1Hour.CBT-RAW',
  'LMN.Power.Total.1Hour.1Hour.CBT-RAW',
  'LGS.Power.Total.1Hour.1Hour.CBT-RAW',
  'LWG.Power.Total.1Hour.1Hour.CBT-RAW'
)

# run queries
all_data_raw <- map_dfr(.x = queries,
                        .f = ~get_USACE_data(query=.x,
                                             startdate = start_date,
                                             enddate = end_date, 
                                             timezone = 'PST'))


# save(all_data_raw, file = './data/power/all_data_raw.rda')

# summarize all data together (data for powerGen project)
combined_data <- all_data_raw %>%
  mutate(datetime = ymd_hms(datetime),
         power_mw = as.double(power_mw)) %>%
  group_by(datetime, timezone, tz_offset) %>%
  # summarize total hourly power gen for all dams
  summarize(power_mw =sum(power_mw),
            n = n()) %>%
  # remove any missing-data records
  filter(n == 4) %>%
  ungroup() %>%
  mutate(name = 'Combined') %>%
  select(-n)

power_data = full_join(all_data_raw %>%
                         mutate(datetime = ymd_hms(datetime),
                                power_mw = as.double(power_mw)),
                       combined_data) %>%
  separate(datetime, into = c('date', 'time'), sep=' ', remove = FALSE) %>%
  mutate(year = year(datetime),
         date = ymd(date),
         year_month = as.Date(ymd_hms(gsub('-\\d{2} ', '-01 ', datetime)), format = '%M/%Y/01')) # cheat

save(power_data, file = './data/power_data.rda')

rm(list=ls())
