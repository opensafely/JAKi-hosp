#######################################################################################
# IMPORT
#######################################################################################
from ehrql import codelist_from_csv

#######################################################################################
# Codelists
#######################################################################################
# prostate
prostate_cancer_icd10 = codelist_from_csv("codelists/user-RochelleKnight-prostate_cancer_icd10.csv",column="code")
prostate_cancer_snomed_clinical = codelist_from_csv("codelists/user-RochelleKnight-prostate_cancer_snomed.csv",column="code")

# pregnancy
pregnancy_snomed_clinical = codelist_from_csv("codelists/user-RochelleKnight-pregnancy_and_birth_snomed.csv",column="code")

# combined oral contraceptive pill
cocp_dmd = codelist_from_csv("codelists/user-elsie_horne-cocp_dmd.csv",column="dmd_id")

# hormone replacement therapy
hrt_dmd = codelist_from_csv("codelists/user-elsie_horne-hrt_dmd.csv",column="dmd_id")

# ethnicity
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    column="Code",
    category_column="Grouping_6",
)
