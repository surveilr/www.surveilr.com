-- TODO: Use ChatGPT to fully understand what participant data represents and incorporate insights from GitHub discussions.
-- If the column in the CSV file `participant` is `patient_id` and instead of `gender` the CSV file has `sex` as the column name.
-- Drop and recreate the participant_data view
DROP VIEW IF EXISTS drh_participant_data;
CREATE VIEW drh_participant_data AS
SELECT
  patient_id AS participant_id, study_id, site_id, diagnosis_icd, med_rxnorm,
  treatment_modality, sex AS gender, race_ethnicity, age, bmi, baseline_hba1c,
  diabetes_type, study_arm
FROM uniform_resource_participant;
