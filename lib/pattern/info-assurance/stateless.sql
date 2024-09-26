DROP VIEW IF EXISTS threat_model;

CREATE VIEW IF NOT EXISTS threat_model AS
WITH json_data AS (
    SELECT
        json_extract(threats.value, '$."a:Value"."b:Id"') AS "id",
        json_extract(threats.value, '$."a:Value"."b:ChangedBy"') AS "changed_by",
        json_extract(threats.value, '$."a:Value"."b:ModifiedAt"') AS "last_modified",
        json_extract(threats.value, '$."a:Value"."b:State"') AS "state",
        json_each.value AS kv_value
    FROM 
        uniform_resource_transform,
        json_each(json_extract(content, '$.ThreatModel.ThreatInstances."a:KeyValueOfstringThreatpc_P0_PhOB"')) AS threats,
        json_each(json_extract(threats.value, '$."a:Value"."b:Properties"."a:KeyValueOfstringstring"'))
)
SELECT
    id,
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'Title' THEN json_extract(kv_value, '$."a:Value"') END) AS "title",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatCategory' THEN json_extract(kv_value, '$."a:Value"') END) AS "category",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatShortDescription' THEN json_extract(kv_value, '$."a:Value"') END) AS "short_description",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatDescription' THEN json_extract(kv_value, '$."a:Value"') END) AS "description",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'InteractionString' THEN json_extract(kv_value, '$."a:Value"') END) AS "interaction",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'Priority' THEN json_extract(kv_value, '$."a:Value"') END) AS "priority",
    state,
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'StateInformation' THEN json_extract(kv_value, '$."a:Value"') END) AS "justification",
    "changed_by",
    "last_modified"
FROM
    json_data
GROUP BY
    id, "changed_by", "last_modified", state;

DROP VIEW IF EXISTS web_application;

CREATE VIEW IF NOT EXISTS web_application AS
SELECT DISTINCT
    json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
FROM 
   uniform_resource_transform,
    json_each(
        CASE 
            WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array' 
            THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
            ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
        END
    ) AS drawing_surface,
    json_each(
        json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
    ) AS border
WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilEllipse'
    AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'Web Application';

DROP VIEW IF EXISTS managed_application;

CREATE VIEW IF NOT EXISTS managed_application AS
SELECT DISTINCT
    json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
FROM 
    uniform_resource_transform,
    json_each(
        CASE 
            WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array' 
            THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
            ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
        END
    ) AS drawing_surface,
    json_each(
        json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
    ) AS border
WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilEllipse' 
    AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'Managed Application';
    
CREATE VIEW IF NOT EXISTS sql_database AS
SELECT DISTINCT
    json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
FROM 
 uniform_resource_transform,
    json_each(
        CASE 
            WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array' 
            THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
            ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
        END
    ) AS drawing_surface,
    json_each(
        json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
    ) AS border
WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilParallelLines'
    AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'SQL Database';

CREATE VIEW IF NOT EXISTS boundaries AS
SELECT DISTINCT
    json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS boundary
    FROM 
    uniform_resource_transform,
    json_each(
        CASE 
            WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array' 
            THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
            ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
        END
    ) AS drawing_surface,
    json_each(
        json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
    ) AS border
    WHERE 
    json_extract(border.value, '$."a:Value"."@i:type"') = 'BorderBoundary'
    AND (
        json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') IN (
            'Other Browsers Boundaries', 
            'CorpNet Trust Boundary', 
            'Generic Trust Border Boundary'
        )
    )
    AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') NOT LIKE '%.%.%.%'
    AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') LIKE '%Boundar%';