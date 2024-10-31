---
title: Code Notebooks
description: Explains the concept of code notebooks
---

**Resource Surveillance Code Notebooks (RSCNs)** are a way to store and manage
executable code, allowing SQL or other "polyglot" code (e.g., Python, R, AI
prompt code) to be kept, tracked, and executed within a **Resource Surveillance
State Database (RSSD)**. The structure enables detailed control over code
execution and maintains a record of execution history and state transitions.

In this system:

1. Each notebook is split into individual **cells**.
2. Each cell contains a single block of code or function and is treated as an
   independently executable unit.
3. Notebooks can be associated with a **kernel**, which is a specific
   computational engine responsible for executing the code.

The RSCN structure allows:

- Storing code in modular, traceable units (cells).
- Associating each cell with a specific kernel for execution.
- Tracking execution states and results for stateful operations, which is
  particularly useful for tasks like SQL migrations.
- Managing versioning and execution control for each cell independently, making
  the system flexible, auditable, and suitable for complex workflows in a
  controlled environment.

This database design enables precise control over notebook-based code execution,
particularly in environments where code execution history and state consistency
are crucial.

### Key Database Tables

There are three primary tables involved: `code_notebook_kernel`,
`code_notebook_cell`, and `code_notebook_state`.

#### 1. `code_notebook_kernel` Table: Kernel Information

The **`code_notebook_kernel` table** stores metadata about each **kernel** or
**execution engine** used for running notebook code. Each record represents a
unique kernel, including details like its name, description, MIME type, and
associated file extension. This table allows for different types of kernels,
depending on the language or environment needed to execute the notebook's code.

- **Kernel**: An engine that executes code in a particular language or
  environment.
- **Fields**:
  - `kernel_name`: The unique name of the kernel (e.g., "SQLite", "Python").
  - `mime_type` and `file_extn`: Describe the type of code the kernel handles
    (e.g., `application/sql` for SQL).
  - **JSON fields** (`elaboration`, `governance`): Optional metadata about
    kernel configurations or governance policies.
  - **Timestamps**: Creation and update timestamps for versioning and auditing.

This table helps enforce that each kernel is uniquely defined by its
`kernel_name` and ensures each notebook cell has a compatible execution engine.

#### 2. `code_notebook_cell` Table: Individual Notebook Cells

The **`code_notebook_cell` table** contains the actual code for each notebook,
stored one code block per row. Each cell represents a unit of interpretable code
tied to a specific notebook and kernel. This table’s schema supports versioning
and tracking of individual cells.

- **Cell Structure**:
  - `notebook_name`: The name of the notebook the cell belongs to.
  - `cell_name`: A unique identifier for the cell within its notebook.
  - `interpretable_code`: The actual code or function that will be executed.
  - `interpretable_code_hash`: A hash of the code, allowing detection of code
    modifications.
  - `notebook_kernel_id`: A foreign key linking to `code_notebook_kernel`,
    specifying the kernel that executes this cell’s code.

- **Uniqueness Constraint**:
  - Cells are uniquely identified by a combination of `notebook_name`,
    `cell_name`, and `interpretable_code_hash`, meaning cells with the same
    `notebook_name` and `cell_name` can exist in multiple versions if their code
    (`interpretable_code`) changes.

- **JSON Metadata Fields**:
  - `arguments`: JSON object to define input arguments or parameters for code
    execution.
  - `cell_governance`: JSON field for policy data (e.g., who can modify or
    execute the cell).

This table organizes and manages each code unit, enabling efficient version
control and traceability of modifications.

#### 3. `code_notebook_state` Table: Tracking Execution States

The **`code_notebook_state` table** records the execution state and transitions
for each cell, enabling detailed tracking of whether a cell has been executed
and what the outcomes were. This is especially useful for **stateful kernels**
where execution results impact future operations.

- **State Tracking**:
  - `from_state` and `to_state`: Indicate the cell's state transition (e.g.,
    from `PENDING` to `EXECUTED`).
  - **Transition Reasons and Results**:
    - `transition_reason`: Explanation for why the state changed (e.g.,
      triggered by user, scheduled task).
    - `transition_result`: JSON-encoded result or outcome of the code execution
      (e.g., output data, success/failure message).

- **Stateful vs Stateless Execution**:
  - Some cells are **stateful** (e.g., a cell that creates a table) and should
    only be executed once, as re-running could have unwanted effects.
  - Others are **stateless** (e.g., cells that compute values without side
    effects) and can be run multiple times without changing the system state.

The state-tracking mechanism here helps ensure that cells are executed in a
controlled, traceable way, preventing unintended re-executions and supporting
auditability.

### Example of How These Tables Work Together

1. **Kernel Definition**:
   - Suppose there’s a kernel with `kernel_name = 'SQL'`, which is
     responsible for executing SQL code. This entry exists in
     `code_notebook_kernel`.

