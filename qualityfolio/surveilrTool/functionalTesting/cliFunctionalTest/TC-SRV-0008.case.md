---
FII: "TC-SRV-0008"
groupId: "GRP-0001"
title: "Validate mandatory flags for scan command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Ensure the `scan` command runs successfully with all required flags.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --target server1 --mode quick`.  
3. Observe the CLI output.  
4. Close the terminal.

### Expected Result

- CLI accepts flags and executes scan successfully, displaying results.
