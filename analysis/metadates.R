# # # # # # # # # # # # # # # # # # # # #
# This script creates the study dates (json file) to be called via a yaml action
# # # # # # # # # # # # # # # # # # # # #

# Import libraries ----
library('tidyverse')
library('here')

# create study_dates ----
study_dates <-
  list(
    studystart_date = "2020-02-01", #start of pandemic
    studyend_date = "2024-07-01"
  )

jsonlite::write_json(study_dates, path = "output/study_dates.json", auto_unbox = TRUE, pretty=TRUE)