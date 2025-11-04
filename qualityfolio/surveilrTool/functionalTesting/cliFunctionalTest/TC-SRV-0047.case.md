---
FII: "TC-SRV-0047"
groupId: "GRP-0001"
title: "Validate Notebook Execution Failure on Invalid SQL Query"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["notebooks", "sql-error", "invalid-query"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Check that Surveilr notebook execution properly handles syntax errors in SQL queries.

### Precondition

- Notebook engine is initialized.
- Test notebook created but not executed.

### Test Steps

1. Add invalid SQL query: `SELEC FROM uniform_resource;`.
2. Run notebook using `surveilr notebooks run "Invalid Notebook"`.
3. Observe output.

### Expected Result

- Error message: `SQL syntax error near 'SELEC'`.
- Notebook execution halted.
- Exit code = 2.


