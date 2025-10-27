---
FII: "TC-SRV-0030"
groupId: "GRP-0001"  
title: "Validate Exit Code on Network Failure"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI returns the correct exit code when a network connection failure occurs.

### Test Steps

1. Disconnect the system from the network.  
2. Execute `surveilr sync --remote`.  
3. Observe CLI output and exit code.  

### Expected Result

- Exit code = 5  
- Output displays `Network unavailable` or `Connection failed`.