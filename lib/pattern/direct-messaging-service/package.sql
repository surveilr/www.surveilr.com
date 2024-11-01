-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as CCDA content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

-- TODO: will this help performance?
-- CREATE INDEX IF NOT EXISTS idx_resource_type ON uniform_resource ((content ->> '$.resourceType'));
-- CREATE INDEX IF NOT EXISTS idx_bundle_entry ON uniform_resource ((json_type(content -> '$.entry')));

-- CCDA Discovery and Enumeration Views
-- --------------------------------------------------------------------------------

-- Summary of the uniform_resource table
-- Provides a count of total rows, valid JSON rows, invalid JSON rows,
-- and potential CCDA v4 candidates and bundles based on JSON structure.
DROP VIEW IF EXISTS uniform_resource_summary;
CREATE VIEW uniform_resource_summary AS
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN json_valid(content) THEN 1 ELSE 0 END) AS valid_json_rows,
    SUM(CASE WHEN json_valid(content) THEN 0 ELSE 1 END) AS invalid_json_rows,
    SUM(CASE WHEN json_valid(content) AND content ->> '$.resourceType' IS NOT NULL THEN 1 ELSE 0 END) AS ccda_v4_candidates,
    SUM(CASE WHEN json_valid(content) AND json_type(content -> '$.entry') = 'array' THEN 1 ELSE 0 END) AS ccda_v4_bundle_candidates
FROM
    uniform_resource;


DROP VIEW IF EXISTS phimail_delivery_detail;
CREATE  VIEW phimail_delivery_detail AS
WITH json_data AS (
  SELECT
    uniform_resource_id,   
    json(content) AS content
  FROM
    uniform_resource
  WHERE
    nature = 'json'
    AND uri LIKE '%messageDeliveryStatus.json'
)
SELECT  
  substr(
    REPLACE(REPLACE(json_extract(value, '$.messageId'), '<', ''), '>', ''),
    instr(REPLACE(REPLACE(json_extract(value, '$.messageId'), '<', ''), '>', ''), '.') + 1
  ) AS direct_address,
  json_extract(value, '$.messageId') AS message_id,
  json_extract(value, '$.messageUId') AS message_uid,
  json_extract(value, '$.statusCode') AS status,
  json_extract(value, '$.recipient') AS recipient,
  value AS json_content
FROM
  json_data,
  json_each(json_data.content);

DROP VIEW IF EXISTS mail_content_detail;
CREATE  VIEW mail_content_detail AS
SELECT  
  json_extract(value, '$.recipient') AS recipient,
  json_extract(value, '$.sender') AS sender,
  -- Remove angle brackets from messageId
  REPLACE(REPLACE(json_extract(value, '$.messageId'), '<', ''), '>', '') AS message_id,
  json_extract(value, '$.messageUId') AS message_uid,  
  json_extract(value, '$.content.mimeType') AS content_mime_type,
  json_extract(value, '$.content.length') AS content_length,
  json_extract(value, '$.content.headers.date') AS content_date,
  json_extract(value, '$.content.headers.subject') AS content_subject,
  json_extract(value, '$.content.headers.from') AS content_from,
  json_extract(value, '$.content.headers.to') AS content_to,
  json_extract(value, '$.content.body') AS content_body,  
  json_extract(value, '$.status') AS status,
  -- Count the number of attachments
  json_array_length(json_extract(value, '$.attachments')) AS attachment_count
FROM
  uniform_resource,
  json_each(uniform_resource.content)
WHERE
  nature = 'json'
  AND uri LIKE '%_content.json';  


  
DROP VIEW IF EXISTS mail_content_attachment;
CREATE  VIEW mail_content_attachment AS
SELECT   
  json_extract(content_json.value, '$.messageUId') AS message_uid,   
  -- Extract attachment details
  json_extract(attachment_json.value, '$.filename') AS attachment_filename,  
  json_extract(attachment_json.value, '$.mimeType') AS attachment_mime_type,
  json_extract(attachment_json.value, '$.filePath') AS attachment_file_path  
  
FROM
  uniform_resource,
  json_each(uniform_resource.content) AS content_json,
  json_each(json_extract(content_json.value, '$.attachments')) AS attachment_json
WHERE
  nature = 'json'
  AND uri LIKE '%_content.json';

DROP VIEW IF EXISTS inbox;
CREATE VIEW inbox AS
SELECT 
  mcd.message_uid as id,
  mcd.content_from AS "from",
  mcd.recipient AS "to",
  mcd.content_subject AS subject,
  mcd.content_body AS content,
  mcd.content_date AS date,
  attachment_count as attachment_count
  
FROM 
  mail_content_detail mcd;

DROP VIEW IF EXISTS medical_record_basic_detail;
CREATE VIEW medical_record_basic_detail AS
SELECT
    COALESCE(substr(
        uri,
        instr(uri, 'ingest/') + length('ingest/'),
        instr(uri, '_') - instr(uri, 'ingest/') - length('ingest/')
    ), '') AS message_uid,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.id.@extension'), '') AS id,
    COALESCE(
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.given.#text'),
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.given'),
        ''
    ) AS first_name,
    COALESCE(
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.family.#text'),
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.family'),
        ''
    ) AS last_name,       
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.guardianPerson.name.given'), '') AS guardian_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.guardianPerson.name.family'), '') AS guardian_family_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.code.@displayName'), '') AS guardian_display_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.given'), '') AS performer_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.family'), '') AS performer_family,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.suffix.#text'), '') AS performer_suffix,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.functionCode.@displayName'), '') AS performer_function_display_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.effectiveTime.low.@value'), '') AS documentatin_from,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.effectiveTime.high.@value'), '') AS documentatin_to,


    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.administrativeGenderCode.@code'), '') AS gender_code,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.birthTime.@value'), '') AS birthTime,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.representedOrganization.name'), '') AS performer_organization,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.given'), '') AS author_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.family'), '') AS author_family,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.suffix.#text'), '') AS author_suffix,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].time.@value'), '') AS authored_on,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.assignedAuthoringDevice.manufacturerModelName'), '') AS author_manufacturer,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.assignedAuthoringDevice.softwareName'), '') AS author_software_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.representedOrganization.name'), '') AS author_organization,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].time.@value'), '') AS author_authored_on


  FROM
   uniform_resource_transform ;

