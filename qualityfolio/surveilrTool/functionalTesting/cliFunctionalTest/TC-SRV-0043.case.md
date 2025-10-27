---
FII: "TC-SRV-0043"
groupId: "GRP-0001"
title: "Validate Surveilr Admin Info Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["admin", "info", "system-status"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "happy path" 
---

### Description

- Verify that `surveilr admin info` provides current Surveilr system details and configurations.

### Precondition

- Surveilr CLI is properly configured and operational.

### Test Steps

1. Execute `surveilr admin info`.
2. Verify that system information and DB stats are displayed.

### Expected Result

- Output includes DB path, record count, and version.
- Exit code = 0.

