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
 