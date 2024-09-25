-- summary of issues across all ingested projects, including counts of open and closed issues, and average time estimates and time spent.
DROP VIEW IF EXISTS project_issue_summary;
CREATE VIEW project_issue_summary AS
SELECT
    pia.name AS project_name,
    COUNT(*) AS issue_count,
    COUNT(CASE WHEN pii.state = 'open' THEN 1 END) AS open_issue_count,
    COUNT(CASE WHEN pii.state = 'closed' THEN 1 END) AS closed_issue_count,
    AVG(pii.time_estimate) AS avg_time_estimate,
    AVG(pii.time_spent) AS avg_time_spent
FROM ur_ingest_session_plm_acct_project pia
JOIN ur_ingest_session_plm_acct_project_issue pii 
    ON pia.ur_ingest_session_plm_acct_project_id = pii.ur_ingest_session_plm_acct_project_id
GROUP BY pia.name;


-- user contributions by showing the number of issues assigned to each user and the number of comments they made.
DROP VIEW IF EXISTS user_contribution_summary;
CREATE VIEW user_contribution_summary AS
SELECT
    u.login AS username,
    COUNT(DISTINCT pii.ur_ingest_session_plm_acct_project_issue_id) AS issues_assigned,
    COUNT(DISTINCT c.ur_ingest_session_plm_comment_id) AS comments_made
FROM ur_ingest_session_plm_user u
LEFT JOIN ur_ingest_session_plm_acct_project_issue pii ON u.ur_ingest_session_plm_user_id = pii.user
LEFT JOIN ur_ingest_session_plm_comment c ON u.ur_ingest_session_plm_user_id = c.user
GROUP BY u.login;


-- Tracks the completion status of milestones, 
-- categorizing them as "Completed On Time," "Completed Late," "Overdue," or "In Progress" based on their due dates and closed dates.
DROP VIEW IF EXISTS milestone_completion_status;
CREATE VIEW milestone_completion_status AS
SELECT
    m.title AS milestone_name,
    m.due_on,
    m.closed_at,
    CASE 
        WHEN m.closed_at IS NOT NULL AND m.due_on IS NOT NULL AND m.closed_at <= m.due_on THEN 'Completed On Time'
        WHEN m.closed_at IS NOT NULL AND m.due_on IS NOT NULL AND m.closed_at > m.due_on THEN 'Completed Late'
        WHEN m.closed_at IS NULL AND m.due_on IS NOT NULL AND m.due_on < CURRENT_TIMESTAMP THEN 'Overdue'
        ELSE 'In Progress'
    END AS completion_status
FROM ur_ingest_session_plm_milestone m;

WITH expected_counts AS (
    SELECT 'project_issue_summary' AS table_name, 1 AS expected_count
    UNION ALL
    SELECT 'user_contribution_summary', 50 AS expected_count
    UNION ALL
    SELECT 'milestone_completion_status', 0 AS expected_count
),
actual_counts AS (
    SELECT 'project_issue_summary' AS table_name, COUNT(*) AS actual_count FROM project_issue_summary
    UNION ALL
    SELECT 'user_contribution_summary', COUNT(*) FROM user_contribution_summary
    UNION ALL
    SELECT 'milestone_completion_status', COUNT(*) FROM milestone_completion_status
),

results AS (
    SELECT
        ec.table_name,
        CASE
            WHEN ac.actual_count = ec.expected_count THEN 'ok - ' || ec.table_name || ' count matches expected (' || ec.expected_count || ')'
            ELSE 'not ok - ' || ec.table_name || ' count does not match expected (' || ec.expected_count || '), found: ' || ac.actual_count
        END AS tap_output
    FROM
        expected_counts ec
    JOIN
        actual_counts ac ON ec.table_name = ac.table_name
),
tap_plan AS (
    SELECT '1..' || COUNT(*) || ' - TAP tests for database tables' AS tap_output FROM results
)

SELECT tap_output FROM tap_plan
UNION ALL
SELECT tap_output FROM results;
