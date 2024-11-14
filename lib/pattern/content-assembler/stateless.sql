DROP VIEW IF EXISTS periodicals_from;
CREATE VIEW periodicals_from AS
    SELECT
        message_from
    FROM
        ur_periodical_chached GROUP BY message_from;

DROP VIEW IF EXISTS periodicals_subject;
CREATE VIEW periodicals_subject AS
    SELECT
    periodical_uniform_resource_id,
    message_from,
    message_to,
    message_subject,
    message_date
    FROM
        ur_periodical_chached;


DROP VIEW IF EXISTS periodical_anchor;
CREATE VIEW periodical_anchor AS
    SELECT
        eac.uniform_resource_id,
        eac.uniform_resource_transform_id,
        eac.anchor as orginal_url,
        acc.canonical_link,
        lnktxt.url_text
    FROM
        ur_transform_html_email_anchor_cached eac
    INNER JOIN ur_periodical_anchor_text_cached lnktxt ON lnktxt.anchor=eac.anchor
    INNER JOIN ur_transform_html_email_anchor_canonical_cached acc ON acc.anchor=eac.anchor;

