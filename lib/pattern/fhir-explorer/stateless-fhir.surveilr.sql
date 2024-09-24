-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as FHIR content, ensuring only valid JSON is processed. It will be automatically
-- included in `ux.sql.ts` but it can also be used independently. Be sure all SQL
-- is idempotent.
-- --------------------------------------------------------------------------------

-- TODO: will this help performance?
-- CREATE INDEX IF NOT EXISTS idx_resource_type ON uniform_resource ((content ->> '$.resourceType'));
-- CREATE INDEX IF NOT EXISTS idx_bundle_entry ON uniform_resource ((json_type(content -> '$.entry')));

-- FHIR Discovery and Enumeration Views
-- --------------------------------------------------------------------------------

-- Summary of the uniform_resource table
-- Provides a count of total rows, valid JSON rows, invalid JSON rows,
-- and potential FHIR v4 candidates and bundles based on JSON structure.
DROP VIEW IF EXISTS uniform_resource_summary;
CREATE VIEW uniform_resource_summary AS
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN json_valid(content) THEN 1 ELSE 0 END) AS valid_json_rows,
    SUM(CASE WHEN json_valid(content) THEN 0 ELSE 1 END) AS invalid_json_rows,
    SUM(CASE WHEN json_valid(content) AND content ->> '$.resourceType' IS NOT NULL THEN 1 ELSE 0 END) AS fhir_v4_candidates,
    SUM(CASE WHEN json_valid(content) AND json_type(content -> '$.entry') = 'array' THEN 1 ELSE 0 END) AS fhir_v4_bundle_candidates
FROM
    uniform_resource;

-- Identifies FHIR v4 candidates in the uniform_resource table
-- Extracts potential FHIR v4 resources and determines if they are bundles.
DROP VIEW IF EXISTS fhir_v4_candidate;
CREATE VIEW fhir_v4_candidate AS
SELECT
    *,
    content ->> '$.resourceType' AS resource_type,
    CASE WHEN json_type(content -> '$.entry') = 'array' THEN 1 ELSE 0 END AS is_bundle
FROM
    uniform_resource
WHERE
    json_valid(content)
    AND content ->> '$.resourceType' IS NOT NULL;

-- Extracts bundle information from FHIR v4 candidates
-- Lists each bundle ID and the resource type contained within the bundles.
DROP VIEW IF EXISTS fhir_v4_bundle_resource;
CREATE VIEW fhir_v4_bundle_resource AS
SELECT
    content ->> '$.id' AS bundle_id,
    entry.value ->> '$.resource.resourceType' AS resource_type,
    entry.value AS resource_content
FROM
    fhir_v4_candidate,
    json_each(content -> '$.entry') AS entry
WHERE
    is_bundle = 1;

-- Summarizes resource types found in FHIR bundles
-- Counts the total number of each resource type present in the bundles.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_summary;
CREATE VIEW fhir_v4_bundle_resource_summary AS
SELECT
    resource_type,
    COUNT(*) AS total_resource_count
FROM
    fhir_v4_bundle_resource
GROUP BY
    resource_type
ORDER BY
    total_resource_count DESC;

-- FHIR Content Views
-- --------------------------------------------------------------------------------

-- Extracts Patient resources from FHIR bundles
-- Provides details about each patient, such as ID, name, gender, birth date, and address.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_patient;
CREATE VIEW fhir_v4_bundle_resource_patient AS
WITH patient_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Patient'
)
SELECT
    resource_content ->> '$.resource.id' AS patient_id,
    resource_content ->> '$.resource.name[0].given[0]' AS first_name,
    resource_content ->> '$.resource.name[0].family' AS last_name,
    resource_content ->> '$.resource.gender' AS gender,
    CASE 
        WHEN resource_content ->> '$.resource.birthDate' IS NOT NULL THEN DATE(resource_content ->> '$.resource.birthDate')
        ELSE NULL
    END AS birth_date,
    resource_content ->> '$.resource.address[0].line[0]' AS address_line,
    resource_content ->> '$.resource.address[0].city' AS city,
    resource_content ->> '$.resource.address[0].state' AS state,
    resource_content ->> '$.resource.address[0].postalCode' AS postal_code,
    resource_content ->> '$.resource.address[0].country' AS country,
    resource_content ->> '$.resource.extension[0].extension[0].valueCoding.display' AS race_display,
    resource_content ->> '$.resource.extension[0].extension[0].valueCoding.code' AS race_code,
    resource_content ->> '$.resource.extension[0].extension[0].valueCoding.system' AS race_system,       
    resource_content ->> '$.resource.extension[1].extension[0].valueCoding.display' AS ethnicity_display,
    resource_content ->> '$.resource.extension[1].extension[0].valueCoding.code' AS ethnicity_code,
    resource_content ->> '$.resource.extension[1].extension[0].valueCoding.system' AS ethnicity_system,
    resource_content ->> '$.resource.communication[0].language.coding[0].code' AS language,
    resource_content ->> '$.resource.meta.lastUpdated' AS lastUpdated,
    resource_content ->> '$.resource.telecom[0].value' AS telecom,
    resource_content ->> '$.resource.identifier[0].value' AS medical_record_number  
