-- Drop the view if it exists
DROP VIEW IF EXISTS drh_participant_data;

-- Create a view with a prefixed and UUID-appended participant_id, and unchanged foreign key values
CREATE VIEW drh_participant_data AS
SELECT
    -- Prefix with 'PART_' and append a UUID-like hex blob
  'PART_' || lower(hex(randomblob(2)) || hex(randomblob(2))) AS participant_id, 
  -- Foreign keys (study_id and site_id) must remain unchanged
  study_id, site_id, diagnosis_icd, med_rxnorm,
  treatment_modality, gender, race_ethnicity, age, bmi, baseline_hba1c,
  diabetes_type, study_arm
FROM uniform_resource_participant;
