---
title: ur_ingest_session_imap_acct_folder
---

## Description

Immutable ingest session folder system represents a folder or mailbox in an
email account, e.g. "INBOX" or "SENT". Each session includes a folder scan, then
folder_name is the folder that was scanned.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_imap_acct_folder" (
    "ur_ingest_session_imap_acct_folder_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_account_id" VARCHAR NOT NULL,
    "folder_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_account_id") REFERENCES "ur_ingest_session_imap_account"("ur_ingest_session_imap_account_id"),
    UNIQUE("ingest_account_id", "folder_name")
)
```

</details>

## Columns

| Name                                  | Type        | Default           | Nullable | Children                                                                                                                                                                                                                | Parents                                                                                                       | Comment                                                 |
| ------------------------------------- | ----------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_imap_acct_folder_id | VARCHAR     |                   | false    | [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource) [ur_ingest_session_imap_acct_folder_message](/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder_message) |                                                                                                               | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_session_id                     | VARCHAR     |                   | false    |                                                                                                                                                                                                                         | [ur_ingest_session](/docs/standard-library/rssd-schema/ur_ingest_session)                           | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_account_id                     | VARCHAR     |                   | false    |                                                                                                                                                                                                                         | [ur_ingest_session_imap_account](/docs/standard-library/rssd-schema/ur_ingest_session_imap_account) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| folder_name                           | TEXT        |                   | false    |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| elaboration                           | TEXT        |                   | true     |                                                                                                                                                                                                                         |                                                                                                               | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                            | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| created_by                            | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| updated_at                            | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| updated_by                            | TEXT        |                   | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| deleted_at                            | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| deleted_by                            | TEXT        |                   | true     |                                                                                                                                                                                                                         |                                                                                                               |                                                         |
| activity_log                          | TEXT        |                   | true     |                                                                                                                                                                                                                         |                                                                                                               | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                                  | Type        | Definition                                                                                                                                                       |
| ----------------------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_imap_acct_folder_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_imap_acct_folder_id)                                                                                                              |
| - (Foreign key ID: 0)                                 | FOREIGN KEY | FOREIGN KEY (ingest_account_id) REFERENCES ur_ingest_session_imap_account (ur_ingest_session_imap_account_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)                                 | FOREIGN KEY | FOREIGN KEY (ingest_session_id) REFERENCES ur_ingest_session (ur_ingest_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                           |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_2 | UNIQUE      | UNIQUE (ingest_account_id, folder_name)                                                                                                                          |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_imap_acct_folder_id)                                                                                                              |
| -                                                     | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                            |

## Indexes

| Name                                                                   | Definition                                                                                                                                                        |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_imap_acct_folder__ingest_session_id__folder_name | CREATE INDEX "idx_ur_ingest_session_imap_acct_folder__ingest_session_id__folder_name" ON "ur_ingest_session_imap_acct_folder"("ingest_session_id", "folder_name") |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_2                  | UNIQUE (ingest_account_id, folder_name)                                                                                                                           |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_1                  | PRIMARY KEY (ur_ingest_session_imap_acct_folder_id)                                                                                                               |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder.svg)
