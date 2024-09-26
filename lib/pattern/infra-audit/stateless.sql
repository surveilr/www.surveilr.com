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
        
DROP VIEW IF EXISTS tenant_based_control_regime;
CREATE VIEW tenant_based_control_regime AS SELECT tcr.control_regime_id,
      tcr.tenant_id,
      cr.name,
      cr.parent_id,
      cr.description,
      cr.logo_url,
      cr.status,
      cr.created_at,
      cr.updated_at
FROM tenant_control_regime tcr
JOIN control_regime cr on cr.control_regime_id = tcr.control_regime_id;


DROP VIEW IF EXISTS audit_session_control;
CREATE VIEW audit_session_control
      AS
        SELECT c.control_group_id,
          c.control_id,
          c.question,
          c.display_order,
          c.control_code,
          ac.audit_control_id,
          ac.control_audit_status AS status,
          ac.audit_session_id
        FROM audit_control ac
        JOIN control c ON c.control_id = ac.control_id;


DROP VIEW IF EXISTS audit_session_list;
CREATE VIEW audit_session_list AS SELECT 
      a.audit_session_id,
      a.control_regime_id as audit_type_id, 
      a.title, 
      a.due_date,
      a.tenant_id,
      a.created_at,
      a.updated_at,
      a.contact_person as contact_person_id,
      a.status,
      a.deleted_at,
      a.deleted_by,
      cr.logo_url,
      cr.name as audit_type,
      cr.parent_id as control_regime_id,
      cr2.name as control_regime_name,
      p.party_name AS tenant_name,
      p2.party_name AS contact_person,
      (CAST(SUM(CASE WHEN ac.control_audit_status = 'Accepted by External Auditor' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(ac.audit_control_id)) * 100 AS percentage_of_completion
      FROM audit_session a
      JOIN control_regime cr ON cr.control_regime_id = a.control_regime_id
      JOIN control_regime cr2 on cr2.control_regime_id = cr.parent_id
      JOIN party p ON p.party_id = a.tenant_id
      JOIN party p2 ON p2.party_id = a.contact_person
      JOIN audit_control ac ON ac.audit_session_id = a.audit_session_id
      GROUP BY 
      a.audit_session_id,
      a.control_regime_id, 
      a.title, 
      a.due_date,
      a.tenant_id,
      a.created_at,
      a.updated_at,
      a.deleted_at,
      a.deleted_by,
      cr.logo_url,
      cr.parent_id,
      cr2.name,
      cr.name,
      p.party_name;


DROP VIEW IF EXISTS query_result;
CREATE VIEW IF NOT EXISTS query_result AS
          WITH RECURSIVE extract_blocks AS (
            SELECT
              uniform_resource_id,
              uri,
              device_id,
              content_digest,
              nature,
              size_bytes,
              last_modified_at,
              created_at,
              updated_at,
              substr(content, instr(content, '<QueryResult'), instr(content || '</QueryResult>', '</QueryResult>') - instr(content, '<QueryResult') + length('</QueryResult>')) AS query_content,
              substr(content, instr(content, '</QueryResult>') + length('</QueryResult>')) AS remaining_content
            FROM
              uniform_resource
            WHERE
              content LIKE '%<QueryResult%' AND nature='mdx'
            UNION ALL
            SELECT
              uniform_resource_id,
              uri,
              device_id,
              content_digest,
              nature,
              size_bytes,
              last_modified_at,
              created_at,
              updated_at,
              substr(remaining_content, instr(remaining_content, '<QueryResult'), instr(remaining_content || '</QueryResult>', '</QueryResult>') - instr(remaining_content, '<QueryResult') + length('</QueryResult>')) AS query_content,
              substr(remaining_content, instr(remaining_content, '</QueryResult>') + length('</QueryResult>')) AS remaining_content
          FROM
              extract_blocks
            WHERE
              remaining_content LIKE '%<QueryResult%' AND nature='mdx'
        ),
        latest_entries AS (
            SELECT
              uri,
              MAX(last_modified_at) AS latest_last_modified_at
            FROM
              uniform_resource
            WHERE
              nature = 'mdx'
            GROUP BY
              uri
        )
        SELECT
          eb.uniform_resource_id,
          eb.uri,
          eb.device_id,
          eb.content_digest,
          eb.nature,
          eb.size_bytes,
          eb.last_modified_at,
          eb.created_at,
          eb.updated_at,
          eb.query_content
        FROM
          extract_blocks eb
        JOIN
          latest_entries le
        ON
          eb.uri = le.uri AND eb.last_modified_at = le.latest_last_modified_at;


DROP VIEW IF EXISTS audit_session_info;
CREATE VIEW audit_session_info AS
      SELECT a.audit_session_id,
      a.title,
      a.due_date,
      a.created_at,
      a.updated_at,
      a.tenant_id,
      a.status,
      a.deleted_at,
      a.deleted_by,
      p1.party_name AS contact_person,
      p2.party_name AS tenant_name,
      crg.control_regime_id as audit_type_id,
      crg.name AS audit_type,
      cr2.name AS control_regime_name,
      cr2.control_regime_id
      FROM audit_session a
      JOIN party p1 ON p1.party_id = a.contact_person
      JOIN control_regime crg ON crg.control_regime_id = a.control_regime_id
      JOIN control_regime cr2 on cr2.control_regime_id = crg.parent_id
      JOIN party p2 on p2.party_id = a.tenant_id;


DROP VIEW IF EXISTS evidence_query_result;
CREATE VIEW evidence_query_result AS
        WITH extracted_data AS (
          SELECT
            uniform_resource_id,
            uri,
            device_id,
            content_digest,
            nature,
            size_bytes,
            last_modified_at,
            created_at,
            updated_at,
            CASE
              WHEN INSTR(query_content, 'title="') > 0 THEN
                SUBSTR(query_content,
                  INSTR(query_content, 'title="') + LENGTH('title="'),
                  INSTR(SUBSTR(query_content, INSTR(query_content, 'title="') + LENGTH('title="')), '"') - 1
                )
              ELSE NULL
            END AS title,
            CASE
              WHEN INSTR(query_content, 'gridStyle="') > 0 THEN
                SUBSTR(query_content,
                  INSTR(query_content, 'gridStyle="') + LENGTH('gridStyle="'),
                  INSTR(SUBSTR(query_content, INSTR(query_content, 'gridStyle="') + LENGTH('gridStyle="')), '"') - 1
                )
              ELSE NULL
            END AS grid_style,
            CASE
              WHEN INSTR(query_content, 'connection="') > 0 THEN
                SUBSTR(query_content,
                  INSTR(query_content, 'connection="') + LENGTH('connection="'),
                  INSTR(SUBSTR(query_content, INSTR(query_content, 'connection="') + LENGTH('connection="')), '"') - 1
                )
              ELSE NULL
            END AS connection,
            CASE
              WHEN INSTR(query_content, 'language="') > 0 THEN
                SUBSTR(query_content,
                  INSTR(query_content, 'language="') + LENGTH('language="'),
                  INSTR(SUBSTR(query_content, INSTR(query_content, 'language="') + LENGTH('language="')), '"') - 1
                )
              ELSE NULL
            END AS language,
            CASE
              WHEN INSTR(query_content, '{\`') > 0 THEN
                SUBSTR(query_content,
                    INSTR(query_content, '{\`') + LENGTH('{\`'),
                    INSTR(SUBSTR(query_content, INSTR(query_content, '{\`') + LENGTH('{\`')), '\`}') - LENGTH('\`') - 1
                )
              ELSE NULL
            END AS query_content,
            CASE
              WHEN INSTR(query_content, 'satisfies="') > 0 THEN
                SUBSTR(query_content,
                  INSTR(query_content, 'satisfies="') + LENGTH('satisfies="'),
                  INSTR(SUBSTR(query_content, INSTR(query_content, 'satisfies="') + LENGTH('satisfies="')), '"') - 1
                )
              ELSE NULL
            END AS satisfies
          FROM query_result
        ),
        split_satisfies AS (
          SELECT
            uniform_resource_id,
            uri,
            device_id,
            content_digest,
            nature,
            size_bytes,
            last_modified_at,
            created_at,
            updated_at,
            title,
            grid_style,
            connection,
            language,
            query_content,
            TRIM(json_each.value) AS fii,
            hex(substr(title, 1, 50)) AS short_title_hex,
            ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title) AS row_num
          FROM extracted_data,
          json_each('["' || REPLACE(satisfies, ', ', '","') || '"]')
        )
        SELECT
          uniform_resource_id,
          uri,
          device_id,
          content_digest,
          nature,
          size_bytes,
          last_modified_at,
          created_at,
          updated_at,
          title,
          grid_style,
          connection,
          language,
          query_content,
          fii,
          uniform_resource_id || '-' || short_title_hex || '-0001-' || printf('%04d', row_num) AS evidence_id
        FROM split_satisfies;


DROP VIEW IF EXISTS audit_session_control_group;
CREATE VIEW audit_session_control_group AS
      SELECT cg.control_group_id,
      cg.title AS control_group_name,
      cg.display_order,
      a.audit_session_id
      FROM control_group cg
      JOIN control c ON c.control_group_id = cg.control_group_id
      JOIN audit_control ac ON ac.control_id = c.control_id
      JOIN audit_session a ON a.audit_session_id = ac.audit_session_id
      GROUP BY cg.control_group_id,
      cg.title,
      a.audit_session_id;
  

DROP VIEW IF EXISTS audit_control_evidence;
CREATE VIEW audit_control_evidence AS 
      SELECT
      acpe.audit_control_id, 
      acpe.status AS evidence_status,
      p.policy_id,
      p.uri,
      p.title,
      p.description,
      p.fii,
      e.evidence_id,
      e.evidence,
      e.title AS evidence_title,
      e.type AS evidence_type
    FROM audit_control_policy_evidence acpe
    JOIN audit_control ac ON ac.audit_control_id = acpe.audit_control_id
    JOIN control c ON c.control_id = ac.control_id
    JOIN policy p ON p.policy_id = acpe.policy_id 
    AND (
      REPLACE(c.fii, ' ', '') = p.fii
      OR ',' || REPLACE(c.fii, ' ', '') || ',' LIKE '%,' || p.fii || ',%'
    )
    LEFT JOIN evidence e ON e.evidence_id = acpe.evidence_id;


DROP VIEW IF EXISTS policy;
CREATE VIEW policy AS
        WITH rankedpolicies AS
          (SELECT u.uniform_resource_id || '-' || u.device_id AS policy_id,
          u.uniform_resource_id,
          u.device_id,
          u.uri,
          u.content_digest,
          u.nature,
          u.size_bytes,
          u.last_modified_at,
          Json_extract(u.frontmatter, '$.title') AS title,
          Json_extract(u.frontmatter, '$.description') AS description,
          Json_extract(u.frontmatter, '$.publishDate') AS publishDate,
          Json_extract(u.frontmatter, '$.publishBy') AS publishBy,
          Json_extract(u.frontmatter, '$.classification') AS classification,
          Json_extract(u.frontmatter, '$.documentVersion') AS documentVersion,
          Json_extract(u.frontmatter, '$.documentType') AS documentType,
          Json_extract(u.frontmatter, '$.approvedBy') AS approvedBy,
          json_each.value AS fii,
          u.created_at,
          u.updated_at,
          Row_number()
          OVER (partition BY u.uri, json_each.value ORDER BY u.last_modified_at DESC) AS rn
          FROM  uniform_resource u,
          Json_each(Json_extract(u.frontmatter, '$.satisfies'))
          WHERE  u.nature = 'md' OR u.nature = 'mdx')
        SELECT policy_id,uniform_resource_id,
          device_id,
          uri,
          content_digest,
          nature,
          size_bytes,
          last_modified_at,
          title,
          description,
          publishdate,
          publishby,
          classification,
          documentversion,
          documenttype,
          approvedby,
          fii,
          created_at,
          updated_at
        FROM rankedpolicies
        WHERE rn = 1;


DROP VIEW IF EXISTS evidence;
CREATE VIEW evidence AS
      SELECT eqr.evidence_id,
        eqr.uniform_resource_id,
        eqr.uri,
        eqr.title,
        eqr.query_content AS evidence,
        eqr.fii,
        'Query Result' AS type
      FROM evidence_query_result eqr

      UNION ALL

      SELECT ea.evidence_id,
        ea.uniform_resource_id,
        ea.uri,
        ea.title,
        ea.extracted AS evidence,
        ea.fii,
        'Anchor Tag' AS type
      FROM evidence_anchortag ea

      UNION ALL

      SELECT ei.evidence_id,
        ei.uniform_resource_id,
        ei.uri,
        ei.title,
        ei.extracted AS evidence,
        ei.fii,
        'Image Tag' AS type
      FROM evidence_imagetag ei
      
      UNION ALL

      SELECT ec.evidence_id,
        ec.uniform_resource_id,
        ec.uri,
        ec.title,
        ec.extracted AS evidence,
        ec.fii,
        'Evidence Tag' AS type
      FROM evidence_customtag ec
      
      UNION ALL

      SELECT eer.evidence_id,
        eer.uniform_resource_id,
        eer.uri,
        eer.title,
        eer.extracted AS evidence,
        eer.fii,
        'EvidenceResult' AS type
      FROM evidence_evidenceresult eer;

DROP VIEW IF EXISTS evidence_evidenceresult;
CREATE VIEW evidence_evidenceresult AS
  WITH RECURSIVE CTE AS (
      SELECT 
          frontmatter->>'title' AS title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          INSTR(content, '<EvidenceResult') AS evidence_result_start,
          INSTR(content, '</EvidenceResult>') AS evidence_result_end,
          SUBSTR(content, INSTR(content, '<EvidenceResult'), 
                INSTR(content, '</EvidenceResult>') - INSTR(content, '<EvidenceResult') + LENGTH('</EvidenceResult>')) AS extracted,
          SUBSTR(content, INSTR(content, '</EvidenceResult>') + LENGTH('</EvidenceResult>')) AS remaining_content,
          last_modified_at,
          created_at,
          uniform_resource_id
      FROM
          uniform_resource
      WHERE
          INSTR(content, '<EvidenceResult') > 0  AND (nature='mdx' OR nature='md')
      UNION ALL
      SELECT
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          INSTR(remaining_content, '<EvidenceResult') AS evidence_result_start,
          INSTR(remaining_content, '</EvidenceResult>') AS evidence_result_end,
          SUBSTR(remaining_content, INSTR(remaining_content, '<EvidenceResult'), 
                INSTR(remaining_content, '</EvidenceResult>') - INSTR(remaining_content, '<EvidenceResult') + LENGTH('</EvidenceResult>')) AS extracted,
          SUBSTR(remaining_content, INSTR(remaining_content, '</EvidenceResult>') + LENGTH('</EvidenceResult>')) AS remaining_content,
          last_modified_at,
          created_at,
          uniform_resource_id
      FROM
          CTE
      WHERE
          INSTR(remaining_content, '<EvidenceResult') > 0 AND INSTR(remaining_content, '</EvidenceResult>') > INSTR(remaining_content, '<EvidenceResult')
  ),
  satisfies_split AS (
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          SUBSTR(
              extracted,
              INSTR(extracted, 'satisfies="') + LENGTH('satisfies="'),
              CASE
                  WHEN INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') > 0 THEN
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') - 1
                  ELSE
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"') - 1
              END
          ) AS satisfies,
          SUBSTR(
              extracted,
              INSTR(extracted, 'satisfies="') + LENGTH('satisfies="') + CASE
                  WHEN INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') > 0 THEN
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',')
                  ELSE
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"')
              END + 1
          ) AS rest_satisfies
      FROM
          CTE
      WHERE
          INSTR(extracted, 'satisfies="') > 0
      UNION ALL
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          TRIM(SUBSTR(rest_satisfies, 1, INSTR(rest_satisfies, ',') - 1)) AS satisfies,
          SUBSTR(rest_satisfies, INSTR(rest_satisfies, ',') + 1) AS rest_satisfies
      FROM
          satisfies_split
      WHERE
          INSTR(rest_satisfies, ',') > 0
      UNION ALL
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          TRIM(rest_satisfies) AS satisfies,
          NULL AS rest_satisfies
      FROM
          satisfies_split
      WHERE
          INSTR(rest_satisfies, ',') = 0 AND LENGTH(TRIM(rest_satisfies)) > 0
  ),
  latest_entries AS (
              SELECT
                uri,
                MAX(last_modified_at) AS latest_last_modified_at
              FROM
                uniform_resource
              GROUP BY
                uri
          )
  SELECT 
  ss.uniform_resource_id,
  ss.uri,
  ss.nature,
  ss.device_id,
  ss.content_digest,
      ss.title,
      ss.content,
      ss.extracted,
      CASE
          WHEN INSTR(satisfies, '"') > 0 THEN SUBSTR(satisfies, 1, INSTR(satisfies, '"') - 1)
          ELSE satisfies
      END AS fii,
      ss.last_modified_at,
      ss.created_at,
      ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title) AS row_num,
      uniform_resource_id || '-' || hex(substr(title, 1, 50))|| '-0005-' || printf('%04d', ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title)) AS evidence_id
  FROM
    satisfies_split ss
    JOIN 
 latest_entries le
        ON
          ss.uri = le.uri AND ss.last_modified_at = le.latest_last_modified_at
  WHERE
    satisfies IS NOT NULL AND satisfies != '' AND fii LIKE '%FII%' 
 group by fii
 ORDER BY
    ss.title, fii;


