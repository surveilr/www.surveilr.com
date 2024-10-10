---
title: Uniform Resource Ingest Resource Path Match Rule
---

## Description

A regular expression can determine the flags to apply to an ingestion path\
and if the regular expr contains a nature capture group that pattern match\
will assign the nature too.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "ur_ingest_resource_path_match_rule" (
    "ur_ingest_resource_path_match_rule_id" VARCHAR PRIMARY KEY NOT NULL,
    "namespace" TEXT NOT NULL,
    "regex" TEXT NOT NULL,
    "flags" TEXT NOT NULL,
    "nature" TEXT,
    "priority" TEXT,
    "description" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("namespace", "regex")
)
```

</details>

## Columns

| Name                                  | Type        | Default           | Nullable | Comment                                                 |
| ------------------------------------- | ----------- | ----------------- | -------- | ------------------------------------------------------- |
| ur_ingest_resource_path_match_rule_id | VARCHAR     |                   | false    | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| namespace                             | TEXT        |                   | false    |                                                         |
| regex                                 | TEXT        |                   | false    |                                                         |
| flags                                 | TEXT        |                   | false    |                                                         |
| nature                                | TEXT        |                   | true     |                                                         |
| priority                              | TEXT        |                   | true     |                                                         |
| description                           | TEXT        |                   | true     |                                                         |
| elaboration                           | TEXT        |                   | true     | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                            | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                         |
| created_by                            | TEXT        | 'UNKNOWN'         | true     |                                                         |
| updated_at                            | TIMESTAMPTZ |                   | true     |                                                         |
| updated_by                            | TEXT        |                   | true     |                                                         |
| deleted_at                            | TIMESTAMPTZ |                   | true     |                                                         |
| deleted_by                            | TEXT        |                   | true     |                                                         |
| activity_log                          | TEXT        |                   | true     | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                                  | Type        | Definition                                            |
| ----------------------------------------------------- | ----------- | ----------------------------------------------------- |
| ur_ingest_resource_path_match_rule_id                 | PRIMARY KEY | PRIMARY KEY (ur_ingest_resource_path_match_rule_id)   |
| sqlite_autoindex_ur_ingest_resource_path_match_rule_2 | UNIQUE      | UNIQUE (namespace, regex)                             |
| sqlite_autoindex_ur_ingest_resource_path_match_rule_1 | PRIMARY KEY | PRIMARY KEY (ur_ingest_resource_path_match_rule_id)   |
| -                                                     | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL) |

## Indexes

| Name                                                  | Definition                                          |
| ----------------------------------------------------- | --------------------------------------------------- |
| sqlite_autoindex_ur_ingest_resource_path_match_rule_2 | UNIQUE (namespace, regex)                           |
| sqlite_autoindex_ur_ingest_resource_path_match_rule_1 | PRIMARY KEY (ur_ingest_resource_path_match_rule_id) |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/ur_ingest_resource_path_match_rule.svg)
