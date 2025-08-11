INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/index.sql',
      'SELECT
  ''list'' as component,
  ''DATA CONVERSION'' as title,
  ''Here are some useful links.'' as description;        
SELECT ''Device Summary'' as title,
''../health_device_summary.sql'' as link,
''Provides information about the device from which the data conversion is carried out'' as description;            
SELECT ''Files List'' as title,
  ''health_converted_file_list.sql'' as link,
  ''Provides the files being converted'' as description;
SELECT ''Tables'' as title,
  ''health_table_list.sql'' as link,
  ''List of the tables'' as description;        
',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health_device_summary.sql',
      'SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from device_data;      
select 
''text'' as component,
''[Back to Home](health/index.sql)'' as contents_md;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/health_converted_file_list.sql',
      '--select ''Number of Files converted'' as Title,select * from number_of_files_converted as description;
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from converted_files_list;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/health_table_list.sql',
      'SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from converted_table_list;
--select ''table'' as component, ''action'' as markdown;
  --select *,
  --format(''[View](view_table_snapshot.sql?id=%s)'', table_name) as action
  --from converted_table_list
  select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/view_table_snapshot.sql',
      '
select 
''title''   as component,
''Table Data Snapshot'' as contents,
 1    as level;       
select 
''text'' as component,
''Study Table'' as contents_md;  
  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  select *        
  from study_data ; 
  select 
''text'' as component,
''CGM File Meta Data table'' as contents_md;  
  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  select *        
  from cgmfilemetadata_view ; 
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/study_data.sql',
      '
  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from study_data;
  select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
    ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/cgmfilemetadata.sql',
      '
    SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
    SELECT * from cgmfilemetadata_view;
    select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
      ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/author_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from author_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/institution_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from institution_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/investigator_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from investigator_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/lab_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from lab_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/participant_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from participant_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/publication_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from publication_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'health/site_data.sql',
      '
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from site_data;
select 
''text'' as component,
''[Back to Home](index.sql)'' as contents_md;
  ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
