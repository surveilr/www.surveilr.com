CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
    "key" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL
);
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('SQL', 'SQLite SQL Statements', NULL, 'application/sql', '.sql', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JSNYQRG5S0VSW07DH7ME0B3K', 'SQL', 'osQuery MS File Carve', '/etc/passwd', '{"osquery-ms-interval":60,"targets":["linux"],"postProcessCarved":"capturable-executable","persistCarvedAsUR":true}', '
#!/bin/bash

# Read from STDIN and echo it so that it gets stored in the database;
# This is useful for testing the capturable executable context.
cat
    ', '809c50cbe81ec41452e35792419a566c1754c0df', 'Get etc file system', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JSNYQRG5S8W14002HNDSRANQ', 'SQL', 'osQuery MS File Carve', '/var/log/auth.log', '{"osquery-ms-interval":60,"targets":["linux"],"postProcessCarved":"capturable-executable","persistCarvedAsUR":true}', '#!/bin/bash

# ----------------------------------------------------------------------
# emit_auth_log_sql.sh
#
# DESCRIPTION:
#   Reads a nested JSON object from STDIN (no jq) that contains:
#     - .surveilr-osquery-ms.session.osquery-carved-file.path => log file path
#     - .surveilr-osquery-ms.session.osquery-node.id          => node ID
#
#   Emits:
#     - CREATE TABLE and UNIQUE INDEX SQL
#     - INSERT OR IGNORE SQL per parsed auth.log line
#     - Normalizes timestamps, adds source_file and ingestion time
#     - Skips duplicates via raw_line + osquery_node_id index
#
# USAGE:
#   cat input.json | SURVEILR_VERBOSE=1 ./emit_auth_log_sql.sh | sqlite3 db.sqlite
#
# ENV VARS:
#   SURVEILR_CARVED_LOG_TABLE_NAME - default: osquery_ms_carved_var_log_auth_log
#   SURVEILR_VERBOSE=1              - enable verbose debug logs to stderr
# ----------------------------------------------------------------------

read json_input

# Extract path and node ID without jq
SURVEILR_CARVED_PATH=$(echo "$json_input" | sed -n ''s/.*"osquery-carved-file"[^{]*{[^}]*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'')
OSQUERY_NODE_ID=$(echo "$json_input" | sed -n ''s/.*"osquery-node"[^{]*{[^}]*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'')

# Defaults
SURVEILR_CARVED_LOG_TABLE_NAME="${SURVEILR_CARVED_LOG_TABLE_NAME:-osquery_ms_carved_var_log_auth_log}"
SURVEILR_CARVED_LOG_UPSERT="${SURVEILR_CARVED_LOG_UPSERT:-1}"
CURRENT_YEAR=$(date +%Y)
SOURCE_FILE=$(basename "$SURVEILR_CARVED_PATH")

# Emit table schema
cat <<EOF
CREATE TABLE IF NOT EXISTS "$SURVEILR_CARVED_LOG_TABLE_NAME" (
    osquery_node_id TEXT NOT NULL,
    logged_at TEXT NOT NULL,
    hostname TEXT NOT NULL,
    service_name TEXT NOT NULL,
    service_pid INTEGER,
    action TEXT,
    auth_user TEXT,
    target_user TEXT,
    remote_ip TEXT,
    port INTEGER,
    protocol TEXT,
    tty TEXT,
    pwd TEXT,
    command TEXT,
    pam_service TEXT,
    pam_result TEXT,
    raw_line TEXT NOT NULL,
    source_file TEXT,
    ingested_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_${SURVEILR_CARVED_LOG_TABLE_NAME}_unique
ON "$SURVEILR_CARVED_LOG_TABLE_NAME" (
    raw_line, osquery_node_id
);
EOF

# Process auth.log lines
while IFS= read -r line; do
    raw="$line"
    [ -z "$raw" ] && continue

    ts_month=$(echo "$line" | awk ''{print $1}'')
    ts_day=$(echo "$line" | awk ''{print $2}'')
    ts_time=$(echo "$line" | awk ''{print $3}'')
    logged_at=$(date -d "$CURRENT_YEAR $ts_month $ts_day $ts_time" ''+%Y-%m-%d %H:%M:%S'' 2>/dev/null)

    if [ -z "$logged_at" ]; then
        [ "$SURVEILR_VERBOSE" = "1" ] && echo "Skipping invalid timestamp: $raw" >&2
        continue
    fi

    hostname=$(echo "$line" | awk ''{print $4}'')
    service_with_pid=$(echo "$line" | awk ''{print $5}'')
    service_name=$(echo "$service_with_pid" | sed -E ''s/\[.*//'')
    service_pid=$(echo "$service_with_pid" | sed -n ''s/.*\[\([0-9]*\)\].*/\1/p'')

    # Initialize optional fields
    action=""
    auth_user=""
    remote_ip=""
    port=""
    protocol=""
    tty=""
    pwd=""
    command=""
    pam_service=""
    pam_result=""
    target_user=""

    if echo "$line" | grep -q "Accepted"; then
        action="Accepted"
        auth_user=$(echo "$line" | awk ''{print $(NF-4)}'')
        remote_ip=$(echo "$line" | awk ''{print $(NF-2)}'')
        port=$(echo "$line" | awk ''{print $(NF-1)}'')
        protocol=$(echo "$line" | awk ''{print $NF}'')
    elif echo "$line" | grep -q "sudo:"; then
        action="Sudo"
        auth_user=$(echo "$line" | awk ''{print $6}'')
        tty=$(echo "$line" | grep -o ''TTY=[^;]*'' | cut -d= -f2)
        pwd=$(echo "$line" | grep -o ''PWD=[^;]*'' | cut -d= -f2)
        target_user=$(echo "$line" | grep -o ''USER=[^;]*'' | cut -d= -f2)
        command=$(echo "$line" | grep -o ''COMMAND=.*'' | cut -d= -f2-)
    elif echo "$line" | grep -q "pam_unix"; then
        pam_service=$(echo "$line" | grep -o ''pam_unix([^)]*)'' | cut -d\( -f2 | cut -d\) -f1 | cut -d: -f1)
        pam_result=$(echo "$line" | awk -F'': '' ''{print $NF}'')
        action="PAM"
        target_user=$(echo "$line" | grep -o ''user [^ ]*'' | awk ''{print $2}'')
    fi

    esc_raw=$(echo "$raw" | cut -c1-1000 | sed "s/''/''''/g")
    esc_command=$(echo "$command" | sed "s/''/''''/g")
    esc_pwd=$(echo "$pwd" | sed "s/''/''''/g")

    printf "INSERT OR IGNORE INTO \"$SURVEILR_CARVED_LOG_TABLE_NAME\" (\n"
    printf "  osquery_node_id, logged_at, hostname, service_name, service_pid,\n"
    printf "  action, auth_user, target_user, remote_ip, port, protocol,\n"
    printf "  tty, pwd, command, pam_service, pam_result, raw_line, source_file\n"
    printf ") VALUES (\n"
    printf "  ''%s'', ''%s'', ''%s'', ''%s'', %s,\n" "$OSQUERY_NODE_ID" "$logged_at" "$hostname" "$service_name" "${service_pid:-NULL}"
    printf "  ''%s'', ''%s'', ''%s'', ''%s'', %s, ''%s'',\n" "$action" "$auth_user" "$target_user" "$remote_ip" "${port:-NULL}" "$protocol"
    printf "  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'',\n" "$tty" "$esc_pwd" "$esc_command" "$pam_service" "$pam_result"
    printf "  ''%s'', ''%s''\n" "$esc_raw" "$SOURCE_FILE"
    printf ");\n"
done < "$SURVEILR_CARVED_PATH"
', '93c06ab8cd630556cacb44eac5e8bc3c2b6eb427', 'Transform /var/log/auth.log from each osQuery-MS node into a combined type-safe parsed table called osquery_ms_carved_var_log_auth_log', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
