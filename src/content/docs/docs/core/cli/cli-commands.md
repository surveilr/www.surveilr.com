---
title: Command-Line Help for Surveilr
description: This document contains the help content for the `surveilr` command-line program.
---

This document contains the help content for the `surveilr` command-line program.


**Command Overview:**

- [`surveilr`](#surveilr)
        - [**Subcommands:**](#subcommands)
        - [**Options:**](#options)
- [`surveilr admin`](#surveilr-admin)
        - [**Subcommands:**](#subcommands-1)
- [`surveilr admin init`](#surveilr-admin-init)
        - [**Options:**](#options-1)
- [`surveilr admin merge`](#surveilr-admin-merge)
        - [**Options:**](#options-2)
- [`surveilr admin cli-help-md`](#surveilr-admin-cli-help-md)
- [`surveilr admin test`](#surveilr-admin-test)
        - [**Subcommands:**](#subcommands-2)
- [`surveilr admin test classifiers`](#surveilr-admin-test-classifiers)
        - [**Options:**](#options-3)
- [`surveilr admin credentials`](#surveilr-admin-credentials)
        - [**Subcommands:**](#subcommands-3)
- [`surveilr admin credentials microsoft-365`](#surveilr-admin-credentials-microsoft-365)
        - [**Options:**](#options-4)
- [`surveilr capturable-exec`](#surveilr-capturable-exec)
        - [**Subcommands:**](#subcommands-4)
- [`surveilr capturable-exec ls`](#surveilr-capturable-exec-ls)
        - [**Options:**](#options-5)
- [`surveilr capturable-exec test`](#surveilr-capturable-exec-test)
        - [**Subcommands:**](#subcommands-5)
- [`surveilr capturable-exec test file`](#surveilr-capturable-exec-test-file)
        - [**Options:**](#options-6)
- [`surveilr capturable-exec test task`](#surveilr-capturable-exec-test-task)
        - [**Options:**](#options-7)
- [`surveilr ingest`](#surveilr-ingest)
        - [**Subcommands:**](#subcommands-6)
- [`surveilr ingest files`](#surveilr-ingest-files)
        - [**Options:**](#options-8)
- [`surveilr ingest tasks`](#surveilr-ingest-tasks)
        - [**Options:**](#options-9)
- [`surveilr ingest imap`](#surveilr-ingest-imap)
        - [**Subcommands:**](#subcommands-7)
        - [**Options:**](#options-10)
- [`surveilr ingest imap microsoft-365`](#surveilr-ingest-imap-microsoft-365)
        - [**Options:**](#options-11)
- [`surveilr ingest plm`](#surveilr-ingest-plm)
        - [**Subcommands:**](#subcommands-8)
        - [**Options:**](#options-12)
- [`surveilr ingest plm github`](#surveilr-ingest-plm-github)
        - [**Options:**](#options-13)
- [`surveilr ingest plm jira`](#surveilr-ingest-plm-jira)
        - [**Options:**](#options-14)
- [`surveilr ingest plm gitlab`](#surveilr-ingest-plm-gitlab)
        - [**Options:**](#options-15)
- [`surveilr ingest plm open-project`](#surveilr-ingest-plm-open-project)
        - [**Options:**](#options-16)
- [`surveilr notebooks`](#surveilr-notebooks)
        - [**Subcommands:**](#subcommands-9)
        - [**Options:**](#options-17)
- [`surveilr notebooks cat`](#surveilr-notebooks-cat)
        - [**Options:**](#options-18)
- [`surveilr notebooks ls`](#surveilr-notebooks-ls)
        - [**Options:**](#options-19)
- [`surveilr web-ui`](#surveilr-web-ui)
        - [**Options:**](#options-20)
- [`surveilr udi`](#surveilr-udi)
        - [**Subcommands:**](#subcommands-10)
- [`surveilr udi pgp`](#surveilr-udi-pgp)
        - [**Subcommands:**](#subcommands-11)
        - [**Options:**](#options-21)
- [`surveilr udi pgp osquery`](#surveilr-udi-pgp-osquery)
        - [**Subcommands:**](#subcommands-12)
- [`surveilr udi pgp osquery local`](#surveilr-udi-pgp-osquery-local)
        - [**Options:**](#options-22)
- [`surveilr udi pgp osquery remote`](#surveilr-udi-pgp-osquery-remote)
        - [**Options:**](#options-23)
- [`surveilr udi admin`](#surveilr-udi-admin)
- [`surveilr upgrade`](#surveilr-upgrade)
        - [**Options:**](#options-24)
- [`surveilr orchestrate`](#surveilr-orchestrate)
        - [**Subcommands:**](#subcommands-13)
        - [**Options:**](#options-25)
- [`surveilr orchestrate sessions`](#surveilr-orchestrate-sessions)
- [`surveilr orchestrate notebooks`](#surveilr-orchestrate-notebooks)
        - [**Options:**](#options-26)
- [`surveilr orchestrate transform-csv`](#surveilr-orchestrate-transform-csv)
        - [**Options:**](#options-27)
- [`surveilr orchestrate transform-html`](#surveilr-orchestrate-transform-html)
        - [**Options:**](#options-28)
- [`surveilr orchestrate transform-xml`](#surveilr-orchestrate-transform-xml)
        - [**Options:**](#options-29)
- [`surveilr orchestrate transform-markdown`](#surveilr-orchestrate-transform-markdown)
- [`surveilr doctor`](#surveilr-doctor)
- [`surveilr shell`](#surveilr-shell)
        - [**Arguments:**](#arguments)
        - [**Options:**](#options-30)

## `surveilr`

**Usage:** `surveilr [OPTIONS] <COMMAND>`

###### **Subcommands:**

* `admin` — Admin / maintenance utilities
* `capturable-exec` — Capturable Executables (CE) maintenance tools
* `ingest` — Ingest content from device file system and other sources
* `notebooks` — Notebooks maintenance utilities
* `web-ui` — Configuration to start the SQLPage webserver
* `udi` — Universal Data Infrastructure
* `upgrade` — Update `surveilr` to latest or specific version
* `orchestrate` — Enable RSSDs to execute SQL-based validation and log "issues," "warnings," and other notifications into the orchestration tables
* `doctor` — Print out the versions of external dependencies that `surveilr` uses on the current host
* `shell` — Execute `sqlite3` and `duckdb` commands directly with unopinionated and very lightweight logging. This command is the generalized version of `orchestrate`

###### **Options:**

* `--device-name <DEVICE_NAME>` — How to identify this device

  Default value: `Abdulbaasit`
* `-d`, `--debug` — Turn debugging information on (repeat for higher levels)
* `--log-mode <LOG_MODE>` — Output logs in json format

  Possible values: `full`, `json`, `compact`

* `--log-file <LOG_FILE>` — File for logs to be written to



## `surveilr admin`

Admin / maintenance utilities

**Usage:** `surveilr admin <COMMAND>`

###### **Subcommands:**

* `init` — initialize an empty database with bootstrap.sql
* `merge` — merge multiple surveillance state databases into a single one
* `cli-help-md` — generate CLI help markdown
* `test` — generate CLI help markdown
* `credentials` — emit credentials



## `surveilr admin init`

initialize an empty database with bootstrap.sql

**Usage:** `surveilr admin init [OPTIONS]`

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `-r`, `--remove-existing-first` — remove the existing database first

  Possible values: `true`, `false`

* `--with-device` — add the current device in the empty database's device table

  Possible values: `true`, `false`




## `surveilr admin merge`

merge multiple surveillance state databases into a single one

**Usage:** `surveilr admin merge [OPTIONS]`

###### **Options:**

* `-c`, `--candidates <CANDIDATES>` — one or more DB name globs to match and merge

  Default value: `*.db`
* `-i`, `--ignore-candidates <IGNORE_CANDIDATES>` — one or more DB name globs to ignore if they match
* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database with merged content

  Default value: `resource-surveillance-aggregated.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `-r`, `--remove-existing-first` — remove the existing database first

  Possible values: `true`, `false`

* `--sql-only` — only generate SQL and emit to STDOUT (no actual merge)

  Possible values: `true`, `false`

* `--detach-on-exit` — Add `DETACH` statements to the SQL statements for the merge

  Default value: `false`

  Possible values: `true`, `false`

* `-p`, `--table-name-patterns <TABLE_NAME_PATTERNS>` — List of table name in SQL like pattern to match

  Default value: `uniform_resource_%`



## `surveilr admin cli-help-md`

generate CLI help markdown

**Usage:** `surveilr admin cli-help-md`



## `surveilr admin test`

generate CLI help markdown

**Usage:** `surveilr admin test <COMMAND>`

###### **Subcommands:**

* `classifiers` — test capturable executables files



## `surveilr admin test classifiers`

test capturable executables files

**Usage:** `surveilr admin test classifiers [OPTIONS]`

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `--builtins` — only show the builtins, not from the database

  Possible values: `true`, `false`




## `surveilr admin credentials`

emit credentials

**Usage:** `surveilr admin credentials <COMMAND>`

###### **Subcommands:**

* `microsoft-365` — microsoft 365 credentials



## `surveilr admin credentials microsoft-365`

microsoft 365 credentials

**Usage:** `surveilr admin credentials microsoft-365 [OPTIONS] --client-id <CLIENT_ID> --client-secret <CLIENT_SECRET>`

###### **Options:**

* `-i`, `--client-id <CLIENT_ID>` — Client ID of the application from MSFT Azure App Directory
* `-s`, `--client-secret <CLIENT_SECRET>` — Client Secret of the application from MSFT Azure App Directory
* `-r`, `--redirect-uri <REDIRECT_URI>` — Redirect URL. Base redirect URL path. It gets concatenated with the server address to form the full redirect url, when using the `auth_code` mode for token generation
* `--env` — Emit values to stdout

  Possible values: `true`, `false`

* `--export` — Emit values to stdout with the "export" syntax right in front to enable direct sourcing

  Possible values: `true`, `false`




## `surveilr capturable-exec`

Capturable Executables (CE) maintenance tools

**Usage:** `surveilr capturable-exec <COMMAND>`

###### **Subcommands:**

* `ls` — list potential capturable executables
* `test` — test capturable executables files



## `surveilr capturable-exec ls`

list potential capturable executables

**Usage:** `surveilr capturable-exec ls [OPTIONS]`

###### **Options:**

* `-r`, `--root-fs-path <ROOT_FS_PATH>` — one or more root paths to ingest

  Default value: `.`
* `--markdown` — emit the results as markdown, not a simple table

  Possible values: `true`, `false`




## `surveilr capturable-exec test`

test capturable executables files

**Usage:** `surveilr capturable-exec test <COMMAND>`

###### **Subcommands:**

* `file` — test capturable executables files
* `task` — Execute a task string as if it was run by `ingest tasks` and show the output



## `surveilr capturable-exec test file`

test capturable executables files

**Usage:** `surveilr capturable-exec test file --fs-path <FS_PATH>`

###### **Options:**

* `-f`, `--fs-path <FS_PATH>`



## `surveilr capturable-exec test task`

Execute a task string as if it was run by `ingest tasks` and show the output

**Usage:** `surveilr capturable-exec test task [OPTIONS]`

###### **Options:**

* `-s`, `--stdin` — send commands in via STDIN the same as with `ingest tasks` and just emit the output

  Possible values: `true`, `false`

* `-t`, `--task <TASK>` — one or more commands that would work as a Deno Task line
* `--cwd <CWD>` — use this as the current working directory (CWD)



## `surveilr ingest`

Ingest content from device file system and other sources

**Usage:** `surveilr ingest <COMMAND>`

###### **Subcommands:**

* `files` — Ingest content from device file system and other sources
* `tasks` — Notebooks maintenance utilities
* `imap` — Ingest content from email boxes When multiple filters (to, cc, bcc, subject, sent_on and status flags) are specified, the result is the intersection of all the messages that match those filters. Or, in other words, only messages that match all the filters
* `plm` — Ingest content from issues



## `surveilr ingest files`

Ingest content from device file system and other sources

**Usage:** `surveilr ingest files [OPTIONS]`

###### **Options:**

* `--dry-run` — don't run the ingestion, just report statistics

  Possible values: `true`, `false`

* `-b`, `--behavior <BEHAVIOR>` — the behavior name in `behavior` table
* `-r`, `--root-fs-path <ROOT_FS_PATH>` — one or more root paths to ingest

  Default value: `.`
* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `--include-state-db-in-ingestion` — include the surveil database in the ingestion candidates

  Possible values: `true`, `false`

* `--stats` — show stats as an ASCII table after completion

  Possible values: `true`, `false`

* `--stats-json` — show stats in JSON after completion

  Possible values: `true`, `false`

* `--save-behavior <SAVE_BEHAVIOR>` — save the options as a new behavior
* `--tenant-id <TENANT_ID>` — Tenant Identifier for multitenancy
* `--tenant-name <TENANT_NAME>` — Tenant name for multitenancy
* `--csv-transform-auto` — Auto Transfrom CSV ingested from files

  Default value: `false`

  Possible values: `true`, `false`




## `surveilr ingest tasks`

Notebooks maintenance utilities

**Usage:** `surveilr ingest tasks [OPTIONS]`

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `--stdin` — read tasks from STDIN

  Possible values: `true`, `false`

* `--stats` — show session stats after completion

  Possible values: `true`, `false`

* `--stats-json` — show session stats as JSON after completion

  Possible values: `true`, `false`




## `surveilr ingest imap`

Ingest content from email boxes When multiple filters (to, cc, bcc, subject, sent_on and status flags) are specified, the result is the intersection of all the messages that match those filters. Or, in other words, only messages that match all the filters

**Usage:** `surveilr ingest imap [OPTIONS] [COMMAND]`

###### **Subcommands:**

* `microsoft-365` — Microsoft 365 Credentials

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `-u`, `--username <USERNAME>` — email address
* `-p`, `--password <PASSWORD>` — password to the email. mainly an app password. See the documentation on how to create an app password
* `-a`, `--server-addr <SERVER_ADDR>` — IMAP server address. e.g imap.gmail.com or outlook.office365.com
* `--port <PORT>` — IMAP server port

  Default value: `993`
* `-f`, `--folder <FOLDER>` — Mailboxes to read from. i.e folders. Takes a regular expression matching the folder names. The default is a "*" which means all folders

  Default value: `*`
* `-s`, `--status <STATUS>` — Status of the messages to be ingested

  Possible values: `all`, `unread`, `read`, `starred`, `deleted`, `draft`

* `-b`, `--batch-size <BATCH_SIZE>` — Maximum number of messages to be ingested

  Default value: `1000`
* `-e`, `--extract-attachments <EXTRACT_ATTACHMENTS>` — Extract Attachments

  Possible values:
  - `no`:
    Pass "no" or omit to skip extracting attachments
  - `yes`:
    Pass "yes" to extract to put into `ur_ingest_session_attachment table` only
  - `uniform-resource`:
    Pass "uniform-resource" to put into both `ur_ingest_session_attachment`` table and `uniform_resource`` table

* `--progress` — Display progress animation for emails downloading and processing

  Default value: `false`

  Possible values: `true`, `false`

* `--subject <SUBJECT>` — Filter messages that contain the specified string in the SUBJECT field
* `--cc <CC>` — Filter messages that contain the specified string in the CC field
* `--bcc <BCC>` — Filter messages that contain the specified string in the BCC field
* `--filter-text <FILTER_TEXT>` — Messages that contain the specified string in the header or body of the message
* `--from <FROM>` — Filter messages that contain the specified string in the FROM field
* `--to <TO>` — Filter messages that contain the specified string in the TO field
* `--sent-on <SENT_ON>` — Messages whose [RFC-2822] Date: header (disregarding time and timezone) is within the specified date. Note: the format must be like: 1-Feb-1994. Check this RFC (https://datatracker.ietf.org/doc/html/rfc2822) for more details



## `surveilr ingest imap microsoft-365`

Microsoft 365 Credentials

**Usage:** `surveilr ingest imap microsoft-365 [OPTIONS] --client-id <CLIENT_ID> --client-secret <CLIENT_SECRET> --mode <MODE>`

###### **Options:**

* `-i`, `--client-id <CLIENT_ID>` — Client ID of the application from MSFT Azure App Directory
* `-s`, `--client-secret <CLIENT_SECRET>` — Client Secret of the application from MSFT Azure App Directory
* `-m`, `--mode <MODE>` — The mode to generate an access_token. Default is 'DeviceCode'

  Possible values: `auth-code`, `device-code`

* `-a`, `--addr <ADDR>` — Address to start the authentication server on, when using the `auth_code` mode for token generation

  Default value: `http://127.0.0.1:8000`
* `-r`, `--redirect-uri <REDIRECT_URI>` — Redirect URL. Base redirect URL path. It gets concatenated with the server address to form the full redirect url, when using the `auth_code` mode for token generation

  Default value: `/redirect`
* `-p`, `--port <PORT>` — Port to bind the server to

  Default value: `8000`



## `surveilr ingest plm`

Ingest content from issues

**Usage:** `surveilr ingest plm [OPTIONS] <COMMAND>`

###### **Subcommands:**

* `github` — Github credentials
* `jira` — Jira Instance
* `gitlab` — A Gitlab instance
* `open-project` — An Open Project Instance

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order
* `-b`, `--batch-size <BATCH_SIZE>` — Maximum number of issues to be ingested

  Default value: `1000`
* `-e`, `--extract-attachments <EXTRACT_ATTACHMENTS>` — Extract Attachments

  Possible values:
  - `no`:
    Pass "no" or omit to skip extracting attachments
  - `yes`:
    Pass "yes" to extract to put into `ur_ingest_session_attachment table` only
  - `uniform-resource`:
    Pass "uniform-resource" to put into both `ur_ingest_session_attachment`` table and `uniform_resource`` table

* `--progress` — Display progress animation for PLM resources downloading and processing

  Default value: `false`

  Possible values: `true`, `false`




## `surveilr ingest plm github`

Github credentials

**Usage:** `surveilr ingest plm github [OPTIONS] --org <ORG> --repo <REPO>`

###### **Options:**

* `-o`, `--org <ORG>` — Organisation Name
* `-t`, `--token <TOKEN>` — Github PAT for accessing private repositiories
* `-r`, `--repo <REPO>` — Name of the repository to fetch issues from
* `-s`, `--state <STATE>` — Filter the github issues by state. Defaults to All

  Possible values:
  - `all`:
    All Issues
  - `open`:
    Open issues only
  - `closed`:
    Closed Issues only




## `surveilr ingest plm jira`

Jira Instance

**Usage:** `surveilr ingest plm jira [OPTIONS] --org <ORG> --project <PROJECT>`

###### **Options:**

* `-o`, `--org <ORG>` — The host to fetch projects from. e.g https://issues.redhat.com
* `-k`, `--key <KEY>` — API Key for accessing private instances
* `-u`, `--user <USER>` — Username for accessing private instances using the Basic Authentication mechanism
* `-p`, `--project <PROJECT>` — Name of the project for fetch issues from



## `surveilr ingest plm gitlab`

A Gitlab instance

**Usage:** `surveilr ingest plm gitlab [OPTIONS] --host <HOST> --organization <ORGANIZATION> --token <TOKEN> --project <PROJECT>`

###### **Options:**

* `--host <HOST>` — The Gitlab host. e.g., gitlab.com
* `-o`, `--organization <ORGANIZATION>` — The organisation name in the host. e.g, gitlab-org
* `-t`, `--token <TOKEN>` — Gitlab PAT for accessing private repositiories
* `-p`, `--project <PROJECT>` — Name of the project to fetch issues from
* `-s`, `--state <STATE>` — Filter the gitlab issues by state. Defaults to All

  Possible values:
  - `all`:
    All Issues
  - `open`:
    Open issues only
  - `closed`:
    Closed Issues only




## `surveilr ingest plm open-project`

An Open Project Instance

**Usage:** `surveilr ingest plm open-project --host <HOST> --token <TOKEN> --project <PROJECT>`

###### **Options:**

* `--host <HOST>` — The Open Project host. e.g., community.open-project.com
* `-t`, `--token <TOKEN>` — Open Project Token for accessing private instances
* `-p`, `--project <PROJECT>` — Name of the project to fetch issues from



## `surveilr notebooks`

Notebooks maintenance utilities

**Usage:** `surveilr notebooks [OPTIONS] <COMMAND>`

###### **Subcommands:**

* `cat` — Notebooks' cells emit utilities
* `ls` — list all notebooks

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-I`, `--state-db-init-sql <STATE_DB_INIT_SQL>` — one or more globs to match as SQL files and batch execute them in alpha order



## `surveilr notebooks cat`

Notebooks' cells emit utilities

**Usage:** `surveilr notebooks cat [OPTIONS]`

###### **Options:**

* `-n`, `--notebook <NOTEBOOK>` — search for these notebooks (include % for LIKE otherwise =)
* `-c`, `--cell <CELL>` — search for these cells (include % for LIKE otherwise =)
* `-s`, `--seps` — add separators before each cell

  Possible values: `true`, `false`




## `surveilr notebooks ls`

list all notebooks

**Usage:** `surveilr notebooks ls [OPTIONS]`

###### **Options:**

* `-m`, `--migratable` — list all SQL cells that will be handled by execute_migrations

  Possible values: `true`, `false`




## `surveilr web-ui`

Configuration to start the SQLPage webserver

**Usage:** `surveilr web-ui [OPTIONS] --port <PORT>`

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-u`, `--url-base-path <URL_BASE_PATH>` — Base URL for SQLPage to start from. Defaults to "/index.sql"

  Default value: `/`
* `-p`, `--port <PORT>` — Port to bind sqplage webserver to
* `--host <HOST>` — Host to bind the server to

  Default value: `localhost`
* `-o`, `--otel <OTEL>` — Port that any OTEL compatible service is running on
* `-m`, `--metrics <METRICS>` — Metrics port. Used for scraping metrics with tools like OpenObserve or Prometheus
* `--open` — Open the SQLPage webpage in the default browser

  Default value: `false`

  Possible values: `true`, `false`




## `surveilr udi`

Universal Data Infrastructure

**Usage:** `surveilr udi <COMMAND>`

###### **Subcommands:**

* `pgp` — UDI PostgreSQL Proxy for remote SQL starts up a server which pretends to be PostgreSQL but proxies its SQL to other CLI services with SQL-like interface (called SQL Suppliers)
* `admin` — 



## `surveilr udi pgp`

UDI PostgreSQL Proxy for remote SQL starts up a server which pretends to be PostgreSQL but proxies its SQL to other CLI services with SQL-like interface (called SQL Suppliers)

**Usage:** `surveilr udi pgp [OPTIONS] [COMMAND]`

###### **Subcommands:**

* `osquery` — query a machine

###### **Options:**

* `-a`, `--addr <ADDR>` — IP address to bind udi-pgp to

  Default value: `127.0.0.1:5432`
* `-u`, `--username <USERNAME>` — Username for authentication
* `-p`, `--password <PASSWORD>` — Password for authentication
* `-i`, `--supplier-id <SUPPLIER_ID>` — Identification for the supplier which will be passed to the client. e.g surveilr udi pgp -u john -p doe -i test-supplier osquery local The psql comand will be: psql -h 127.0.0.1 -p 5432 -d "test-supplier" -c "select * from system_info"
* `-c`, `--config <CONFIG>` — Config file for UDI-PGP. Either a .ncl file or JSON file
* `-d`, `--admin-state-fs-path <ADMIN_STATE_FS_PATH>` — Admin SQLite Database path for state management

  Default value: `resource-surveillance-admin.sqlite.db`



## `surveilr udi pgp osquery`

query a machine

**Usage:** `surveilr udi pgp osquery <COMMAND>`

###### **Subcommands:**

* `local` — execute osquery on the local machine
* `remote` — execute osquery on remote hosts



## `surveilr udi pgp osquery local`

execute osquery on the local machine

**Usage:** `surveilr udi pgp osquery local [OPTIONS]`

###### **Options:**

* `-a`, `--atc-file-path <ATC_FILE_PATH>` — ATC Configuration File path



## `surveilr udi pgp osquery remote`

execute osquery on remote hosts

**Usage:** `surveilr udi pgp osquery remote [OPTIONS]`

###### **Options:**

* `-s`, `--ssh-targets <SSH_TARGETS>` — SSH details of hosts to execute osquery on including and identifier. e,g. "user@127.0.0.1:22,john"/"user@host.com:1234,doe"



## `surveilr udi admin`

**Usage:** `surveilr udi admin`



## `surveilr upgrade`

Update `surveilr` to latest or specific version

**Usage:** `surveilr upgrade [OPTIONS]`

###### **Options:**

* `-v`, `--version <VERSION>` — The version to update to. If not present, it defaults to the latest
* `-y`, `--yes` — Skip confirmation

  Default value: `false`

  Possible values: `true`, `false`

* `-t`, `--token <TOKEN>` — An optional Github autehntication token to authenticate requests or to prevent rate limiting



## `surveilr orchestrate`

Enable RSSDs to execute SQL-based validation and log "issues," "warnings," and other notifications into the orchestration tables

**Usage:** `surveilr orchestrate [OPTIONS] [COMMAND]`

###### **Subcommands:**

* `sessions` — 
* `notebooks` — 
* `transform-csv` — Resource transformation utilities for CSV data stored in the RSSD
* `transform-html` — Resource transformation utilities for CSV data stored in the RSSD
* `transform-xml` — Resource transformation utilities for CSV data stored in the RSSD
* `transform-markdown` — 

###### **Options:**

* `-s`, `--sql <SCRIPTS>` — one or more globs to match as SQL files and batch execute them in alpha order
* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `-n`, `--nature <NATURE>` — Nature of the orchestration

  Possible values: `v&v`, `deidentification`, `surveilr-transform-csv`, `surveilr-transform-html`, `surveilr-transform-xml`

* `--save-script` — Save script content to RSSD

  Default value: `true`

  Possible values: `true`, `false`




## `surveilr orchestrate sessions`

**Usage:** `surveilr orchestrate sessions`



## `surveilr orchestrate notebooks`

**Usage:** `surveilr orchestrate notebooks [OPTIONS]`

###### **Options:**

* `-n`, `--notebook <NOTEBOOK>` — search for these notebooks (include % for LIKE otherwise =)
* `-c`, `--cell <CELL>` — search for these cells (include % for LIKE otherwise =)
* `-a`, `--arg <ARG>` — create a temp table called surveilr_orchestration_session_arg with columns session_id, key and value which will simple insert all args as rows in the temp table that the code_notebook_cell SQL code can rely on



## `surveilr orchestrate transform-csv`

Resource transformation utilities for CSV data stored in the RSSD

**Usage:** `surveilr orchestrate transform-csv [OPTIONS]`

###### **Options:**

* `-r`, `--reset-transforms` — Indicates if all current transforms should be deleted before running the transform

  Default value: `false`

  Possible values: `true`, `false`

* `-m`, `--reduce-data-duplication` — Nulls out the `content` table in `uniform_resource` for those content which were transformed to tables

  Default value: `true`

  Possible values: `true`, `false`




## `surveilr orchestrate transform-html`

Resource transformation utilities for CSV data stored in the RSSD

**Usage:** `surveilr orchestrate transform-html [OPTIONS]`

###### **Options:**

* `-r`, `--reset-transforms` — Indicates if all current transforms should be deleted before running the transform

  Default value: `false`

  Possible values: `true`, `false`

* `-m`, `--reduce-data-duplication` — Nulls out the `content` table in `uniform_resource` for those content which were transformed to tables

  Default value: `true`

  Possible values: `true`, `false`

* `-c`, `--css-select <CSS_SELECT>` — List of CSS selectors with names and values. e.g. -css-select="name_of_select_query:div > p" i.e, select all p tags in a div tag
* `-f`, `--format <FORMAT>` — Format the content should be transformed into

  Default value: `json`

  Possible values: `json`




## `surveilr orchestrate transform-xml`

Resource transformation utilities for CSV data stored in the RSSD

**Usage:** `surveilr orchestrate transform-xml [OPTIONS]`

###### **Options:**

* `-r`, `--reset-transforms` — Indicates if all current transforms should be deleted before running the transform

  Default value: `false`

  Possible values: `true`, `false`

* `-m`, `--reduce-data-duplication` — Nulls out the `content` table in `uniform_resource` for those content which were transformed to tables

  Default value: `true`

  Possible values: `true`, `false`




## `surveilr orchestrate transform-markdown`

**Usage:** `surveilr orchestrate transform-markdown`



## `surveilr doctor`

Print out the versions of external dependencies that `surveilr` uses on the current host

**Usage:** `surveilr doctor`



## `surveilr shell`

Execute `sqlite3` and `duckdb` commands directly with unopinionated and very lightweight logging. This command is the generalized version of `orchestrate`

**Usage:** `surveilr shell [OPTIONS] [SCRIPTS]...`

###### **Arguments:**

* `<SCRIPTS>` — SQL scripts to execute (file paths or URLs)

###### **Options:**

* `-d`, `--state-db-fs-path <STATE_DB_FS_PATH>` — target SQLite database

  Default value: `resource-surveillance.sqlite.db`
* `--engine <ENGINE>` — Perform all SQL executions with this shell. Defaults to `rusqlite`(which is also sqlite3)

  Default value: `rusqlite`

  Possible values: `rusqlite`, `duckdb`, `rhai`

* `--cmd <CMD>` — run "COMMAND" before reading stdin
* `--no-observability` — skip logging. shell executions are logged in `orchestration_*`` related tables

  Default value: `false`

  Possible values: `true`, `false`

* `--output <OUTPUT>` — Return the output of the last SQL statement in JSON

  Default value: `json`

  Possible values: `json`, `line`, `table`

* `--import-env <IMPORT_ENV>` — Import environment variables to place into the `session_state_ephemeral` table. Pass `.*` to import all env variables or any regular expression to determine which env vars are imported
* `--session-state-table-name <SESSION_STATE_TABLE_NAME>` — A Special argument to override the name of `session_state_ephemeral`

  Default value: `session_state_ephemeral`



<hr/>

<small><i>
    This document was generated automatically by
    <a href="https://crates.io/crates/clap-markdown"><code>clap-markdown</code></a>.
</i></small>

