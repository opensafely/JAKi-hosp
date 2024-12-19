#######################################################################################
# HELPER FUNCTIONS for the dataset_definition
#######################################################################################
from ehrql.tables.tpp import (
    apcs,
    clinical_events, 
    medications,
    covid_therapeutics
)

#######################################################################################
### COUNT all prior events (including index_date)
#######################################################################################
## In PRIMARY CARE
# CTV3/Read
def count_matching_event_clinical_ctv3_before(codelist, index_date, where=True):
    return(
        clinical_events.where(where)
        .where(clinical_events.ctv3_code.is_in(codelist))
        .where(clinical_events.date.is_on_or_before(index_date))
        .count_for_patient()
    )

## In SECONDARY CARE (Hospital Episodes)
def count_matching_event_apc_before(codelist, index_date, where=True):
    return(
        apcs.where(where)
        .where(apcs.primary_diagnosis.is_in(codelist) | apcs.secondary_diagnosis.is_in(codelist))
        .where(apcs.admission_date.is_on_or_before(index_date))
        .count_for_patient()
    )

#######################################################################################
### ANY HISTORY of ... and give first ... (including index_date) 
#######################################################################################
## In PRIMARY CARE
# CTV3/Read
def first_matching_event_clinical_ctv3_before(codelist, index_date, where=True):
    return(
        clinical_events.where(where)
        .where(clinical_events.ctv3_code.is_in(codelist))
        .where(clinical_events.date.is_on_or_before(index_date))
        .sort_by(clinical_events.date)
        .first_for_patient()
    )
# Snomed
def first_matching_event_clinical_snomed_before(codelist, index_date, where=True):
    return(
        clinical_events.where(where)
        .where(clinical_events.snomedct_code.is_in(codelist))
        .where(clinical_events.date.is_on_or_before(index_date))
        .sort_by(clinical_events.date)
        .first_for_patient()
    )
# Medication
def first_matching_med_dmd_before(codelist, index_date, where=True):
    return(
        medications.where(where)
        .where(medications.dmd_code.is_in(codelist))
        .where(medications.date.is_on_or_before(index_date))
        .sort_by(medications.date)
        .first_for_patient()
    )

## In SECONDARY CARE (Hospital Episodes)
def first_matching_event_apc_before(codelist, index_date, where=True):
    return(
        apcs.where(where)
        .where(apcs.primary_diagnosis.is_in(codelist) | apcs.secondary_diagnosis.is_in(codelist))
        .where(apcs.admission_date.is_on_or_before(index_date))
        .sort_by(apcs.admission_date)
        .first_for_patient()
    )

#######################################################################################
### Any future events (including baseline_date and study end_date)
#######################################################################################
## In COVID Therapeutics dataset
def first_matching_event_bari_between(setting, baseline_date, end_date, where=True):
    return(
        covid_therapeutics.where(where)
        .where(covid_therapeutics.intervention.is_in(["Baricitinib"]))
        .where(covid_therapeutics.covid_indication.is_in([setting]))
        .where(covid_therapeutics.treatment_start_date.is_on_or_between(baseline_date, end_date))
        .sort_by(covid_therapeutics.treatment_start_date)
        .first_for_patient()
    )
def last_matching_event_bari_between(setting, baseline_date, end_date, where=True):
    return(
        covid_therapeutics.where(where)
        .where(covid_therapeutics.intervention.is_in(["Baricitinib"]))
        .where(covid_therapeutics.covid_indication.is_in([setting]))
        .where(covid_therapeutics.treatment_start_date.is_on_or_between(baseline_date, end_date))
        .sort_by(covid_therapeutics.treatment_start_date)
        .last_for_patient()
    )

## In PRIMARY CARE
# CTV3/Read
def first_matching_event_clinical_ctv3_between(codelist, baseline_date, end_date, where=True):
    return(
        clinical_events.where(where)
        .where(clinical_events.ctv3_code.is_in(codelist))
        .where(clinical_events.date.is_on_or_between(baseline_date, end_date))
        .sort_by(clinical_events.date)
        .first_for_patient()
    )
# Snomed
def first_matching_event_clinical_snomed_between(codelist, baseline_date, end_date, where=True):
    return(
        clinical_events.where(where)
        .where(clinical_events.snomedct_code.is_in(codelist))
        .where(clinical_events.date.is_on_or_between(baseline_date, end_date))
        .sort_by(clinical_events.date)
        .first_for_patient()
    )
# Medication
def first_matching_med_dmd_between(codelist, baseline_date, end_date, where=True):
    return(
        medications.where(where)
        .where(medications.dmd_code.is_in(codelist))
        .where(medications.date.is_on_or_between(baseline_date, end_date))
        .sort_by(medications.date)
        .first_for_patient()
    )

## In SECONDARY CARE
def first_matching_event_apc_between(codelist, baseline_date, end_date, where=True):
    return(
        apcs.where(where)
        .where(apcs.primary_diagnosis.is_in(codelist) | apcs.secondary_diagnosis.is_in(codelist))
        .where(apcs.admission_date.is_on_or_between(baseline_date, end_date))
        .sort_by(apcs.admission_date)
        .first_for_patient()
    )

## In OUTPATIENT CARE
def first_matching_event_opa_between(codelist, baseline_date, end_date, where=True):
    return(
        opa_diag.where(where)
        .where(opa_diag.primary_diagnosis_code.is_in(codelist) | opa_diag.secondary_diagnosis_code_1.is_in(codelist))
        .where(opa_diag.appointment_date.is_on_or_between(baseline_date, end_date))
        .sort_by(opa_diag.appointment_date)
        .first_for_patient()
    )

## In EMERGENCY CARE
def first_matching_event_ec_snomed_between(codelist, baseline_date, end_date, where=True):
    conditions = [
        getattr(emergency_care_attendances, column_name).is_in(codelist)
        for column_name in ([f"diagnosis_{i:02d}" for i in range(1, 25)])
    ]
    return(
        emergency_care_attendances.where(where)
        .where(any_of(conditions))
        .where(emergency_care_attendances.arrival_date.is_on_or_between(baseline_date, end_date))
        .sort_by(emergency_care_attendances.arrival_date)
        .first_for_patient()
    )

## DEATH
def matching_death_between(codelist, baseline_date, end_date, where=True):
    conditions = [
        getattr(ons_deaths, column_name).is_in(codelist)
        for column_name in (["underlying_cause_of_death"]+[f"cause_of_death_{i:02d}" for i in range(1, 16)])
    ]
    return any_of(conditions) & ons_deaths.date.is_on_or_between(baseline_date, end_date)

### CAUSES of DEATH without any date restrictions
def cause_of_death_matches(codelist):
    conditions = [
        getattr(ons_deaths, column_name).is_in(codelist)
        for column_name in (["underlying_cause_of_death"]+[f"cause_of_death_{i:02d}" for i in range(1, 16)])
    ]
    return any_of(conditions)


### BMI calculation
def most_recent_bmi(*, minimum_age_at_measurement, where=True):
    age_threshold = patients.date_of_birth + days(
        # This is obviously inexact but, given that the dates of birth are rounded to
        # the first of the month anyway, there's no point trying to be more accurate
        int(365.25 * minimum_age_at_measurement)
    )
    return (
        # This captures just explicitly recorded BMI observations rather than attempting
        # to calculate it from height and weight measurements. Investigation has shown
        # this to have no real benefit it terms of coverage or accuracy.
        clinical_events.where(where)
        .where(clinical_events.ctv3_code == CTV3Code("22K.."))
        .where(clinical_events.date >= age_threshold)
        .sort_by(clinical_events.date)
        .last_for_patient()
    )