2. **Notebook and Cell Definition**:
   - A SQL notebook named `"ConstructionSqlNotebook"` is created, and it’s split
     into individual cells, each containing a SQL statement for data processing,
     schema modification, etc.
   - Each cell is linked to the `SQLite` kernel by the `notebook_kernel_id`.

3. **Cell Execution and State Tracking**:
   - Each cell’s execution is tracked in `code_notebook_state`, where it
     transitions from an initial state (like `PENDING`) to a final state (like
     `EXECUTED`) once the code runs successfully.
   - If the notebook is used to manage SQL schema migrations, a cell in
     `"ConstructionSqlNotebook"` might be marked as `EXECUTED` once it has
     created a table, preventing redundant re-executions.

### Special Case: Migratable SQL

For specific SQL notebooks, such as `"ConstructionSqlNotebook"`, certain cells
are candidates for migration. Cells that have not yet been executed (i.e.,
without an `EXECUTED` state in `code_notebook_state`) are considered
**unmigrated** and represent SQL code that hasn’t yet been applied to the
database.

This setup allows the system to track which parts of a SQL migration notebook
have been applied and which are still pending, ensuring orderly migration
processes without redundant operations.

## Code Notebooks Models and Schema

The `code_notebook_kernel` table defines each **kernel** or **execution engine**
responsible for running code in the notebook cells. Each record represents a
unique kernel, specifying the programming language or environment it supports.

| Column                    | Type            | Description                                                                    |
| ------------------------- | --------------- | ------------------------------------------------------------------------------ |
| `code_notebook_kernel_id` | VARCHAR         | Primary key, uniquely identifies each kernel.                                  |
| `kernel_name`             | TEXT            | Unique name of the kernel (e.g., `SQLite`, `Python`).                          |
| `description`             | TEXT            | Description of the kernel.                                                     |
| `mime_type`               | TEXT            | MIME type associated with the code language (e.g., `application/sql` for SQL). |
| `file_extn`               | TEXT            | File extension associated with the kernel (e.g., `.sql`).                      |
| `elaboration`             | JSON (nullable) | Optional metadata about kernel configurations.                                 |
| `governance`              | JSON (nullable) | Optional governance policies related to the kernel.                            |
| `created_at`              | TIMESTAMPTZ     | Timestamp when the kernel was created.                                         |
| `created_by`              | TEXT            | User who created the kernel.                                                   |
| `updated_at`              | TIMESTAMPTZ     | Timestamp of the last update.                                                  |
| `updated_by`              | TEXT            | User who last updated the kernel.                                              |
| `deleted_at`              | TIMESTAMPTZ     | Timestamp if the kernel is deleted (soft delete).                              |
| `deleted_by`              | TEXT            | User who deleted the kernel.                                                   |
| `activity_log`            | TEXT            | Log of kernel activities for auditing purposes.                                |

The `code_notebook_cell` table stores the actual code for each notebook, with
one row per code block or cell. Each cell is associated with a specific notebook
and a kernel.

| Column                    | Type            | Description                                                                             |
| ------------------------- | --------------- | --------------------------------------------------------------------------------------- |
| `code_notebook_cell_id`   | VARCHAR         | Primary key, uniquely identifies each cell.                                             |
| `notebook_kernel_id`      | VARCHAR         | Foreign key linking to `code_notebook_kernel`, specifies the kernel used for execution. |
| `notebook_name`           | TEXT            | Name of the notebook this cell belongs to.                                              |
| `cell_name`               | TEXT            | Unique name of the cell within the notebook.                                            |
| `interpretable_code`      | TEXT            | The actual code to be executed.                                                         |
| `interpretable_code_hash` | TEXT            | Hash of the code, used for detecting code modifications.                                |
| `description`             | TEXT            | Description of the cell's purpose.                                                      |
| `arguments`               | JSON (nullable) | JSON object containing input arguments for code execution.                              |
| `cell_governance`         | JSON (nullable) | Governance policies related to the cell.                                                |
| `created_at`              | TIMESTAMPTZ     | Timestamp when the cell was created.                                                    |
| `created_by`              | TEXT            | User who created the cell.                                                              |
| `updated_at`              | TIMESTAMPTZ     | Timestamp of the last update.                                                           |
| `updated_by`              | TEXT            | User who last updated the cell.                                                         |
| `deleted_at`              | TIMESTAMPTZ     | Timestamp if the cell is deleted (soft delete).                                         |
| `deleted_by`              | TEXT            | User who deleted the cell.                                                              |
| `activity_log`            | TEXT            | Log of cell activities for auditing purposes.                                           |

**Uniqueness Constraint**: Cells are uniquely identified by a combination of
`notebook_name`, `cell_name`, and `interpretable_code_hash`. This enables
multiple versions of a cell with the same name in the same notebook as long as
the code differs.

The `code_notebook_state` table records the state transitions for each cell,
allowing for tracking of code execution history, particularly for **stateful
kernels**.

