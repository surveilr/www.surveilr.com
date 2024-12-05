DROP TABLE IF EXISTS metric_definitions;
CREATE TABLE IF NOT EXISTS metric_definitions (
    metric_id TEXT PRIMARY KEY,
    metric_name TEXT NOT NULL UNIQUE,
    metric_info TEXT NOT NULL -- Stores JSON with "description" and "formula" details
);

-- Metric: Time CGM Active
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'time_cgm_active', 
    'Time CGM Active', 
    '{"description": "This metric calculates the percentage of time during a specific period (e.g., a day, week, or month) that the CGM device is actively collecting data. It takes into account the total duration of the monitoring period and compares it to the duration during which the device was operational and recording glucose readings.", 
      "formula": "Percentage of time CGM is active = (Duration CGM is active / Total duration of monitoring period) × 100"}'
);

-- Metric: Number of Days CGM Worn
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'number_of_days_cgm_worn', 
    'Number of Days CGM Worn', 
    '{"description": "This metric represents the total number of days the CGM device was worn by the user over a monitoring period. It helps in assessing the adherence to wearing the device as prescribed.", 
      "formula": "Number of days CGM worn = Count of days with CGM data recorded in the monitoring period"}'
);

-- Metric: Mean Glucose
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'mean_glucose', 
    'Mean Glucose', 
    '{"description": "Mean glucose reflects the average glucose level over the monitoring period, serving as an indicator of overall glucose control. It is a simple yet powerful measure in glucose management.", 
      "formula": "Mean glucose = Sum of all glucose readings / Number of readings"}'
);

-- Metric: Glucose Management Indicator (GMI)
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'gmi', 
    'Glucose Management Indicator (GMI)', 
    '{"description": "GMI provides an estimated A1C level based on mean glucose, which can be used as an indicator of long-term glucose control. GMI helps in setting and assessing long-term glucose goals.", 
      "formula": "GMI = (3.31 + 0.02392 × Mean glucose) × 100"}'
);

-- Metric: Glucose Variability
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'glucose_variability', 
    'Glucose Variability', 
    '{"description": "Glucose variability measures fluctuations in glucose levels over time, calculated as the coefficient of variation (%CV). A lower %CV indicates more stable glucose control.", 
      "formula": "Glucose variability = (Standard deviation of glucose / Mean glucose) × 100"}'
);

-- Insert a single record for AGP metrics and axes
INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info)
VALUES (
    'AGP_metrics',
    'Ambulatory Glucose Profile (AGP)',
    '{"description": "The Ambulatory Glucose Profile (AGP) summarizes glucose monitoring data over a specified period, typically 14 to 90 days. It provides a visual representation of glucose levels, helping to identify patterns and variability in glucose management.",
        "metrics": {
            "time_in_target_range": {
                "description": "This metric indicates the percentage of time glucose levels are within the target range (typically 70-180 mg/dL). It is essential for evaluating the effectiveness of diabetes management.",
                "formula": "Percentage in Target Range = (Time in Target Range / Total Time) × 100"
            },
            "below_70": {
                "description": "Tracks the percentage of time glucose levels are below 70 mg/dL, indicating hypoglycemic episodes. Understanding these periods helps prevent severe lows.",
                "formula": "Percentage below 70 mg/dL = (Time below 70 mg/dL / Total Time) × 100"
            },
            "above_180": {
                "description": "Indicates the percentage of time glucose levels exceed 180 mg/dL, highlighting periods of hyperglycemia. Managing these episodes is critical for overall health.",
                "formula": "Percentage above 180 mg/dL = (Time above 180 mg/dL / Total Time) × 100"
            },
            "quartiles": {
                "description": "Quartiles divide glucose readings into four equal parts, helping to understand glucose level distribution. Q1 is the 25th percentile, Q2 is the median, and Q3 is the 75th percentile.",
                "formula": "Quartiles are calculated from sorted glucose readings: Q1 = 25th percentile, Q2 = 50th percentile (median), Q3 = 75th percentile."
            }
        },
        "axes": {
            "x_axis": {
                "description": "Time of Day - The X-axis represents the time of day, segmented into hourly intervals. It typically includes the following time points: 12 AM, 3 AM, 6 AM, 9 AM, 12 PM, 3 PM, 6 PM, 9 PM, and 11 PM."
            },
            "y_axis": {
                "description": "Glucose Levels -The Y-axis represents glucose levels measured in milligrams per deciliter (mg/dL). It typically displays a range from 0 mg/dL to 350 mg/dL, indicating when glucose levels are within, below, or above the target range."
            }
        }
    }'
);

