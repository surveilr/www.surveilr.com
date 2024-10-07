---
title: orchestration_session_log
---

## Description

An orchestration issue is generated when an error or warning needs to\
be created during the orchestration of an entry in a session.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_session_log" (
    "orchestration_session_log_id" UUID PRIMARY KEY NOT NULL,
    "category" TEXT,
    "parent_exec_id" UUID,
    "content" TEXT NOT NULL,
    "sibling_order" INTEGER,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_log"("orchestration_session_log_id")
)
```

</details>

## Columns

| Name                         | Type    | Default | Nullable | Children                                                                                            | Parents                                                                                             | Comment                                                     |
| ---------------------------- | ------- | ------- | -------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| orchestration_session_log_id | UUID    |         | false    | [orchestration_session_log](/docs/standard-library/rssd-schema/orchestration_session_log) |                                                                                                     | {"isSqlDomainZodDescrMeta":true,"isUuid":true}              |
| category                     | TEXT    |         | true     |                                                                                                     |                                                                                                     |                                                             |
| parent_exec_id               | UUID    |         | true     |                                                                                                     | [orchestration_session_log](/docs/standard-library/rssd-schema/orchestration_session_log) | {"isSqlDomainZodDescrMeta":true,"isUuid":true}              |
| content                      | TEXT    |         | false    |                                                                                                     |                                                                                                     |                                                             |
| sibling_order                | INTEGER |         | true     |                                                                                                     |                                                                                                     |                                                             |
| elaboration                  | TEXT    |         | true     |                                                                                                     |                                                                                                     | isse-specific attributes/properties in JSON ("custom data") |

## Constraints

| Name                                         | Type        | Definition                                                                                                                                          |
| -------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| orchestration_session_log_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_session_log_id)                                                                                                          |
| - (Foreign key ID: 0)                        | FOREIGN KEY | FOREIGN KEY (parent_exec_id) REFERENCES orchestration_session_log (orchestration_session_log_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_orchestration_session_log_1 | PRIMARY KEY | PRIMARY KEY (orchestration_session_log_id)                                                                                                          |
| -                                            | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                               |

## Indexes

| Name                                         | Definition                                 |
| -------------------------------------------- | ------------------------------------------ |
| sqlite_autoindex_orchestration_session_log_1 | PRIMARY KEY (orchestration_session_log_id) |

## Relations

![er](../../../../../../assets/images/content/docs/standard-library/rssd-schema/orchestration_session_log.svg)