FROM
    patient_resources;

-- Calculates the average age of patients
-- Uses the birth date from the FHIR Patient resources to compute the average age.
DROP VIEW IF EXISTS fhir_v4_patient_age_avg;
CREATE VIEW fhir_v4_patient_age_avg AS
WITH patient_birth_dates AS (
    SELECT
        birth_date
    FROM
        fhir_v4_bundle_resource_patient
    WHERE
        birth_date IS NOT NULL
)
SELECT
    AVG((julianday('now') - julianday(birth_date)) / 365.25) AS average_age
FROM
    patient_birth_dates;

-- Extracts Observation resources from FHIR bundles
-- Provides details about each observation, such as ID, status, category, code, subject, effective date/time, issued date/time, and value.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_observation;
CREATE VIEW fhir_v4_bundle_resource_observation AS
WITH observation_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Observation'
)
SELECT
    resource_content ->> '$.resource.identifier[0].value' AS identifier_1,
    resource_content ->> '$.resource.identifier[1].value' AS identifier_2,
    resource_content ->> '$.resource.identifier[2].value' AS identifier_3,
    resource_content ->> '$.resource.identifier[3].value' AS identifier_4,
    resource_content ->> '$.resource.interpretation[0].coding[0].code' AS interpretation_code,
    resource_content ->> '$.resource.interpretation[0].coding[0].system' AS interpretation_system,
    resource_content ->> '$.resource.interpretation[0].coding[0].display' AS interpretation_display,
    resource_content ->> '$.resource.referenceRange[0].low.value' AS reference_low,
    resource_content ->> '$.resource.referenceRange[0].high.value' AS reference_high,
    resource_content ->> '$.resource.referenceRange[0].text' AS reference_text,
    resource_content ->> '$.resource.referenceRange[0].appliesTo[0].text' AS appliesTo_text,
    resource_content ->> '$.resource.effectiveDateTime' AS effectiveDateTime,
    resource_content ->> '$.resource.id' AS observation_id,
    resource_content ->> '$.resource.status' AS status,
    resource_content ->> '$.resource.meta.lastUpdated' AS lastUpdated,
    resource_content ->> '$.resource.code.text' AS code_text,
    resource_content ->> '$.resource.note.text[0]' AS note_1,
    resource_content ->> '$.resource.note.text[1]' AS note_2,
    resource_content ->> '$.resource.note.text[2]' AS note_3,
    resource_content ->> '$.resource.basedOn[0].reference' AS basedOn_reference,
    resource_content ->> '$.resource.subject.display' AS subject_display,
    resource_content ->> '$.resource.subject.reference' AS subject_reference,
    resource_content ->> '$.resource.encounter.display' AS encounter_display,
    resource_content ->> '$.resource.category[0].coding[0].system' AS category_system,
    resource_content ->> '$.resource.category[0].coding[0].code' AS category_code,
    resource_content ->> '$.resource.category[0].coding[0].display' AS category_display,
    resource_content ->> '$.resource.code.coding[0].system' AS code_system,
    resource_content ->> '$.resource.code.coding[0].code' AS code,
    resource_content ->> '$.resource.code.coding[0].display' AS code_display,
    resource_content ->> '$.resource.subject.reference' AS subject_reference,
    CASE 
        WHEN resource_content ->> '$.resource.effectiveDateTime' IS NOT NULL THEN DATETIME(resource_content ->> '$.resource.effectiveDateTime')
        ELSE NULL
    END AS effective_date_time,
    CASE 
        WHEN resource_content ->> '$.resource.issued' IS NOT NULL THEN DATETIME(resource_content ->> '$.resource.issued')
        ELSE NULL
    END AS issued_date_time,
    resource_content ->> '$.resource.valueQuantity.value' AS value_quantity,
    resource_content ->> '$.resource.valueQuantity.unit' AS value_unit,
    resource_content ->> '$.resource.valueString' AS value_string,
    resource_content ->> '$.resource.valueCodeableConcept.coding[0].code' AS value_codeable_concept_code,
    resource_content ->> '$.resource.valueCodeableConcept.coding[0].display' AS value_codeable_concept_display
