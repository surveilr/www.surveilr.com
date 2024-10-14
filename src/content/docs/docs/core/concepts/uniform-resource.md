---
title: uniform_resource Table
description: Explains resources and the constellation of uniform_resource-related tables.
---

A **resource** can be any entity that contains data or is used to facilitate
system operations. In a typical information system, resources include files,
devices, network components, web services, users, applications, and more.
Effective resource management helps ensure security, efficiency, and compliance
by allowing for proper monitoring, maintenance, and control of these entities.

One of the benefits of `surveilr` is its _heavily opinionated_ relational
database schema in general and design of the `uniform_resource` table used in
particular. The `uniform_resource` table is built to serve complex requirements
in cybersecurity, compliance, and resource management scenarios. We will also
cover its related tables and provide practical SQL examples to demonstrate their
use.

In an RSSD, **`uniform_resource`** represents a central element designed for
append-only, immutable storage of entities in a file system. It is highly
opinionated, aiming to maintain a history of resources by linking back to
ingestion sessions, devices, and their original sources. This design ensures not
only traceability but also reliability in terms of historical audit and
compliance.

The table is structured to track metadata related to any given resource, such as
files or data components. Key features include the ability to record unique
identifiers, content digests for data integrity, and paths of origin, all of
which are critical in compliance and cybersecurity use cases.

Let's look at the schema for the `uniform_resource` table to get a better
understanding:

```sql
CREATE TABLE IF NOT EXISTS "uniform_resource" (
    "uniform_resource_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR,
    "ingest_imap_acct_folder_id" VARCHAR,
    "ingest_issue_acct_project_id" VARCHAR,
    "uri" TEXT NOT NULL,
    "content_digest" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size_bytes" INTEGER,
    "last_modified_at" TIMESTAMPTZ,
    "content_fm_body_attrs" TEXT CHECK(json_valid(content_fm_body_attrs) OR content_fm_body_attrs IS NULL),
    "frontmatter" TEXT CHECK(json_valid(frontmatter) OR frontmatter IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
    FOREIGN KEY("ingest_issue_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    UNIQUE("device_id", "content_digest", "uri", "size_bytes")
);
```

### Breaking Down the `uniform_resource` Table

The `uniform_resource` table is opinionated in its approach, ensuring that the
database maintains a rich historical record of any given resource. Let us dive
into some of the core attributes of the table:

- **`uniform_resource_id`**: This is the primary key that uniquely identifies a
  resource. This ID ensures that every resource in the system can be traced
  back.
- **`device_id`** and **`ingest_session_id`**: These columns link a resource to
  a specific device and an ingestion session, thereby providing context on where
  and how the resource originated.
- **`uri`**: The Uniform Resource Identifier (URI) field serves as a globally
  unique reference to the resource, capturing its address within the system.
- **`content_digest`**: This is a checksum or hash representing the content of
  the resource. It is used to verify data integrity, making sure that the
  resource content hasn’t been tampered with.
- **`nature`**: This field describes the type or nature of the resource, such as
  whether it is a file, a document, or any other type of entity.
- **`frontmatter`** and **`content_fm_body_attrs`**: These JSON fields are used
  to store metadata and attributes about the content, enhancing the resource's
  descriptive capabilities.
- **`created_at`, `updated_at`, `deleted_at`**: These timestamps are crucial for
  tracking the life cycle of a resource, enabling historical and
  compliance-based reporting.

### Related Tables

The `uniform_resource` table interacts with several other tables, forming a
comprehensive system to manage, audit, and secure resources. This constellation
of related tables understands the diverse sources, multiple modalities, and
various formats that a resource can have, whether it’s a file, an email message,
or an issue from a PLM system.

#### 1. `ur_ingest_session`

The **`ur_ingest_session`** table captures sessions during which resources are
ingested into the system. Each ingestion session is recorded with metadata,
providing a timestamp and a snapshot of the state at that point.

- **Purpose**: To record and track the ingestion sessions, providing context for
  when and how resources were added to the system.
- **Key Columns**:
  - `ur_ingest_session_id`: Primary key for the session.
  - `ingest_started_at` and `ingest_finished_at`: Timestamps for tracking the
    duration of an ingestion session.
  - `device_id`: Links the session to a specific device.

Example SQL to list all resources ingested in a given session:

```sql
SELECT ur.*
FROM uniform_resource ur
JOIN ur_ingest_session uis ON ur.ingest_session_id = uis.ur_ingest_session_id
WHERE uis.ingest_started_at BETWEEN '2024-01-01' AND '2024-12-31';
```

#### 2. `ur_ingest_session_fs_path`

The **`ur_ingest_session_fs_path`** table stores file system paths linked to an
ingestion session. It ensures traceability for the file system structure when
resources were ingested.

- **Purpose**: To track the root file system paths that were ingested as part of
  a session, allowing for reconstruction of the original file system structure.
