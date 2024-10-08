---
title: ur_ingest_session_fs_path
---

## Description

Immutable ingest session file system path represents a discovery or "walk" path.
If the session included a file system scan, then root_path is the root file
system path that was scanned. If the session was discovering resources in
another target then root_path would be representative of the target path (could
be a URI).

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_fs_path" (
    "ur_ingest_session_fs_path_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "root_path" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("ingest_session_id", "root_path", "created_at")
)
```

</details>

## Columns

| Name                         | Type        | Default           | Nullable | Children                                                                                                                                                                                          | Parents                                                                             | Comment                                                 |
| ---------------------------- | ----------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_fs_path_id | VARCHAR     |                   | false    | [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource) [ur_ingest_session_fs_path_entry](/docs/standard-library/rssd-schema/ur_ingest_session_fs_path_entry) |                                                                                     | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_session_id            | VARCHAR     |                   | false    |                                                                                                                                                                                                   | [ur_ingest_session](/docs/standard-library/rssd-schema/ur_ingest_session) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| root_path                    | TEXT        |                   | false    |                                                                                                                                                                                                   |                                                                                     |                                                         |
| elaboration                  | TEXT        |                   | true     |                                                                                                                                                                                                   |                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                   | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| created_by                   | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| updated_at                   | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| updated_by                   | TEXT        |                   | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| deleted_at                   | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| deleted_by                   | TEXT        |                   | true     |                                                                                                                                                                                                   |                                                                                     |                                                         |
| activity_log                 | TEXT        |                   | true     |                                                                                                                                                                                                   |                                                                                     | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                         | Type        | Definition                                                                                                                             |
| -------------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_fs_path_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_fs_path_id)                                                                                             |
| - (Foreign key ID: 0)                        | FOREIGN KEY | FOREIGN KEY (ingest_session_id) REFERENCES ur_ingest_session (ur_ingest_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_ur_ingest_session_fs_path_2 | UNIQUE      | UNIQUE (ingest_session_id, root_path, created_at)                                                                                      |
| sqlite_autoindex_ur_ingest_session_fs_path_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_fs_path_id)                                                                                             |
| -                                            | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                  |

## Indexes

| Name                                                        | Definition                                                                                                                                  |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_fs_path__ingest_session_id__root_path | CREATE INDEX "idx_ur_ingest_session_fs_path__ingest_session_id__root_path" ON "ur_ingest_session_fs_path"("ingest_session_id", "root_path") |
| sqlite_autoindex_ur_ingest_session_fs_path_2                | UNIQUE (ingest_session_id, root_path, created_at)                                                                                           |
| sqlite_autoindex_ur_ingest_session_fs_path_1                | PRIMARY KEY (ur_ingest_session_fs_path_id)                                                                                                  |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_fs_path.svg)
