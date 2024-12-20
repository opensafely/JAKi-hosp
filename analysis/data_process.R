################################################################################
## This script does the following:
# 1. Import/extract feather dataset from OpenSAFELY: 21 variables needed from OpenSAFELY
# 2. Basic type formatting of variables -> fn_extract_data.R()
# 3. Process the ethnicity covariate and apply the diabetes algorithm -> fn_diabetes_algorithm.R()
# 4. Save the output: data_processed containing only 8 variables
################################################################################

################################################################################
# 0.0 Import libraries + functions
################################################################################
library('arrow')
library('readr')
library('here')
library('lubridate')
library('dplyr')
library('tidyr')
library('ggplot2')

## Import custom user functions
source(here::here("analysis", "functions", "fn_extract_data.R"))
source(here::here("analysis", "functions", "fn_case_when.R"))
source(here::here("analysis", "functions", "fn_roundmid_any.R"))
source(here::here("analysis", "functions", "fn_quality_assurance_midpoint6.R"))

################################################################################
# 0.1 Create directories for output
################################################################################
fs::dir_create(here::here("output", "data"))
fs::dir_create(here::here("output", "data_properties"))

################################################################################
# 0.2 Define redaction threshold
################################################################################
threshold <- 6

################################################################################
# 0.3 Import dates
################################################################################
source(here::here("analysis", "metadates.R"))
# Convert the meta-dates into Date objects
study_dates <- lapply(study_dates, function(x) as.Date(x))

################################################################################
# 1 Import data
################################################################################
input_filename <- "dataset.arrow"

################################################################################
# 2 Reformat the imported data
################################################################################
data_extracted <- fn_extract_data(input_filename)

################################################################################
# 3 Process the data
################################################################################
data_processed <- data_extracted %>%
  mutate(
    cov_cat_age = cut(
      cov_num_age,
      breaks = c(18, 40, 60, 80, 110),
      labels = c("18-39", "40-59", "60-79", "80+"),
      right = FALSE),
    
    cov_cat_sex = fn_case_when(
      cov_cat_sex == "female" ~ "Female",
      cov_cat_sex == "male" ~ "Male",
      TRUE ~ NA_character_),
    
    ethnicity_cat = fn_case_when(
      ethnicity_cat == "1" ~ "White",
      ethnicity_cat == "4" ~ "Black",
      ethnicity_cat == "3" ~ "South Asian",
      ethnicity_cat == "2" ~ "Mixed",
      ethnicity_cat == "5" ~ "Other",
      ethnicity_cat == "0" ~ "Unknown",
      TRUE ~ NA_character_)
    )

################################################################################
# 4 Apply the quality assurance criteria
################################################################################
qa <- fn_quality_assurance_midpoint6(data_processed, study_dates, threshold)
n_qa_excluded_midpoint6 <- qa$n_qa_excluded_midpoint6
data_processed <- qa$data_processed

#table(data_processed$exp_status_bari_hosp_first) # check!

################################################################################
# 5 Exposure
################################################################################
### Baricitinib, at hosp admission
## Histogram, in monthly counts (binwidth = 30)
histo_bari_hosp_monthly <- ggplot(data_processed, aes(x = exp_date_bari_hosp_first)) +
  geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
  labs(
    title = "Number of Persons Treated Over Time",
    x = "Date of First Baricitinib In-Hosp Treatment",
    y = "Number of Persons"
  ) +
  theme_minimal()
# Show aggregate data for this histogram
n_histo_bari_hosp_monthly <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_hosp_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = n()
  ) %>%
  arrange(time_interval) # Ensure chronological order
# rounded to midpoint6
n_histo_bari_hosp_monthly_midpoint6 <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_hosp_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = fn_roundmid_any(n(), threshold)
  ) %>%
  arrange(time_interval)

### Baricitinib, hosp onset
## Histogram, in monthly counts (binwidth = 30)
histo_bari_hosp_onset_monthly <- ggplot(data_processed, aes(x = exp_date_bari_hosp_onset_first)) +
  geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
  labs(
    title = "Number of Persons Treated Over Time",
    x = "Date of First Baricitinib Hosp Onset Treatment",
    y = "Number of Persons"
  ) +
  theme_minimal()
# Show aggregate data for this histogram
n_histo_bari_hosp_onset_monthly <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_hosp_onset_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = n()
  ) %>%
  arrange(time_interval) # Ensure chronological order
# rounded to midpoint6
n_histo_bari_hosp_onset_monthly_midpoint6 <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_hosp_onset_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = fn_roundmid_any(n(), threshold)
  ) %>%
  arrange(time_interval)

### Baricitinib, outpatient
## Histogram, in monthly counts (binwidth = 30)
histo_bari_outpatient_monthly <- ggplot(data_processed, aes(x = exp_date_bari_outpatient_first)) +
  geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
  labs(
    title = "Number of Persons Treated Over Time",
    x = "Date of First Baricitinib Outpatient Treatment",
    y = "Number of Persons"
  ) +
  theme_minimal()
# Show aggregate data for this histogram
n_histo_bari_outpatient_monthly <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_outpatient_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = n()
  ) %>%
  arrange(time_interval) # Ensure chronological order
# rounded to midpoint6
n_histo_bari_outpatient_monthly_midpoint6 <- data_processed %>%
  mutate(time_interval = floor_date(exp_date_bari_outpatient_first, "month")) %>%
  group_by(time_interval) %>%
  summarise(
    count = fn_roundmid_any(n(), threshold)
  ) %>%
  arrange(time_interval)


################################################################################
# 6 Save output
################################################################################
# the data
write_rds(data_processed, here::here("output", "data_processed.rds"))

# histograms (as png), and underlying aggregate data
ggsave(
  filename = here::here("output", "data_properties", "histo_bari_hosp_monthly.png"),
  plot=histo_bari_hosp_monthly)
write.csv(n_histo_bari_hosp_monthly, file = here::here("output", "data_properties", "n_histo_bari_hosp_monthly.csv"))
write.csv(n_histo_bari_hosp_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_hosp_monthly_midpoint6.csv"))

ggsave(
  filename = here::here("output", "data_properties", "histo_bari_hosp_onset_monthly.png"),
  plot=histo_bari_hosp_onset_monthly)
write.csv(n_histo_bari_hosp_onset_monthly, file = here::here("output", "data_properties", "n_histo_bari_hosp_onset_monthly.csv"))
write.csv(n_histo_bari_hosp_onset_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_hosp_onset_monthly_midpoint6.csv"))

ggsave(
  filename = here::here("output", "data_properties", "histo_bari_outpatient_monthly.png"),
  plot=histo_bari_outpatient_monthly)
write.csv(n_histo_bari_outpatient_monthly, file = here::here("output", "data_properties", "n_histo_bari_outpatient_monthly.csv"))
write.csv(n_histo_bari_outpatient_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_outpatient_monthly_midpoint6.csv"))
