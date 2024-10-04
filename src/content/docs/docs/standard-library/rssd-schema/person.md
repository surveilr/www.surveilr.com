---
title: person
---

## Description

Entity to store information about individuals as persons. Each person has a
unique ID associated with them.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "person" (
    "person_id" VARCHAR NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("code"),
    UNIQUE("person_id")
)
```

</details>

## Columns

| Name               | Type        | Default           | Nullable | Parents                                                                 | Comment                                                            |
| ------------------ | ----------- | ----------------- | -------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------ |
| person_id          | VARCHAR     |                   | false    | [party](/docs/standard-library/rssd-schema/party)             | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}                  |
| person_first_name  | TEXT        |                   | false    |                                                                         | The first name of the person.                                      |
| person_middle_name | TEXT        |                   | true     |                                                                         | The middle name of the person, if applicable.                      |
| person_last_name   | TEXT        |                   | false    |                                                                         | The last name of the person.                                       |
| honorific_prefix   | TEXT        |                   | true     |                                                                         | An honorific prefix for the person, such as "Mr.", "Ms.", or "Dr." |
| honorific_suffix   | TEXT        |                   | true     |                                                                         | An honorific suffix for the person, such as "Jr." or "Sr."         |
| gender_id          | TEXT        |                   | false    | [gender_type](/docs/standard-library/rssd-schema/gender_type) |                                                                    |
| elaboration        | TEXT        |                   | true     |                                                                         | Any elaboration needed for the person.                             |
| created_at         | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                         |                                                                    |
| created_by         | TEXT        | 'UNKNOWN'         | true     |                                                                         |                                                                    |
| updated_at         | TIMESTAMPTZ |                   | true     |                                                                         |                                                                    |
| updated_by         | TEXT        |                   | true     |                                                                         |                                                                    |
| deleted_at         | TIMESTAMPTZ |                   | true     |                                                                         |                                                                    |
| deleted_by         | TEXT        |                   | true     |                                                                         |                                                                    |
| activity_log       | TEXT        |                   | true     |                                                                         | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true}            |

## Constraints

| Name                      | Type        | Definition                                                                                               |
| ------------------------- | ----------- | -------------------------------------------------------------------------------------------------------- |
| - (Foreign key ID: 0)     | FOREIGN KEY | FOREIGN KEY (gender_id) REFERENCES gender_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)     | FOREIGN KEY | FOREIGN KEY (person_id) REFERENCES party (party_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE   |
| sqlite_autoindex_person_1 | UNIQUE      | UNIQUE (person_id)                                                                                       |
| -                         | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                    |

## Indexes

| Name                                                                           | Definition                                                                                                                                                                            |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| idx_person__person_id__person_first_name__person_middle_name__person_last_name | CREATE INDEX "idx_person__person_id__person_first_name__person_middle_name__person_last_name" ON "person"("person_id", "person_first_name", "person_middle_name", "person_last_name") |
| sqlite_autoindex_person_1                                                      | UNIQUE (person_id)                                                                                                                                                                    |

## Relations

![er](../../../../../assets/person.svg)
