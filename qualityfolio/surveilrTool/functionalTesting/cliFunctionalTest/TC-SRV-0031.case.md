---
FII: "TC-SRV-0031"  
groupId: "GRP-0001"  
title: "Validate Exit Code on Authentication Failure"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI returns a defined non-zero exit code when authentication fails.

### Test Steps

1. Run `surveilr login --user invalid --pass wrong`.  
2. Observe error message and exit code.  

### Expected Result

- Exit code = 6  
- Output displays `Authentication failed`.
