-- ---------------------------------------------------------------------------------
-- Script to extract, denormalize, and cache FHIR data from JSONB in surveilr RSSDs.
-- ---------------------------------------------------------------------------------
-- This "stateful" pattern assumes that "stateless" views have been created which 
-- capture logic that might be slow to query so tables are created which act like
-- materialized views.
-- ---------------------------------------------------------------------------------

-- Cache for the fhir_v4_bundle_resource_patient view.
-- Caches detailed information about Patient resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_patient_cached;
CREATE TABLE fhir_v4_bundle_resource_patient_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_patient;

-- Calculates the average age of patients
-- Uses the birth date from the cached FHIR Patient resources to compute the average age with better performance.
DROP VIEW IF EXISTS fhir_v4_patient_age_avg_cached;
CREATE VIEW fhir_v4_patient_age_avg_cached AS
WITH patient_birth_dates AS (
    SELECT
        birth_date
    FROM
        fhir_v4_bundle_resource_patient_cached
    WHERE
        birth_date IS NOT NULL
)
SELECT
    AVG((julianday('now') - julianday(birth_date)) / 365.25) AS average_age
FROM
    patient_birth_dates;


-- TODO: add indexes to help improve performance

-- Cache for the fhir_v4_bundle_resource_encounter view.
-- Caches detailed information about Encounter resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_encounter_cached;
CREATE TABLE fhir_v4_bundle_resource_encounter_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_encounter;

-- Cache for the fhir_v4_bundle_resource_condition view.
-- Caches detailed information about condition resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_condition_cached;
CREATE TABLE fhir_v4_bundle_resource_condition_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_condition;

-- Cache for the fhir_v4_bundle_resource_service_request view.
-- Caches detailed information about Service request resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_service_request_cached;
CREATE TABLE fhir_v4_bundle_resource_service_request_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_service_request;


-- Cache for the fhir_v4_bundle_resource_procedure view.
-- Caches detailed information about Procedure resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_procedure_cached;
CREATE TABLE fhir_v4_bundle_resource_procedure_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_procedure;

  
-- Cache for the fhir_v4_bundle_resource_practitioner view.
-- Caches detailed information about Practioner resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_practitioner_cached;
CREATE TABLE fhir_v4_bundle_resource_practitioner_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_practitioner;

  -- Cache for the fhir_v4_bundle_resource_practitioner view.
-- Caches detailed information about Practioner resources extracted from FHIR bundles.
DROP TABLE IF EXISTS fhir_v4_bundle_resource_observation_cached;
CREATE TABLE fhir_v4_bundle_resource_observation_cached AS 
  SELECT * FROM fhir_v4_bundle_resource_observation;