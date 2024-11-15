---
title: "Harnessing SQL for Compliance: Building a Powerful Compliance Explorer Tool"
metaTitle: "Compliance Explorer: SQL-Driven Solution for Information Controls Management"
description: "Discover Compliance Explorer, an SQL-based tool built on surveilr to streamline compliance management. Learn how this solution enables efficient querying, reporting, and real-time control over regulatory data."
author: "Ajay Kumaran"
authorImage: "@/images/blog/ajay-kumaran.avif"
authorImageAlt: "Ajay Kumaran"
pubDate: 2024-11-15
cardImage: "@/images/blog/sql-for-compliance.avif"
cardImageAlt: "Harnessing SQL for Compliance"
readTime: 3
tags: ["compliance explorer", "compliance management", "etl for compliance", "regulatory compliance", "data governance", "sql-based compliance tools"]
---

# Building a Compliance Explorer: SQL-Based Approach to Manage Information Controls

In today’s data-driven landscape, organizations must rigorously manage risks
related to information systems, security, and data compliance. Information
Controls help address these needs by implementing regulatory, statutory, and
operational measures that ensure organizational resilience and regulatory
alignment. With Compliance Explorer, built on `surveilr`, we introduce an
SQL-based solution that enables effective compliance management and efficient
data interaction.

## What is Compliance Explorer?

Compliance Explorer is a SQL-driven tool for managing and exploring information
controls. By leveraging SQL-based ETL (Extract, Transform, Load) patterns,
Compliance Explorer can ingest, cache, and present compliance data through a web
UI, creating an accessible framework for organizations to view, query, and
report on data-driven compliance controls. This tool is powered by `surveilr`
and structured around three core scripts: `stateless.sql`, `stateful.sql`, and
`package.sql.ts`.

## Components of Compliance Explorer

### 1. `stateless.sql`: Defining Views for Data Extraction

The `stateless.sql` script creates views that specify how controls data should
be extracted from CSV files and presented. For instance, in a typical setup, the
`uniform_resource.csv` tables are ingested to outline compliance metrics across
different regions and frameworks. By focusing on view-based transformations,
`stateless.sql` avoids data duplication and ensures up-to-date presentation of
compliance controls.

```sql
-- Sample view creation in stateless.sql
CREATE VIEW compliance_view AS
SELECT control_id, control_description, source, geography
FROM uniform_resource;
```

### 2. `stateful.sql`: Caching Extracted Data

Once data has been ingested and structured through `stateless.sql` views,
`stateful.sql` takes over by creating tables to cache this extracted data.
Caching enables quicker access to precomputed information, making data querying
faster and more efficient. This script is vital for managing stateful operations
where historical data and ongoing compliance insights are needed.

```sql
-- Sample table creation in stateful.sql
CREATE TABLE compliance_cache AS
SELECT * FROM compliance_view;
```

### 3. `package.sql.ts`: Orchestrating the Database and Web UI

The `package.sql.ts` file is the entry point of Compliance Explorer. It loads
database objects, initializes a web UI for interaction, and sets up menu-based
navigation within the web application. Using Deno for runtime execution,
`package.sql.ts` can dynamically apply SQL logic, update views, and orchestrate
cached data tables in real time. The setup allows users to view controls data,
query compliance information, and manage navigation seamlessly within the UI.

```typescript
// package.sql.ts entry point
export class ComplianceExplorerSqlPages extends spn.TypicalSqlPageNotebook {
    // DML logic for navigation and page generation
}
```

## Setting Up Compliance Explorer

### Step 1: Directory Structure and Ingestion

To get started, prepare a working directory for Compliance Explorer and an
`ingest` folder for control files.

```bash
$ mkdir -p /tmp/compliance-explorer/ingest
$ cd /tmp/compliance-explorer
```

Place control files, such as `SCF_2024.2.csv`, into the `ingest` folder. The
structure should resemble:

```
compliance-explorer
├── ingest
│   ├── SCF_2024.2.csv
├── package.sql.ts
└── stateless.sql
```

### Step 2: Ingesting Data with `surveilr`

Download the `surveilr` binary into the `compliance-explorer` directory, and
then use the following command to ingest the files from the `ingest` folder.
This process generates an SQLite database, `resource-surveillance.sqlite.db`,
containing all the control data.

```bash
$ ./surveilr ingest files -r ingest/
```

After ingestion, your directory should look like this:

```
compliance-explorer
├── ingest
│   ├── SCF_2024.2.csv
├── package.sql.ts
└── stateless.sql
└── resource-surveillance.sqlite.db
```

### Step 3: Running Compliance Explorer

Once ingestion is complete, run `package.sql.ts` to load the data in the console
or launch the interactive web UI:

```bash
$ deno run -A ./package.sql.ts | surveilr shell   # Console interaction
$ surveilr shell ./package.sql.ts                 # Alternative console command
```

To interact through the web, start the UI in watch mode:

```bash
$ ../../std/surveilrctl.ts dev
```

Navigate to `http://localhost:9000/` to access the Compliance Explorer
interface. Here, you can browse controls, query information, and explore
compliance details.

## Working with Cached Data

After applying `stateless.sql`, you no longer need the raw data files in
`ingest/`—all content is accessible via views or cached tables in
`resource-surveillance.sqlite.db`. This SQLite database is portable and can be
renamed, archived, or used with reporting tools like DBeaver, DataGrip, or other
SQLite-compatible software for further analysis.

## Why Use Compliance Explorer?

Compliance Explorer simplifies complex compliance requirements by using an
SQL-based approach that scales with your data needs. With Compliance Explorer,
you can:

- **Easily query compliance controls** across multiple regulatory frameworks.
- **Build reports** based on cached compliance data.
- **Seamlessly integrate** with the web UI for real-time interaction and
  insights.

Compliance Explorer provides a robust, scalable solution for organizations
needing a centralized view of compliance data across various standards, making
it ideal for sectors that must comply with stringent information governance and
data protection regulations.

## Conclusion

With Compliance Explorer, powered by `surveilr`, your organization gains a
flexible and efficient tool for navigating the complexities of data compliance
and information controls. Try it today to see how SQL-based compliance
management can transform your organization’s approach to data-driven
decision-making.

For more insights on SQL-based ETL/ELT processes and compliance management,
explore our [surveilr blog](https://www.surveilr.com/blog).