DROP VIEW IF EXISTS evidence_customtag;
CREATE VIEW evidence_customtag AS
      WITH RECURSIVE CTE AS (
          -- Base case: Initial extraction
          SELECT
              uniform_resource_id,
              uri,
              nature,
              device_id,
              content_digest,
              frontmatter->>'title' AS title,
              content,
              INSTR(content, '<evidence') AS evidence_start,
              INSTR(SUBSTR(content, INSTR(content, '<evidence')), '/>') AS evidence_end,
              SUBSTR(content, INSTR(content, '<evidence'), INSTR(SUBSTR(content, INSTR(content, '<evidence')), '/>') + 1) AS extracted,
              SUBSTR(content, INSTR(content, '<evidence') + INSTR(SUBSTR(content, INSTR(content, '<evidence')), '/>') + 1) AS remaining_content ,
              last_modified_at,
              created_at
          FROM uniform_resource 
          WHERE INSTR(content, '<evidence') > 0
          UNION ALL
          SELECT
              uniform_resource_id,
              uri,
              nature,
              device_id,
              content_digest,
              title,
              content,
              INSTR(remaining_content, '<evidence') AS evidence_start,
              INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<evidence')), '/>') AS evidence_end,
              SUBSTR(remaining_content, INSTR(remaining_content, '<evidence'), INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<evidence')), '/>') + 1) AS extracted,
              SUBSTR(remaining_content, INSTR(remaining_content, '<evidence') + INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<evidence')), '/>') + 1) AS remaining_content,
              last_modified_at,
              created_at
          FROM CTE
          WHERE INSTR(remaining_content, '<evidence') > 0
      ),
      ExtractSatisfies AS (
          SELECT
              uniform_resource_id,
              uri,
              nature,
              device_id,
              content_digest,
              title,
              content,
              extracted,
              
              -- Extract the value of the satisfies attribute
              TRIM(SUBSTR(extracted,
                          INSTR(extracted, 'satisfies="') + LENGTH('satisfies="'),
                          INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"') - 1
                         )
              ) AS satisfies_value,
              last_modified_at,
              created_at
          FROM CTE
          WHERE extracted IS NOT NULL AND INSTR(LOWER(extracted), 'satisfies="') > 0
      ),
      SplitSatisfies AS (
          SELECT
              uniform_resource_id,
              uri,
              nature,
              device_id,
              content_digest,
              title,
              content,
              extracted,
              
              TRIM(SUBSTR(satisfies_value, 1, INSTR(satisfies_value || ',', ',') - 1)) AS satisfy,
              CASE
                  WHEN INSTR(satisfies_value, ',') > 0 THEN
                      TRIM(SUBSTR(satisfies_value, INSTR(satisfies_value, ',') + 1))
                  ELSE
                      NULL
              END AS remaining_satisfies,
              last_modified_at,
              created_at
          FROM ExtractSatisfies
          WHERE satisfies_value IS NOT NULL AND satisfies_value != ''
          UNION ALL
          SELECT
              uniform_resource_id,
              uri,
              nature,
              device_id,
              content_digest,
              title,
              content,
              extracted,
              TRIM(SUBSTR(remaining_satisfies, 1, INSTR(remaining_satisfies || ',', ',') - 1)) AS satisfy,
              CASE
                  WHEN INSTR(remaining_satisfies, ',') > 0 THEN
                      TRIM(SUBSTR(remaining_satisfies, INSTR(remaining_satisfies, ',') + 1))
                  ELSE
                      NULL
              END AS remaining_satisfies,
              last_modified_at,
              created_at
          FROM SplitSatisfies
          WHERE remaining_satisfies IS NOT NULL AND remaining_satisfies != ''
      ),
      latest_entries AS (
            SELECT
              uri,
              MAX(last_modified_at) AS latest_last_modified_at
            FROM
              uniform_resource
            GROUP BY
              uri
        )
      SELECT
          ss.uniform_resource_id,
          ss.uri,
          ss.nature,
          ss.device_id,
          ss.content_digest,
          ss.title,
          ss.content,
          ss.extracted,
          satisfy AS fii,
          ss.last_modified_at,
          ss.created_at,
          ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title) AS row_num,
     uniform_resource_id || '-' || hex(substr(title, 1, 50))|| '-0004-' || printf('%04d', ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title)) AS evidence_id    
      FROM SplitSatisfies ss
      JOIN 
 latest_entries le
        ON
          ss.uri = le.uri AND ss.last_modified_at = le.latest_last_modified_at
      WHERE satisfy IS NOT NULL AND satisfy != ''
      group BY fii,ss.title order by ss.title;


