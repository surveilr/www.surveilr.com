---
FII: "TC-SRV-0045"
groupId: "GRP-0001"
title: "Validate Error Message for Invalid Database in Surveilr CLI"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["error-handling", "invalid-db", "admin"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path" 
---

### Description

- Validate that Surveilr throws an appropriate error when an invalid or corrupted database file is provided to any command.

### Precondition

- Invalid or empty `.db` file exists at `/data/rssd/invalid.db`.

### Test Steps

1. Execute `surveilr admin info --db /data/rssd/invalid.db`.
2. Observe error message and exit code.

### Expected Result

- CLI displays `Error: Invalid database file`.
- Exit code = 8.

