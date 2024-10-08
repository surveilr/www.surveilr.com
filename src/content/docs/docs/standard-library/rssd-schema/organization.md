---
title: organization
---

## Description

Entity to store information about organizations. Each organization has a unique
ID associated with it.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "organization" (
    "organization_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT,
    "federal_tax_id_num" TEXT,
    "registration_date" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    UNIQUE("organization_id", "name")
)
```

</details>

## Columns

| Name               | Type        | Default           | Nullable | Parents                                                     | Comment                                                           |
| ------------------ | ----------- | ----------------- | -------- | ----------------------------------------------------------- | ----------------------------------------------------------------- |
| organization_id    | VARCHAR     |                   | false    | [party](/docs/standard-library/rssd-schema/party) | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}                 |
| name               | TEXT        |                   | false    |                                                             | The name of the organization.                                     |
| alias              | TEXT        |                   | true     |                                                             | An alias or alternative name for the organization, if applicable. |
| description        | TEXT        |                   | true     |                                                             | A description of the organization.                                |
| license            | TEXT        |                   | true     |                                                             | The license number or identifier for the organization.            |
| federal_tax_id_num | TEXT        |                   | true     |                                                             | The federal tax identification number of the organization.        |
| registration_date  | TIMESTAMPTZ |                   | true     |                                                             | The date on which the organization was registered.                |
| elaboration        | TEXT        |                   | true     |                                                             | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}                |
| created_at         | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                             |                                                                   |
| created_by         | TEXT        | 'UNKNOWN'         | true     |                                                             |                                                                   |
| updated_at         | TIMESTAMPTZ |                   | true     |                                                             |                                                                   |
| updated_by         | TEXT        |                   | true     |                                                             |                                                                   |
| deleted_at         | TIMESTAMPTZ |                   | true     |                                                             |                                                                   |
| deleted_by         | TEXT        |                   | true     |                                                             |                                                                   |
| activity_log       | TEXT        |                   | true     |                                                             | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true}           |

## Constraints

| Name                            | Type        | Definition                                                                                                   |
| ------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
| - (Foreign key ID: 0)           | FOREIGN KEY | FOREIGN KEY (organization_id) REFERENCES party (party_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_organization_1 | UNIQUE      | UNIQUE (organization_id, name)                                                                               |
| -                               | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                        |

## Indexes

| Name                                    | Definition                                                                                          |
| --------------------------------------- | --------------------------------------------------------------------------------------------------- |
| idx_organization__organization_id__name | CREATE INDEX "idx_organization__organization_id__name" ON "organization"("organization_id", "name") |
| sqlite_autoindex_organization_1         | UNIQUE (organization_id, name)                                                                      |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/organization.svg)