DROP VIEW IF EXISTS evidence_anchortag;
CREATE VIEW evidence_anchortag AS WITH RECURSIVE CTE AS (
    SELECT 
        frontmatter->>'title' AS title,
        uri,
        nature,
         device_id,
         content_digest,
        content,
        INSTR(content, '<a') AS href_start,
        INSTR(content, '</a>') AS href_end,
        SUBSTR(content, INSTR(content, '<a'), 
               INSTR(content, '</a>') - INSTR(content, '<a') + LENGTH('</a>')) AS extracted,
        SUBSTR(content, INSTR(content, '</a>') + LENGTH('</a>')) AS remaining_content,
        last_modified_at,
        created_at,
        uniform_resource_id
    FROM
        uniform_resource
    WHERE
        INSTR(content, '<a') > 0  AND (nature='mdx' OR nature='md')
    UNION ALL
    SELECT
        title,
        uri,
        nature,
        device_id,
        content_digest,
        content,
        INSTR(remaining_content, '<a') AS href_start,
        INSTR(remaining_content, '</a>') AS href_end,
        SUBSTR(remaining_content, INSTR(remaining_content, '<a'), 
               INSTR(remaining_content, '</a>') - INSTR(remaining_content, '<a') + LENGTH('</a>')) AS extracted,
        SUBSTR(remaining_content, INSTR(remaining_content, '</a>') + LENGTH('</a>')) AS remaining_content,
         last_modified_at,
         created_at,
         uniform_resource_id
    FROM
        CTE
    WHERE
        INSTR(remaining_content, '<a') > 0 AND INSTR(remaining_content, '</a>') > INSTR(remaining_content, '<a')
  ),
  satisfies_split AS (
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          SUBSTR(
              extracted,
              INSTR(extracted, 'satisfies="') + LENGTH('satisfies="'),
              CASE
                  WHEN INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') > 0 THEN
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') - 1
                  ELSE
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"') - 1
              END
          ) AS satisfies,
          SUBSTR(
              extracted,
              INSTR(extracted, 'satisfies="') + LENGTH('satisfies="') + CASE
                  WHEN INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',') > 0 THEN
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), ',')
                  ELSE
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"')
              END + 1
          ) AS rest_satisfies
      FROM
          CTE
      WHERE
          INSTR(extracted, 'satisfies="') > 0
      UNION ALL
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          TRIM(SUBSTR(rest_satisfies, 1, INSTR(rest_satisfies, ',') - 1)) AS satisfies,
          SUBSTR(rest_satisfies, INSTR(rest_satisfies, ',') + 1) AS rest_satisfies
      FROM
          satisfies_split
      WHERE
          INSTR(rest_satisfies, ',') > 0
      UNION ALL
      SELECT 
          title,
          uri,
          nature,
          device_id,
          content_digest,
          content,
          extracted,
          last_modified_at,
          created_at,
          uniform_resource_id,
          TRIM(rest_satisfies) AS satisfies,
          NULL AS rest_satisfies
      FROM
          satisfies_split
      WHERE
          INSTR(rest_satisfies, ',') = 0 AND LENGTH(TRIM(rest_satisfies)) > 0
  ),
  latest_entries AS (
              SELECT
                uri,
                MAX(last_modified_at) AS latest_last_modified_at
              FROM
                uniform_resource
              GROUP BY
                uri
          )
  SELECT 
  ss.uniform_resource_id,
  ss.uri,
  ss.nature,
  ss.device_id,
  ss.content_digest,
      ss.title,
      ss.content,
      ss.extracted,
      CASE
          WHEN INSTR(satisfies, '"') > 0 THEN SUBSTR(satisfies, 1, INSTR(satisfies, '"') - 1)
          ELSE satisfies
      END AS fii,
      ss.last_modified_at,
      ss.created_at,
      ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title) AS row_num,
      uniform_resource_id || '-' || hex(substr(title, 1, 50))|| '-0002-' || printf('%04d', ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title)) AS evidence_id
  FROM
      satisfies_split ss
      JOIN 
  latest_entries le
          ON
            ss.uri = le.uri AND ss.last_modified_at = le.latest_last_modified_at
  WHERE
      satisfies IS NOT NULL AND satisfies != '' AND fii LIKE '%FII%' 
  group by ss.title,fii
  ORDER BY
      ss.title, fii;


