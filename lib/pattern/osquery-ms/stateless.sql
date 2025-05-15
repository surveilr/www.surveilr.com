-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as osqueryms content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

DROP VIEW IF EXISTS surveilr_osquery_ms_node_detail;
CREATE VIEW surveilr_osquery_ms_node_detail AS
SELECT
    n.surveilr_osquery_ms_node_id,
    n.node_key,
    n.host_identifier,
    n.osquery_version,
    n.last_seen,
    n.created_at,
    i.updated_at,
    i.address AS ip_address,
    i.mac,
    b.boundary,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 60 THEN 
            (strftime('%s', 'now') - strftime('%s', n.created_at)) || ' seconds ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 3600 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 60) || ' minutes ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 86400 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 3600) || ' hours ago'
        ELSE 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 86400) || ' days ago'
    END AS added_to_surveilr_osquery_ms,
    o.name AS operating_system,
    round(a.available_space, 2) || ' GB' AS available_space,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', last_seen)) < 60 THEN 'Online'
        ELSE 'Offline'
    END AS node_status,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 60 THEN 
            (strftime('%s', 'now') - strftime('%s', n.last_seen)) || ' seconds ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 3600 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 60) || ' minutes ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 86400 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 3600) || ' hours ago'
        ELSE 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 86400) || ' days ago'
    END AS last_fetched,
    CASE
        WHEN CAST(u.days AS INTEGER) > 0 THEN 
            'about ' || u.days || ' day' || (CASE WHEN CAST(u.days AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        WHEN CAST(u.hours AS INTEGER) > 0 THEN 
            'about ' || u.hours || ' hour' || (CASE WHEN CAST(u.hours AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        WHEN CAST(u.minutes AS INTEGER) > 0 THEN 
            'about ' || u.minutes || ' minute' || (CASE WHEN CAST(u.minutes AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        ELSE 
            'about ' || u.seconds || ' second' || (CASE WHEN CAST(u.seconds AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
    END AS last_restarted,
    COALESCE(failed_policies.failed_count, 0) AS issues
FROM surveilr_osquery_ms_node n
LEFT JOIN surveilr_osquery_ms_node_available_space a ON n.node_key = a.node_key
LEFT JOIN surveilr_osquery_ms_node_os_version o ON n.node_key = o.node_key
LEFT JOIN surveilr_osquery_ms_node_uptime u ON n.node_key = u.node_key
LEFT JOIN surveilr_osquery_ms_node_interface_address i ON n.node_key = i.node_key
LEFT JOIN surveilr_osquery_ms_node_boundary b ON n.node_key = b.node_key
LEFT JOIN (
    SELECT node_key, COUNT(*) AS failed_count
    FROM surveilr_osquery_ms_node_executed_policy
    WHERE policy_result = 'Fail'
    GROUP BY node_key
) AS failed_policies ON n.node_key = failed_policies.node_key;

