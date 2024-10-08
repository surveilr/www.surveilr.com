---
title: ur_ingest_session_plm_milestone
---

## Description

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_plm_milestone" (
    "ur_ingest_session_plm_milestone_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "title" TEXT NOT NULL,
    "milestone_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "html_url" TEXT NOT NULL,
    "open_issues" INTEGER,
    "closed_issues" INTEGER,
    "due_on" TIMESTAMPTZ,
    "closed_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id")
)
```

</details>

## Columns

| Name                                  | Type        | Default           | Nullable | Parents                                                                                                               | Comment                                                                   |
| ------------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| ur_ingest_session_plm_milestone_id    | VARCHAR     |                   | false    |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}                         |
| ur_ingest_session_plm_acct_project_id | VARCHAR     |                   | false    | [ur_ingest_session_plm_acct_project](/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}                         |
| title                                 | TEXT        |                   | false    |                                                                                                                       |                                                                           |
| milestone_id                          | TEXT        |                   | false    |                                                                                                                       |                                                                           |
| url                                   | TEXT        |                   | false    |                                                                                                                       |                                                                           |
| html_url                              | TEXT        |                   | false    |                                                                                                                       |                                                                           |
| open_issues                           | INTEGER     |                   | true     |                                                                                                                       |                                                                           |
| closed_issues                         | INTEGER     |                   | true     |                                                                                                                       |                                                                           |
| due_on                                | TIMESTAMPTZ |                   | true     |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isDateSqlDomain":true,"isDateTime":true} |
| closed_at                             | TIMESTAMPTZ |                   | true     |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isDateSqlDomain":true,"isDateTime":true} |
| elaboration                           | TEXT        |                   | true     |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}                        |
| created_at                            | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                       |                                                                           |
| created_by                            | TEXT        | 'UNKNOWN'         | true     |                                                                                                                       |                                                                           |
| updated_at                            | TIMESTAMPTZ |                   | true     |                                                                                                                       |                                                                           |
| updated_by                            | TEXT        |                   | true     |                                                                                                                       |                                                                           |
| deleted_at                            | TIMESTAMPTZ |                   | true     |                                                                                                                       |                                                                           |
| deleted_by                            | TEXT        |                   | true     |                                                                                                                       |                                                                           |
| activity_log                          | TEXT        |                   | true     |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true}                   |

## Constraints

| Name                                               | Type        | Definition                                                                                                                                                                                   |
| -------------------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_plm_milestone_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_milestone_id)                                                                                                                                             |
| - (Foreign key ID: 0)                              | FOREIGN KEY | FOREIGN KEY (ur_ingest_session_plm_acct_project_id) REFERENCES ur_ingest_session_plm_acct_project (ur_ingest_session_plm_acct_project_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_ur_ingest_session_plm_milestone_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_milestone_id)                                                                                                                                             |
| -                                                  | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                                                        |

## Indexes

| Name                                                                       | Definition                                                                                                                                                              |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_plm_milestone__ur_ingest_session_plm_acct_project_id | CREATE INDEX "idx_ur_ingest_session_plm_milestone__ur_ingest_session_plm_acct_project_id" ON "ur_ingest_session_plm_milestone"("ur_ingest_session_plm_acct_project_id") |
| sqlite_autoindex_ur_ingest_session_plm_milestone_1                         | PRIMARY KEY (ur_ingest_session_plm_milestone_id)                                                                                                                        |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_plm_milestone.svg)