DROP VIEW IF EXISTS patient_detail;
CREATE VIEW patient_detail AS
SELECT
    COALESCE(substr(
        uri,
        instr(uri, 'ingest/') + length('ingest/'),
        instr(uri, '_') - instr(uri, 'ingest/') - length('ingest/')
    ), '') AS message_uid,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.id.@extension'), '') AS id,
    COALESCE(
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.given.#text'),
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.given'),
        ''
    ) AS first_name,
    COALESCE(
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.family.#text'),
        json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.family'),
        ''
    ) AS last_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.streetAddressLine'), '') AS address,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.city'), '') AS city,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.state'), '') AS state,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.country'), '') AS country,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.postalCode'), '') AS postalCode,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.telecom.value'), '') AS patient,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.addr.@use'), '') AS addr_use, 
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.administrativeGenderCode.@code'), '') AS gender_code,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.birthTime.@value'), '') AS birthTime,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.raceCode.@displayName'), '') AS race_displayName,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.ethnicGroupCode.@displayName'), '') AS ethnic_displayName,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.languageCommunication.languageCode.@code'), '') AS language_code,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.guardianPerson.name.given'), '') AS guardian_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.guardianPerson.name.family'), '') AS guardian_family_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.code.@displayName'), '') AS guardian_display_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.given'), '') AS performer_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.family'), '') AS performer_family,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.assignedPerson.name.suffix.#text'), '') AS performer_suffix,
    COALESCE(json_extract(content, '$.ClinicalDocument.documentationOf.serviceEvent.performer.assignedEntity.representedOrganization.name'), '') AS performer_organization,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.given'), '') AS author_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.family'), '') AS author_family,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].assignedAuthor.assignedPerson.name.suffix.#text'), '') AS author_suffix,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[0].time.@value'), '') AS authored_on,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.assignedAuthoringDevice.manufacturerModelName'), '') AS author_manufacturer,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.assignedAuthoringDevice.softwareName'), '') AS author_software_name,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].assignedAuthor.representedOrganization.name'), '') AS author_organization,
    COALESCE(json_extract(content, '$.ClinicalDocument.author[1].time.@value'), '') AS author_authored_on,
    COALESCE(json_extract(content, '$.ClinicalDocument.id.@extension'), '') AS document_extension,
    COALESCE(json_extract(content, '$.ClinicalDocument.id.@root'), '') AS document_id,
    COALESCE(json_extract(content, '$.ClinicalDocument.versionNumber.@value'), '') AS version,
    COALESCE(json_extract(content, '$.ClinicalDocument.setId.@extension'), '') AS set_id_extension,
    COALESCE(json_extract(content, '$.ClinicalDocument.setId.@root'), '') AS set_id_root,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.name'), '') AS custodian,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.addr.streetAddressLine'), '') AS custodian_address_line1,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.addr.city'), '') AS custodian_city,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.addr.state'), '') AS custodian_state,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.addr.postalCode'), '') AS custodian_postal_code,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.addr.country'), '') AS custodian_country,
    COALESCE(json_extract(content, '$.ClinicalDocument.custodian.assignedCustodian.representedCustodianOrganization.telecom.@value'), '') AS custodian_telecom,
    COALESCE(json_extract(content, '$.ClinicalDocument.effectiveTime.@value'), '') AS custodian_time,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.name'), '') AS provider_organization,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.addr.streetAddressLine'), '') AS guardian_address,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.addr.city'), '') AS guardian_city,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.addr.state'), '') AS guardian_state,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.addr.postalCode'), '') AS guardian_zip,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.guardian.addr.country'), '') AS guardian_country,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.addr.streetAddressLine'), '') AS provider_address_line,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.addr.city'), '') AS provider_city,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.addr.state'), '') AS provider_state,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.addr.country'), '') AS provider_country,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.addr.postalCode'), '') AS provider_zip,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.id.@extension'), '') AS provider_extension,
    COALESCE(json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.providerOrganization.id.@root'), '') AS provider_root,
    COALESCE(json_extract(content, '$.ClinicalDocument.title'), '') AS document_title
FROM
   uniform_resource_transform ;

  DROP VIEW IF EXISTS author_detail;
  
  CREATE VIEW author_detail AS
  SELECT
      message_uid,
      COALESCE(GROUP_CONCAT(author_time), '') AS author_times,
      COALESCE(GROUP_CONCAT(author_id_extension), '') AS author_id_extensions,
      COALESCE(GROUP_CONCAT(author_id_root), '') AS author_id_roots,
      COALESCE(GROUP_CONCAT(author_code), '') AS author_codes,
      COALESCE(GROUP_CONCAT(author_displayName), '') AS author_displayNames,
      COALESCE(GROUP_CONCAT(author_codeSystem), '') AS author_codeSystems,
      COALESCE(GROUP_CONCAT(author_codeSystemName), '') AS author_codeSystemNames,
      COALESCE(GROUP_CONCAT(author_street), '') AS author_streets,
      COALESCE(GROUP_CONCAT(author_city), '') AS author_cities,
      COALESCE(GROUP_CONCAT(author_state), '') AS author_states,
      COALESCE(GROUP_CONCAT(author_postalCode), '') AS author_postalCodes,
      COALESCE(GROUP_CONCAT(author_country), '') AS author_countries,
      COALESCE(GROUP_CONCAT(author_telecom_use), '') AS author_telecom_uses,
      COALESCE(GROUP_CONCAT(author_telecom_value), '') AS author_telecom_values,
      COALESCE(GROUP_CONCAT(author_given_name), '') AS author_given_names,
      COALESCE(GROUP_CONCAT(author_family_name), '') AS author_family_names,
      COALESCE(GROUP_CONCAT(author_suffix), '') AS author_suffixes,
      COALESCE(GROUP_CONCAT(device_manufacturer), '') AS device_manufacturers,
      COALESCE(GROUP_CONCAT(device_software), '') AS device_software,
      COALESCE(GROUP_CONCAT(organization_name), '') AS organization_names,
      COALESCE(GROUP_CONCAT(organization_id_extension), '') AS organization_id_extensions,
      COALESCE(GROUP_CONCAT(organization_id_root), '') AS organization_id_roots,
      COALESCE(GROUP_CONCAT(organization_telecom), '') AS organization_telecoms,
      COALESCE(GROUP_CONCAT(organization_street), '') AS organization_streets,
      COALESCE(GROUP_CONCAT(organization_city), '') AS organization_cities,
      COALESCE(GROUP_CONCAT(organization_state), '') AS organization_states,
      COALESCE(GROUP_CONCAT(organization_postalCode), '') AS organization_postalCodes,
      COALESCE(GROUP_CONCAT(organization_country), '') AS organization_countries
  FROM (
      SELECT
          COALESCE(substr(
                  uri,
                  instr(uri, 'ingest/') + length('ingest/'),
                  instr(uri, '_') - instr(uri, 'ingest/') - length('ingest/')
              ), '') AS message_uid,
          json_extract(author.value, '$.time.@value') AS author_time,
          json_extract(author.value, '$.assignedAuthor.id.@extension') AS author_id_extension,
          json_extract(author.value, '$.assignedAuthor.id.@root') AS author_id_root,
          json_extract(author.value, '$.assignedAuthor.code.@code') AS author_code,
          json_extract(author.value, '$.assignedAuthor.code.@displayName') AS author_displayName,
          json_extract(author.value, '$.assignedAuthor.code.@codeSystem') AS author_codeSystem,
          json_extract(author.value, '$.assignedAuthor.code.@codeSystemName') AS author_codeSystemName,
          json_extract(author.value, '$.assignedAuthor.addr.streetAddressLine') AS author_street,
          json_extract(author.value, '$.assignedAuthor.addr.city') AS author_city,
          json_extract(author.value, '$.assignedAuthor.addr.state') AS author_state,
          json_extract(author.value, '$.assignedAuthor.addr.postalCode') AS author_postalCode,
          json_extract(author.value, '$.assignedAuthor.addr.country') AS author_country,
          json_extract(author.value, '$.assignedAuthor.telecom.@use') AS author_telecom_use,
          json_extract(author.value, '$.assignedAuthor.telecom.@value') AS author_telecom_value,
          json_extract(author.value, '$.assignedAuthor.assignedPerson.name.given') AS author_given_name,
          json_extract(author.value, '$.assignedAuthor.assignedPerson.name.family') AS author_family_name,
          json_extract(author.value, '$.assignedAuthor.assignedPerson.name.suffix.#text') AS author_suffix,
          json_extract(author.value, '$.assignedAuthor.assignedAuthoringDevice.manufacturerModelName') AS device_manufacturer,
          json_extract(author.value, '$.assignedAuthor.assignedAuthoringDevice.softwareName') AS device_software,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.name') AS organization_name,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.id.@extension') AS organization_id_extension,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.id.@root') AS organization_id_root,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.telecom.@value') AS organization_telecom,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.addr.streetAddressLine') AS organization_street,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.addr.city') AS organization_city,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.addr.state') AS organization_state,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.addr.postalCode') AS organization_postalCode,
          json_extract(author.value, '$.assignedAuthor.representedOrganization.addr.country') AS organization_country
      FROM 
          uniform_resource_transform,
          json_each(
              CASE 
                  WHEN json_type(content, '$.ClinicalDocument.author') = 'array' THEN json_extract(content, '$.ClinicalDocument.author')
                  ELSE json_array(json_extract(content, '$.ClinicalDocument.author'))
              END
          ) AS author
  ) AS subquery
  GROUP BY message_uid;

