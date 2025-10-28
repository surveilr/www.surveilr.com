---
FII: "TC-SRV-0014"
groupId: "GRP-0001"
title: "Conflicting flags"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description

- Provide flags that conflict with each other to check CLI error handling.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --mode quick --mode full --target server1`.  
3. Observe the CLI output for errors.  
4. Close the terminal.

### Expected Result

- CLI returns error: "Conflicting flags: --mode quick and --mode full".
