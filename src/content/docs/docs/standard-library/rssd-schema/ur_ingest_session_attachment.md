---
title: ur_ingest_session_attachment
---

## Description

uniform_resource transformed content

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_session_attachment" (
    "ur_ingest_session_attachment_id" VARCHAR PRIMARY KEY NOT NULL,
    "uniform_resource_id" VARCHAR,
    "name" TEXT,
    "uri" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size" INTEGER,
    "checksum" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("uniform_resource_id", "checksum", "nature", "size")
)
```

</details>

## Columns

| Name                            | Type        | Default           | Nullable | Parents                                                                           | Comment                                                 |
| ------------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------- | ------------------------------------------------------- |
| ur_ingest_session_attachment_id | VARCHAR     |                   | false    |                                                                                   | ur_ingest_session_attachment ULID primary key           |
| uniform_resource_id             | VARCHAR     |                   | true     | [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource) | uniform_resource row ID of original content             |
| name                            | TEXT        |                   | true     |                                                                                   |                                                         |
| uri                             | TEXT        |                   | false    |                                                                                   |                                                         |
| content                         | BLOB        |                   | true     |                                                                                   | transformed content                                     |
| nature                          | TEXT        |                   | true     |                                                                                   | file extension or MIME                                  |
| size                            | INTEGER     |                   | true     |                                                                                   |                                                         |
| checksum                        | TEXT        |                   | true     |                                                                                   |                                                         |
| elaboration                     | TEXT        |                   | true     |                                                                                   | anything that doesn't fit in other columns (JSON)       |
| created_at                      | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                   |                                                         |
| created_by                      | TEXT        | 'UNKNOWN'         | true     |                                                                                   |                                                         |
| updated_at                      | TIMESTAMPTZ |                   | true     |                                                                                   |                                                         |
| updated_by                      | TEXT        |                   | true     |                                                                                   |                                                         |
| deleted_at                      | TIMESTAMPTZ |                   | true     |                                                                                   |                                                         |
| deleted_by                      | TEXT        |                   | true     |                                                                                   |                                                         |
| activity_log                    | TEXT        |                   | true     |                                                                                   | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                            | Type        | Definition                                                                                                                             |
| ----------------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ur_ingest_session_attachment_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_attachment_id)                                                                                          |
| - (Foreign key ID: 0)                           | FOREIGN KEY | FOREIGN KEY (uniform_resource_id) REFERENCES uniform_resource (uniform_resource_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_ur_ingest_session_attachment_2 | UNIQUE      | UNIQUE (uniform_resource_id, checksum, nature, size)                                                                                   |
| sqlite_autoindex_ur_ingest_session_attachment_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_session_attachment_id)                                                                                          |
| -                                               | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                  |

## Indexes

| Name                                                           | Definition                                                                                                                                        |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_ur_ingest_session_attachment__uniform_resource_id__content | CREATE INDEX "idx_ur_ingest_session_attachment__uniform_resource_id__content" ON "ur_ingest_session_attachment"("uniform_resource_id", "content") |
| sqlite_autoindex_ur_ingest_session_attachment_2                | UNIQUE (uniform_resource_id, checksum, nature, size)                                                                                              |
| sqlite_autoindex_ur_ingest_session_attachment_1                | PRIMARY KEY (ur_ingest_session_attachment_id)                                                                                                     |

## Relations

![er](../../../../../assets/ur_ingest_session_attachment.svg)
