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



/* 'orchestrateStatefulIaSQL' in '[object Object]' returned type undefined instead of string | string[] | SQLa.SqlTextSupplier */
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ur/index.sql', 'ur/index.sql', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', 'ur/index.sql', 99, 'ur/info-schema.sql', 'ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-files.sql', 'ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-imap-account.sql', 'ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.', NULL)
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
  LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id AND ure.nature = 'ingest_fs_path'
  LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT
      ur.uniform_resource_id,
      graph.name,
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
      ur.nature,
      ur.content
  FROM uniform_resource ur
  INNER JOIN uniform_resource_edge edge ON edge.uniform_resource_id=ur.uniform_resource_id
  INNER JOIN uniform_resource_graph graph ON graph.name=edge.graph_name
  INNER JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ur_ingest_session_imap_acct_folder_message_id = edge.node_id
  INNER JOIN ur_ingest_session_imap_acct_folder iaf ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  WHERE ur.nature = 'text' AND graph.name='imap' AND ur.ingest_session_imap_acct_folder_message IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap_content;
  CREATE  VIEW uniform_resource_imap_content AS
  SELECT
      uri.uniform_resource_id,
      base_ur.uniform_resource_id baseID,
      ext_ur.uniform_resource_id extID,
      base_ur.uri as base_uri,
      ext_ur.uri as ext_uri,
      base_ur.nature as base_nature,
      ext_ur.nature as ext_nature,
      json_extract(part.value, '$.body.Html') AS html_content
  FROM
      uniform_resource_imap uri
  INNER JOIN uniform_resource base_ur ON base_ur.uniform_resource_id=uri.uniform_resource_id
  INNER JOIN uniform_resource ext_ur ON ext_ur.uri = base_ur.uri ||'/json' AND ext_ur.nature = 'json',
  json_each(ext_ur.content, '$.parts') AS part
  WHERE ext_ur.nature = 'json' AND html_content NOT NULL;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '') AS file_extension,
            ur_ingest_session_fs_path.ur_ingest_session_fs_path_id as ingest_session_fs_path_id,
            ur_ingest_session_fs_path.root_path AS ingest_session_root_fs_path,
            COUNT(ur_ingest_session_fs_path_entry.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_fs_path ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_fs_path.ingest_session_id
        LEFT JOIN
            ur_ingest_session_fs_path_entry ON ur_ingest_session_fs_path.ur_ingest_session_fs_path_id = ur_ingest_session_fs_path_entry.ingest_fs_path_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_fs_path_entry.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_fs_path_entry.file_extn,
            ur_ingest_session_fs_path.root_path
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        file_extension,
        ingest_session_fs_path_id,
        ingest_session_root_fs_path,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        file_extension;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, 'Ok') AS ur_status,
            COALESCE(uniform_resource.nature, 'UNKNOWN') AS nature,
            COUNT(ur_ingest_session_task.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_task ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_task.ingest_session_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_task.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_task.captured_executable
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        ur_status,
        nature,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        ur_status;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_file_issue" AS
      SELECT us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics
        FROM ur_ingest_session_fs_path_entry ufs
        JOIN ur_ingest_session_fs_path usp ON ufs.ingest_fs_path_id = usp.ur_ingest_session_fs_path_id
        JOIN ur_ingest_session us ON usp.ingest_session_id = us.ur_ingest_session_id
       WHERE ufs.ur_status IS NOT NULL
    GROUP BY us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics;
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.
-- select 'test' into absolute_url;
DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS

SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    'console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    'console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
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
    '[Content](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
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

DROP VIEW IF EXISTS rssd_statistics_overview;
CREATE VIEW rssd_statistics_overview AS
SELECT 
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size()) AS db_size_mb,
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size()) AS db_size_gb,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table') AS total_tables,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'index') AS total_indexes,
    (SELECT SUM(tbl_rows) FROM (
        SELECT name, 
              (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows
        FROM sqlite_master t WHERE type='table'
    )) AS total_rows,
    (SELECT page_size FROM pragma_page_size()) AS page_size,
    (SELECT page_count FROM pragma_page_count()) AS total_pages;

CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);
DROP VIEW IF EXISTS rssd_table_statistic;
CREATE VIEW rssd_table_statistic AS
SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
FROM sqlite_master m
WHERE m.type = 'table';

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
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'index.sql';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, 'index.sql', 'index.sql', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', 'index.sql', 999, 'console/index.sql', 'console/index.sql', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', 'console/index.sql', 1, 'console/info-schema/index.sql', 'console/info-schema/index.sql', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/index.sql', 'console/sqlpage-files/index.sql', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/content.sql', 'console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-nav/index.sql', 'console/sqlpage-nav/index.sql', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', 'console/index.sql', 2, 'console/notebooks/index.sql', 'console/notebooks/index.sql', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL),
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL),
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL),
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL)
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
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
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
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
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
              SELECT ''Home'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
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
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'orchestration/index.sql', 'orchestration/index.sql', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', 'orchestration/index.sql', 99, 'orchestration/info-schema.sql', 'orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
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
-- delete all /ip-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/infra/audit%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'opsfolio/index.sql', 'opsfolio/index.sql', 'Opsfolio', NULL, NULL, 'Opsfolio', NULL),
    ('prime', '/opsfolio', 2, 'opsfolio/infra/audit/index.sql', 'opsfolio/infra/audit/index.sql', 'Infrastructure Audits', NULL, NULL, 'The Infra Audit is designed to manage and streamline audits across
various frameworks, including HIPAA, HITRUST, AICPA, and others. This project
provides a comprehensive platform for conducting, tracking, and reporting on
compliance audits, ensuring that your organization meets the necessary
regulatory requirements.', NULL),
    ('prime', '/opsfolio', 3, 'opsfolio/infra/audit/control_regime.sql', 'opsfolio/infra/audit/control_regime.sql', 'Control Regimes', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 1, 'opsfolio/infra/audit/session_list.sql', 'opsfolio/infra/audit/session_list.sql', 'Audit Sessions', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 1, 'opsfolio/infra/audit/session_detail.sql', 'opsfolio/infra/audit/session_detail.sql', 'Audit Sessions', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 1, 'opsfolio/infra/audit/control_detail.sql', 'opsfolio/infra/audit/control_detail.sql', 'Controls Detail', NULL, NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Resource Surveillance State Database (RSSD)",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "index.sql",
  "menu_item": [
    {
      "link": "index.sql",
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
       ''https://www.surveilr.com/assets/brand/favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''/docs/index.sql'',
              ''title'', ''Docs'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/docs/index.sql/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer;',
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
    WHERE namespace = ''prime'' AND path=''ur/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''ur''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''ur''||''/index.sql''
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
    WHERE namespace = ''prime'' AND path=''ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
  SELECT ''table'' AS component,
  ''Name'' AS markdown,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search;

SELECT
''Table'' as "Type",
  ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_table
  WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
  GROUP BY table_name

  UNION ALL

SELECT
''View'' as "Type",
  ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
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
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-files.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-files.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file );
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
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
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-imap-account.sql/index.sql'') as contents;
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
''['' || email || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
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
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT
  ''Uniform Resource'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
  ''Folder'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id:: TEXT as link;
SELECT
  ''title'' as component,
  (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

--Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''folder'' AS markdown;
  SELECT ''['' || folder_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
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
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''
SELECT
  ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
  ''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id=''|| ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  ''title''   as component,
  (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap );
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
            TRUE AS small,
              ''subject'' AS markdown;;
SELECT
''['' || subject || ''](uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id || '')'' AS "subject"
  , "from",
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || $folder_id ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || $folder_id ||  '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
SELECT
 ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' AS link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   subject AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Breadcrumb ends-- -

  --- back button-- -
    select ''button'' as component;
select
"<< Back" as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id as link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Display uniform_resource table with pagination
  SELECT
''datagrid'' as component;
SELECT
''From'' as title,
  "from" as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''To'' as title,
  email as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''Subject'' as title,
  subject as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;

  SELECT ''html'' AS component;
  SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
            ',
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
 WHERE namespace = ''prime'' AND parent_path = ''index.sql''
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
    WHERE namespace = ''prime'' AND path=''console/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''console''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''console''||''/index.sql''
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
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
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
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
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
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component,
$name AS contents;
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
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
   SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
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
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql'' || '')
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
      SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '')[📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

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
      ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

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
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
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
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || $redirect as link WHERE $redirect is NOT NULL;',
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
    WHERE namespace = ''prime'' AND path=''console/sqlpage-nav/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
    ''['' || c.cell_name || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' ||
    replace(c.notebook_name, '' '', ''%20'') ||
    ''&cell='' ||
    replace(c.cell_name, '' '', ''%20'') ||
    '')'' AS "Cell",
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
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
      'console/migrations/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
    ''foldable'' as component;
SELECT
    ''RSSD Lifecycle(Migration) Documentation'' as title,
    ''
This document provides an organized and comprehensive overview of ``surveilr``''''s RSSD migration process starting from ``v 1.0.0``, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the ``session_state_ephemeral`` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The ``assurance_schema`` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

``surveilr`` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''''s language and structure. The main tables involved here are:

- **``code_notebook_kernel``**: Stores information about different kernels, each representing a unique execution environment or language.
- **``code_notebook_cell``**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **``code_notebook_state``**: Tracks each cell''''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, ``surveilr`` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **``code_notebook_cell_versions``**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **``code_notebook_cell_latest``**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **``code_notebook_sql_cell_migratable``**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, ``surveilr`` dynamically generates a script that executes only the necessary cells.

### Key Views

- **``code_notebook_sql_cell_migratable_not_executed``**: Lists migratable cells that haven’t yet been executed.
- **``code_notebook_sql_cell_migratable_state``**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''''s time to apply changes to the database, this section explains the process in detail, focusing on how ``surveilr`` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: ``surveilr`` first verifies whether the required tables, such as ``code_notebook_cell``, ``code_notebook_state``, and others starting with ``code_notebook%``, are already set up in the database.
- **Setup**: If these tables do not yet exist, ``surveilr`` automatically initiates the setup by running the initial SQL script, known as ``bootstrap.sql``. This script contains SQL commands that create all the essential tables and views discussed in previous sections.
- **Seeding**: During the execution of ``bootstrap.sql``, essential data, such as temporary values in the ``session_state_ephemeral`` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, ``surveilr`` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: ``surveilr`` begins by consulting views such as ``code_notebook_sql_cell_migratable_not_executed``. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: ``surveilr`` then checks whether each cell is marked as “idempotent” or “non-idempotent.”
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing ``_once_``, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

``surveilr`` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, ``surveilr`` checks its eligibility status. If it''''s non-idempotent and already executed, it''''s marked with a comment noting that it''''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''''s last execution date.
- **State Transition Records**: After each cell''''s SQL code, additional commands are added to record the cell''''s transition state. This step inserts information into ``code_notebook_state``, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, ``surveilr`` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The ``COMMIT`` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, ``surveilr`` concludes by recording details about the migration process.

- **Final Updates to ``code_notebook_state``**: Any cells marked as “Executed” are updated in ``code_notebook_state`` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in ``session_state_ephemeral``, since these values were only needed during the migration process.
    '' as description_md;


SELECT ''title'' AS component, ''Pending Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed.
    If migrations have been completed successfully, this list will be empty,
    indicating that all migratable cells have been processed and marked as executed.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp
FROM
    code_notebook_sql_cell_migratable_not_executed AS c
ORDER BY
    c.cell_name;

-- State of Executed Migrations
SELECT ''title'' AS component, ''State of Executed Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process,
    showing the latest version of each migratable cell.
    For each cell, it provides details on its transition states,
    the reason and result of the migration, and the timestamp of when the migration occurred.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp,
    c.from_state,
    c.to_state,
    c.transition_reason,
    c.transition_result,
    c.transitioned_at
FROM
    code_notebook_sql_cell_migratable_state AS c
ORDER BY
    c.cell_name;


-- Executable Migrations
SELECT ''title'' AS component, ''Executable Migrations'' AS contents;
SELECT ''text'' AS component, ''All cells that are candidates for migration (including duplicates)'' as contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
        c.code_notebook_cell_id,
        c.notebook_name,
        c.cell_name,
        ''['' || c.cell_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
        c.interpretable_code_hash,
        c.is_idempotent,
        c.version_timestamp
    FROM
        code_notebook_sql_cell_migratable_version AS c
    ORDER BY
        c.cell_name;

-- All Migrations
SELECT ''button'' as component;
SELECT
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks'' as link,
    ''See all notebook entries'' as title;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/notebook-cell.sql',
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
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
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
      'console/about.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/about.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                 -- Title Component
    SELECT
    ''text'' AS component,
    (''Resource Surveillance v'' || replace(sqlpage.exec(''surveilr'', ''--version''), ''surveilr '', '''')) AS title;

    -- Description Component
      SELECT
          ''text'' AS component,
          ''A detailed description of what is incorporated into surveilr. It informs of critical dependencies like rusqlite, sqlpage, pgwire, e.t.c, ensuring they are present and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for more insights.''
          AS contents_md;

      -- Section: Dependencies
      SELECT
          ''title'' AS component,
          ''Internal Dependencies'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          "Dependency",
          "Version"
      FROM (
          SELECT
              ''SQLPage'' AS "Dependency",
              json_extract(json_data, ''$.versions.sqlpage'') AS "Version"
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Pgwire'',
              json_extract(json_data, ''$.versions.pgwire'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Rusqlite'',
              json_extract(json_data, ''$.versions.rusqlite'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
      );

      -- Section: Static Extensions
      SELECT
          ''title'' AS component,
          ''Statically Linked Extensions'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          json_extract(value, ''$.name'') AS "Extension Name",
          json_extract(value, ''$.url'') AS "URL",
          json_extract(value, ''$.version'') AS "Version"
      FROM json_each(
          json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.static_extensions'')
      );

    -- Section: Dynamic Extensions
    SELECT
        ''title'' AS component,
        ''Dynamically Linked Extensions'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Extension Name",
        json_extract(value, ''$.path'') AS "Path"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.dynamic_extensions'')
    );

    -- Section: Environment Variables
    SELECT
        ''title'' AS component,
        ''Environment Variables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Variable",
        json_extract(value, ''$.value'') AS "Value"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.env_vars'')
    );

    -- Section: Capturable Executables
    SELECT
        ''title'' AS component,
        ''Capturable Executables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Executable Name",
        json_extract(value, ''$.output'') AS "Output"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.capturable_executables'')
    );

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;

SELECT
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md, ''$SITE_PREFIX_URL'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') AS "Content"
FROM console_information_schema_view
WHERE view_name LIKE ''surveilr_doctor%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/statistics/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/statistics/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''datagrid'' as component;
SELECT ''Size'' as title, "db_size_mb" || '' MB'' as description FROM rssd_statistics_overview;
SELECT ''Tables'' as title, "total_tables" as description FROM rssd_statistics_overview;
SELECT ''Indexes'' as title, "total_indexes" as description FROM rssd_statistics_overview;
SELECT ''Rows'' as title, "total_rows" as description FROM rssd_statistics_overview;
SELECT ''Page Size'' as title, "page_size" as description FROM rssd_statistics_overview;
SELECT ''Total Pages'' as title, "total_pages" as description FROM rssd_statistics_overview;
    
select ''text'' as component, ''Tables'' as title;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT * FROM rssd_table_statistic ORDER BY table_size_mb DESC;
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
    WHERE namespace = ''prime'' AND path=''orchestration/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''orchestration''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''orchestration''||''/index.sql''
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
    WHERE namespace = ''prime'' AND path=''orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
     ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
     ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              select
 ''card''             as component,
 3                 as columns;
  SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND parent_path = ''/opsfolio'' AND sibling_order = 2
   ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/infra/audit/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/infra/audit/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''card'' as component
SELECT name  as title,
''arrow-big-right'' as icon,
''/opsfolio/infra/audit/control_regime.sql?id='' ||control_regime_id || '''' as link
FROM
tenant_based_control_regime WHERE tenant_id = ''239518031485599747'' AND parent_id == '''';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/infra/audit/control_regime.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/infra/audit/control_regime.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''opsfolio/infra/audit/control_regime.sql/index.sql'') as contents;
    ;
SELECT ''card'' as component
SELECT name  as title,
''arrow-big-right'' as icon,
''/opsfolio/infra/audit/session_list.sql?id='' ||control_regime_id || '''' as link
FROM
tenant_based_control_regime WHERE tenant_id = ''239518031485599747'' AND parent_id = $id:: Text;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/infra/audit/session_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/infra/audit/session_list.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''opsfolio/infra/audit/session_list.sql/index.sql'') as contents;
    ;

SELECT ''table'' AS component,
       TRUE AS sort,
       TRUE AS search,
       ''Session'' AS markdown;

SELECT ''['' || title || ''](/opsfolio/infra/audit/session_detail.sql?id='' || audit_type_id  || ''&sessionid='' || audit_session_id || '')'' AS "Session",
       audit_type AS "Audit Type",
       due_date AS "Due Date",
       tenant_name AS "Tenant"
FROM audit_session_list
WHERE tenant_id = ''239518031485599747'' AND audit_type_id = $id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/infra/audit/session_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/infra/audit/session_detail.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''title'' AS component,
''Control List'' AS contents
select ''table'' as component,
''Control code'' AS markdown;
SELECT
''['' || control_code || ''](/opsfolio/infra/audit/control_detail.sql?id='' || control_id || '')'' AS "Control code",
common_criteria as "Common criteria",
question as "Question"
  FROM control WHERE CAST(audit_type_id AS TEXT)=CAST($id AS TEXT);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/infra/audit/control_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''opsfolio/infra/audit/control_detail.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
  ''title'' AS component
  select ''table'' as component
  SELECT
  fii AS "FII",
  question AS "Question",
  common_criteria as "Common criteria",
  expected_evidence as "Evidence",
  control_regime as "Control Regime"
    FROM control WHERE CAST(control_id AS TEXT)=CAST($id AS TEXT);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
