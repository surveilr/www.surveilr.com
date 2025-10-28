---
FII: "TC-SRV-0009"
groupId: "GRP-0001"
title: "Optional flag execution"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Check behavior when optional flags are provided for commands.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --target server1 --mode quick --verbose`.  
3. Observe the CLI output.  
4. Close the terminal.

### Expected Result

- CLI executes scan with verbose output enabled.