-- Seed SQL for metrics definitions with JSON formatted metric_info

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('liability_index', 'Liability Index', '{"description": "The Liability Index quantifies the risk associated with glucose variability, measured in mg/dL.", "formula": "Liability Index = (Total Duration of monitoring period) * (Average of CGM_i)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('hypoglycemic_episodes', 'Hypoglycemic Episodes', '{"description": "This metric counts the number of occurrences when glucose levels drop below a specified hypoglycemic threshold, indicating potentially dangerous low blood sugar events.", "formula": "Hypoglycemic Episodes = COUNT(CASE WHEN CGM_i < Threshold THEN 1 END)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('euglycemic_episodes', 'Euglycemic Episodes', '{"description": "This metric counts the number of instances where glucose levels remain within the target range, indicating stable and healthy glucose control.", "formula": "Euglycemic Episodes = COUNT(CASE WHEN CGM_i BETWEEN LowThreshold AND HighThreshold THEN 1 END)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('hyperglycemic_episodes', 'Hyperglycemic Episodes', '{"description": "This metric counts the number of instances where glucose levels exceed a certain hyperglycemic threshold, indicating potentially harmful high blood sugar events.", "formula": "Hyperglycemic Episodes = COUNT(CASE WHEN CGM_i > Threshold THEN 1 END)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('m_value', 'M Value', '{"description": "The M Value provides a measure of glucose variability, calculated from the mean of the absolute differences between consecutive CGM values over a specified period.", "formula": "M Value = Mean(ABS(CGM_i - CGM_(i-1)))"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('mean_amplitude', 'Mean Amplitude', '{"description": "Mean Amplitude quantifies the average degree of fluctuation in glucose levels over a given time frame, giving insight into glucose stability.", "formula": "Mean Amplitude = Mean(ABS(CGM_i - Mean(CGM)))"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('average_daily_risk_range', 'Average Daily Risk Range', '{"description": "This metric assesses the average risk associated with daily glucose variations, expressed in mg/dL.", "formula": "Average Daily Risk Range = (Max(CGM) - Min(CGM)) / Number of Days"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('j_index', 'J Index', '{"description": "The J Index calculates glycemic variability using both high and low glucose readings, offering a comprehensive view of glucose fluctuations.", "formula": "J Index = (3.0 * Hypoglycemia Component) + (1.6 * Hyperglycemia Component)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('low_blood_glucose_index', 'Low Blood Glucose Index', '{"description": "This metric quantifies the risk associated with low blood glucose levels over a specified period, measured in mg/dL.", "formula": "Low Blood Glucose Index = SUM(CASE WHEN CGM_i < LowThreshold THEN 1 ELSE 0 END)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('high_blood_glucose_index', 'High Blood Glucose Index', '{"description": "This metric quantifies the risk associated with high blood glucose levels over a specified period, measured in mg/dL.", "formula": "High Blood Glucose Index = SUM(CASE WHEN CGM_i > HighThreshold THEN 1 ELSE 0 END)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('glycemic_risk_assessment', 'Glycemic Risk Assessment Diabetes Equation (GRADE)', '{"description": "GRADE is a metric that combines various glucose metrics to assess overall glycemic risk in individuals with diabetes, calculated using multiple input parameters.", "formula": "GRADE = (Weights based on Low, Normal, High CGM values)"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('continuous_overall_net_glycemic_action', 'Continuous Overall Net Glycemic Action (CONGA)', '{"description": "CONGA quantifies the net glycemic effect over time by evaluating the differences between CGM values at specified intervals.", "formula": "CONGA = Mean(ABS(CGM_i - CGM_(i-k))) for k=1 to n"}');

INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
('mean_of_daily_differences', 'Mean of Daily Differences', '{"description": "This metric calculates the average of the absolute differences between daily CGM readings, giving insight into daily glucose variability.", "formula": "Mean of Daily Differences = Mean(ABS(CGM_i - CGM_(i-1)))"}');


INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
(
    'daily_glucose_profile', 
    'Daily Glucose Profile', 
    '{
        "description": "The Daily Glucose Profile Chart visualizes a participant''s glucose levels over a specified timeframe, typically the last 14 days. Each point on the graph represents a glucose reading taken at a specific hour, indicating the participant''s response to food intake, exercise, medication, and other lifestyle factors. Monitoring these thresholds helps in identifying periods of risk: hypoglycemia, for glucose levels below 70 mg/dL, and hyperglycemia, for levels above 180 mg/dL. This analysis can guide interventions and adjustments in treatment. A consistently high or low profile may lead to further investigation and modifications in treatment plans.",
        "axes": {
            "y_axis": "The y-axis represents glucose levels in mg/dL, with a lower threshold of 70 mg/dL indicating hypoglycemia risk and an upper threshold of 180 mg/dL indicating hyperglycemia risk.",
            "x_axis": "The x-axis spans a week from Friday to Thursday, displaying data between 12 PM and 10 PM each day, focusing on peak active hours for glucose level variations."
        }
    }'
);


INSERT OR IGNORE INTO metric_definitions (metric_id, metric_name, metric_info) VALUES
(
    'goals_for_type_1_and_type_2_diabetes_chart_metrics', 
    'Goals for Type 1 and Type 2 Diabetes chart Metrics', 
    '{
        "description": "Goals for Type 1 and Type 2 Diabetes Chart provides a comprehensive view of a participant''s glucose readings categorized into different ranges over a specified period.",
        "metrics": {
            "very_low": {
                "description": "Represents the count and percentage of readings below 54 mg/dL, which may indicate critical hypoglycemia."
            },
            "low": {
                "description": "Represents the count and percentage of readings between 54 mg/dL and 69 mg/dL, indicating a potential risk of hypoglycemia."
            },
            "in_range": {
                "description": "The percentage and count of readings between 70 mg/dL and 180 mg/dL, considered the target glucose range for optimal health.",
                "target": "over 70%"
            },
            "high": {
                "description": "Includes readings between 181 mg/dL and 250 mg/dL, indicating borderline hyperglycemia."
            },
            "very_high": {
                "description": "Represents readings above 250 mg/dL, indicating potentially dangerous hyperglycemia."
            }
        },
        "formula": "The calculation for each category is performed by counting the total readings in each defined glucose range. The chart shows both the total time spent in each range and the percentage of total readings over a defined monitoring period. Example: If a participant has 100 readings and 10 are below 54 mg/dL, the percentage is calculated as (10 / 100) * 100, resulting in 10%. Usage: The chart aids healthcare providers and participants in understanding glucose variability and making informed decisions.",
        "axes": "x-axis: Time intervals and y-axis: Percentages of time in each range"
    }'
);


DROP VIEW IF EXISTS metric_info_view;
CREATE VIEW metric_info_view AS
SELECT 
    metric_id,
    metric_name,
    json_extract(metric_info, '$.description') AS "Metrics Description",
    json_extract(metric_info, '$.formula') AS formula,    
    json_extract(metric_info, '$.metrics') AS "Metrics Details",    
    json_extract(metric_info, '$.axes') AS "Axes Details"    
FROM 
    metric_definitions;