DROP VIEW IF EXISTS periodicals_from_count;
CREATE VIEW periodicals_from_count AS
    SELECT
        COUNT(DISTINCT message_from) AS dashboard_from_count
    FROM
        ur_periodical_chached;

DROP VIEW IF EXISTS periodical_filtered_count;
CREATE VIEW periodical_filtered_count AS
    SELECT
        COUNT(anchor) AS dashboard_periodical_filtered_count
    FROM
        ur_transform_html_email_anchor_cached;

DROP VIEW IF EXISTS anchor_removed_count;
CREATE VIEW anchor_removed_count AS
    SELECT
        COUNT(anchor) AS dashboard_anchor_removed_count
    FROM
        ur_transform_html_email_anchor_subscription_filter_chached WHERE anchor_type NOT NULL;

DROP VIEW IF EXISTS anchor_total_count;
CREATE VIEW anchor_total_count AS
    SELECT
        COUNT(anchor) AS dashboard_anchor_total_count
    FROM
        ur_transform_html_email_anchor_subscription_filter_chached;

DROP VIEW IF EXISTS periodicals_from;
CREATE VIEW periodicals_from AS
    SELECT
        pc.message_from, COUNT(pc.message_subject) as subject_count,
        (SELECT
            COUNT(eac.anchor)
        FROM
            ur_transform_html_email_anchor_cached eac
        INNER JOIN ur_periodical_anchor_text_cached lnktxt ON lnktxt.anchor=eac.anchor
        INNER JOIN ur_transform_html_email_anchor_canonical_cached acc ON acc.anchor=eac.anchor WHERE eac.uniform_resource_id=pc.periodical_uniform_resource_id) as periodical_count
    FROM
        ur_periodical_chached pc
    GROUP BY pc.message_from;


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


DROP VIEW IF EXISTS removed_anchor_list;
CREATE VIEW removed_anchor_list AS
    SELECT
        rmlst.uniform_resource_id,
        rmlst.anchor,
        rmlst.anchor_type,
        rmtxt.url_text
    FROM
        ur_transform_html_email_anchor_subscription_filter_chached rmlst
        INNER JOIN ur_removed_anchor_text_cached rmtxt ON rmtxt.uniform_resource_id=rmlst.uniform_resource_id
        AND rmtxt.uniform_resource_transform_id=rmlst.uniform_resource_transform_id
        AND rmlst.anchor=rmlst.anchor
        WHERE rmlst.anchor_type NOT NULL;


DROP VIEW IF EXISTS error_link_count;
CREATE VIEW error_link_count AS
    SELECT
        count(url) as error_count
    FROM
        ur_transform_http_url_status_cached WHERE status='Failed';

DROP VIEW IF EXISTS error_link_list;
CREATE VIEW error_link_list AS
    SELECT
        sc.url,
        lnktxt.url_text,
        sc.response_status_code,
        sc.response_status,
        sc.message,
        pc.message_from,
        pc.message_to,
        pc.message_subject
    FROM
        ur_transform_http_url_status_cached sc
        INNER JOIN ur_periodical_anchor_text_cached lnktxt ON lnktxt.anchor=sc.url
        INNER JOIN ur_periodical_chached pc ON pc.periodical_uniform_resource_id=sc.uniform_resource_id
        WHERE sc.status='Failed';