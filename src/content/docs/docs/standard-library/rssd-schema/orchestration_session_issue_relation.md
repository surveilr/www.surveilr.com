---
title: orchestration_session_issue_relation
---

## Description

An orchestration issue is generated when an error or warning needs to\
be created during the orchestration of an entry in a session.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_session_issue_relation" (
    "orchestration_session_issue_relation_id" UUID PRIMARY KEY NOT NULL,
    "issue_id_prime" UUID NOT NULL,
    "issue_id_rel" TEXT NOT NULL,
    "relationship_nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("issue_id_prime") REFERENCES "orchestration_session_issue"("orchestration_session_issue_id")
)
```

</details>

## Columns

| Name                                    | Type | Default | Nullable | Parents                                                                                                 | Comment                                                     |
| --------------------------------------- | ---- | ------- | -------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| orchestration_session_issue_relation_id | UUID |         | false    |                                                                                                         | {"isSqlDomainZodDescrMeta":true,"isUuid":true}              |
| issue_id_prime                          | UUID |         | false    | [orchestration_session_issue](/docs/standard-library/rssd-schema/orchestration_session_issue) | {"isSqlDomainZodDescrMeta":true,"isUuid":true}              |
| issue_id_rel                            | TEXT |         | false    |                                                                                                         |                                                             |
| relationship_nature                     | TEXT |         | false    |                                                                                                         |                                                             |
| elaboration                             | TEXT |         | true     |                                                                                                         | isse-specific attributes/properties in JSON ("custom data") |

## Constraints

| Name                                                    | Type        | Definition                                                                                                                                              |
| ------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| orchestration_session_issue_relation_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_session_issue_relation_id)                                                                                                   |
| - (Foreign key ID: 0)                                   | FOREIGN KEY | FOREIGN KEY (issue_id_prime) REFERENCES orchestration_session_issue (orchestration_session_issue_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_orchestration_session_issue_relation_1 | PRIMARY KEY | PRIMARY KEY (orchestration_session_issue_relation_id)                                                                                                   |
| -                                                       | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                   |

## Indexes

| Name                                                    | Definition                                            |
| ------------------------------------------------------- | ----------------------------------------------------- |
| sqlite_autoindex_orchestration_session_issue_relation_1 | PRIMARY KEY (orchestration_session_issue_relation_id) |

## Relations

![er](../../../../../assets/orchestration_session_issue_relation.svg)
