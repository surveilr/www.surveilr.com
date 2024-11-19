
DROP VIEW IF EXISTS participant_cgm_date_range_view;

CREATE VIEW
    participant_cgm_date_range_view AS
SELECT
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    participant_id,
    CAST(strftime ('%Y-%m-%d', MIN(Date_Time)) AS TEXT) AS participant_cgm_start_date,
    CAST(strftime ('%Y-%m-%d', MAX(Date_Time)) AS TEXT) AS participant_cgm_end_date,
    CAST(
        strftime ('%Y-%m-%d', DATE (MAX(Date_Time), '-1 day')) AS TEXT
    ) AS end_date_minus_1_day,
    CAST(
        strftime ('%Y-%m-%d', DATE (MAX(Date_Time), '-7 day')) AS TEXT
    ) AS end_date_minus_7_days,
    CAST(
        strftime ('%Y-%m-%d', DATE (MAX(Date_Time), '-14 day')) AS TEXT
    ) AS end_date_minus_14_days,
    CAST(
        strftime ('%Y-%m-%d', DATE (MAX(Date_Time), '-30 day')) AS TEXT
    ) AS end_date_minus_30_days,
    CAST(
        strftime ('%Y-%m-%d', DATE (MAX(Date_Time), '-90 day')) AS TEXT
    ) AS end_date_minus_90_days
FROM
    combined_cgm_tracing
GROUP BY
    participant_id;


