DROP VIEW IF EXISTS linkedin_connection_overview;
CREATE VIEW linkedin_connection_overview AS
SELECT 
    c."First Name" AS first_name,
    c."Last Name" AS last_name,
    c."Email Address" AS email,
    c."Company" AS company,
    c."Position" AS position,
    c."Connected On" AS connection_date
FROM uniform_resource_connections c;

DROP VIEW IF EXISTS linkedin_connection_count;
CREATE VIEW linkedin_connection_count AS
SELECT 
    COUNT(*) as connection_count
FROM uniform_resource_connections;

DROP VIEW IF EXISTS linkedin_top_skills;
CREATE VIEW linkedin_top_skills AS
SELECT 
    Name AS skills
FROM uniform_resource_skills
ORDER BY skills ASC;

DROP VIEW IF EXISTS linkedin_top_skills_count;
CREATE VIEW linkedin_top_skills_count AS
SELECT 
    COUNT(Name) AS total_skills
FROM uniform_resource_skills;

DROP VIEW IF EXISTS linkedin_employment_timeline_count;
CREATE VIEW linkedin_employment_timeline_count AS
SELECT 
    COUNT(*) as time_line_count 
FROM uniform_resource_positions p;

DROP VIEW IF EXISTS linkedin_employment_timeline;
CREATE VIEW linkedin_employment_timeline AS
SELECT 
    p."Company Name" AS company_name,
    p."Title" AS job_title,
    p."Started On" AS start_date,
    p."Finished On" AS end_date
FROM uniform_resource_positions p
ORDER BY start_date DESC;