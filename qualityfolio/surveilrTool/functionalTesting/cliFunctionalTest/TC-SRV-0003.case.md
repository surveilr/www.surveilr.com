---
FII: "TC-SRV-0003"
groupId: "GRP-0001"
title: "Check - CLI Status Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr status` command displays the current environment and system status correctly.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr status`.  
3. Review the console output for environment info, running services, and health status.  
4. Close the terminal.

### Expected Result

- The CLI outputs accurate environment information and system health status.  