FROM
    observation_resources;

-- Extracts Encounter resources from FHIR bundles
-- Provides details about each Encounter resources.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_encounter;
CREATE VIEW fhir_v4_bundle_resource_encounter AS
    WITH Encounter_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Encounter'
)
SELECT
    resource_content ->> '$.resource.id' id,
    resource_content ->> '$.resource.meta.lastUpdated' lastUpdated,
    resource_content ->> '$.resource.type[0].coding.code' type_code,
    resource_content ->> '$.resource.type[0].coding.system' type_system,
    resource_content ->> '$.resource.type[0].coding.display' type_display,
    resource_content ->> '$.resource.class.code' class_code,
    resource_content ->> '$.resource.class.system' class_system,
    resource_content ->> '$.resource.class.display' class_display,
    resource_content ->> '$.resource.period.start' period_start,
    resource_content ->> '$.resource.period.end' period_end,
    resource_content ->> '$.resource.status' status,
    resource_content ->> '$.resource.subject.display' subject_display,
    resource_content ->> '$.resource.subject.reference' subject_reference,
    resource_content ->> '$.resource.location[0].location' location,
    resource_content ->> '$.resource.diagnosis[0].reference' diagnosis_reference,
    resource_content ->> '$.resource.extension[0].lineage meta data[0].url' extension_url,
    resource_content ->> '$.resource.extension[0].lineage meta data[0].valueString' extension_valueString,
    resource_content ->> '$.resource.identifier[0].value' identifier_value,
    resource_content ->> '$.resource.reasonCode[0].coding.code' reasonCode_code,
    resource_content ->> '$.resource.reasonCode[0].coding.system' reasonCode_system,
    resource_content ->> '$.resource.serviceType.coding[0].code' serviceType_code,
    resource_content ->> '$.resource.serviceType.coding[0].system' serviceType_system,
    resource_content ->> '$.resource.hospitalization.admitSource.coding.code' admitSource_code,
    resource_content ->> '$.resource.hospitalization.dischargeDisposition.coding[0].code' dischargeDisposition_code,
    resource_content ->> '$.resource.hospitalization.dischargeDisposition.coding[0].display' dischargeDisposition_display,
    resource_content ->> '$.resource.reasonReference[0].reference' reasonReference_reference,
    resource_content ->> '$.resource.participant.type.coding[0].code' participant_type_code,
    resource_content ->> '$.resource.resourceType' resourceType
FROM
    Encounter_resources;
 
-- Extracts Condition resources from FHIR bundles
-- Provides details about each Condition resources.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_condition;
CREATE VIEW fhir_v4_bundle_resource_condition AS
  WITH condition_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Condition'
)
  SELECT
  resource_content ->> '$.resource.id' id,
  resource_content ->> '$.resource.code.coding[0].code' code,
  resource_content ->> '$.resource.code.coding[0].system' code_system,
  resource_content ->> '$.resource.code.coding[0].display' code_display,
  resource_content ->> '$.resource.code.text' code_text,
  resource_content ->> '$.resource.meta.lastUpdated' lastUpdated,
  resource_content ->> '$.resource.subject.display' subject_display,
  resource_content ->> '$.resource.subject.reference' subject_reference,
  resource_content ->> '$.resource.encounter.display' encounter_display,
  resource_content ->> '$.resource.encounter.reference' encounter_reference,
  resource_content ->> '$.resource.onsetDateTime' onsetDateTime,
  resource_content ->> '$.resource.Slices for category.category:us-core.coding[0].code' category_code,
  resource_content ->> '$.resource.Slices for category.category:us-core.coding[0].system' category_system
FROM
   condition_resources;
  
