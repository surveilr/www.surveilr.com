---
title: ur_ingest_session_imap_acct_folder_message
---

## Description

Contains messages related in a folder that was ingested. On multiple executions,
unlike uniform_resource, ur_ingest_session_imap_acct_folder_message rows are
always inserted and references the uniform_resource primary key of its related
content. This method allows for a more efficient query of message version
differences across sessions. With SQL queries, you can detect which sessions
have a messaged added or modified, which sessions have a message deleted, and
what the differences are in message contents if they were modified across
sessions.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_imap_acct_folder_message" (
    "ur_ingest_session_imap_acct_folder_message_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_imap_acct_folder_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "message" TEXT NOT NULL,
    "message_id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "cc" TEXT CHECK(json_valid(cc)) NOT NULL,
    "bcc" TEXT CHECK(json_valid(bcc)) NOT NULL,
    "status" TEXT[] NOT NULL,
    "date" DATE,
    "email_references" TEXT CHECK(json_valid(email_references)) NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("message", "message_id")
)
```

</details>

## Columns

| Name                                          | Type        | Default           | Nullable | Parents                                                                                                               | Comment                                                 |
| --------------------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_imap_acct_folder_message_id | VARCHAR     |                   | false    |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_session_id                             | VARCHAR     |                   | false    | [ur_ingest_session](/docs/standard-library/rssd-schema/ur_ingest_session)                                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| ingest_imap_acct_folder_id                    | VARCHAR     |                   | false    | [ur_ingest_session_imap_acct_folder](/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| uniform_resource_id                           | VARCHAR     |                   | true     | [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource)                                     | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| message                                       | TEXT        |                   | false    |                                                                                                                       |                                                         |
| message_id                                    | TEXT        |                   | false    |                                                                                                                       |                                                         |
| subject                                       | TEXT        |                   | false    |                                                                                                                       |                                                         |
| from                                          | TEXT        |                   | false    |                                                                                                                       |                                                         |
| cc                                            | TEXT        |                   | false    |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| bcc                                           | TEXT        |                   | false    |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| status                                        | TEXT[]      |                   | false    |                                                                                                                       |                                                         |
| date                                          | DATE        |                   | true     |                                                                                                                       |                                                         |
| email_references                              | TEXT        |                   | false    |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                                    | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                       |                                                         |
| created_by                                    | TEXT        | 'UNKNOWN'         | true     |                                                                                                                       |                                                         |
| updated_at                                    | TIMESTAMPTZ |                   | true     |                                                                                                                       |                                                         |
| updated_by                                    | TEXT        |                   | true     |                                                                                                                       |                                                         |
| deleted_at                                    | TIMESTAMPTZ |                   | true     |                                                                                                                       |                                                         |
| deleted_by                                    | TEXT        |                   | true     |                                                                                                                       |                                                         |
| activity_log                                  | TEXT        |                   | true     |                                                                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                                          | Type        | Definition                                                                                                                                                                        |
| ------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_imap_acct_folder_message_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_imap_acct_folder_message_id)                                                                                                                       |
| - (Foreign key ID: 0)                                         | FOREIGN KEY | FOREIGN KEY (uniform_resource_id) REFERENCES uniform_resource (uniform_resource_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                                            |
| - (Foreign key ID: 1)                                         | FOREIGN KEY | FOREIGN KEY (ingest_imap_acct_folder_id) REFERENCES ur_ingest_session_imap_acct_folder (ur_ingest_session_imap_acct_folder_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 2)                                         | FOREIGN KEY | FOREIGN KEY (ingest_session_id) REFERENCES ur_ingest_session (ur_ingest_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                                            |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_message_2 | UNIQUE      | UNIQUE (message, message_id)                                                                                                                                                      |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_message_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_imap_acct_folder_message_id)                                                                                                                       |
| -                                                             | CHECK       | CHECK(json_valid(cc))                                                                                                                                                             |
| -                                                             | CHECK       | CHECK(json_valid(bcc))                                                                                                                                                            |
| -                                                             | CHECK       | CHECK(json_valid(email_references))                                                                                                                                               |

## Indexes

| Name                                                              | Definition                                                                                                                                            |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_imap_acct_folder_message__ingest_session_id | CREATE INDEX "idx_ur_ingest_session_imap_acct_folder_message__ingest_session_id" ON "ur_ingest_session_imap_acct_folder_message"("ingest_session_id") |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_message_2     | UNIQUE (message, message_id)                                                                                                                          |
| sqlite_autoindex_ur_ingest_session_imap_acct_folder_message_1     | PRIMARY KEY (ur_ingest_session_imap_acct_folder_message_id)                                                                                           |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_session_imap_acct_folder_message.svg)
