drop view if exists inbox;
CREATE VIEW inbox AS
SELECT
    ur_imap.uniform_resource_id AS base_uniform_resource_id,
    ur_imap."from" AS message_from,
    ur_imap."subject" AS message_subject,
    ur_imap."date" AS message_date,
    ur_extended.uniform_resource_id AS extended_uniform_resource_id,
    ur_extended.uri AS extended_uri
FROM
    ur_ingest_session_imap_acct_folder_message ur_imap
JOIN
    uniform_resource ur_base
    ON ur_base.uniform_resource_id = ur_imap.uniform_resource_id
JOIN
    uniform_resource ur_extended
    ON ur_extended.uri = ur_base.uri || '/html'
WHERE
    ur_extended.uri LIKE '%/html';