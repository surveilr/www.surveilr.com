# `surveilr` osQuery Server Management Pattern

- `stateless.sql` script focuses on creating views that define how to extract
  and present specific query results from the `uniform_resource` tables.

- `package.sql.ts` script is the entry point for loading typical database
  objects and Web UI content.

- `queries.sql.ts` script focuses on adding osQuery queries to the RSSD.

## Try it out on any device without this repo (if you're just using the SQL scripts)

```bash
# load the "Console" and other menu/routing utilities plus info assurance Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/ms to see all nodes
```

## Adding New osQuery Queries

This guide explains how to add new osQuery queries to your `SurveilrOsqueryMsQueries` class using the `osQueryMsCell` decorator.

### Understanding the Query System

The osQuery system works by defining queries as methods in a class that extends `TypicalCodeNotebook`. Each method:
- Is decorated with `@osQueryMsCell`
- Returns a SQL string that will be executed by osQuery
- Can have a string literal name (like `"System Information"`)

# Important Package Behavior: Upserts Only

## Understanding Package Behavior

The `surveilr` osQuery Server Management system follows an important design principle:

**The package scripts (`package.sql.ts`, `queries.sql.ts`, etc.) only perform upserts (insert or update operations) and never delete any data.**

## Performing Deletions

When you need to remove data, queries, or configurations, you must explicitly do so through separate SQL calls. This deliberate separation ensures that deletions are intentional and carefully managed.

### Example: Deleting an osQuery Configuration

If you need to remove a specific osQuery query that's no longer needed, you would:

```sql
-- Delete a specific query by name from the management server
DELETE FROM code_notebook_cell 
WHERE name = 'osQuery Management Server (Prime)'
AND json_extract(cell_governance, '$.query_name') = 'Windows Registry Settings';
```

### Example: Cleaning Up All Queries for a Specific Platform

```sql
-- Remove all Windows-specific queries
DELETE FROM code_notebook_cell 
WHERE cell_name = 'osQuery Management Server (Prime)'
AND json_extract(cell_governance, '$.targets') LIKE '%windows%'
AND json_extract(cell_governance, '$.targets') NOT LIKE '%linux%' 
AND json_extract(cell_governance, '$.targets') NOT LIKE '%macos%';
```

### How to Add a New Query

#### Step 1: Identify the Information You Need

First, determine what system information you want to collect.

#### Step 2: Find the Appropriate osQuery Tables

Consult the [osQuery schema documentation](https://osquery.io/schema/) to find the tables that contain the data you need.

#### Step 3: Add a New Method to the Class

Add a new method to the `SurveilrOsqueryMsQueries` class following this pattern:

```typescript
@osQueryMsCell({
  description: "Your query description here",
  // Optional: additional configuration
})
"Your Query Name"() {
  return `SELECT column1, column2, column3 FROM table_name WHERE condition`;
}
```

#### Step 4: Customize the Query Parameters (Optional)

The `osQueryMsCell` decorator accepts several parameters:

```typescript
@osQueryMsCell(
  {
    description: "Description of what this query does",
    // Any other initialization parameters
  },
  ["darwin", "windows"], // Target platforms (default: ["darwin", "windows", "linux"])
  true, // Singleton (default: false) - If true, only one instance of this query will run
  ["additional.jq.filter"] // Additional JQ filters for processing results
)
```

## Examples

Here are some common osQuery examples you might want to add:

### 1. List Running Processes

```typescript
@osQueryMsCell({
  description: "Lists all currently running processes",
})
"Running Processes"() {
  return `SELECT pid, name, path, cmdline, state, parent 
          FROM processes 
          ORDER BY start_time DESC`;
}
```

### 2. Network Connections

```typescript
@osQueryMsCell({
  description: "Current network connections",
})
"Network Connections"() {
  return `SELECT pid, family, protocol, local_address, local_port, 
          remote_address, remote_port, state 
          FROM process_open_sockets 
          WHERE state != ''`;
}
```

### 3. Installed Applications

```typescript
@osQueryMsCell({
  description: "Lists installed applications",
  // Only run on macOS and Windows
}, ["darwin", "windows"])
"Installed Applications"() {
  return `
    SELECT name, bundle_short_version, bundle_version
    FROM apps
    WHERE bundle_identifier != ''
  `;
}
```

## Advanced Configuration

For more complex scenarios, you can customize the query execution parameters:

### Custom Interval

To adjust how frequently a query runs:

```typescript
@osQueryMsCell({
  description: "Checks system load every 5 minutes",
  cell_governance: JSON.stringify({
    ...osQueryMsCellGovernance,
    "osquery-ms-interval": 300, // 5 minutes in seconds
  }),
})
```

### Platform-Specific Queries

For queries that should only run on specific operating systems:

```typescript
@osQueryMsCell({
  description: "Windows-specific registry query",
}, ["windows"])
"Windows Registry Settings"() {
  return `SELECT path, name, data FROM registry WHERE path LIKE 'HKEY_LOCAL_MACHINE\\Software\\%'`;
}
```

## Loading the Queries
To load the queries in the RSSD, simply run:
```bash
$ deno run -A ./queries.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./queries.sql.ts                 # option 2 (same as option 1)
```