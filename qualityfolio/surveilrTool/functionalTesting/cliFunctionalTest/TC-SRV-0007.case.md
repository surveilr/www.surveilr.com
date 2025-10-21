---
FII: "TC-SRV-0007"
groupId: "GRP-0001"
title: "Check - CLI Environment Flag Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that CLI commands respect environment flags and return data corresponding to the specified environment.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr status --env qa`.  
3. Review the console output for the specified environment info.  
4. Close the terminal.

### Expected Result

- The CLI outputs information specific to the environment provided in the flag.