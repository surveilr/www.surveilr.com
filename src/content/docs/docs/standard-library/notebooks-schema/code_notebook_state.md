---
title: code_notebook_state
description: Explanation of the `code_notebook_state` 
---


## Description

Records the state of a notebook's cells' executions, computations, and results for Kernels that are stateful.  For example, a SQL Notebook Cell that creates tables should only be run once (meaning it's statefule).  Other Kernels might store results for functions and output defined in one cell can be used in later cells.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "code_notebook_state" (
    "code_notebook_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "code_notebook_cell_id" VARCHAR NOT NULL,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMP,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMP,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("code_notebook_cell_id") REFERENCES "code_notebook_cell"("code_notebook_cell_id"),
    UNIQUE("code_notebook_cell_id", "from_state", "to_state")
)
```

</details>

## Columns

| Name                   | Type      | Default           | Nullable | Parents                                     | Comment                                                                   |
| ---------------------- | --------- | ----------------- | -------- | ------------------------------------------- | ------------------------------------------------------------------------- |
| code_notebook_state_id | VARCHAR   |                   | false    |                                             | code_notebook_state primary key                                           |
| code_notebook_cell_id  | VARCHAR   |                   | false    | [code_notebook_cell](/docs/standard-library/notebooks-schema/code_notebook_cell) | code_notebook_cell row this state describes                               |
| from_state             | TEXT      |                   | false    |                                             | the previous state (set to "INITIAL" when it's the first transition)      |
| to_state               | TEXT      |                   | false    |                                             | the current state; if no rows exist it means no state transition occurred |
| transition_result      | TEXT      |                   | true     |                                             | if the result of state change is necessary for future use                 |
| transition_reason      | TEXT      |                   | true     |                                             | short text or code explaining why the transition occurred                 |
| transitioned_at        | TIMESTAMP | CURRENT_TIMESTAMP | true     |                                             | when the transition occurred                                              |
| elaboration            | TEXT      |                   | true     |                                             | any elaboration needed for the state transition                           |
| created_at             | TIMESTAMP | CURRENT_TIMESTAMP | true     |                                             |                                                                           |
| created_by             | TEXT      | 'UNKNOWN'         | true     |                                             |                                                                           |
| updated_at             | TIMESTAMP |                   | true     |                                             |                                                                           |
| updated_by             | TEXT      |                   | true     |                                             |                                                                           |
| deleted_at             | TIMESTAMP |                   | true     |                                             |                                                                           |
| deleted_by             | TEXT      |                   | true     |                                             |                                                                           |
| activity_log           | TEXT      |                   | true     |                                             | {"isSqlDomainZodDescrMeta":true,"isJsonSqlDomain":true}                   |

## Constraints

| Name                                   | Type        | Definition                                                                                                                                   |
| -------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| code_notebook_state_id                 | PRIMARY KEY | PRIMARY KEY (code_notebook_state_id)                                                                                                         |
| - (Foreign key ID: 0)                  | FOREIGN KEY | FOREIGN KEY (code_notebook_cell_id) REFERENCES code_notebook_cell (code_notebook_cell_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| sqlite_autoindex_code_notebook_state_2 | UNIQUE      | UNIQUE (code_notebook_cell_id, from_state, to_state)                                                                                         |
| sqlite_autoindex_code_notebook_state_1 | PRIMARY KEY | PRIMARY KEY (code_notebook_state_id)                                                                                                         |
| -                                      | CHECK       | CHECK(json_valid(transition_result) OR transition_result IS NULL)                                                                            |
| -                                      | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                        |

## Indexes

| Name                                   | Definition                                           |
| -------------------------------------- | ---------------------------------------------------- |
| sqlite_autoindex_code_notebook_state_2 | UNIQUE (code_notebook_cell_id, from_state, to_state) |
| sqlite_autoindex_code_notebook_state_1 | PRIMARY KEY (code_notebook_state_id)                 |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/notebooks-schema/code_notebook_state.svg)