DROP VIEW IF EXISTS evidence_imagetag;
CREATE VIEW evidence_imagetag AS
  WITH RECURSIVE CTE AS (
      -- Base case: Initial extraction
      SELECT
          uniform_resource_id,
          uri,
          nature,
          device_id,
          content_digest,
          frontmatter->>'title' AS title,
          content,
          INSTR(content, '<img') AS imgtag_start,
          INSTR(SUBSTR(content, INSTR(content, '<img')), '/>') AS imgtag_end,
          SUBSTR(content, INSTR(content, '<img'), INSTR(SUBSTR(content, INSTR(content, '<img')), '/>') + 1) AS extracted,
          SUBSTR(content, INSTR(content, '<img') + INSTR(SUBSTR(content, INSTR(content, '<img')), '/>') + 1) AS remaining_content ,
          last_modified_at,
          created_at
      FROM uniform_resource 
      WHERE INSTR(content, '<img') > 0
      UNION ALL
      SELECT
          uniform_resource_id,
          uri,
          nature,
          device_id,
          content_digest,
          title,
          content,
          INSTR(remaining_content, '<img') AS imgtag_start,
          INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<img')), '/>') AS imgtag_end,
          SUBSTR(remaining_content, INSTR(remaining_content, '<img'), INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<img')), '/>') + 1) AS extracted,
          SUBSTR(remaining_content, INSTR(remaining_content, '<img') + INSTR(SUBSTR(remaining_content, INSTR(remaining_content, '<img')), '/>') + 1) AS remaining_content,
          last_modified_at,
          created_at
      FROM CTE
      WHERE INSTR(remaining_content, '<img') > 0
  ),
  ExtractSatisfies AS (
      SELECT
          uniform_resource_id,
          uri,
          nature,
          device_id,
          content_digest,
          title,
          content,
          extracted,
          
          -- Extract the value of the satisfies attribute
          TRIM(SUBSTR(extracted,
                      INSTR(extracted, 'satisfies="') + LENGTH('satisfies="'),
                      INSTR(SUBSTR(extracted, INSTR(extracted, 'satisfies="') + LENGTH('satisfies="')), '"') - 1
                    )
          ) AS satisfies_value,
          last_modified_at,
          created_at
      FROM CTE
      WHERE extracted IS NOT NULL AND INSTR(LOWER(extracted), 'satisfies="') > 0
  ),
  SplitSatisfies AS (
      SELECT
          uniform_resource_id,
          uri,
          nature,
          device_id,
          content_digest,
          title,
          content,
          extracted,
          
          TRIM(SUBSTR(satisfies_value, 1, INSTR(satisfies_value || ',', ',') - 1)) AS satisfy,
          CASE
              WHEN INSTR(satisfies_value, ',') > 0 THEN
                  TRIM(SUBSTR(satisfies_value, INSTR(satisfies_value, ',') + 1))
              ELSE
                  NULL
          END AS remaining_satisfies,
          last_modified_at,
          created_at
      FROM ExtractSatisfies
      WHERE satisfies_value IS NOT NULL AND satisfies_value != ''
      UNION ALL
      SELECT
          uniform_resource_id,
          uri,
          nature,
          device_id,
          content_digest,
          title,
          content,
          extracted,
          TRIM(SUBSTR(remaining_satisfies, 1, INSTR(remaining_satisfies || ',', ',') - 1)) AS satisfy,
          CASE
              WHEN INSTR(remaining_satisfies, ',') > 0 THEN
                  TRIM(SUBSTR(remaining_satisfies, INSTR(remaining_satisfies, ',') + 1))
              ELSE
                  NULL
          END AS remaining_satisfies,
          last_modified_at,
          created_at
      FROM SplitSatisfies
      WHERE remaining_satisfies IS NOT NULL AND remaining_satisfies != ''
  ),
  latest_entries AS (
              SELECT
                uri,
                MAX(last_modified_at) AS latest_last_modified_at
              FROM
                uniform_resource
              GROUP BY
                uri
          )
  SELECT
      ss.uniform_resource_id,
      ss.uri,
      ss.nature,
      ss.device_id,
      ss.content_digest,
      ss.title,
      ss.content,
      ss.extracted,
      ss.satisfy AS fii,
      ss.last_modified_at,
      ss.created_at,
      ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title) AS row_num,
      uniform_resource_id || '-' || hex(substr(title, 1, 50))|| '-0003-' || printf('%04d', ROW_NUMBER() OVER (PARTITION BY uniform_resource_id, title ORDER BY uniform_resource_id, title)) AS evidence_id        
  FROM SplitSatisfies ss
  JOIN 
  latest_entries le
          ON
            ss.uri = le.uri AND ss.last_modified_at = le.latest_last_modified_at
  WHERE ss.satisfy IS NOT NULL AND ss.satisfy != ''
  group by fii,ss.title order by ss.title;

