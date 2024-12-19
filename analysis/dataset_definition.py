# numpy for random seed - and set random seed
#import numpy as np 
#np.random.seed(209109) # random seed

#######################################################################################
# IMPORT
#######################################################################################
## Import ehrQL functions
from ehrql import (
    create_dataset
)

## Import TPP tables
from ehrql.tables.tpp import (
    clinical_events,
    patients
)

## Import all codelists from codelists.py
from codelists import *

## Import the variable helper functions 
from variable_helper_functions import *

#######################################################################################
# DEFINE or IMPORT the index date
#######################################################################################
index_date = "2020-02-01" # start of pandemic in UK
studyend_date = "2024-07-01"

#######################################################################################
# INITIALISE the dataset and set the dummy dataset size
#######################################################################################
dataset = create_dataset()
dataset.configure_dummy_data(population_size=10000)
dataset.define_population(patients.exists_for_patient())

#######################################################################################
# DEFINE necessary variables to build algo
#######################################################################################
## Demographics
# Year of birth
dataset.birth_year_num = patients.date_of_birth

# Ethnicity in 6 categories
dataset.ethnicity_cat = (
    clinical_events.where(clinical_events.ctv3_code.is_in(ethnicity_codes))
    .sort_by(clinical_events.date)
    .last_for_patient()
    .ctv3_code.to_category(ethnicity_codes)
)

#######################################################################################
# EXPOSURE
#######################################################################################
## Baricitinib
## First baricitinib treatment, at hospital admission, after pandemic start
dataset.exp_date_bari_hosp_first = first_matching_event_bari_between("hospitalised_with", index_date, studyend_date).treatment_start_date 
## First baricitinib treatment, hospital onset, after pandemic start
dataset.exp_date_bari_hosp_onset_first = first_matching_event_bari_between("hospital_onset", index_date, studyend_date).treatment_start_date 
## First baricitinib treatment, outpatient, after pandemic start
dataset.exp_date_bari_outpatient_first = first_matching_event_bari_between("non_hospitalised", index_date, studyend_date).treatment_start_date 