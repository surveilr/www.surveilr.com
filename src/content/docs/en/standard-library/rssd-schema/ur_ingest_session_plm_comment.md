---
title: ur_ingest_session_plm_comment
---

## Description

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_plm_comment" (
    "ur_ingest_session_plm_comment_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR NOT NULL,
    "comment_id" TEXT NOT NULL,
    "node_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "body" TEXT,
    "body_text" TEXT,
    "body_html" TEXT,
    "user" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    FOREIGN KEY("user") REFERENCES "ur_ingest_session_plm_user"("ur_ingest_session_plm_user_id"),
    UNIQUE("comment_id", "url", "body")
)
```

</details>

## Columns

| Name                                        | Type        | Default           | Nullable | Parents                                                                                                                           | Comment                                                 |
| ------------------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_plm_comment_id            | VARCHAR     |                   | false    |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ur_ingest_session_plm_acct_project_issue_id | VARCHAR     |                   | false    | [ur_ingest_session_plm_acct_project_issue](/docs/standard-library/rssd-schema/ur_ingest_session_plm_acct_project_issue) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| comment_id                                  | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| node_id                                     | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| url                                         | TEXT        |                   | false    |                                                                                                                                   |                                                         |
| body                                        | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| body_text                                   | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| body_html                                   | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| user                                        | VARCHAR     |                   | false    | [ur_ingest_session_plm_user](/docs/standard-library/rssd-schema/ur_ingest_session_plm_user)                             | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| elaboration                                 | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                                  | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                   |                                                         |
| created_by                                  | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                   |                                                         |
| updated_at                                  | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| updated_by                                  | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| deleted_at                                  | TIMESTAMPTZ |                   | true     |                                                                                                                                   |                                                         |
| deleted_by                                  | TEXT        |                   | true     |                                                                                                                                   |                                                         |
| activity_log                                | TEXT        |                   | true     |                                                                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                             | Type        | Definition                                                                                                                                                                                                     |
| ------------------------------------------------ | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_plm_comment_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_comment_id)                                                                                                                                                                 |
| - (Foreign key ID: 0)                            | FOREIGN KEY | FOREIGN KEY (user) REFERENCES ur_ingest_session_plm_user (ur_ingest_session_plm_user_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                                                                    |
| - (Foreign key ID: 1)                            | FOREIGN KEY | FOREIGN KEY (ur_ingest_session_plm_acct_project_issue_id) REFERENCES ur_ingest_session_plm_acct_project_issue (ur_ingest_session_plm_acct_project_issue_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_ur_ingest_session_plm_comment_2 | UNIQUE      | UNIQUE (comment_id, url, body)                                                                                                                                                                                 |
| sqlite_autoindex_ur_ingest_session_plm_comment_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_plm_comment_id)                                                                                                                                                                 |
| -                                                | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                                                                          |

## Indexes

| Name                                                                           | Definition                                                                                                                                                                      |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id | CREATE INDEX "idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_comment"("ur_ingest_session_plm_acct_project_issue_id") |
| sqlite_autoindex_ur_ingest_session_plm_comment_2                               | UNIQUE (comment_id, url, body)                                                                                                                                                  |
| sqlite_autoindex_ur_ingest_session_plm_comment_1                               | PRIMARY KEY (ur_ingest_session_plm_comment_id)                                                                                                                                  |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_plm_comment.svg)
