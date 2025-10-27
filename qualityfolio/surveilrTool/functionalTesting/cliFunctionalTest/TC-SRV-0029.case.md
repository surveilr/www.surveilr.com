---
FII: "TC-SRV-0029"
groupId: "GRP-0001"  
title: "Validate Exit Code on User Interrupt (Ctrl+C)"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "Low"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that CLI exits gracefully when the process is interrupted by the user (Ctrl+C).

### Test Steps

1. Run `surveilr analyze`.  
2. Press Ctrl+C during execution.  
3. Capture the exit code.  

### Expected Result

- Exit code = 130  
- Output displays `Process interrupted by user`.