DROP VIEW IF EXISTS study_combined_dashboard_participant_metrics_view;
CREATE VIEW study_combined_dashboard_participant_metrics_view AS
WITH combined_data AS (
    SELECT 
        dg.tenant_id,
        dg.study_id,             
        dg.participant_id,
        dg.gender,
        dg.age,
        dg.study_arm,
        dg.baseline_hba1c,
        GROUP_CONCAT(DISTINCT cfm.devicename) AS cgm_devices,  -- Combine devices into a single string
        GROUP_CONCAT(DISTINCT cfm.file_name || '.' || cfm.file_format) AS cgm_files,    -- Combine file names into a single string
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tir,
        ROUND(SUM(CASE WHEN dc.CGM_Value > 250 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar_vh,
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar_h,
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr_l,
        ROUND(SUM(CASE WHEN dc.CGM_Value < 54 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr_vl,
        ROUND(SUM(CASE WHEN dc.CGM_Value > 180 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar,
        ROUND(SUM(CASE WHEN dc.CGM_Value < 70 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr,
        CEIL((AVG(dc.CGM_Value) * 0.155) + 95) AS gmi,
        ROUND((SQRT(AVG(dc.CGM_Value * dc.CGM_Value) - AVG(dc.CGM_Value) * AVG(dc.CGM_Value)) / AVG(dc.CGM_Value)) * 100, 2) AS percent_gv,
        ROUND((3.0 * ((SUM(CASE WHEN dc.CGM_Value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                      (0.8 * (SUM(CASE WHEN dc.CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))) + 
              (1.6 * ((SUM(CASE WHEN dc.CGM_Value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                      (0.5 * (SUM(CASE WHEN dc.CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))), 2) AS gri,
        COUNT(DISTINCT DATE(dc.Date_Time)) AS days_of_wear,
        MIN(DATE(dc.Date_Time)) AS data_start_date,
        MAX(DATE(dc.Date_Time)) AS data_end_date,   
        ROUND(
            COALESCE(
                (COUNT(DISTINCT DATE(dc.Date_Time)) * 1.0 / 
                (JULIANDAY(MAX(DATE(dc.Date_Time))) - JULIANDAY(MIN(DATE(dc.Date_Time))) + 1)) * 100, 
                0), 
            2) AS wear_time_percentage
    FROM drh_participant dg 
    JOIN combined_cgm_tracing dc ON dg.participant_id = dc.participant_id
    LEFT JOIN uniform_resource_cgm_file_metadata cfm 
        ON dc.participant_id = cfm.patient_id
    GROUP BY dg.study_id, dg.tenant_id, dg.participant_id
)
SELECT * 
FROM combined_data
ORDER BY     
    CASE 
        WHEN LENGTH(participant_id) - LENGTH(REPLACE(participant_id, '-', '')) = 1 THEN 
            CAST(SUBSTR(participant_id, INSTR(participant_id, '-') + 1) AS INTEGER) 
        ELSE participant_id 
    END ASC;


-----Metric Specific Views----------------------------------------------------------        
DROP VIEW IF EXISTS drh_participant_cgm_dates;

CREATE VIEW drh_participant_cgm_dates As
SELECT 
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    participant_id,
    MIN(Date_Time) AS cgm_start_date,
    MAX(Date_Time) AS cgm_end_date
FROM 
    combined_cgm_tracing
GROUP BY 
    participant_id;
   


DROP VIEW IF EXISTS drh_participant_metrics;

-- Create the 
CREATE VIEW drh_participant_metrics AS
SELECT 
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    participant_id,
    MIN(Date_Time) AS cgm_start_date,
    MAX(Date_Time) AS cgm_end_date,
    ROUND(AVG(CGM_Value), 2) AS mean_glucose,
    COUNT(DISTINCT DATE(Date_Time)) AS number_of_days_cgm_worn,
    ROUND(
        (COUNT(DISTINCT DATE(Date_Time)) / 
        ROUND((julianday(MAX(Date_Time)) - julianday(MIN(Date_Time)) + 1))
        ) * 100, 2) AS percentage_active,
    ROUND(AVG(CGM_Value) * 0.155 + 95, 2) AS gmi,
    ROUND((SQRT(AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) / AVG(CGM_Value)) * 100, 2) AS coefficient_of_variation
FROM 
    combined_cgm_tracing
GROUP BY 
    participant_id;



DROP VIEW IF EXISTS drh_time_range_stacked_metrics;
   
CREATE VIEW drh_time_range_stacked_metrics AS
   WITH GlucoseMetrics AS (
    SELECT 
        participant_id, 
        COUNT(*) AS total_readings, 
        SUM(CASE WHEN CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) AS time_below_range_low, 
        SUM(CASE WHEN CGM_Value < 54 THEN 1 ELSE 0 END) AS time_below_range_very_low, 
        SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) AS time_in_range, 
        SUM(CASE WHEN CGM_Value > 250 THEN 1 ELSE 0 END) AS time_above_vh, 
        SUM(CASE WHEN CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) AS time_above_range_high 
    FROM 
        combined_cgm_tracing
    GROUP BY 
        participant_id 
), Defaults AS (
    SELECT 
        0 AS total_readings, 
        0 AS time_below_range_low, 
        0 AS time_below_range_very_low, 
        0 AS time_in_range, 
        0 AS time_above_vh, 
        0 AS time_above_range_high 
)

SELECT 
    gm.participant_id,
    COALESCE(CASE WHEN gm.total_readings = 0 THEN 0 ELSE (gm.time_below_range_low * 100.0 / gm.total_readings) END, 0) AS time_below_range_low_percentage, 
    COALESCE(gm.time_below_range_low, 0) AS time_below_range_low, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN '00 hours, 00 minutes' ELSE printf('%02d hours, %02d minutes', (gm.time_below_range_low * 5) / 60, (gm.time_below_range_low * 5) % 60) END, '00 hours, 00 minutes') AS time_below_range_low_string, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN 0 ELSE (gm.time_below_range_very_low * 100.0 / gm.total_readings) END, 0) AS time_below_range_very_low_percentage, 
    COALESCE(gm.time_below_range_very_low, 0) AS time_below_range_very_low, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN '00 hours, 00 minutes' ELSE printf('%02d hours, %02d minutes', (gm.time_below_range_very_low * 5) / 60, (gm.time_below_range_very_low * 5) % 60) END, '00 hours, 00 minutes') AS time_below_range_very_low_string, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN 0 ELSE (gm.time_in_range * 100.0 / gm.total_readings) END, 0) AS time_in_range_percentage, 
    COALESCE(gm.time_in_range, 0) AS time_in_range, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN '00 hours, 00 minutes' ELSE printf('%02d hours, %02d minutes', (gm.time_in_range * 5) / 60, (gm.time_in_range * 5) % 60) END, '00 hours, 00 minutes') AS time_in_range_string, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN 0 ELSE (gm.time_above_vh * 100.0 / gm.total_readings) END, 0) AS time_above_vh_percentage, 
    COALESCE(gm.time_above_vh, 0) AS time_above_vh, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN '00 hours, 00 minutes' ELSE printf('%02d hours, %02d minutes', (gm.time_above_vh * 5) / 60, (gm.time_above_vh * 5) % 60) END, '00 hours, 00 minutes') AS time_above_vh_string, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN 0 ELSE (gm.time_above_range_high * 100.0 / gm.total_readings) END, 0) AS time_above_range_high_percentage, 
    COALESCE(gm.time_above_range_high, 0) AS time_above_range_high, 
    COALESCE(CASE WHEN gm.total_readings = 0 THEN '00 hours, 00 minutes' ELSE printf('%02d hours, %02d minutes', (gm.time_above_range_high * 5) / 60, (gm.time_above_range_high * 5) % 60) END, '00 hours, 00 minutes') AS time_above_range_high_string 
FROM 
    Defaults d 
    LEFT JOIN GlucoseMetrics gm ON 1=1;


DROP VIEW IF EXISTS drh_agp_metrics;
   
CREATE VIEW drh_agp_metrics AS
WITH glucose_data AS (
    SELECT
        gr.participant_id,
        gr.Date_Time AS timestamp,
        strftime('%Y-%m-%d %H', gr.Date_Time) AS hourValue,
        gr.CGM_Value AS glucose_level
    FROM
        combined_cgm_tracing gr
),
ranked_data AS (
    SELECT
        participant_id,
        hourValue,
        glucose_level,
        ROW_NUMBER() OVER (PARTITION BY participant_id, hourValue ORDER BY glucose_level) AS row_num,
        COUNT(*) OVER (PARTITION BY participant_id, hourValue) AS total_count
    FROM
        glucose_data
),
percentiles AS (
    SELECT
        participant_id,
        hourValue AS hour,
        MAX(CASE WHEN row_num = CAST(0.05 * total_count AS INT) THEN glucose_level END) AS p5,
        MAX(CASE WHEN row_num = CAST(0.25 * total_count AS INT) THEN glucose_level END) AS p25,
        MAX(CASE WHEN row_num = CAST(0.50 * total_count AS INT) THEN glucose_level END) AS p50,
        MAX(CASE WHEN row_num = CAST(0.75 * total_count AS INT) THEN glucose_level END) AS p75,
        MAX(CASE WHEN row_num = CAST(0.95 * total_count AS INT) THEN glucose_level END) AS p95
    FROM
        ranked_data
    GROUP BY
        participant_id, hour
),
hourly_averages AS (
    SELECT
        participant_id,
        SUBSTR(hour, 1, 10) AS date,
        SUBSTR(hour, 12) AS hour,
        COALESCE(AVG(p5), 0) AS p5,
        COALESCE(AVG(p25), 0) AS p25,
        COALESCE(AVG(p50), 0) AS p50,
        COALESCE(AVG(p75), 0) AS p75,
        COALESCE(AVG(p95), 0) AS p95
    FROM
        percentiles
    GROUP BY
        participant_id, hour
)
SELECT
    participant_id,
    hour,
    COALESCE(AVG(p5), 0) AS p5,
    COALESCE(AVG(p25), 0) AS p25,
    COALESCE(AVG(p50), 0) AS p50,
    COALESCE(AVG(p75), 0) AS p75,
    COALESCE(AVG(p95), 0) AS p95
FROM
    hourly_averages
GROUP BY
    participant_id, hour
ORDER BY
    participant_id, hour;



DROP VIEW IF EXISTS drh_glycemic_risk_indicator;

CREATE VIEW drh_glycemic_risk_indicator AS 
  SELECT 
    participant_id, 
    ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2) AS time_above_VH_percentage,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2) AS time_above_H_percentage,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2) AS time_in_range_percentage,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2) AS time_below_low_percentage,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2) AS time_below_VL_percentage,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                   (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2) AS Hypoglycemia_Component,
    ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                   (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2) AS Hyperglycemia_Component,
    ROUND(COALESCE((3.0 * ((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                            (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))) + 
                   (1.6 * ((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                            (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))), 0), 2) AS GRI
FROM combined_cgm_tracing
GROUP BY participant_id;


DROP VIEW IF EXISTS drh_advanced_metrics;
CREATE  VIEW drh_advanced_metrics AS
WITH risk_scores AS (
    SELECT 
        participant_id,
        CGM_Value,
        CASE
            WHEN CGM_Value < 90 THEN 10 * (5 - (CGM_Value / 18.0)) * (5 - (CGM_Value / 18.0))
            WHEN CGM_Value > 180 THEN 10 * ((CGM_Value / 18.0) - 10) * ((CGM_Value / 18.0) - 10)
            ELSE 0
        END AS risk_score
    FROM combined_cgm_tracing
),
average_risk AS (
    SELECT 
        participant_id,
        AVG(risk_score) AS avg_risk_score
    FROM risk_scores
    GROUP BY participant_id
),
amplitude_data AS (
    SELECT 
        participant_id,
        ABS(MAX(CGM_Value) - MIN(CGM_Value)) AS amplitude
    FROM combined_cgm_tracing
    GROUP BY participant_id, DATE(Date_Time)
),
mean_amplitude AS (
    SELECT 
        participant_id,
        AVG(amplitude) AS mean_amplitude
    FROM amplitude_data
    GROUP BY participant_id
),
participant_min_max AS (
    SELECT 
        participant_id,
        MIN(CGM_Value) AS min_glucose,
        MAX(CGM_Value) AS max_glucose,
        MIN(DATETIME(Date_Time)) AS start_time,
        MAX(DATETIME(Date_Time)) AS end_time
    FROM combined_cgm_tracing
    GROUP BY participant_id
),
m_value AS (
    SELECT 
        participant_id,
        (max_glucose - min_glucose) / ((strftime('%s', end_time) - strftime('%s', start_time)) / 60.0) AS m_value
    FROM participant_min_max
),
daily_risk AS (
    SELECT 
        participant_id,
        DATE(Date_Time) AS day,
        MAX(CGM_Value) - MIN(CGM_Value) AS daily_range
    FROM combined_cgm_tracing
    GROUP BY participant_id, DATE(Date_Time)
),
average_daily_risk AS (
    SELECT 
        participant_id,
        AVG(daily_range) AS average_daily_risk
    FROM daily_risk
    GROUP BY participant_id
),
glucose_stats AS (
    SELECT
        participant_id,
        AVG(CGM_Value) AS mean_glucose,
        (AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) AS variance_glucose
    FROM combined_cgm_tracing
    GROUP BY participant_id
),
lbgi_hbgi AS (
    SELECT 
        participant_id,
        ROUND(SUM(CASE WHEN (CGM_Value - 2.5) / 2.5 > 0 THEN ((CGM_Value - 2.5) / 2.5) * ((CGM_Value - 2.5) / 2.5) ELSE 0 END) * 5, 2) AS lbgi, 
        ROUND(SUM(CASE WHEN (CGM_Value - 9.5) / 9.5 > 0 THEN ((CGM_Value - 9.5) / 9.5) * ((CGM_Value - 9.5) / 9.5) ELSE 0 END) * 5, 2) AS hbgi
    FROM combined_cgm_tracing
    GROUP BY participant_id
),
daily_diffs AS (
    SELECT
        participant_id,
        DATE(Date_Time) AS date,
        CGM_Value,
        CGM_Value - LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY DATE(Date_Time)) AS daily_diff
    FROM combined_cgm_tracing
),
mean_daily_diff AS (
    SELECT
        participant_id,
        AVG(daily_diff) AS mean_daily_diff
    FROM daily_diffs
    WHERE daily_diff IS NOT NULL
    GROUP BY participant_id
),
lag_values AS (
    SELECT 
        participant_id,
        Date_Time,
        CGM_Value,
        LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY Date_Time) AS lag_CGM_Value
    FROM combined_cgm_tracing
),
conga_hourly AS (
    SELECT 
        participant_id,
        SQRT(
            AVG(
                (CGM_Value - lag_CGM_Value) * (CGM_Value - lag_CGM_Value)
            ) OVER (PARTITION BY participant_id ORDER BY Date_Time)
        ) AS conga_hourly
    FROM lag_values
    WHERE lag_CGM_Value IS NOT NULL
    GROUP BY participant_id
),
liability_index AS (
    SELECT
        participant_id,
        SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) AS hypoglycemic_episodes, 
        SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) AS euglycemic_episodes, 
        SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END) AS hyperglycemic_episodes, 
        ROUND(CAST(
            (SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) + SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END))
            AS REAL
        ) / COUNT(*), 2) AS liability_index
    FROM combined_cgm_tracing
    GROUP BY participant_id
),
j_index AS (
    SELECT
        participant_id,
        ROUND(0.001 * (mean_glucose + sqrt(variance_glucose)) * (mean_glucose + sqrt(variance_glucose)), 2) AS j_index
    FROM glucose_stats
),
time_in_tight_range AS ( 
    SELECT        
        participant_id,
        (SUM(CASE WHEN CGM_Value BETWEEN 70 AND 140 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS time_in_tight_range_percentage,
        SUM(CASE WHEN CGM_Value BETWEEN 70 AND 140 THEN 1 ELSE 0 END) AS time_in_tight_range        
    FROM combined_cgm_tracing
    GROUP BY participant_id
)
SELECT
    participant_id,
    COALESCE((SELECT time_in_tight_range_percentage FROM time_in_tight_range WHERE participant_id = p.participant_id), 0) AS time_in_tight_range_percentage,
    COALESCE((SELECT avg_risk_score FROM average_risk WHERE participant_id = p.participant_id), 0) AS grade,
    COALESCE((SELECT mean_amplitude FROM mean_amplitude WHERE participant_id = p.participant_id), 0) AS mean_amplitude,
    COALESCE((SELECT m_value FROM m_value WHERE participant_id = p.participant_id), 0) AS m_value,
    COALESCE((SELECT average_daily_risk FROM average_daily_risk WHERE participant_id = p.participant_id), 0) AS average_daily_risk,
    COALESCE((SELECT mean_glucose FROM glucose_stats WHERE participant_id = p.participant_id), 0) AS mean_glucose,
    COALESCE((SELECT lbgi FROM lbgi_hbgi WHERE participant_id = p.participant_id), 0) AS lbgi,
    COALESCE((SELECT hbgi FROM lbgi_hbgi WHERE participant_id = p.participant_id), 0) AS hbgi,
    COALESCE((SELECT mean_daily_diff FROM mean_daily_diff WHERE participant_id = p.participant_id), 0) AS mean_daily_diff,
    COALESCE((SELECT conga_hourly FROM conga_hourly WHERE participant_id = p.participant_id), 0) AS conga_hourly,
    COALESCE((SELECT hypoglycemic_episodes FROM liability_index WHERE participant_id = p.participant_id), 0) AS hypoglycemic_episodes,
    COALESCE((SELECT euglycemic_episodes FROM liability_index WHERE participant_id = p.participant_id), 0) AS euglycemic_episodes,
    COALESCE((SELECT hyperglycemic_episodes FROM liability_index WHERE participant_id = p.participant_id), 0) AS hyperglycemic_episodes,
    COALESCE((SELECT liability_index FROM liability_index WHERE participant_id = p.participant_id), 0) AS liability_index,
    COALESCE((SELECT j_index FROM j_index WHERE participant_id = p.participant_id), 0) AS j_index
FROM (
    SELECT DISTINCT participant_id 
    FROM combined_cgm_tracing
) AS p;



------cached tables-------------------------



-- Drop the cached table if it already exists
DROP TABLE IF EXISTS participant_dashboard_cached;
-- Create and populate the table with data from the view
CREATE TABLE participant_dashboard_cached AS
SELECT * FROM study_combined_dashboard_participant_metrics_view;



DROP TABLE IF EXISTS cgm_table_name_cached;

CREATE TABLE cgm_table_name_cached AS 
SELECT DISTINCT 
    pdc.tenant_id,
    pdc.study_id, 
    sm.tbl_name AS table_name, 
    REPLACE(sm.tbl_name, 'uniform_resource_', '') || '.' || ur.nature AS file_name
FROM 
    participant_dashboard_cached pdc
JOIN 
    sqlite_master sm
    ON sm.type = 'table'
    AND sm.name LIKE 'uniform_resource%'
    AND sm.name != 'uniform_resource_transform'
    AND sm.name != 'uniform_resource'
JOIN 
    uniform_resource ur 
    ON ur.uri LIKE '%' || REPLACE(sm.tbl_name, 'uniform_resource_', '') || '%';



DROP TABLE IF EXISTS combined_cgm_tracing_cached;

CREATE TABLE
    combined_cgm_tracing_cached AS
SELECT
    *
FROM
    combined_cgm_tracing;



DROP TABLE IF EXISTS participant_cgm_date_range_cached;

CREATE TABLE
    participant_cgm_date_range_cached AS
SELECT
    *
FROM
    participant_cgm_date_range_view;



