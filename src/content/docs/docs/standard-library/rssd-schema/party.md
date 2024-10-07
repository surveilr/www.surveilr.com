---
title: Party
---

## Description

Entity representing parties involved in business transactions.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "party" (
    "party_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_type_id" TEXT NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("code")
)
```

</details>

## Columns

| Name          | Type        | Default           | Nullable | Children                                                                                                                                                                                                                                                                                                                                                                                                      | Parents                                                               | Comment                                                 |
| ------------- | ----------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------- |
| party_id      | VARCHAR     |                   | false    | [party_relation](/docs/standard-library/rssd-schema/party_relation) [person](/docs/standard-library/rssd-schema/person) [organization](/docs/standard-library/rssd-schema/organization) [organization_role](/docs/standard-library/rssd-schema/organization_role) [device_party_relationship](/docs/standard-library/rssd-schema/device_party_relationship) |                                                                       | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}       |
| party_type_id | TEXT        |                   | false    |                                                                                                                                                                                                                                                                                                                                                                                                               | [party_type](/docs/standard-library/rssd-schema/party_type) |                                                         |
| party_name    | TEXT        |                   | false    |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       | The name of the party                                   |
| elaboration   | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       | Any elaboration needed for the party.                   |
| created_at    | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| created_by    | TEXT        | 'UNKNOWN'         | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| updated_at    | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| updated_by    | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| deleted_at    | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| deleted_by    | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       |                                                         |
| activity_log  | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                       | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true} |

## Constraints

| Name                     | Type        | Definition                                                                                                  |
| ------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------- |
| party_id                 | PRIMARY KEY | PRIMARY KEY (party_id)                                                                                      |
| - (Foreign key ID: 0)    | FOREIGN KEY | FOREIGN KEY (party_type_id) REFERENCES party_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_party_1 | PRIMARY KEY | PRIMARY KEY (party_id)                                                                                      |
| -                        | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                       |

## Indexes

| Name                                 | Definition                                                                                    |
| ------------------------------------ | --------------------------------------------------------------------------------------------- |
| idx_party__party_type_id__party_name | CREATE INDEX "idx_party__party_type_id__party_name" ON "party"("party_type_id", "party_name") |
| sqlite_autoindex_party_1             | PRIMARY KEY (party_id)                                                                        |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/party.svg)
