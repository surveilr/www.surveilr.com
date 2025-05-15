## Overview

`surveilr_notebook_cell_exec` is a SQLite extension function that allows for the execution of stored SQL code from the `code_notebook_cell` table. It provides a mechanism to dynamically execute SQL stored in notebook cells, enabling powerful automation and scheduled tasks.

> **Introduced in version:** 1.8.0

## Description

This function retrieves SQL code stored in a specified notebook cell and executes it within the current SQLite connection context. It acts as a bridge between the notebook storage system and the SQL execution engine, allowing for dynamic and contextual execution of stored queries.

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `notebook_name` | `String` | The name of the notebook containing the cell to execute. This is a unique identifier within the Surveilr system that groups related cells together. |
| `cell_name` | `String` | The name of the specific cell within the notebook whose code should be executed. Each cell contains interpretable SQL code that can be run independently. |

## Return Value

| Type | Description |
|------|-------------|
| `bool` | Returns `true` if the execution succeeds without errors. Returns `false` if the execution fails. |


## Usage Examples

### Basic Usage

```sql
-- Execute a specific notebook cell
SELECT surveilr_notebook_cell_exec('system_maintenance', 'cleanup_old_logs');

-- Use within conditional logic
SELECT CASE 
    WHEN (SELECT count(*) FROM logs WHERE timestamp < date('now', '-30 days')) > 1000
    THEN surveilr_notebook_cell_exec('system_maintenance', 'cleanup_old_logs')
    ELSE 0
END;
```