DROP VIEW IF EXISTS patient_observation;
CREATE VIEW patient_observation AS
 SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL;

DROP VIEW IF EXISTS patient_allergy;
CREATE VIEW patient_allergy AS
SELECT
   message_uid,
   section_title,
   section_code,
   json_extract(td.value, '$.td[0]') as substance,
   json_extract(td.value, '$.td[1].content.#text' ) as reaction,
   json_extract(td.value, '$.td[2]') as status 
FROM
   patient_observation,
   json_each(section_data) td 
WHERE
   section_code = '48765-2';

DROP VIEW IF EXISTS patient_medication;
CREATE VIEW patient_medication AS
SELECT
   message_uid,
   section_title,
   section_code,
   json_extract(td.value, '$[0].content.#text'),
   json_extract(td.value, '$[1]'),
   json_extract(td.value, '$[2]'),
   json_extract(td.value, '$[3]'),
   json_extract(td.value, '$[4]'),
   json_extract(td.value, '$[5]') 
FROM
   patient_observation,
   json_each(section_data) td 
WHERE
   section_code = '10160-0';

DROP VIEW IF EXISTS patient_lab_report;
CREATE VIEW patient_lab_report AS
SELECT
   message_uid,
   section_title,
   section_code,
   json_extract(td.value, '$.td.#text') as lab_test_header,
   COALESCE(json_extract(td.value, '$.td[0].content.#text'), json_extract(td.value, '$.td[0]')) as lab_test_name,
   json_extract(td.value, '$.td[1]') as lab_test_result 
FROM
   patient_observation,
   json_each(section_data) td 
WHERE
   section_code = '30954-2';   

DROP VIEW IF EXISTS patient_procedure;
CREATE VIEW patient_procedure AS
SELECT
   message_uid,
   section_title,
   section_code,
   json_extract(td.value, '$.td[0].#text') as description,
   json_extract(td.value, '$.td[1]') as date,
   json_extract(td.value, '$.td[2]') as status 
FROM
   patient_observation,
   json_each(section_data) td 
WHERE
   section_code = '47519-4';

DROP VIEW IF EXISTS patient_social_history;
CREATE VIEW patient_social_history AS
 SELECT
   message_uid,
   section_title,
   section_code,
   COALESCE(json_extract(td.value, '$[0]'),json_extract(td.value, '$.td[0].#text')) as history, 
            COALESCE(json_extract(td.value, '$[1].#text'),json_extract(td.value, '$.td[1]')) as observation, 
            COALESCE(json_extract(td.value, '$[2]'),json_extract(td.value, '$.td[2]')) as date
