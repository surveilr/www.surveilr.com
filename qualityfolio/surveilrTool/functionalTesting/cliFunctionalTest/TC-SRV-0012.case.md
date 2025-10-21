---
FII: "TC-SRV-0012"
groupId: "GRP-0001"
title: "Invalid flag name"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Check CLI response to unsupported or invalid flags.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --target server1 --speed fast`.  
3. Observe the CLI output for errors.  
4. Close the terminal.

### Expected Result

- CLI returns error: "Unsupported flag: --speed".
