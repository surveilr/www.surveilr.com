#!/bin/bash
#
# rssd-stats.sql.sh
#
# @description
# This script runs the `rssd-stats.gen.sql` SQL generator script via `sqlite3` and outputs
# the generated SQL to STDOUT. The script can either take the SQLite database path as 
# an argument or use the `SURVEILR_STATEDB_FS_PATH` environment variable. If neither 
# is provided, it defaults to `resource-surveillance.sqlite.db`.
#
# @usage
# ./lib/cookbook/rssd-stats.sql.sh [<path_to_database>]
#
# Generating the SQL and creating the console_information_schema_table_physical table:
#   surveilr shell ./lib/cookbook/rssd-stats.sql.sh
#   - NOTE: because rssd-stats.sql.sh is an executable, surveilr will execute it first
#           and assume STDOUT is SQL and "execute" SQL which will create the table
#
# If no argument is passed:
# ./lib/cookbook/rssd-stats.sql.sh
# It will then check for the `SURVEILR_STATEDB_FS_PATH` environment variable or default 
# to `resource-surveillance.sqlite.db`.
#
# @notes
# - Ensure that `rssd-stats.gen.sql` exists in the same directory as this script.
# - The SQLite database path can be provided as an argument or set via `SURVEILR_STATEDB_FS_PATH`.

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_SCRIPT_PATH="$SCRIPT_DIR/rssd-stats.gen.sql"

# If a database path is provided as an argument, use it, otherwise fallback to env var or default
DB_PATH="${1:-${SURVEILR_STATEDB_FS_PATH:-resource-surveillance.sqlite.db}}"

# Check if the SQL script file exists in the same directory as the script
if [ ! -f "$SQL_SCRIPT_PATH" ]; then
  echo "SQL script file not found: $SQL_SCRIPT_PATH"
  exit 1
fi

# Run the SQL script using sqlite3 and output the generated SQL to STDOUT
sqlite3 "$DB_PATH" < "$SQL_SCRIPT_PATH"
