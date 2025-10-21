---
FII: "TC-SRV-0026"
groupId: "GRP-0001"  
title: "Validate Exit Code for Missing Required Arguments"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI returns a non-zero exit code when required arguments are missing.

### Test Steps

1. Run `surveilr scan` without parameters.  
2. Observe the exit code and CLI message.  

### Expected Result

- Exit code = 2  
- Output displays usage help or argument error message.