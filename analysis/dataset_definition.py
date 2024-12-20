# numpy for random seed - and set random seed
#import numpy as np 
#np.random.seed(209109) # random seed

#######################################################################################
# IMPORT
#######################################################################################
## Import ehrQL functions
from ehrql import (
    create_dataset,
    case,
    when
)

## Import TPP tables
from ehrql.tables.tpp import (
    clinical_events,
    patients,
    ons_deaths,
    medications,
    apcs
)

## Import all codelists from codelists.py
from codelists import *

## Import the variable helper functions 
from variable_helper_functions import *

## json (for the dates)
import json

#######################################################################################
# DEFINE or IMPORT the dates
#######################################################################################
with open("output/study_dates.json") as f:
  study_dates = json.load(f)
studyend_date = study_dates["studyend_date"]
studystart_date = study_dates["studystart_date"]

#######################################################################################
# INITIALISE the dataset and set the dummy dataset size
#######################################################################################
dataset = create_dataset()
dataset.configure_dummy_data(population_size=10000)
dataset.define_population(patients.exists_for_patient())

#######################################################################################
#  QUALITY ASSURANCES and demographics
#######################################################################################
# Sex
dataset.qa_bin_is_female_or_male = patients.sex.is_in(["female", "male"]) 
dataset.cov_cat_sex = patients.sex
## Year of birth and age at pandemic start
dataset.qa_num_birth_year = patients.date_of_birth
dataset.cov_num_age = patients.age_on(studystart_date)
## Date of death
dataset.qa_date_of_death = ons_deaths.date
## Pregnancy (over entire study period -> don't have helper function for this)
dataset.qa_bin_pregnancy = clinical_events.where(clinical_events.snomedct_code.is_in(pregnancy_snomed_clinical)).exists_for_patient()
## Combined oral contraceptive pill (over entire study period -> don't have helper function for this)
dataset.qa_bin_cocp = medications.where(medications.dmd_code.is_in(cocp_dmd)).exists_for_patient()
## Hormone replacement therapy (over entire study period -> don't have helper function for this)
dataset.qa_bin_hrt = medications.where(medications.dmd_code.is_in(hrt_dmd)).exists_for_patient()
## Prostate cancer (over entire study period -> don't have helper function for this)
### Primary care
prostate_cancer_snomed = clinical_events.where(clinical_events.snomedct_code.is_in(prostate_cancer_snomed_clinical)).exists_for_patient()
### HES APC
prostate_cancer_hes = apcs.where(apcs.all_diagnoses.contains_any_of(prostate_cancer_icd10)).exists_for_patient()
### ONS (stated anywhere on death certificate)
prostate_cancer_death = cause_of_death_matches(prostate_cancer_icd10)
# Combined: Any prostate cancer diagnosis
dataset.qa_bin_prostate_cancer = case(
    when(prostate_cancer_snomed).then(True),
    when(prostate_cancer_hes).then(True),
    when(prostate_cancer_death).then(True),
    otherwise=False
)
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
dataset.exp_date_bari_hosp_first = first_matching_event_bari_between("hospitalised_with", studystart_date, studyend_date).treatment_start_date 
## First baricitinib treatment, hospital onset, after pandemic start
dataset.exp_date_bari_hosp_onset_first = first_matching_event_bari_between("hospital_onset", studystart_date, studyend_date).treatment_start_date 
## First baricitinib treatment, outpatient, after pandemic start
dataset.exp_date_bari_outpatient_first = first_matching_event_bari_between("non_hospitalised", studystart_date, studyend_date).treatment_start_date 