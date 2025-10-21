---
FII: "TC-SRV-0033"  
groupId: "GRP-0001"  
title: "Validate Exit Code Propagation in Shell Scripts"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "Medium"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that shell scripts correctly capture and propagate CLI exit codes during automation.

### Test Steps

1. Create a shell script that calls a failing Surveilr command.  
2. Execute the script and capture the exit code.  

### Expected Result

- Script receives the same exit code returned by CLI.  
- Failure logged appropriately.
