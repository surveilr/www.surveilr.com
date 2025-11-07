---
FII: "TC-SRV-0033"  
groupId: "GRP-0001"  
title: "Validate surveilr shell error when sqlite3 is missing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["shell"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify that CLI shows an appropriate error if `sqlite3` dependency is missing.

### Test Steps
1. Remove or rename the `sqlite3` binary.  
2. Run `surveilr shell "SELECT 1;"`.  
3. Observe the error output.

### Expected Result
- CLI displays `Error: sqlite3 not found` and exits gracefully.