---
FII: "TC-SRV-0032"  
groupId: "GRP-0001"  
title: "Validate running SQL command using surveilr shell"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["shell"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that `surveilr shell` can execute a basic SQL command successfully.

### Test Steps
1. Open terminal.  
2. Run `surveilr shell "SELECT 1;"`.  
3. Observe the console result.

### Expected Result
- CLI returns a valid result table with the query output.