FROM
   patient_observation,
   json_each(section_data) td 
WHERE
   section_code = '29762-2';
DROP VIEW IF EXISTS patient_immunization_data;
CREATE VIEW patient_immunization_data AS
  WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT 
    message_uid,
    section_code,
    json_extract(td.value, '$.td[0]."#text"') AS vaccine,
    json_extract(td.value, '$.td[1]') AS date,
    json_extract(td.value, '$.td[2]') AS status
FROM
  component_detail,
  json_each(section_data) td
WHERE section_code='11369-6';


DROP VIEW IF EXISTS patient_medical_equipment;
CREATE VIEW patient_medical_equipment AS
  WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT 
    message_uid,
    section_code,
    json_extract(td.value, '$.td[0]') AS "Supply/Device",
    json_extract(td.value, '$.td[1]') AS "Date Supplied"
FROM
  component_detail,
  json_each(section_data) td
WHERE section_code='46264-8';

DROP VIEW IF EXISTS patient_insurance_provier;
CREATE VIEW patient_insurance_provier AS
  WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT 
    message_uid,
    section_code,
    json_extract(td.value, '$[0]') AS "Payer name",
    json_extract(td.value, '$[1]') AS "Policy type / Coverage type",
    json_extract(td.value, '$[2]') AS "Policy ID",
    json_extract(td.value, '$[3]') AS "Covered party ID",
    json_extract(td.value, '$[4]') AS "Policy Holder"
FROM
  component_detail,
  json_each(section_data) td
WHERE section_code='48768-6';


DROP VIEW IF EXISTS patient_plan_of_care;
CREATE VIEW patient_plan_of_care AS
  WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT 
    message_uid,
    section_code,
    json_extract(td.value, '$[0]') AS "Planned Activity",
    json_extract(td.value, '$[1]') AS "Planned Date"
   
FROM
  component_detail,
  json_each(section_data) td
WHERE section_code='18776-5';


DROP VIEW IF EXISTS patient_family_history;
CREATE VIEW patient_family_history AS
  WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text') AS component_title,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT 
    message_uid,
    section_code,    
    json_extract(component_title, '$.paragraph') as title,
    json_extract(td.value, '$.td[0]')

   
FROM
  component_detail dt, 
  json_each(section_data) td
WHERE section_code='10157-6';

 

DROP VIEW IF EXISTS patient_diagnosis;
CREATE VIEW patient_diagnosis AS
WITH component_detail AS (
  SELECT
    COALESCE(substr(
      uri,
      instr(uri, 'ingest/') + length('ingest/'),
      instr(substr(uri, instr(uri, 'ingest/') + length('ingest/')), '_') - 1
    ), '') AS message_uid,
    json_extract(value, '$.section.title') AS section_title,
    json_extract(value, '$.section.code.@code') AS section_code,
    json_extract(value, '$.section.text') AS component_title,
    json_extract(value, '$.section.text.table.tbody.tr') AS section_data
  FROM
    uniform_resource_transform,
    json_each(json_extract(content, '$.ClinicalDocument.component.structuredBody.component'))
  WHERE
    json_type(value, '$.section.title') IS NOT NULL
)
SELECT
  message_uid,
  section_title,
  section_code,
  CASE 
	WHEN section_code = '48765-2' THEN
      '<table><tr><th>Substance</th><th>Reaction</th><th>Status</th></tr>' ||
	    group_concat(
	      '<tr><td>' || json_extract(td.value, '$.td[0]') || '</td>' ||
	      '<td>' || json_extract(td.value, '$.td[1].content.#text') || '</td>' ||
	      '<td>' || json_extract(td.value, '$.td[2]') || '</td></tr>', ''
	    )||'</table>'
  WHEN section_code = '10160-0' THEN
    	group_concat('<table><tr><th>Medication</th><th>Directions</th><th>Start Date</th><th>Status</th><th>Indications</th><th>Fill Instructions</th></tr>
	    <tr>   
	    <td>'||json_extract(td.value, '$[0].content.#text')||'</td>
	    <td>'||json_extract(td.value, '$[1]')||'</td>
	    <td>'||json_extract(td.value, '$[2]')||'</td>
	    <td>'||json_extract(td.value, '$[3]')||'</td>
	    <td>'||json_extract(td.value, '$[4]')||'</td>
	    <td>'||json_extract(td.value, '$[5]')||'</td>
	 </tr></table>','')
 WHEN section_code = '30954-2' THEN
    '<table>' ||
        CASE 
            WHEN json_extract(td.value, '$.td.#text') IS NOT NULL or json_extract(td.value, '$.td.#text')!='' THEN
                '<tr><th colspan="2">' || COALESCE(json_extract(td.value, '$.td.#text'),'') || '</th></tr>'
            ELSE ''
        END ||
        group_concat(
            '<tr><td style="width:60%">' || 
            COALESCE(json_extract(td.value, '$.td[0].content.#text'), json_extract(td.value, '$.td[0]')) || 
            '</td><td>' || json_extract(td.value, '$.td[1]') || 
            '</td></tr>', 
        '') ||
    '</table>'
   WHEN section_code = '47519-4' THEN
    '<table><tr><th>Description</th><th>Date and Time (Range)</th><th>Status</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(td.value, '$.td[0].#text')|| 
            '</td><td>' || json_extract(td.value, '$.td[1]') || 
            '</td><td>' || json_extract(td.value, '$.td[2]') || 
            '</td></tr>', 
        '') ||
    '</table>'
   WHEN section_code = '29762-2' THEN
    '<table><tr><th>Social History Observation</th><th>Description</th><th>Dates Observed</th></tr>'||
        group_concat(
            '<tr><td>' || 
            COALESCE(json_extract(td.value, '$[0]'),json_extract(td.value, '$.td[0].#text')) || 
            '</td><td>' || COALESCE(json_extract(td.value, '$[1].#text'),json_extract(td.value, '$.td[1]')) || 
            '</td><td>' || COALESCE(json_extract(td.value, '$[2]'),json_extract(td.value, '$.td[2]')) || 
            '</td></tr>', 
        '') ||
    '</table>'
   WHEN section_code = '11369-6' THEN
    '<table><tr><th>Vaccine</th><th>Date</th><th>Status</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(td.value, '$.td[0]."#text"') || 
            '</td><td>' || json_extract(td.value, '$.td[1]') || 
            '</td><td>' || json_extract(td.value, '$.td[2]') || 
            '</td></tr>', 
        '') ||
    '</table>'
  WHEN section_code = '46264-8' THEN
    '<table><tr><th>Supply/Device</th><th>Date Supplied</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(td.value, '$.td[0]') || 
            '</td><td>' || json_extract(td.value, '$.td[1]')||            
            '</td></tr>', 
        '') ||
    '</table>'
   WHEN section_code = '48768-6' THEN
    '<table><tr><th>Payer name</th><th>Policy type / Coverage type</th><th>Policy ID</th><th>Covered party ID</th><th>Policy Holder</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(td.value, '$[0]') || 
            '</td><td>' || json_extract(td.value, '$[1]')|| 
            '</td><td>' || json_extract(td.value, '$[2]')|| 
            '</td><td>' || json_extract(td.value, '$[3]')|| 
            '</td><td>' || json_extract(td.value, '$[4]')|| 
            '</td></tr>', 
        '') ||
    '</table>'
  WHEN section_code = '18776-5' THEN
    '<table><tr><th>Planned Activity</th><th>Planned Date</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(td.value, '$[0]') || 
            '</td><td>' || json_extract(td.value, '$[1]')||            
            '</td></tr>', 
        '') ||
    '</table>'
  WHEN section_code = '10157-6' THEN
    '<table><tr><th>Patient</th><th>Diagnosis</th><th>Age At Onset</th></tr>'||
        group_concat(
            '<tr><td>' || 
            json_extract(component_title, '$.paragraph')|| 
            '</td><td>' || json_extract(td.value, '$.td[0]')|| 
            '</td><td>' || json_extract(td.value, '$.td[1]')|| 
            '</td></tr>', 
        '') ||
    '</table>'        
  END AS table_data
