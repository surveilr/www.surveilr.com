---
FII: "TC-SRV-0010"
groupId: "GRP-0001"
title: "Flag order independence"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that CLI accepts flags in any order without failure.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --mode quick --target server1`.  
3. Observe the CLI output.  
4. Close the terminal.

### Expected Result

- CLI executes successfully regardless of the flag order.
