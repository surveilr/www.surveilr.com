---
FII: "TC-SRV-0011"
groupId: "GRP-0001"
title: "Missing mandatory flag"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Test behavior when a required flag is missing for the command.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --mode quick`.  
3. Observe the CLI output for errors.  
4. Close the terminal.

### Expected Result

- CLI returns error: "Missing required flag: --target".