FROM
  component_detail,
  json_each(section_data) td
GROUP BY
  section_title, section_code,message_uid;   


DROP VIEW IF EXISTS patient_clinical_observation;
CREATE VIEW patient_clinical_observation AS
  with clinical_document as(
   SELECT
    json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.id.@extension') AS patient_id,
    json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.given') AS patient_first_name,
    json_extract(content, '$.ClinicalDocument.recordTarget.patientRole.patient.name.family') AS patient_last_name,
    json_extract(content, '$.ClinicalDocument.component.structuredBody.component[2].section.entry') AS json_data   
FROM
    uniform_resource_transform
 )   
 SELECT
    patient_id,    
    json_extract(json_data, '$.organizer.code.@displayName') AS observatin_name,    
    json_extract(value, '$.observation.code.@code') AS observation_code,
    json_extract(value, '$.observation.code.@displayName') AS observation_display_name,
    json_extract(value, '$.observation.value.@value') AS observation_value,
    json_extract(value, '$.observation.value.@unit') AS observation_unit,
    json_extract(json_data, '$.organizer.statusCode.@code') AS status_code,
    json_extract(json_data, '$.organizer.effectiveTime.low.@value') AS effective_time_low,
    json_extract(json_data, '$.organizer.effectiveTime.high.@value') AS effective_time_high,
    json_extract(value, '$.observation.effectiveTime.@value') AS observation_effective_time
FROM
    clinical_document,
    json_each(json_extract(json_data, '$.organizer.component'))
WHERE
    json_valid(json_data);
 
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.

DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS
SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    '/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
FROM sqlite_master tbl
JOIN pragma_table_info(tbl.name) col
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
FROM sqlite_master vw
JOIN pragma_table_info(vw.name) col
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, '/', '/', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', '/', 999, '/console', '/console/', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', '/console', 1, '/console/info-schema', '/console/info-schema/', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', '/console', 3, '/console/sqlpage-files', '/console/sqlpage-files/', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', '/console', 3, '/console/sqlpage-files/content.sql', '/console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', '/console', 3, '/console/sqlpage-nav', '/console/sqlpage-nav/', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', '/console', 2, '/console/notebooks', '/console/notebooks/', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title, ''/'' AS link;
              SELECT ''Console'' as title, ''/console'' AS link;
              SELECT ''Content'' as title, ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/fhir%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/ur', '/ur/', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', '/ur', 99, '/ur/info-schema.sql', '/ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', '/ur', 1, '/ur/uniform-resource-files.sql', '/ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', '/ur', 1, '/ur/uniform-resource-imap-account.sql', '/ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN ur_ingest_session_fs_path p ON ur.ingest_fs_path_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id
  WHERE ur.ingest_fs_path_id IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT ur.uniform_resource_id,
        iac.ur_ingest_session_imap_account_id,
        iac.email,
        iac.host,
        iacm.subject,
        iacm."from",
        iacm.message,
        iacm.date,
        iaf.ur_ingest_session_imap_acct_folder_id,
        iaf.ingest_account_id,
        iaf.folder_name,
        ur.size_bytes,
        ur.nature
  FROM uniform_resource ur
  LEFT JOIN ur_ingest_session_imap_acct_folder iaf ON ur.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  LEFT JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  WHERE ur.ingest_imap_acct_folder_id IS NOT NULL;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/orchestration', '/orchestration/', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', '/orchestration', 99, '/orchestration/info-schema.sql', '/orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
