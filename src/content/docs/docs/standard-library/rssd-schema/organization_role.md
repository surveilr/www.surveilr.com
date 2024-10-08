---
title: organization_role
---

## Description

Entity to associate individuals with roles in organizations. Each organization
role has a unique ID associated with it.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "organization_role" (
    "organization_role_id" VARCHAR PRIMARY KEY NOT NULL,
    "person_id" VARCHAR NOT NULL,
    "organization_id" VARCHAR NOT NULL,
    "organization_role_type_id" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("code"),
    UNIQUE("person_id", "organization_id", "organization_role_type_id")
)
```

</details>

## Columns

| Name                      | Type        | Default           | Nullable | Parents                                                                                       | Comment                                                 |
| ------------------------- | ----------- | ----------------- | -------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| organization_role_id      | VARCHAR     |                   | false    |                                                                                               | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| person_id                 | VARCHAR     |                   | false    | [party](/docs/standard-library/rssd-schema/party)                                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| organization_id           | VARCHAR     |                   | false    | [party](/docs/standard-library/rssd-schema/party)                                   | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| organization_role_type_id | TEXT        |                   | false    | [organization_role_type](/docs/standard-library/rssd-schema/organization_role_type) |                                                         |
| elaboration               | TEXT        |                   | true     |                                                                                               | {"isSqlDomainZodDescrMeta":true,"isJsonText":true}      |
| created_at                | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                               |                                                         |
| created_by                | TEXT        | 'UNKNOWN'         | true     |                                                                                               |                                                         |
| updated_at                | TIMESTAMPTZ |                   | true     |                                                                                               |                                                         |
| updated_by                | TEXT        |                   | true     |                                                                                               |                                                         |
| deleted_at                | TIMESTAMPTZ |                   | true     |                                                                                               |                                                         |
| deleted_by                | TEXT        |                   | true     |                                                                                               |                                                         |
| activity_log              | TEXT        |                   | true     |                                                                                               | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                                 | Type        | Definition                                                                                                                          |
| ------------------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| organization_role_id                 | PRIMARY KEY | PRIMARY KEY (organization_role_id)                                                                                                  |
| - (Foreign key ID: 0)                | FOREIGN KEY | FOREIGN KEY (organization_role_type_id) REFERENCES organization_role_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)                | FOREIGN KEY | FOREIGN KEY (organization_id) REFERENCES party (party_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                        |
| - (Foreign key ID: 2)                | FOREIGN KEY | FOREIGN KEY (person_id) REFERENCES party (party_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                              |
| sqlite_autoindex_organization_role_2 | UNIQUE      | UNIQUE (person_id, organization_id, organization_role_type_id)                                                                      |
| sqlite_autoindex_organization_role_1 | PRIMARY KEY | PRIMARY KEY (organization_role_id)                                                                                                  |
| -                                    | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                               |

## Indexes

| Name                                                                         | Definition                                                                                                                                                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_organization_role__person_id__organization_id__organization_role_type_id | CREATE INDEX "idx_organization_role__person_id__organization_id__organization_role_type_id" ON "organization_role"("person_id", "organization_id", "organization_role_type_id") |
| sqlite_autoindex_organization_role_2                                         | UNIQUE (person_id, organization_id, organization_role_type_id)                                                                                                                  |
| sqlite_autoindex_organization_role_1                                         | PRIMARY KEY (organization_role_id)                                                                                                                                              |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/organization_role.svg)
