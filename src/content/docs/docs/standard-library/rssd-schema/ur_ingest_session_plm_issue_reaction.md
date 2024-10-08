---
title: ur_ingest_session_plm_issue_reaction
---

## Description

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_plm_issue_reaction" (
    "ur_ingest_session_plm_issue_reaction_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_plm_reaction_id" VARCHAR NOT NULL,
    "ur_ingest_plm_issue_id" VARCHAR NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 1,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_plm_reaction_id") REFERENCES "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id"),
    FOREIGN KEY("ur_ingest_plm_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    UNIQUE("ur_ingest_plm_issue_id", "ur_ingest_plm_reaction_id")
)
```

</details>

## Columns

| Name                                    | Type        | Default           | Nullable | Parents                                                                                                                           | Comment                                                 |
| --------------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_plm_issue_reaction_id | VARCHAR     |                   | false    |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ur_ingest_plm_reaction_id               | VARCHAR     |                   | false    | [ur_ingest_session_plm_reaction](/docs/standard-library/rssd-schema/ur_ingest_session_plm_reaction)                     | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ur_ingest_plm_issue_id                  | VARCHAR     |                   | false    | [ur_ingest_session_plm_acct_project_issue](/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project_issue) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| count                                   | INTEGER     | 1                 | false    |                                                                                                                                   |                                                         |
| elaboration                             | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                              | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                   |                                                         |
| created_by                              | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                   |                                                         |
| updated_at                              | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| updated_by                              | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| deleted_at                              | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| deleted_by                              | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| activity_log                            | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                                    | Type        | Definition                                                                                                                                                                                |
| ------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_plm_issue_reaction_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_issue_reaction_id)                                                                                                                                     |
| - (Foreign key ID: 0)                                   | FOREIGN KEY | FOREIGN KEY (ur_ingest_plm_issue_id) REFERENCES ur_ingest_session_plm_acct_project_issue (ur_ingest_session_plm_acct_project_issue_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)                                   | FOREIGN KEY | FOREIGN KEY (ur_ingest_plm_reaction_id) REFERENCES ur_ingest_session_plm_reaction (ur_ingest_session_plm_reaction_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                  |
| sqlite_autoindex_ur_ingest_session_plm_issue_reaction_2 | UNIQUE      | UNIQUE (ur_ingest_plm_issue_id, ur_ingest_plm_reaction_id)                                                                                                                                |
| sqlite_autoindex_ur_ingest_session_plm_issue_reaction_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_issue_reaction_id)                                                                                                                                     |
| -                                                       | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                                                     |

## Indexes

| Name                                                                              | Definition                                                                                                                                                                            |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id | CREATE INDEX "idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id" ON "ur_ingest_session_plm_issue_reaction"("ur_ingest_session_plm_issue_reaction_id") |
| sqlite_autoindex_ur_ingest_session_plm_issue_reaction_2                           | UNIQUE (ur_ingest_plm_issue_id, ur_ingest_plm_reaction_id)                                                                                                                            |
| sqlite_autoindex_ur_ingest_session_plm_issue_reaction_1                           | PRIMARY KEY (ur_ingest_session_plm_issue_reaction_id)                                                                                                                                 |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_plm_issue_reaction.svg)