-- delete all /dms-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/dms%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/dms', '/dms/', 'Direct Protocol Email System', NULL, NULL, 'Email system with direct protocol', NULL),
    ('prime', '/dms', 1, '/dms/inbox.sql', '/dms/inbox.sql', 'Inbox', NULL, NULL, NULL, NULL),
    ('prime', '/dms', 2, '/dms/dispatched.sql', '/dms/dispatched.sql', 'Dispatched', NULL, NULL, NULL, NULL),
    ('prime', '/dms', 2, '/dms/failed.sql', '/dms/failed.sql', 'Failed', NULL, NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Resource Surveillance State Database (RSSD)",
  "icon": "",
  "favicon": "https://www.surveilr.com/favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "/",
  "menu_item": [
    {
      "link": "/",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Resource Surveillance State Database (RSSD)'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''/'' AS link,
       ''{"link":"/","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', ''/ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/ur''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/console''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || ''](/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), 2) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/console''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/console''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    content_web_ui_link_abbrev_md as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    content_web_ui_link_abbrev_md as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql](/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql)
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-nav''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
       ''['' || c.cell_name || ''](notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
       c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/ur''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/ur''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/ur''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''ur_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/ur/uniform-resource-files.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''Uniform Resources'' AS title,
      "Size (bytes)" as align_right,
      TRUE AS sort,
      TRUE AS search,
      TRUE AS hover,
      TRUE AS striped_rows,
      TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
 LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-account.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/ur/uniform-resource-imap-account.sql'') as contents;
    ;

select
    ''title''   as component,
    ''Mailbox'' as contents;
-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''Uniform Resources'' AS title,
      "Size (bytes)" as align_right,
      TRUE AS sort,
      TRUE AS search,
      TRUE AS hover,
      TRUE AS striped_rows,
      TRUE AS small,
      ''email'' AS markdown;
SELECT
  ''['' || email || ''](/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
    FROM uniform_resource_imap
    GROUP BY ur_ingest_session_imap_account_id
    ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-folder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
SELECT
    ''Home'' as title,
    ''/''    as link;
SELECT
    ''Uniform Resource'' as title,
    ''/ur'' as link;
SELECT
    ''Uniform Resources (IMAP)'' as title,
    ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
    ''Folder'' as title,
    ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id::TEXT as link;

SELECT
    ''title''   as component,
    (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id=$imap_account_id::TEXT) as contents;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''Uniform Resources'' AS title,
      "Size (bytes)" as align_right,
      TRUE AS sort,
      TRUE AS search,
      TRUE AS hover,
      TRUE AS striped_rows,
      TRUE AS small,
      ''folder'' AS markdown;
SELECT ''['' || folder_name || ''](/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_account_id=$imap_account_id::TEXT
  GROUP BY ur_ingest_session_imap_acct_folder_id
  ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT
''breadcrumb'' AS component;
SELECT
    ''Home'' AS title,
    ''/''    AS link;
SELECT
    ''Uniform Resource'' AS title,
    ''/ur'' AS link;
SELECT
    ''Uniform Resources (IMAP)'' AS title,
    ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
 ''Folder'' AS title,
 "uniform-resource-imap-folder.sql?imap_account_id="|| ur_ingest_session_imap_account_id AS link
FROM uniform_resource_imap
WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
 folder_name AS title,
 "uniform-resource-imap-mail-list.sql?folder_id="|| ur_ingest_session_imap_acct_folder_id AS link
FROM uniform_resource_imap
WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

 SELECT
    ''title''   as component,
    (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''Uniform Resources'' AS title,
      "Size (bytes)" as align_right,
      TRUE AS sort,
      TRUE AS search,
      TRUE AS hover,
      TRUE AS striped_rows,
      TRUE AS small;
SELECT subject,"from",
  CASE
    WHEN ROUND(julianday(''now'') - julianday(date)) = 0 THEN ''Today''
    WHEN ROUND(julianday(''now'') - julianday(date)) = 1 THEN ''1 day ago''
    WHEN ROUND(julianday(''now'') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
    WHEN ROUND(julianday(''now'') - julianday(date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
    WHEN ROUND(julianday(''now'') - julianday(date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(date)) / 30) AS INT) || '' months ago''
    ELSE CAST(ROUND((julianday(''now'') - julianday(date)) / 365) AS INT) || '' years ago''
END AS "Relative Time",
strftime(''%Y-%m-%d'', substr(date, 1, 19)) as date
FROM uniform_resource_imap
WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
ORDER BY uniform_resource_id
LIMIT $limit
OFFSET $offset;
SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/orchestration''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''/orchestration''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/dms''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/dms''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/dms''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/inbox.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/dms/inbox.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/dms/inbox.sql'') as contents;
    ;

SELECT ''table'' AS component,
      ''subject'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT id,
"from",
 ''['' || subject || ''](/dms/email-detail.sql?id='' || id || '')'' AS "subject",
date
from inbox;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/email-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
select
''breadcrumb'' as component;
select
    ''Home'' as title,
    ''/''    as link;
select
    ''Direct Protocol Email System'' as title,
    ''/dms/'' as link;
select
    ''inbox'' as title,
    ''/dms/inbox.sql'' as link;
select
    "subject" as title from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);

select
    ''datagrid'' as component;
select
    ''From'' as title,
    "from" as "description" from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
select
    ''To'' as title,
    "to" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
select
    ''Subject'' as title,
    "subject" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
select
    ''Date'' as title,
    "date" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);

select ''datagrid'' as component;
  SELECT content AS description FROM inbox WHERE id = $id::TEXT;
  SELECT ''table'' AS component, ''attachment'' AS markdown;
  SELECT
      CASE
          WHEN attachment_filename LIKE ''%.xml'' OR attachment_mime_type = ''application/xml''
          THEN ''['' || attachment_filename || '']('' || attachment_file_path || '' "download")'' || '' | '' || ''[View Details](/dms/patient-detail.sql?id='' || message_uid || '' "View Details")''
          ELSE ''['' || attachment_filename || '']('' || attachment_file_path || '' "download")''
      END AS "attachment"
  FROM mail_content_attachment
  WHERE CAST(message_uid AS TEXT) = CAST($id AS TEXT);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/patient-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
    SELECT
    ''breadcrumb'' as component;
    SELECT
        ''Home'' as title,
        ''/''    as link;
    SELECT
        ''Direct Protocol Email System'' as title,
        ''/dms/'' as link;
    SELECT
        ''inbox'' as title,
        ''/dms/inbox.sql'' as link;
    SELECT
        ''/dms/email-detail.sql?id='' || id as link,
        "subject" as title from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
    SELECT
        first_name as title from patient_detail where CAST(message_uid AS TEXT)=CAST($id AS TEXT) ;

   SELECT ''html'' AS component, ''
  <link rel="stylesheet" href="/assets/style.css">
  <h2>'' || document_title || ''</h2>
  <table class="patient-summary">
    <tr>
      <th>Patient</th>
      <td>'' || first_name || '' '' || last_name || ''<br>
          <b>Patient-ID</b>: '' || id || '' (SSN) <b>Date of Birth</b>: '' || substr(birthTime, 7, 2) ||
      CASE
        WHEN strftime(''%d'', birthTime) IN (''01'', ''21'', ''31'') THEN ''st''
        WHEN strftime(''%d'', birthTime) IN (''02'', ''22'') THEN ''nd''
        WHEN strftime(''%d'', birthTime) IN (''03'', ''23'') THEN ''rd''
        ELSE ''th''
      END || '' '' ||
      CASE
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''1'' THEN ''January''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''2'' THEN ''February''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''3'' THEN ''March''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''4'' THEN ''April''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''5'' THEN ''May''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''6'' THEN ''June''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''7'' THEN ''July''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''8'' THEN ''August''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''9'' THEN ''September''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''10'' THEN ''October''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''11'' THEN ''November''
        WHEN cast(substr(birthTime, 5, 2) AS text) = ''12'' THEN ''December''
        ELSE ''Invalid Month''
      END || '' '' || substr(birthTime, 1, 4) || '' <b>Gender</b>: Female</td>
    </tr>
    <tr>
      <th>Guardian</th>
      <td>'' || guardian_name || '' '' || guardian_family_name || '' - '' || guardian_display_name || ''</td>
    </tr>
    <tr>''
    ||
    CASE
      WHEN performer_name != '''' THEN ''
      <th>Documentation Of</th>
      <td><b>Performer</b>: '' || performer_name || '' '' || performer_family || '' '' || performer_suffix || '' <b>Organization</b>: '' || performer_organization || ''</td>
    </tr>''
      ELSE ''''
    END ||''
    <tr>
      <th>Author</th>
      <td>'' || ad.author_given_names || '' '' || ad.author_family_names || '' '' || ad.author_suffixes || '', <b>Authored On</b>: '' ||
      CASE
        WHEN substr(author_times, 7, 2) = ''01'' THEN substr(author_times, 9, 2) || ''st ''
        WHEN substr(author_times, 7, 2) = ''02'' THEN substr(author_times, 9, 2) || ''nd ''
        WHEN substr(author_times, 7, 2) = ''03'' THEN substr(author_times, 9, 2) || ''rd ''
        ELSE substr(author_times, 9, 2) || ''th ''
      END ||
      CASE
        WHEN substr(author_times, 5, 2) = ''01'' THEN ''January ''
        WHEN substr(author_times, 5, 2) = ''02'' THEN ''February ''
        WHEN substr(author_times, 5, 2) = ''03'' THEN ''March ''
        WHEN substr(author_times, 5, 2) = ''04'' THEN ''April ''
        WHEN substr(author_times, 5, 2) = ''05'' THEN ''May ''
        WHEN substr(author_times, 5, 2) = ''06'' THEN ''June ''
        WHEN substr(author_times, 5, 2) = ''07'' THEN ''July ''
        WHEN substr(author_times, 5, 2) = ''08'' THEN ''August ''
        WHEN substr(author_times, 5, 2) = ''09'' THEN ''September ''
        WHEN substr(author_times, 5, 2) = ''10'' THEN ''October ''
        WHEN substr(author_times, 5, 2) = ''11'' THEN ''November ''
        WHEN substr(author_times, 5, 2) = ''12'' THEN ''December ''
        ELSE ''Invalid Month''
      END ||
      substr(author_times, 1, 4) || ''</td>
    </tr>
    '' ||
    CASE
      WHEN ad.organization_names != '''' THEN ''
      <tr>
        <th>Author</th>
        <td>'' || ad.device_manufacturers || '' - '' || ad.device_software || '', Organization: '' || ad.organization_names || '', <b>Authored On</b>: '' ||
        CASE
          WHEN substr(author_times, 7, 2) = ''01'' THEN substr(author_times, 9, 2) || ''st ''
          WHEN substr(author_times, 7, 2) = ''02'' THEN substr(author_times, 9, 2) || ''nd ''
          WHEN substr(author_times, 7, 2) = ''03'' THEN substr(author_times, 9, 2) || ''rd ''
          ELSE substr(author_times, 9, 2) || ''th ''
        END ||
        CASE
          WHEN substr(author_times, 5, 2) = ''01'' THEN ''January ''
          WHEN substr(author_times, 5, 2) = ''02'' THEN ''February ''
          WHEN substr(author_times, 5, 2) = ''03'' THEN ''March ''
          WHEN substr(author_times, 5, 2) = ''04'' THEN ''April ''
          WHEN substr(author_times, 5, 2) = ''05'' THEN ''May ''
          WHEN substr(author_times, 5, 2) = ''06'' THEN ''June ''
          WHEN substr(author_times, 5, 2) = ''07'' THEN ''July ''
          WHEN substr(author_times, 5, 2) = ''08'' THEN ''August ''
          WHEN substr(author_times, 5, 2) = ''09'' THEN ''September ''
          WHEN substr(author_times, 5, 2) = ''10'' THEN ''October ''
          WHEN substr(author_times, 5, 2) = ''11'' THEN ''November ''
          WHEN substr(author_times, 5, 2) = ''12'' THEN ''December ''
        END ||
        substr(author_times, 1, 4) || ''</td>
      </tr>''
      ELSE ''''
    END || ''
  </table>'' AS html
FROM patient_detail pd
JOIN author_detail ad ON pd.message_uid = ad.message_uid
WHERE CAST(pd.message_uid AS TEXT) = CAST($id AS TEXT);

    SELECT ''html'' AS component, ''
      <link rel="stylesheet" href="/assets/style.css">
      <table class="patient-details">
      <tr>
      <th class="no-border-bottom" style="background-color: #f2f2f2"><b>Document</b></th>
      <td class="no-border-bottom" style="width:30%">
        ID: ''|| document_extension||'' (''|| document_id||'')<br>
        Version:''|| version||''<br>
        Set-ID: ''|| set_id_extension||''
      </td>
      <th style="background-color: #f2f2f2"><b>Created On</b></th>
      <td class="no-border-bottom"> '' ||
      CASE
          WHEN substr(custodian_time, 7, 2) = ''01'' THEN substr(custodian_time, 9, 2) || ''st ''
          WHEN substr(custodian_time, 7, 2) = ''02'' THEN substr(custodian_time, 9, 2) || ''nd ''
          WHEN substr(custodian_time, 7, 2) = ''03'' THEN substr(custodian_time, 9, 2) || ''rd ''
          ELSE substr(custodian_time, 9, 2) || ''th ''
      END ||
      CASE
          WHEN substr(custodian_time, 5, 2) = ''01'' THEN ''January ''
          WHEN substr(custodian_time, 5, 2) = ''02'' THEN ''February ''
          WHEN substr(custodian_time, 5, 2) = ''03'' THEN ''March ''
          WHEN substr(custodian_time, 5, 2) = ''04'' THEN ''April ''
          WHEN substr(custodian_time, 5, 2) = ''05'' THEN ''May ''
          WHEN substr(custodian_time, 5, 2) = ''06'' THEN ''June ''
          WHEN substr(custodian_time, 5, 2) = ''07'' THEN ''July ''
          WHEN substr(custodian_time, 5, 2) = ''08'' THEN ''August ''
          WHEN substr(custodian_time, 5, 2) = ''09'' THEN ''September ''
          WHEN substr(custodian_time, 5, 2) = ''10'' THEN ''October ''
          WHEN substr(custodian_time, 5, 2) = ''11'' THEN ''November ''
          WHEN substr(custodian_time, 5, 2) = ''12'' THEN ''December ''
      END ||
      substr(custodian_time, 1, 4) || ''</td>
      </tr>
      <tr>
        <th style="background-color: #f2f2f2"><b>Custodian</b></th>
        <td>''|| custodian||''</td>
        <th style="background-color: #f2f2f2"><b>Contact Details</b></th>
        <td>
          Workplace: ''|| custodian_address_line1||'' ''|| custodian_city||'', ''|| custodian_state||'' ''|| custodian_postal_code||''<br> ''|| custodian_country||''<br>
          Tel Workplace: ''|| custodian_telecom||''
        </td>
      </tr>
    </table>''AS html
    FROM patient_detail
    WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);

    SELECT ''html'' AS component, ''
    <link rel="stylesheet" href="/assets/style.css">
    <style>
      .patient-details {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
        font-family: Arial, sans-serif;
      }

    </style>

    <table class="patient-details">
      <tr>
        <th class="no-border-bottom" ><b>Patient</b></th>
        <td class="no-border-bottom" style="width:30%">''|| first_name||''  ''|| last_name||''</td>
        <th class="no-border-bottom" ><b>Contact Details</b></th>
        <td class="no-border-bottom">''|| address||'' ''|| city||'', ''|| state||'' ''|| postalCode||'' ''|| addr_use||''</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Date of Birth</b></th>
        <td class="no-border-bottom">''|| strftime(''%Y-%m-%d'', substr(birthTime, 1, 4) || ''-'' || substr(birthTime, 5, 2) || ''-'' || substr(birthTime, 7, 2))||'' </td>
        <th class="no-border-bottom" ><b>Gender</b></th>
        <td class="no-border-bottom">''|| CASE
        WHEN gender_code = ''F'' THEN ''Female''
        WHEN gender_code = ''M'' THEN ''Male''
        ELSE ''Other''
      END||''</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Race</b></th>
        <td class="no-border-bottom">''||race_displayName||''</td>
        <th class="no-border-bottom" ><b>Ethnicity</b></th>
        <td class="no-border-bottom">''||ethnic_displayName||''</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Patient-IDs</b></th>
        <td class="no-border-bottom">''||id||''</td>
        <th class="no-border-bottom" ><b>Language Communication</b></th>
        <td class="no-border-bottom">''||
        CASE
            WHEN language_code IS NOT NULL THEN language_code
            ELSE ''Not Given''
        END
        ||''</td>
      </tr>

      <tr>
        <th class="no-border-bottom" ><b>Guardian</b></th>
        <td class="no-border-bottom">''||guardian_name||'' ''||guardian_family_name||'' ''||guardian_display_name||''</td>
        <th class="no-border-bottom" ><b>Contact Details</b></th>
        <td class="no-border-bottom">''|| guardian_address||'', ''|| guardian_city||'' ,''|| guardian_state||'', ''|| guardian_zip||'' ,''|| guardian_country||''</td>
      </tr>

      <tr>
        <th class="no-border-bottom" ><b>Provider Organization</b></th>
        <td class="no-border-bottom">''||provider_organization||''</td>
        <th class="no-border-bottom" ><b>Contact Details (Organization)</b></th>
        <td class="no-border-bottom">''|| provider_address_line||'', ''|| provider_city||'' ,''|| provider_state||'', ''|| provider_country||'' ,''|| provider_zip||''</td>
      </tr>


    </table> ''AS html
  FROM patient_detail
  WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);


  select ''html'' as component;
  select ''<link rel="stylesheet" href="/assets/style.css">
    <details class="accordian-head">
  <summary>''||section_title||''</summary>
  <div class="patient-details">
    <div>''||table_data||''</div>
  </div>
  </details>'' as html
  FROM patient_diagnosis
  WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/dispatched.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/dms/dispatched.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/dms/dispatched.sql'') as contents;
    ;

SELECT ''table'' as component,
      ''subject'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT * from phimail_delivery_detail where status=''dispatched'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'dms/failed.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/dms/failed.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/dms/failed.sql'') as contents;
    ;

SELECT ''table'' as component,
      ''subject'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT * from phimail_delivery_detail where status!=''dispatched'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
