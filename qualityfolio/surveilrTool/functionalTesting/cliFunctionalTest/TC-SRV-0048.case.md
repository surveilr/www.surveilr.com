---
FII: "TC-SRV-0048"
groupId: "GRP-0001"
title: "Validate Shell Fails Gracefully When Database Missing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["shell", "missing-db", "error"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Verify that the shell displays a meaningful error when the default database file cannot be located.

### Precondition

- Delete or rename `resource-surveillance.sqlite.db`.

### Test Steps

1. Execute `surveilr shell`.
2. Observe CLI message.
3. Capture exit status.

### Expected Result

- CLI prints `Error: resource-surveillance.sqlite.db not found.`
- Shell session does not open.
- Exit code = 7.



