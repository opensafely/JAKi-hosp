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

################################################################################
# 0.1 Define redaction threshold
################################################################################
threshold <- 6

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
    ethnicity_cat = fn_case_when(
      ethnicity_cat == "1" ~ "White",
      ethnicity_cat == "4" ~ "Black",
      ethnicity_cat == "3" ~ "South Asian",
      ethnicity_cat == "2" ~ "Mixed",
      ethnicity_cat == "5" ~ "Other",
      ethnicity_cat == "0" ~ "Unknown",
      TRUE ~ NA_character_) # if ethnicity is NA, it remains NA -> will not influence diabetes algo, except that for step 5 only age will be used for these cases
    )

################################################################################
# 4 Exposure
################################################################################
### Baricitinib, at hosp admission
## Histogram, in monthly counts (binwidth = 30)
ggplot(data_processed, aes(x = exp_date_bari_hosp_first)) +
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
ggplot(data_processed, aes(x = exp_date_bari_hosp_onset_first)) +
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
ggplot(data_processed, aes(x = exp_date_bari_outpatient_first)) +
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
# 4 Save output
################################################################################
# the data
write_rds(data_processed, here::here("output", "data_processed.rds"))

# histograms, png and underlying aggregate data
# Save the histo as a PNG file
ggsave(
  filename = here::here("output", "data_properties", "histo_bari_hosp_monthly.png"),
  plot = ggplot(data_processed, aes(x = exp_date_bari_hosp_first)) +
    geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
    labs(
      title = "Number of Persons Treated Over Time",
      x = "Date of First Baricitinib In-Hosp Treatment",
      y = "Number of Persons"
    ) +
    theme_minimal(),
  width = 8, height = 6, dpi = 300
)
write.csv(n_histo_bari_hosp_monthly, file = here::here("output", "data_properties", "n_histo_bari_hosp_monthly.csv"))
write.csv(n_histo_bari_hosp_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_hosp_monthly_midpoint6.csv"))

ggsave(
  filename = here::here("output", "data_properties", "histo_bari_hosp_onset_monthly.png"),
  plot = ggplot(data_processed, aes(x = exp_date_bari_hosp_onset_first)) +
    geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
    labs(
      title = "Number of Persons Treated Over Time",
      x = "Date of First Baricitinib Hosp Onset Treatment",
      y = "Number of Persons"
    ) +
    theme_minimal(),
  width = 8, height = 6, dpi = 300
)
write.csv(n_histo_bari_hosp_onset_monthly, file = here::here("output", "data_properties", "n_histo_bari_hosp_onset_monthly.csv"))
write.csv(n_histo_bari_hosp_onset_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_hosp_onset_monthly_midpoint6.csv"))

ggsave(
  filename = here::here("output", "data_properties", "histo_bari_outpatient_monthly.png"),
  plot = ggplot(data_processed, aes(x = exp_date_bari_outpatient_first)) +
    geom_histogram(binwidth = 30, fill = "green", color = "black", boundary = 0) + 
    labs(
      title = "Number of Persons Treated Over Time",
      x = "Date of First Baricitinib Outpatient Treatment",
      y = "Number of Persons"
    ) +
    theme_minimal(),
  width = 8, height = 6, dpi = 300
)
write.csv(n_histo_bari_outpatient_monthly, file = here::here("output", "data_properties", "n_histo_bari_outpatient_monthly.csv"))
write.csv(n_histo_bari_outpatient_monthly_midpoint6, file = here::here("output", "data_properties", "n_histo_bari_outpatient_monthly_midpoint6.csv"))
