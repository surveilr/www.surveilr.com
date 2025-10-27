---
FII: "TC-SRV-0044"
groupId: "GRP-0001"
title: "Validate Surveilr Admin Reset Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-27"
test_type: "Automation"
tags: ["admin", "reset", "cache"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path" 
---

### Description

- Validate that `surveilr admin reset` clears all cached data without affecting evidence files.

### Precondition

- Cached metadata present in `/var/surveilr/cache`.

### Test Steps

1. Execute `surveilr admin reset`.
2. Verify that cache folder is cleared.
3. Ensure evidence files remain intact.

### Expected Result

- Cache cleared successfully.
- Evidence data preserved.
- Exit code = 0.