DROP VIEW IF EXISTS audit_session_control_status;
CREATE VIEW audit_session_control_status AS 
      SELECT
      a.audit_session_id,
      a.title,
      a.contact_person,
      a.audit_type,
      a.due_date,
      a.created_at,
      a.updated_at,
      a.tenant_id,
      a.tenant_name,
      a.control_regime_id,
      a.control_regime_name,
      Json_group_array(
      Json_object(
      'control_group_id', cg.control_group_id,
      'control_group_name', cg.control_group_name,
      'display_order', cg.display_order,
      'controls',
        (
          SELECT
          Json_group_array(
          Json_object(
          'id', c.audit_control_id,
          'control_id', c.control_id,
          'order', c.display_order,
          'question', c.question,
          'status', c.status,
          'control_code',ct.control_code,
          'fii', ct.fii,
          'policy',
            (
            WITH EvidenceGrouped AS (
              SELECT 
              policy_id,
              uri,
              title,
              description,
              fii,
              json_group_array(
                json_object(
                  'evidenceId', evidence_id,
                  'evidence', evidence,
                  'title', evidence_title,
                  'type', evidence_type,
                  'status', evidence_status
                )
              ) FILTER (WHERE evidence_id IS NOT NULL) AS evidence
              FROM audit_control_evidence 
              WHERE audit_control_id = c.audit_control_id
              GROUP BY policy_id, uri, title, description, fii
            )
                SELECT 
                json_group_array(
                  json_object(
                    'policyId', policy_id,
                    'uri', uri,
                    'title', title,
                    'description', description,
                    'fii', fii,
                    'evidence', COALESCE(json(evidence), json('[]'))
                  )
                ) AS policy_json
                FROM EvidenceGrouped
              )
            )
            )
            FROM
              audit_session_control c
              JOIN control ct ON ct.control_id = c.control_id
            WHERE
              c.control_group_id = cg.control_group_id
              AND c.audit_session_id = a.audit_session_id
          )
        )
      ) AS audit_control
      FROM
        audit_session_info a
      JOIN audit_session_control_group cg ON cg.audit_session_id = a.audit_session_id
      GROUP BY 
        a.audit_session_id 
      ORDER BY cg.display_order ASC;

