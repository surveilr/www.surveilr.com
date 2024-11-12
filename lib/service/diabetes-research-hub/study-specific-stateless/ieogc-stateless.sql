-- Drop the view if it exists, then create the drh_participant view
DROP VIEW IF EXISTS drh_participant;

CREATE VIEW
    drh_participant AS
    SELECT
    (
        SELECT
            party_id
        FROM
            party
        LIMIT
            1
    ) AS tenant_id,  -- Fetching tenant_id from the party table (assuming party table exists)
    'IEOGC-' || PtID AS participant_id,  -- Prefix 'IEOGC-' to PtID to form participant_id
    (
        SELECT
            study_id
        FROM
            uniform_resource_study
        LIMIT
            1
    ) AS study_id,  -- Fetching study_id from the uniform_resource_study table
    '' AS site_id,  -- Placeholder for site_id
    '' AS diagnosis_icd,  -- Placeholder for diagnosis ICD
    '' AS med_rxnorm,  -- Placeholder for medication RxNorm
    '' AS treatment_modality,  -- Placeholder for treatment modality
    Gender AS gender,  -- Mapping Gender
    Race || ', ' || RaceDs AS race_ethnicity,  -- Concatenate Race and Ethnicity for race_ethnicity
    -- Randomly generate age between 11 and 17
    (11 + (ABS(RANDOM()) % 7)) AS age,  -- Generates a random age between 11 and 17
    CASE
        WHEN Weight IS NOT NULL
        AND Height IS NOT NULL THEN (Weight / ((Height / 100.0) * (Height / 100.0)))  -- BMI calculation if Weight and Height are available
        ELSE NULL
    END AS bmi,  -- Alias for BMI calculation
    HbA1C AS baseline_hba1c,  -- Mapping HbA1C to baseline_hba1c
    CASE
        WHEN Type1Dm = 'Yes' THEN 'Type 1 Diabetes'  -- If Type1Dm is 'yes', then set diabetes_type as 'Type 1 D'
        ELSE ''  -- Otherwise set it as empty
    END AS diabetes_type,  -- Adjusted logic for diabetes type
    '' AS study_arm  -- Placeholder for study arm
FROM
    uniform_resource_tblDEnrollment;
