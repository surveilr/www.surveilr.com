---
title: Orchestration Session State
---

## Description

Records the state of an orchestration session, computations, and results for
Kernels that are stateful. For example, a SQL Notebook Cell that creates tables
should only be run once (meaning it's stateful). Other Kernels might store
results for functions and output defined in one cell can be used in later cells.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_session_state" (
    "orchestration_session_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    UNIQUE("orchestration_session_state_id", "from_state", "to_state")
)
```

</details>

## Columns

| Name                           | Type        | Default           | Nullable | Parents                                                                                                 | Comment                                                                   |
| ------------------------------ | ----------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| orchestration_session_state_id | VARCHAR     |                   | false    |                                                                                                         | orchestration_session_state primary key                                   |
| session_id                     | VARCHAR     |                   | false    | [orchestration_session](/docs/standard-library/rssd-schema/orchestration_session)             | orchestration_session row this state describes                            |
| session_entry_id               | VARCHAR     |                   | true     | [orchestration_session_entry](/docs/standard-library/rssd-schema/orchestration_session_entry) | orchestration_session_entry row this state describes (optional)           |
| from_state                     | TEXT        |                   | false    |                                                                                                         | the previous state (set to "INITIAL" when it's the first transition)      |
| to_state                       | TEXT        |                   | false    |                                                                                                         | the current state; if no rows exist it means no state transition occurred |
| transition_result              | TEXT        |                   | true     |                                                                                                         | if the result of state change is necessary for future use                 |
| transition_reason              | TEXT        |                   | true     |                                                                                                         | short text or code explaining why the transition occurred                 |
| transitioned_at                | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     |                                                                                                         | when the transition occurred                                              |
| elaboration                    | TEXT        |                   | true     |                                                                                                         | any elaboration needed for the state transition                           |

## Constraints

| Name                                           | Type        | Definition                                                                                                                                                |
| ---------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| orchestration_session_state_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_session_state_id)                                                                                                              |
| - (Foreign key ID: 0)                          | FOREIGN KEY | FOREIGN KEY (session_entry_id) REFERENCES orchestration_session_entry (orchestration_session_entry_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 1)                          | FOREIGN KEY | FOREIGN KEY (session_id) REFERENCES orchestration_session (orchestration_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                   |
| sqlite_autoindex_orchestration_session_state_2 | UNIQUE      | UNIQUE (orchestration_session_state_id, from_state, to_state)                                                                                             |
| sqlite_autoindex_orchestration_session_state_1 | PRIMARY KEY | PRIMARY KEY (orchestration_session_state_id)                                                                                                              |
| -                                              | CHECK       | CHECK(json_valid(transition_result) OR transition_result IS NULL)                                                                                         |
| -                                              | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                     |

## Indexes

| Name                                           | Definition                                                    |
| ---------------------------------------------- | ------------------------------------------------------------- |
| sqlite_autoindex_orchestration_session_state_2 | UNIQUE (orchestration_session_state_id, from_state, to_state) |
| sqlite_autoindex_orchestration_session_state_1 | PRIMARY KEY (orchestration_session_state_id)                  |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/orchestration_session_state.svg)
