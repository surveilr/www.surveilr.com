---
title: orchestration_nature
---

## Description

Entity to define relationships between multiple tenants to multiple devices

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_nature" (
    "orchestration_nature_id" TEXT PRIMARY KEY NOT NULL,
    "nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("orchestration_nature_id", "nature")
)
```

</details>

## Columns

| Name                    | Type        | Default           | Nullable | Children                                                                                    | Comment                                                 |
| ----------------------- | ----------- | ----------------- | -------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| orchestration_nature_id | TEXT        |                   | false    | [orchestration_session](/docs/standard-library/rssd-schema/orchestration_session) |                                                         |
| nature                  | TEXT        |                   | false    |                                                                                             |                                                         |
| elaboration             | TEXT        |                   | true     |                                                                                             | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at              | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                             |                                                         |
| created_by              | TEXT        | 'UNKNOWN'         | true     |                                                                                             |                                                         |
| updated_at              | TIMESTAMPTZ |                   | true     |                                                                                             |                                                         |
| updated_by              | TEXT        |                   | true     |                                                                                             |                                                         |
| deleted_at              | TIMESTAMPTZ |                   | true     |                                                                                             |                                                         |
| deleted_by              | TEXT        |                   | true     |                                                                                             |                                                         |
| activity_log            | TEXT        |                   | true     |                                                                                             | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                    | Type        | Definition                                            |
| --------------------------------------- | ----------- | ----------------------------------------------------- |
| orchestration_nature_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_nature_id)                 |
| sqlite_autoindex_orchestration_nature_2 | UNIQUE      | UNIQUE (orchestration_nature_id, nature)              |
| sqlite_autoindex_orchestration_nature_1 | PRIMARY KEY | PRIMARY KEY (orchestration_nature_id)                 |
| -                                       | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL) |

## Indexes

| Name                                                      | Definition                                                                                                                              |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| idx_orchestration_nature__orchestration_nature_id__nature | CREATE INDEX "idx_orchestration_nature__orchestration_nature_id__nature" ON "orchestration_nature"("orchestration_nature_id", "nature") |
| sqlite_autoindex_orchestration_nature_2                   | UNIQUE (orchestration_nature_id, nature)                                                                                                |
| sqlite_autoindex_orchestration_nature_1                   | PRIMARY KEY (orchestration_nature_id)                                                                                                   |

## Relations

![er](../../../../../assets/orchestration_nature.svg)