DROP VIEW IF EXISTS control_group;
CREATE VIEW control_group AS 
          SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM
              uniform_resource_aicpa_soc2_controls
            GROUP BY
              "Common Criteria"
              
          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_aicpa_soc2_type2_controls
            GROUP BY
              "Common Criteria" 
          
          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_hipaa_security_rule_safeguards
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_hitrust_e1_assessment
            GROUP BY
              "Common Criteria" 

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 1" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 1" != ""
            GROUP BY
              cntl."SCF Domain"

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 2" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 2" != ""
            GROUP BY
              cntl."SCF Domain"

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 3" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 3" != ""
            GROUP BY
              cntl."SCF Domain"
            
          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id!="") AS control_group_id,
              "SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_thsa
            GROUP BY
              "SCF Domain"
          
          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_code_quality_infrastructure
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_database_quality_infrastructure
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scheduled_audit
            GROUP BY
              "Common Criteria";

DROP VIEW IF EXISTS control;
CREATE VIEW control AS
            WITH control_regime_cte AS (
              SELECT
                reg.name as control_regime,
                reg.control_regime_id as control_regime_id,
                audit.name as audit_type_name,
                audit.control_regime_id as audit_type_id
              FROM
                  control_regime as audit
              INNER JOIN control_regime as reg ON audit.parent_id = reg.control_regime_id
            )
            SELECT
              CAST(cntl."#" AS INTEGER) AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_id,
              cntl."Control Identifier" AS control_identifier,
              cntl."Control Identifier" AS control_code,
              cntl."Fii ID" AS fii,
              cntl."Common Criteria" AS common_criteria,
              cntl."Name" AS expected_evidence,
              cntl."Questions Descriptions" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS audit_type_id
            FROM
                uniform_resource_aicpa_soc2_controls cntl
            INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
            WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I')

        UNION ALL

            SELECT
              CAST(cntl."#" AS INTEGER) AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') as control_id,
              cntl."Control Identifier" AS control_identifier,"Control Identifier" AS control_code, "Fii ID" AS fii,
              cntl."Common Criteria" AS common_criteria,
              cntl."Name" AS expected_evidence,
              cntl."Questions Descriptions" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS audit_type_id
            FROM uniform_resource_aicpa_soc2_type2_controls cntl
            INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
            WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II')

        UNION ALL

          SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."HIPAA Security Rule Reference", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA') as control_id,
            cntl."HIPAA Security Rule Reference" AS control_identifier,
            cntl."HIPAA Security Rule Reference" AS control_code,
            cntl."FII Id" AS fii,
            cntl."Common Criteria" AS common_criteria,
            "" AS expected_evidence,
            cntl.Safeguard AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='HIPAA') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='HIPAA') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='HIPAA') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA') AS audit_type_id
          FROM uniform_resource_hipaa_security_rule_safeguards cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA')

        UNION ALL

          SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Fii ID", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') as control_id,
            cntl."Control Identifier" AS control_identifier,"Control Identifier" AS control_code, "Fii ID" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl.Description AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS audit_type_id
          FROM uniform_resource_hitrust_e1_assessment cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment')

        UNION ALL

          SELECT
            (SELECT COUNT(*)
            FROM uniform_resource_scf_2024_2 AS sub
            WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 1" != "") AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 1", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' || 
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') as control_id,
            'CMMCLEVEL-' || (ROWID) as control_identifier,
            cntl."US CMMC 2.0 Level 1" AS control_code,
            cntl."SCF #" AS fii,
            cntl."SCF Domain" AS common_criteria,
            "" AS expected_evidence,
            cntl."SCF Control Question" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 AS cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              cntl."US CMMC 2.0 Level 1" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1')

        UNION ALL

          SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 2" != "") AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 2", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') as control_id,
              'CMMCLEVEL-' || (ROWID) AS control_identifier,
              cntl."US CMMC 2.0 Level 2" AS control_code,
              cntl."SCF #" AS fii,
              cntl."SCF Domain" AS common_criteria,
              "" AS expected_evidence,
              cntl."SCF Control Question" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              "US CMMC 2.0 Level 2" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2')

        UNION ALL

          SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 3" != "") AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 3", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') as control_id,
              'CMMCLEVEL-' || (ROWID) AS control_identifier,
              cntl."US CMMC 2.0 Level 3" AS control_code,
              cntl."SCF #" AS fii,
              cntl."SCF Domain" AS common_criteria,
              "" AS expected_evidence,
              cntl."SCF Control Question" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              "US CMMC 2.0 Level 3" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') as control_id,
            cntl."SCF #" AS control_identifier,
            cntl."SCF #" AS control_code,
            cntl."SCF #" AS fii,
            cntl."SCF Domain" AS common_criteria,
            "" AS expected_evidence, 
            cntl."SCF Control Question" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS audit_type_id
          FROM uniform_resource_thsa cntl
          INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') as control_id,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Control Identifier" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl."Questions Descriptions" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS audit_type_id
          FROM uniform_resource_code_quality_infrastructure cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') as control_id,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Control Identifier" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl."Questions Descriptions" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS audit_type_id
          FROM uniform_resource_database_quality_infrastructure cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria" 
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure')

        UNION ALL

        SELECT 
          CAST(cntl."#" AS INTEGER) AS display_order,
          cg.control_group_id,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
          || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Fii ID", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
          (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') as control_id,
          cntl."Control Identifier" AS control_identifier,
          cntl."Control Identifier" AS control_code,
          cntl."Fii ID" AS fii,
          cntl."Common Criteria" AS common_criteria,
          cntl."Name" AS expected_evidence,
          cntl."Questions Descriptions" AS question,
          (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS control_regime,
          (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS control_regime_id,
          (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS audit_type,
          (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS audit_type_id
        FROM uniform_resource_scheduled_audit cntl
        INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
        WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit');

