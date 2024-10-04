---
title: orchestration_session_exec
---

## Description

Records the state of an orchestration session command or other execution.

<details>
<summary><strong>Table Definition</strong></summary>

```sql
CREATE TABLE "orchestration_session_exec" (
    "orchestration_session_exec_id" VARCHAR PRIMARY KEY NOT NULL,
    "exec_nature" TEXT NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "parent_exec_id" VARCHAR,
    "namespace" TEXT,
    "exec_identity" TEXT,
    "exec_code" TEXT NOT NULL,
    "exec_status" INTEGER NOT NULL,
    "input_text" TEXT,
    "exec_error_text" TEXT,
    "output_text" TEXT,
    "output_nature" TEXT CHECK(json_valid(output_nature) OR output_nature IS NULL),
    "narrative_md" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_exec"("orchestration_session_exec_id")
)
```

</details>

## Columns

| Name                          | Type    | Default | Nullable | Children                                                                                              | Parents                                                                                                 | Comment                                                              |
| ----------------------------- | ------- | ------- | -------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| orchestration_session_exec_id | VARCHAR |         | false    | [orchestration_session_exec](/docs/standard-library/rssd-schema/orchestration_session_exec) |                                                                                                         | orchestration_session_exec primary key                               |
| exec_nature                   | TEXT    |         | false    |                                                                                                       |                                                                                                         | the nature of orchestration_session_exec row (e.g. shell, SQL, etc.) |
| session_id                    | VARCHAR |         | false    |                                                                                                       | [orchestration_session](/docs/standard-library/rssd-schema/orchestration_session)             | orchestration_session row this state describes                       |
| session_entry_id              | VARCHAR |         | true     |                                                                                                       | [orchestration_session_entry](/docs/standard-library/rssd-schema/orchestration_session_entry) | orchestration_session_entry row this state describes (optional)      |
| parent_exec_id                | VARCHAR |         | true     |                                                                                                       | [orchestration_session_exec](/docs/standard-library/rssd-schema/orchestration_session_exec)   | if this row is a child of a parent execution                         |
| namespace                     | TEXT    |         | true     |                                                                                                       |                                                                                                         | an arbitrary grouping strategy                                       |
| exec_identity                 | TEXT    |         | true     |                                                                                                       |                                                                                                         | an arbitrary identity of this execution                              |
| exec_code                     | TEXT    |         | false    |                                                                                                       |                                                                                                         | the shell command, SQL or other code executed                        |
| exec_status                   | INTEGER |         | false    |                                                                                                       |                                                                                                         | numerical description of result                                      |
| input_text                    | TEXT    |         | true     |                                                                                                       |                                                                                                         | if STDIN or other technique to send in content was used              |
| exec_error_text               | TEXT    |         | true     |                                                                                                       |                                                                                                         | text representation of error from exec                               |
| output_text                   | TEXT    |         | true     |                                                                                                       |                                                                                                         | STDOUT or other result in text format                                |
| output_nature                 | TEXT    |         | true     |                                                                                                       |                                                                                                         | hints about the nature of the output                                 |
| narrative_md                  | TEXT    |         | true     |                                                                                                       |                                                                                                         | a block of Markdown text with human-friendly narrative of execution  |
| elaboration                   | TEXT    |         | true     |                                                                                                       |                                                                                                         | any elaboration needed for the execution                             |

## Constraints

| Name                                          | Type        | Definition                                                                                                                                                |
| --------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| orchestration_session_exec_id                 | PRIMARY KEY | PRIMARY KEY (orchestration_session_exec_id)                                                                                                               |
| - (Foreign key ID: 0)                         | FOREIGN KEY | FOREIGN KEY (parent_exec_id) REFERENCES orchestration_session_exec (orchestration_session_exec_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE     |
| - (Foreign key ID: 1)                         | FOREIGN KEY | FOREIGN KEY (session_entry_id) REFERENCES orchestration_session_entry (orchestration_session_entry_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE |
| - (Foreign key ID: 2)                         | FOREIGN KEY | FOREIGN KEY (session_id) REFERENCES orchestration_session (orchestration_session_id) ON UPDATE NO ACTION ON DELETE NO ACTION MATCH NONE                   |
| sqlite_autoindex_orchestration_session_exec_1 | PRIMARY KEY | PRIMARY KEY (orchestration_session_exec_id)                                                                                                               |
| -                                             | CHECK       | CHECK(json_valid(output_nature) OR output_nature IS NULL)                                                                                                 |
| -                                             | CHECK       | CHECK(json_valid(elaboration) OR elaboration IS NULL)                                                                                                     |

## Indexes

| Name                                          | Definition                                  |
| --------------------------------------------- | ------------------------------------------- |
| sqlite_autoindex_orchestration_session_exec_1 | PRIMARY KEY (orchestration_session_exec_id) |

## Relations

![er](../../../../../assets/orchestration_session_exec.svg)
