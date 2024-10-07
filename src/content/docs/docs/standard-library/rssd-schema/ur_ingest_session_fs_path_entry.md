---
title: Uniform Resource Ingest Session Fs Path Entry
---

## Description

Contains entries related to file system content ingestion paths. On multiple
executions, unlike uniform_resource, ur_ingest_session_fs_path_entry rows are
always inserted and references the uniform_resource primary key of its related
content. This method allows for a more efficient query of file version
differences across sessions. With SQL queries, you can detect which sessions
have a file added or modified, which sessions have a file deleted, and what the
differences are in file contents if they were modified across sessions.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_fs_path_entry" (
    "ur_ingest_session_fs_path_entry_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "file_path_abs" TEXT NOT NULL,
    "file_path_rel_parent" TEXT NOT NULL,
    "file_path_rel" TEXT NOT NULL,
    "file_basename" TEXT NOT NULL,
    "file_extn" TEXT,
    "captured_executable" TEXT CHECK(json_valid(captured_executable) OR captured_executable IS NULL),
    "ur_status" TEXT,
    "ur_diagnostics" TEXT CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL),
    "ur_transformations" TEXT CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id")
)
```

</details>

## Columns

| Name                               | Type        | Default           | Nullable | Parents                                                                                             | Comment                                                 |
| ---------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_fs_path_entry_id | VARCHAR     |                   | false    |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_session_id                  | VARCHAR     |                   | false    | [ur_ingest_session](/docs/standard-library/rssd-schema/ur_ingest_session)                 | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_fs_path_id                  | VARCHAR     |                   | false    | [ur_ingest_session_fs_path](/docs/standard-library/rssd-schema/ur_ingest_session_fs_path) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| uniform_resource_id                | VARCHAR     |                   | true     | [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource)                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| file_path_abs                      | TEXT        |                   | false    |                                                                                                     |                                                         |
| file_path_rel_parent               | TEXT        |                   | false    |                                                                                                     |                                                         |
| file_path_rel                      | TEXT        |                   | false    |                                                                                                     |                                                         |
| file_basename                      | TEXT        |                   | false    |                                                                                                     |                                                         |
| file_extn                          | TEXT        |                   | true     |                                                                                                     |                                                         |
| captured_executable                | TEXT        |                   | true     |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| ur_status                          | TEXT        |                   | true     |                                                                                                     |                                                         |
| ur_diagnostics                     | TEXT        |                   | true     |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| ur_transformations                 | TEXT        |                   | true     |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| elaboration                        | TEXT        |                   | true     |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                         | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                     |                                                         |
| created_by                         | TEXT        | 'UNKNOWN'         | true     |                                                                                                     |                                                         |
| updated_at                         | TIMESTAMPTZ |                   | true     |                                                                                                     |                                                         |
| updated_by                         | TEXT        |                   | true     |                                                                                                     |                                                         |
| deleted_at                         | TIMESTAMPTZ |                   | true     |                                                                                                     |                                                         |
| deleted_by                         | TEXT        |                   | true     |                                                                                                     |                                                         |
| activity_log                       | TEXT        |                   | true     |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                               | Type        | Definition                                                                                                                                             |
| -------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ur_ingest_session_fs_path_entry_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_fs_path_entry_id)                                                                                                       |
| - (Foreign key ID: 0)                              | FOREIGN KEY | FOREIGN KEY (uniform_resource_id) REFERENCES uniform_resource (uniform_resource_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                 |
| - (Foreign key ID: 1)                              | FOREIGN KEY | FOREIGN KEY (ingest_fs_path_id) REFERENCES ur_ingest_session_fs_path (ur_ingest_session_fs_path_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 2)                              | FOREIGN KEY | FOREIGN KEY (ingest_session_id) REFERENCES ur_ingest_session (ur_ingest_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                 |
| sqlite_autoindex_ur_ingest_session_fs_path_entry_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_fs_path_entry_id)                                                                                                       |
| -                                                  | CHECK       | CHECK(json_valid(captured_executable) OR captured_executable IS NULL)                                                                                  |
| -                                                  | CHECK       | CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL)                                                                                            |
| -                                                  | CHECK       | CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL)                                                                                    |
| -                                                  | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                  |

## Indexes

| Name                                                                  | Definition                                                                                                                                                      |
| --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_fs_path_entry__ingest_session_id__file_path_abs | CREATE INDEX "idx_ur_ingest_session_fs_path_entry__ingest_session_id__file_path_abs" ON "ur_ingest_session_fs_path_entry"("ingest_session_id", "file_path_abs") |
| sqlite_autoindex_ur_ingest_session_fs_path_entry_1                    | PRIMARY KEY (ur_ingest_session_fs_path_entry_id)                                                                                                                |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_fs_path_entry.svg)
