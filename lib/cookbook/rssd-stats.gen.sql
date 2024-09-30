/*
 * @file lib/cookbook/rssd-stats.gen.sql
 * 
 * @description
 * This script dynamically generates SQL to create a permanent table named 
 * `console_information_schema_table_physical` that provides metadata about all 
 * user-defined tables in a SQLite database. It gathers and stores the following 
 * information for each table:
 * 
 * - `table_name`: The name of the user-defined table.
 * - `total_columns`: The total number of columns in the table, retrieved using 
 *   `pragma_table_info()`.
 * - `total_rows`: The total number of rows in the table, calculated by querying 
 *   the table itself.
 * - `size_bytes`: The size of the table in bytes, derived from the `dbstat` virtual 
 *   table, which provides low-level information about the physical size of tables.
 * - `prepared_at`: A timestamp using `CURRENT_TIMESTAMP` that records when the 
 *   metadata was prepared.
 * 
 * @note
 * SQLite restricts the use of certain virtual tables, such as `dbstat`, in views, 
 * which is why a table is used to store the metadata instead of a view. Using a 
 * table also helps avoid recalculating expensive operations like row counting or 
 * size calculation every time the data is queried.
 * 
 * @usage
 * This script can be used with the SQLite database `resource-surveillance.sqlite.db` 
 * by executing the following commands in sequence:
 * 
 * 1. Generate the SQL dynamically and pipe the output to SQLite for execution:
 * 
 * ```bash
 * cat ../../cookbook/rssd-stats.gen.sql | sqlite3 resource-surveillance.sqlite.db | \
 * sqlite3 resource-surveillance.sqlite.db
 * ```
 * 
 * 2. Query the newly created `console_information_schema_table_physical` table 
 * to retrieve metadata for all user-defined tables:
 * 
 * ```bash
 * sqlite3 resource-surveillance.sqlite.db -cmd "SELECT * FROM console_information_schema_table_physical;"
 * ```
 * 
 * @example
 * Suppose you have this script saved as `lib/cookbook/rssd-stats.gen.sql`, and you 
 * have a SQLite database called `resource-surveillance.sqlite.db`. You can run 
 * the following command to generate and execute the SQL, followed by querying 
 * the metadata table in one go:
 * 
 * ```bash
 * cat ../../cookbook/rssd-stats.gen.sql | sqlite3 resource-surveillance.sqlite.db | \
 * sqlite3 resource-surveillance.sqlite.db && \
 * sqlite3 resource-surveillance.sqlite.db -cmd "SELECT * FROM console_information_schema_table_physical;"
 * ```
 * 
 * This will:
 * - Generate and execute the SQL that creates the `console_information_schema_table_physical` table.
 * - Drop the `console_information_schema_table_physical` table if it already exists, 
 *   and recreate it with up-to-date metadata.
 * - Query the newly created table to return the metadata for all user-defined tables.
 * 
 * @notes
 * - Re-run this script periodically if the structure or content of the database changes.
 * - The `prepared_at` column records when the metadata was last generated.
 */

/* SQL Generator Script */
WITH table_selects AS (
  SELECT
    'SELECT ''' || name || ''' AS table_name, ' ||
    '(SELECT COUNT(*) FROM pragma_table_info(''' || name || ''')) AS total_columns, ' ||
    '(SELECT COUNT(*) FROM ' || quote(name) || ') AS total_rows, ' ||
    '(SELECT IFNULL(SUM(pgsize), 0) FROM dbstat WHERE name = ''' || name || ''') AS size_bytes, ' ||
    'CURRENT_TIMESTAMP AS prepared_at'
  AS select_statement
  FROM sqlite_master
  WHERE type = 'table'
    AND name NOT LIKE 'sqlite_%'
)
SELECT
  'DROP TABLE IF EXISTS console_information_schema_table_physical;' || char(10) ||
  'CREATE TABLE console_information_schema_table_physical AS' || char(10) || 
  GROUP_CONCAT(
    '    ' || select_statement,
    ' UNION ALL' || char(10)
  ) || ';'
FROM table_selects;