| Column                   | Type            | Description                                                                                    |
| ------------------------ | --------------- | ---------------------------------------------------------------------------------------------- |
| `code_notebook_state_id` | VARCHAR         | Primary key, uniquely identifies each state record.                                            |
| `code_notebook_cell_id`  | VARCHAR         | Foreign key linking to `code_notebook_cell`, identifies the cell whose state is being tracked. |
| `from_state`             | TEXT            | State before the transition (e.g., `PENDING`).                                                 |
| `to_state`               | TEXT            | State after the transition (e.g., `EXECUTED`).                                                 |
| `transition_reason`      | TEXT            | Reason for the state change (e.g., triggered by user action).                                  |
| `transition_result`      | JSON (nullable) | Result of the transition (e.g., success, error messages).                                      |
| `transitioned_at`        | TIMESTAMPTZ     | Timestamp of the state transition.                                                             |
| `elaboration`            | JSON (nullable) | Additional metadata related to the state transition.                                           |
| `created_at`             | TIMESTAMPTZ     | Timestamp when the record was created.                                                         |
| `created_by`             | TEXT            | User who created the record.                                                                   |
| `updated_at`             | TIMESTAMPTZ     | Timestamp of the last update.                                                                  |
| `updated_by`             | TEXT            | User who last updated the record.                                                              |
| `deleted_at`             | TIMESTAMPTZ     | Timestamp if the record is deleted (soft delete).                                              |
| `deleted_by`             | TEXT            | User who deleted the record.                                                                   |
| `activity_log`           | TEXT            | Log of state activities for auditing purposes.                                                 |

### Stateful vs Stateless Execution

- **Stateful Cells**: Cells that perform persistent operations (e.g., creating
  tables) should only be executed once.
- **Stateless Cells**: Cells that perform non-persistent computations can be
  executed multiple times without side effects.

## Notebook Cells for Script Storage & Execution Tracking

The `code_notebook_cell` table serves as a comprehensive repository to store and
manage SQL scripts of all kinds, including but not limited to:

- `SQL DDL`: For database structure modifications such as `CREATE`, `ALTER`, and
  `DROP`.
- `SQL DQL`: Scripts related to data querying like `SELECT` operations.
- `SQL DML`: Scripts for data manipulation including `INSERT`, `UPDATE`, and
  `DELETE`.
- ... and other SQL operations.

While it's versatile enough to manage various SQL tasks, `code_notebook_cell`
table's primary advantage lies in storing SQL DDL scripts needed for migrations

**Columns**:

- `code_notebook_cell_id`: A unique identifier for each SQL script.
- `notebook_name`: Broad categorization or project name. Especially useful for
  grouping related migration scripts.
- `cell_name`: A descriptive name for the SQL operation or step.
- `cell_governance`: Optional JSON field for any governance or
  compliance-related data.
- `kernel`: The SQL dialect or interpreter the script targets, such as
  PostgreSQL, MySQL, etc. (might also support shebang-style for non SQL)
- `interpretable_code`: The SQL script itself (or any other runtime).
- `description`: A brief description or context regarding the purpose of the
  script.
- `activity_log`: optional JSON which stores the history of the changes to thie
  notebook cell

### Migration Scripts & Database Evolution

One of the best uses for `code_notebook_cell` is to manage SQL DDL scripts
crucial for database migrations. As databases evolve, tracking structural
changes becomes vital. By cataloging these DDL scripts, one can maintain a clear
version history, ensuring that database evolution is orderly, reversible, and
auditable.

To maintain a clear audit trail of script execution, the `code_notebook_state`
table logs each execution's status. And, migration scripts can use the state to
know whether something has already been executed.

**Inserting a New Execution State**:

To log the execution of a script, you can add an entry like so:

```sql
INSERT INTO code_notebook_state 
(code_notebook_state_id, code_notebook_cell_id, from_state, to_state, created_at, created_by)
VALUES
(
    'generated_or_provided_state_id',
    (SELECT code_notebook_cell_id 
     FROM code_notebook_cell 
     WHERE notebook_name = 'specific_project_name' 
     AND cell_name = 'specific_script_name'),
    'INITIAL',
    'EXECUTED',
    CURRENT_TIMESTAMP,
    'executor_name_or_system'
);
```

**State Transitions**:

With `from_state` and `to_state`, you can track a script's lifecycle, from its
`INITIAL` state to any subsequent states like 'EXECUTED', 'ROLLED_BACK', etc.
This provides a traceable path of script interactions.

### CLI Use

One way to keep your code and the database in sync is to just use the database
to get its SQL (instead of putting it into an app) and execute the SQL directly
in the database.

```bash
$ sqlite3 xyz.db "select sql from code_notebook_cell where code_notebook_cell_id = 'infoSchemaMarkdown'" | sqlite3 xyz.db
```

You can pass in arguments using `.parameter` or `sql_parameters` table, like:

```bash
$ echo ".parameter set X Y; $(sqlite3 xyz.db \"SELECT sql FROM code_notebook_cell where code_notebook_cell_id = 'init'\")" | sqlite3 xyz.db
```