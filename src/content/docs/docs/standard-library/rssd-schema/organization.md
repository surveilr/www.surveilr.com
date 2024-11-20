---
title: Organization
---

## Description

Entity to store information about organizations. Each organization has a unique ID associated with it.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "organization" (
    "organization_id" ULID PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT NOT NULL,
    "federal_tax_id_num" TEXT,
    "registration_date" DATE NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
)
```

</details>

## Columns

| Name               | Type        | Default           | Nullable | Parents           | Comment                                                 |
| ------------------ | ----------- | ----------------- | -------- | ----------------- | ------------------------------------------------------- |
| organization_id    | ULID        |                   | false    |                   | {"isSqlDomainZodDescrMeta":true,"isUlid":true}          |
| party_id           | VARCHAR     |                   | false    | [party](/docs/standard-library/rssd-schema/party) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| name               | TEXT        |                   | false    |                   |                                                         |
| alias              | TEXT        |                   | true     |                   |                                                         |
| description        | TEXT        |                   | true     |                   |                                                         |
| license            | TEXT        |                   | false    |                   |                                                         |
| federal_tax_id_num | TEXT        |                   | true     |                   |                                                         |
| registration_date  | DATE        |                   | false    |                   |                                                         |
| elaboration        | TEXT        |                   | true     |                   | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at         | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                   |                                                         |
| created_by         | TEXT        | 'UNKNOWN'         | true     |                   |                                                         |
| updated_at         | TIMESTAMPTZ |                   | true     |                   |                                                         |
| updated_by         | TEXT        |                   | true     |                   |                                                         |
| deleted_at         | TIMESTAMPTZ |                   | true     |                   |                                                         |
| deleted_by         | TEXT        |                   | true     |                   |                                                         |
| activity_log       | TEXT        |                   | true     |                   | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                            | Type        | Definition                                                                                            |
| ------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| organization_id                 | PRIMARY KEY | PRIMARY KEY (organization_id)                                                                         |
| - (Foreign key ID: 0)           | FOREIGN KEY | FOREIGN KEY (party_id) REFERENCES party (party_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_organization_1 | PRIMARY KEY | PRIMARY KEY (organization_id)                                                                         |
| -                               | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                 |

## Indexes

| Name                            | Definition                    |
| ------------------------------- | ----------------------------- |
| sqlite_autoindex_organization_1 | PRIMARY KEY (organization_id) |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/organization.svg)
