---
title: ur_ingest_session_plm_issue_type
---

## Description

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_plm_issue_type" (
    "ur_ingest_session_plm_issue_type_id" VARCHAR PRIMARY KEY NOT NULL,
    "avatar_id" TEXT,
    "description" TEXT NOT NULL,
    "icon_url" TEXT NOT NULL,
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "subtask" BOOLEAN NOT NULL,
    "url" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("id", "name")
)
```

</details>

## Columns

| Name                                | Type        | Default           | Nullable | Children                                                                                                                          | Comment                                                 |
| ----------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_plm_issue_type_id | VARCHAR     |                   | false    | [ur_ingest_session_plm_acct_project_issue](/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project_issue) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| avatar_id                           | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| description                         | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| icon_url                            | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| id                                  | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| name                                | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| subtask                             | BOOLEAN     |                   | false    |                                                                                                                                   |                                                         |
| url                                 | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| elaboration                         | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                          | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                   |                                                         |
| created_by                          | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                   |                                                         |
| updated_at                          | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| updated_by                          | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| deleted_at                          | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| deleted_by                          | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| activity_log                        | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                                | Type        | Definition                                            |
| --------------------------------------------------- | ----------- | ----------------------------------------------------- |
| ur_ingest_session_plm_issue_type_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_issue_type_id)     |
| sqlite_autoindex_ur_ingest_session_plm_issue_type_2 | UNIQUE      | UNIQUE (id, name)                                     |
| sqlite_autoindex_ur_ingest_session_plm_issue_type_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_issue_type_id)     |
| -                                                   | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL) |

## Indexes

| Name                                                | Definition                                                                                          |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_plm_issue_type__id            | CREATE INDEX "idx_ur_ingest_session_plm_issue_type__id" ON "ur_ingest_session_plm_issue_type"("id") |
| sqlite_autoindex_ur_ingest_session_plm_issue_type_2 | UNIQUE (id, name)                                                                                   |
| sqlite_autoindex_ur_ingest_session_plm_issue_type_1 | PRIMARY KEY (ur_ingest_session_plm_issue_type_id)                                                   |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_plm_issue_type.svg)
