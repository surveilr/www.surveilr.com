---
FII: "TC-SRV-0025"  
groupId: "GRP-0001"  
title: "Validate Exit Code for Invalid Command Execution"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "Medium"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that the Surveilr CLI returns a non-zero exit code when an invalid command is executed.

### Test Steps

1. Open a terminal.  
2. Execute `surveilr invalid-command`.  
3. Capture the exit code and check the output.  

### Expected Result

- Exit code = 1  
- Output displays `Command not found` or `Invalid command`.