- **Key Columns**:
  - `ur_ingest_session_fs_path_id`: Primary key for the file system path entry.
  - `ingest_session_id`: Links the file system path to a specific ingestion
    session.
  - `root_path`: The root path of the ingested file system.

Example SQL to find the root paths of all resources for a given device:

```sql
SELECT DISTINCT fs.root_path
FROM ur_ingest_session_fs_path fs
JOIN uniform_resource ur ON fs.ingest_session_id = ur.ingest_session_id
WHERE ur.device_id = 'DEVICE1234';
```

#### 3. `ur_ingest_session_imap_account`

The **`ur_ingest_session_imap_account`** table records details about IMAP
accounts used during an ingestion session, particularly for email messages.

- **Purpose**: To manage email accounts that are used as sources for ingestion,
  allowing email messages to be treated as resources.
- **Key Columns**:
  - `ur_ingest_session_imap_account_id`: Primary key for the IMAP account.
  - `ingest_session_id`: Links the account to a specific ingestion session.
  - `email`, `host`: Details about the email account used.

#### 4. `ur_ingest_session_imap_acct_folder`

The **`ur_ingest_session_imap_acct_folder`** table captures details about the
folders within an IMAP account from which messages were ingested.

- **Purpose**: To track email folders involved in ingestion, such as inboxes or
  custom folders.
- **Key Columns**:
  - `ur_ingest_session_imap_acct_folder_id`: Primary key for the IMAP folder.
  - `ingest_session_id`, `ingest_account_id`: Links the folder to an IMAP
    account and session.
  - `folder_name`: Name of the folder being ingested.

#### 5. `ur_ingest_session_plm_acct_project`

The **`ur_ingest_session_plm_acct_project`** table stores information about
Product Lifecycle Management (PLM) projects, such as those from GitHub or Jira,
involved in an ingestion session.

- **Purpose**: To track PLM projects that are ingested as resources, enabling
  issues, tasks, and other project data to be part of the resource pool.
- **Key Columns**:
  - `ur_ingest_session_plm_acct_project_id`: Primary key for the PLM project.
  - `name`, `description`: Metadata about the PLM project.

#### 6. `ur_ingest_session_fs_path_entry`

The **`ur_ingest_session_fs_path_entry`** table records individual file entries
within a file system that are part of an ingestion session.

- **Purpose**: To provide detailed tracking of files that were ingested,
  allowing for version control and change tracking at the file level.
- **Key Columns**:
  - `ur_ingest_session_fs_path_entry_id`: Primary key for the file system path
    entry.
  - `file_path_abs`, `file_basename`: Details about the file path and name.
  - `uniform_resource_id`: Links the file entry to the `uniform_resource` table.

### Compliance and Security Aspects

The RSSD database is designed with a focus on compliance and security. Here’s
how `uniform_resource` helps achieve this:

1. **Immutability**: All tables are append-only. Any modification is essentially
   a new version, which ensures historical integrity and auditability. This
   immutability is critical for compliance, ensuring there is no tampering
   without leaving traces.

2. **Content Hashing**: The `content_digest` field stores a hash of the
   resource's content. This allows for integrity checks to confirm that data
   hasn’t been altered, which is fundamental for detecting tampering or
   corruption.

3. **Detailed Provenance Tracking**: With links to ingestion sessions, file
   paths, and originating devices, the `uniform_resource` table can help
   reconstruct the history of a resource. This is crucial in cybersecurity for
   incident analysis and forensic purposes.

4. **Attributes as JSON**: JSON fields like `frontmatter` and
   `content_fm_body_attrs` store complex metadata about the resource. This
   flexibility allows the system to adapt to evolving compliance requirements
   without altering the table schema significantly.

### Practical Example: How to Track Resource Changes

Suppose we want to track changes to a specific file across different ingestion
sessions to see how it has evolved. Here’s a query to achieve that:

```sql
SELECT ur.uniform_resource_id, ur.uri, ur.content_digest, ur.created_at
FROM uniform_resource ur
JOIN ur_ingest_session uis ON ur.ingest_session_id = uis.ur_ingest_session_id
WHERE ur.uri = '/data/logs/security.log'
ORDER BY ur.created_at DESC;
```

This SQL query helps us track how a file (`security.log`) has been captured over
multiple ingestion sessions, providing a snapshot of its historical changes.

The **`uniform_resource`** table is a robust solution for managing resources
with immutability and traceability in mind. By combining the resource with
associated devices, ingestion sessions, and file paths, the RSSD database is
built to cater to the high-demand needs of compliance and cybersecurity.

With its opinionated approach, the `uniform_resource` table doesn’t just capture
the current state of resources—it also records the entire historical context,
making it suitable for audit, analysis, and compliance. This elaborate
infrastructure ensures data integrity, reliability, and full transparency into
each resource's life cycle.
