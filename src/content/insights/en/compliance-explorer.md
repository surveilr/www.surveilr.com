---
title: "Surveilr Compliance Explorer Pattern – Streamlining Compliance with
SQL Scripts"
metaTitle: "Surveilr Compliance Explorer Pattern – Streamlining Compliance with SQL Scripts"
description: "Discover Surveilr's Compliance Explorer Pattern – a powerful tool for managing compliance data with SQL-based automation. Ideal for organizations looking to centralize compliance evidence, monitor resources, and simplify data analysis across platforms"
author: "Geo V L"
authorImage: "@/images/blog/geo-vl.avif"
authorImageAlt: "Geo V L"
pubDate: 2024-11-11
cardImage: "@/images/insights/compliance-explorer-pattern.avif"
cardImageAlt: "Compliance Explorer"
readTime: 3
tags: ["compliance", "surveilr-pattern"]
---

**Surveilr Compliance Explorer Pattern – Streamlining Compliance with SQL
Scripts**

The Surveilr Compliance Explorer Pattern is an innovative solution for
organizations managing information controls, which are essential security,
compliance, and operational measures aimed at reducing risk in information
systems and data handling. Designed with flexibility in mind, this pattern
leverages SQL scripts to help users extract, present, and cache compliance data
effectively. Here’s how it works and how you can get started.

### Key Components of the Surveilr Compliance Explorer Pattern

1. **Stateless SQL Script (`stateless.sql`):** This script is designed to create
   database views that define how control data is extracted from structured
   files like `uniform_resource.csv`. These views make it easy to retrieve and
   display specific compliance data on demand without needing to re-ingest the
   data each time.

2. **Stateful SQL Script (`stateful.sql`):** For users who need to cache data
   for quicker access, the `stateful.sql` script creates tables that store data
   extracted by the views. This approach allows compliance and audit teams to
   access the latest data without running the same extractions repeatedly.

3. **Package SQL Script (`package.sql.ts`):** Acting as the primary entry point,
   this script loads necessary database objects and Web UI content, providing
   users with a simplified experience in managing and visualizing data. This
   central script is crucial for setting up the user interface and accessing the
   Surveilr database.

### How to Use the Compliance Explorer Pattern

Surveilr’s flexibility extends to a variety of platforms, so you can run this
pattern on almost any device without needing the Surveilr repository itself.
Here’s a step-by-step guide to getting started:

1. **Prepare a Working Directory:** First, set up a folder for your compliance
   data:
   ```bash
   mkdir -p /tmp/compliance-explorer
   cd /tmp/compliance-explorer
   ```

2. **Prepare Control Files:** Place control data CSV files (e.g.,
   `SCF_2024.2.csv`) in an `ingest` folder inside your directory:
   ```bash
   compliance-explorer
   ├── ingest
   │   ├── SCF_2024.2.csv
   ├── package.sql.ts
   └── stateless.sql
   ```

3. **Download and Ingest Data with Surveilr:** Download the Surveilr binary to
   your working directory and use it to ingest the control files, creating an
   SQLite database (`resource-surveillance.sqlite.db`) that serves as your
   compliance repository:
   ```bash
   ./surveilr ingest files -r ingest/
   ```

   After ingestion, your folder will look like this:
   ```bash
   compliance-explorer
   ├── ingest
   │   ├── SCF_2024.2.csv
   ├── package.sql.ts
   └── stateless.sql
   └── resource-surveillance.sqlite.db            # SQLite database
   ```

4. **Query and Visualize Data:** Once data is ingested, Surveilr is no longer
   required. Use standard tools like `sqlite3`, DBeaver, or DataGrip to access
   your compliance data from the `resource-surveillance.sqlite.db` database. You
   can also load the Surveilr Web UI for a richer interface:
   ```bash
   deno run -A ./package.sql.ts | surveilr shell
   ```

5. **Accessing the Web UI:** Start the Surveilr web UI to view compliance data:
   ```bash
   ../../std/surveilrctl.ts dev
   ```

   Visit `http://localhost:9000/` to browse the UI or access the specific schema
   for data management services (DMS) at
   `http://localhost:9000/dms/info-schema.sql`.

### Compliance Explorer’s Advantage

The Surveilr Compliance Explorer Pattern streamlines compliance workflows with
reusable SQL scripts for data extraction and caching, enabling organizations to:

- **Centralize Compliance Data:** Store and organize compliance information in a
  single, easily accessible SQLite database.
- **Simplify Data Management:** Run one-time ingestions and visualize data in
  real time without needing to repeat complex extraction processes.
- **Enhance Flexibility:** Use SQL queries to generate views or reports
  on-demand, facilitating quick compliance checks, audits, and updates.

This pattern empowers teams to effectively manage compliance requirements and
reduces the complexity of regulatory data handling, offering a seamless,
accessible solution across varied operational environments.
