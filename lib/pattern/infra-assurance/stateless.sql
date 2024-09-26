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

DROP VIEW IF EXISTS border_boundary;
CREATE VIEW border_boundary AS
   SELECT 
    json_extract(outer.value, '$.a:Value.Properties.a:anyType[0].b:DisplayName') AS displayName,
    json_extract(inner.value, '$.b:Value.#text') AS name,
    json_extract(outer.value, '$.a:Value.@i:type') as type
FROM 
  uniform_resource_transform,
  json_each(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel.Borders.a:KeyValueOfguidanyType')) AS outer,
  json_each(json_extract(outer.value, '$.a:Value.Properties.a:anyType')) AS inner
WHERE 
  json_array_length(json_extract(outer.value, '$.a:Value.Properties.a:anyType')) >= 2 AND json_extract(inner.value, '$.b:Value.#text') IS NOT NULL
  AND json_extract(outer.value, '$.a:Value.@i:type') = 'BorderBoundary' AND json_extract(inner.value, '$.b:Value.#text') LIKE '%Boundary';

DROP VIEW IF EXISTS asset_service_view;
CREATE VIEW asset_service_view AS
SELECT
  asser.name,ast.name as server,ast.organization_id,astyp.value as asset_type,astyp.asset_service_type_id,bnt.name as boundary,asser.description,asser.port,asser.experimental_version,asser.production_version,asser.latest_vendor_version,asser.resource_utilization,asser.log_file,asser.url,
  asser.vendor_link,asser.installation_date,asser.criticality,o.name AS owner,sta.value as tag, ast.criticality as asset_criticality,ast.asymmetric_keys_encryption_enabled as asymmetric_keys,
  ast.cryptographic_key_encryption_enabled as cryptographic_key,ast.symmetric_keys_encryption_enabled as symmetric_keys
  FROM asset_service asser
  INNER JOIN asset_service_type astyp ON astyp.asset_service_type_id = asser.asset_service_type_id
  INNER JOIN asset ast ON ast.asset_id = asser.asset_id
  INNER JOIN organization o ON o.organization_id=ast.organization_id
  INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
  INNER JOIN boundary bnt ON bnt.boundary_id=ast.boundary_id;

DROP VIEW IF EXISTS server_data;
CREATE VIEW server_data AS
WITH base_query AS (
    SELECT 
        ur.device_id,  
        d.name AS device_name,
        CASE 
            WHEN json_extract(outer.value, '$.name') LIKE '/%' 
            THEN substr(json_extract(outer.value, '$.name'), 2) 
            ELSE json_extract(outer.value, '$.name') 
        END AS displayName,
        json_extract(outer.value, '$.status') as status
    FROM 
        uniform_resource AS ur
        JOIN device AS d ON ur.device_id = d.device_id,
        json_each(ur.content) AS outer
    WHERE 
        ur.nature = 'json' 
        AND ur.uri = 'listContainers'
)
SELECT 
    av.*,bq.status
FROM 
    base_query bq
JOIN 
    asset_service_view av 
ON 
    av.name = bq.displayName 
    AND av.server LIKE '%' || bq.device_name || '%';


DROP VIEW IF EXISTS security_incident_response_view;
CREATE VIEW security_incident_response_view AS
SELECT i.title AS incident,i.incident_date,ast.name as asset_name,ic.value AS category,s.value AS severity,
    p.value AS priority,it.value AS internal_or_external,i.location,i.it_service_impacted,
    i.impacted_modules,i.impacted_dept,p1.person_first_name || ' ' || p1.person_last_name AS reported_by,
    p2.person_first_name || ' ' || p2.person_last_name AS reported_to,i.brief_description,
    i.detailed_description,p3.person_first_name || ' ' || p3.person_last_name AS assigned_to,
    i.assigned_date,i.investigation_details,i.containment_details,i.eradication_details,i.business_impact,
    i.lessons_learned,ist.value AS status,i.closed_date,i.feedback_from_business,i.reported_to_regulatory,i.report_date,i.report_time,
    irc.description AS root_cause_of_the_issue,p4.value AS probability_of_issue,irc.testing_analysis AS testing_for_possible_root_cause_analysis,
    irc.solution,p5.value AS likelihood_of_risk,irc.modification_of_the_reported_issue,irc.testing_for_modified_issue,irc.test_results
    FROM incident i
    INNER JOIN asset ast ON ast.asset_id = i.asset_id
    INNER JOIN incident_category ic ON ic.incident_category_id = i.category_id
    INNER JOIN severity s ON s.code = i.severity_id
    INNER JOIN priority p ON p.code = i.priority_id
    INNER JOIN incident_type it ON it.incident_type_id = i.internal_or_external_id
    INNER JOIN person p1 ON p1.person_id = i.reported_by_id
    INNER JOIN person p2 ON p2.person_id = i.reported_to_id
    INNER JOIN person p3 ON p3.person_id = i.assigned_to_id
    INNER JOIN incident_status ist ON ist.incident_status_id = i.status_id
    LEFT JOIN incident_root_cause irc ON irc.incident_id = i.incident_id
    LEFT JOIN priority p4 ON p4.code = irc.probability_id
    LEFT JOIN priority p5 ON p5.code = irc.likelihood_of_risk_id;

DROP VIEW IF EXISTS security_impact_analysis_view;
CREATE VIEW security_impact_analysis_view AS
SELECT v.short_name as vulnerability, ast.name as security_risk,te.title as security_threat,
    ir.impact as impact_of_risk,pc.controls as proposed_controls,p1.value as impact_level,
    p2.value as risk_level,sia.existing_controls,pr.value as priority,sia.reported_date,
    pn1.person_first_name || ' ' || pn1.person_last_name AS reported_by,
    pn2.person_first_name || ' ' || pn2.person_last_name AS responsible_by
    FROM security_impact_analysis sia
    INNER JOIN vulnerability v ON v.vulnerability_id = sia.vulnerability_id
    INNER JOIN asset_risk ar ON ar.asset_risk_id = sia.asset_risk_id
    INNER JOIN asset ast ON ast.asset_id = ar.asset_id
    INNER JOIN threat_event te ON te.threat_event_id = ar.threat_event_id
    INNER JOIN impact_of_risk ir ON ir.security_impact_analysis_id = sia.security_impact_analysis_id
    INNER JOIN proposed_controls pc ON pc.security_impact_analysis_id = sia.security_impact_analysis_id
    INNER JOIN probability p1 ON p1.code = sia.impact_level_id
    INNER JOIN probability p2 ON p2.code = sia.risk_level_id
    INNER JOIN priority pr ON pr.code = sia.priority_id
    INNER JOIN person pn1 ON pn1.person_id = sia.reported_by_id
    INNER JOIN person pn2 ON pn2.person_id = sia.responsible_by_id;