DROP VIEW IF EXISTS fhir_v4_bundle_resource_service_request;
CREATE VIEW fhir_v4_bundle_resource_service_request AS
  WITH servicerequest_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'ServiceRequest'
)
 SELECT
  resource_content ->> '$.resource.id' id,
  resource_content ->> '$.resource.meta.lastUpdated' lastUpdated,
  resource_content ->> '$.resource.code.coding[0].code' code,
  resource_content ->> '$.resource.code.coding[0].system' code_system,
  resource_content ->> '$.resource.code.coding[0].display' code_display,
  resource_content ->> '$.resource.category.coding[0].code' category_code,
  resource_content ->> '$.resource.category.coding[0].system' category_code_system,
  resource_content ->> '$.resource.category.coding[0].display' category_code_display,    
  resource_content ->> '$.resource.intent' intent,
  resource_content ->> '$.resource.status' status,
  resource_content ->> '$.resource.subject.display' subject_display,
  resource_content ->> '$.resource.subject.reference' subject_reference,
  resource_content ->> '$.resource.encounter.display' encounter_display,
  resource_content ->> '$.resource.encounter.reference' encounter_reference,
  resource_content ->> '$.resource.occurrencePeriod.start' occurrencePeriod_start,
  resource_content ->> '$.resource.occurrencePeriod.end' occurrencePeriod_end,
  resource_content ->> '$.resource.occurrenceDateTime' occurrenceDateTime
FROM
     servicerequest_resources;

-- Extracts Procedure resources from FHIR bundles
-- Provides details about each Procedure resources.
DROP VIEW IF EXISTS fhir_v4_bundle_resource_procedure;
CREATE VIEW fhir_v4_bundle_resource_procedure AS
WITH procedure_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Procedure'
)
SELECT
    resource_content->>'$.resource.id' AS id,
    resource_content->>'$.resource.text' AS text,
    resource_content->>'$.resource.code.coding[0].code' AS code,
    resource_content->>'$.resource.code.coding[0].system' AS system,
    resource_content->>'$.resource.code.coding[0].display' AS display,
    resource_content->>'$.resource.meta.lastUpdated' AS lastUpdated,
    resource_content->>'$.resource.subject.display' AS subject_display,
    resource_content->>'$.resource.subject.reference' AS subject_reference,
    resource_content->>'$.resource.bodySite.coding[0].code' AS bodySite,
    resource_content->>'$.resource.encounter.display' AS encounter_display,
    resource_content->>'$.resource.encounter.reference' AS encounter_reference,
    resource_content->>'$.resource.extension[0].lineage meta data[0].url' AS lineage_meta_data_url,
    resource_content->>'$.resource.extension[0].lineage meta data[0].valueString' AS lineage_meta_data_value,
    resource_content->>'$.resource.performer[0].actor[0].reference' AS performer_reference,
    resource_content->>'$.resource.performer[0].actor[0].display' AS performer_display,
    resource_content->>'$.resource.identifier[0].value' AS identifier_value_0,
    resource_content->>'$.resource.identifier[1].value' AS identifier_value_1,
    resource_content->>'$.resource.identifier[2].value' AS identifier_value_2,
    resource_content->>'$.resource.identifier[3].value' AS identifier_value_3,
    resource_content->>'$.resource.identifier[4].value' AS identifier_value_4,
    resource_content->>'$.resource.performedDateTime' AS performedDateTime
FROM procedure_resources;

DROP VIEW IF EXISTS fhir_v4_bundle_resource_practitioner;
CREATE VIEW fhir_v4_bundle_resource_practitioner AS
WITH practitioner_resources AS (
    SELECT
        resource_content
    FROM
        fhir_v4_bundle_resource
    WHERE
        resource_type = 'Practitioner'
)
SELECT
    resource_content->>'$.resource.id' AS id,
    resource_content->>'$.resource.meta.lastUpdated' AS lastUpdated,
    resource_content->>'$.resource.extension[0].lineage_meta_data[0].url' AS lineage_meta_data_url_0,
    resource_content->>'$.resource.extension[0].lineage_meta_data[0].valueString' AS lineage_meta_data_value_0,
    resource_content->>'$.resource.extension[0].lineage_meta_data[1].url' AS lineage_meta_data_url_1,
    resource_content->>'$.resource.extension[0].lineage_meta_data[1].valueString' AS lineage_meta_data_value_1,
    resource_content->>'$.resource.extension[0].lineage_meta_data[2].url' AS lineage_meta_data_url_2,
    resource_content->>'$.resource.extension[0].lineage_meta_data[2].valueString' AS lineage_meta_data_value_2
FROM
    practitioner_resources;
