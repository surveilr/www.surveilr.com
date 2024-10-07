---
title: orchestration_session
---

## Description

An orchestration session groups multiple orchestration events for reporting or
other purposes

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_session" (
    "orchestration_session_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "orchestration_nature_id" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "orch_started_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "orch_finished_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "args_json" TEXT CHECK(json_valid(args_json) OR args_json IS NULL),
    "diagnostics_json" TEXT CHECK(json_valid(diagnostics_json) OR diagnostics_json IS NULL),
    "diagnostics_md" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("orchestration_nature_id") REFERENCES "orchestration_nature"("orchestration_nature_id")
)
```

</details>

## Columns

| Name                     | Type        | Default           | Nullable | Children                                                                                                                                                                                                                                                                                                                                                                                                                      | Parents                                                                                   | Comment                                                                   |
| ------------------------ | ----------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| orchestration_session_id | VARCHAR     |                   | false    | [orchestration_session_entry](/docs/standard-library/rssd-schema/orchestration_session_entry) [orchestration_session_state](/docs/standard-library/rssd-schema/orchestration_session_state) [orchestration_session_exec](/docs/standard-library/rssd-schema/orchestration_session_exec) [orchestration_session_issue](/docs/standard-library/rssd-schema/orchestration_session_issue) |                                                                                           | orchestration_session primary key and internal label (UUID)               |
| device_id                | VARCHAR     |                   | false    |                                                                                                                                                                                                                                                                                                                                                                                                                               | [device](/docs/standard-library/rssd-schema/device)                             | {"isSqlDomainZodDescrMeta":true,"isVarChar":true}                         |
| orchestration_nature_id  | TEXT        |                   | false    |                                                                                                                                                                                                                                                                                                                                                                                                                               | [orchestration_nature](/docs/standard-library/rssd-schema/orchestration_nature) |                                                                           |
| version                  | TEXT        |                   | false    |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           |                                                                           |
| orch_started_at          | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           |                                                                           |
| orch_finished_at         | TIMESTAMPTZ |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           | {"isSqlDomainZodDescrMeta":true,"isDateSqlDomain":true,"isDateTime":true} |
| elaboration              | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           | JSON governance data (description, documentation, usage, etc. in JSON)    |
| args_json                | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           | Sesison arguments in a machine-friendly (engine-dependent) JSON format    |
| diagnostics_json         | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           | Diagnostics in a machine-friendly (engine-dependent) JSON format          |
| diagnostics_md           | TEXT        |                   | true     |                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                           | Diagnostics in a human-friendly readable markdown format                  |

## Constraints

| Name                                     | Type        | Definition                                                                                                                                         |
| ---------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| orchestration_session_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_session_id)                                                                                                             |
| - (Foreign key ID: 0)                    | FOREIGN KEY | FOREIGN KEY (orchestration_nature_id) REFERENCES orchestration_nature (orchestration_nature_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)                    | FOREIGN KEY | FOREIGN KEY (device_id) REFERENCES device (device_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                                           |
| sqlite_autoindex_orchestration_session_1 | PRIMARY KEY | PRIMARY KEY (orchestration_session_id)                                                                                                             |
| -                                        | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                              |
| -                                        | CHECK       | CHECK(json_valid(args_json) OR args_json IS NULL)                                                                                                  |
| -                                        | CHECK       | CHECK(json_valid(diagnostics_json) OR diagnostics_json IS NULL)                                                                                    |

## Indexes

| Name                                     | Definition                             |
| ---------------------------------------- | -------------------------------------- |
| sqlite_autoindex_orchestration_session_1 | PRIMARY KEY (orchestration_session_id) |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/orchestration_session.svg)
