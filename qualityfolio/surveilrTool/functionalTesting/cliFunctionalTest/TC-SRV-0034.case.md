---
FII: "TC-SRV-0034"  
groupId: "GRP-0001"  
title: "Validate Exit Code for Internal Exception Handling"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI returns a controlled non-zero exit code for internal exceptions.

### Test Steps

1. Set invalid environment variables.  
2. Run any Surveilr CLI command.  
3. Capture the exit code and output.  

### Expected Result

- Exit code = 8  
- Output includes `Unhandled exception` or stack trace message.
