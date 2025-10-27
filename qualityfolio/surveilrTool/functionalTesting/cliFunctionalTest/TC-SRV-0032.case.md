---
FII: "TC-SRV-0032"  
groupId: "GRP-0001"  
title: "Validate Exit Code on Missing Configuration File"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "Medium"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI exits with a non-zero code when the configuration file is missing.

### Test Steps

1. Rename or delete CLI configuration file.  
2. Execute `surveilr run`.  
3. Observe error message and exit code.  

### Expected Result

- Exit code = 7  
- Output displays `Configuration file not found`.
