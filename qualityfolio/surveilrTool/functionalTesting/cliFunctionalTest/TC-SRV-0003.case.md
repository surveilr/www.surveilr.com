---
FII: "TC-SRV-0003"
groupId: "GRP-0001"
title: "Validate - invalid flag handling for surveilr admin"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["admin", "cli", "validation"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Verify that when an invalid or unsupported flag is passed to the `surveilr admin` command, the CLI provides a clear error message and does not crash.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr admin --invalid`.  
3. Observe the console output.

### Expected Result

- The CLI should display an error message such as “unexpected argument ‘--invalid’” and show help or usage guidance without crashing.