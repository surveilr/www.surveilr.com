---
FII: "TC-SRV-0024"  
groupId: "GRP-0001"  
title: "Validate Exit Code for Successful Command Execution"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "happy path"  
---

### Description

- Validate that the Surveilr CLI returns exit code `0` for successful command execution without any errors.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr status`.  
3. Capture the exit code after execution.  
4. Close the terminal.

### Expected Result

- Exit code = 0  
- Output displays `System operational` or equivalent success message.
