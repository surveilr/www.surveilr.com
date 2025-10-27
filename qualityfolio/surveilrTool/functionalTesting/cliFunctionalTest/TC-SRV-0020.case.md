---
FII: "TC-SRV-0020"
groupId: "GRP-0001"
title: "Verify logs capture errors for invalid command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Log Outputs"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Check that errors are logged when an invalid or non-existent CLI command is executed.

### Preconditions

- CLI installed.  
- Invalid command known (e.g., `surveilr invalidcmd`).

### Test Steps

1. Open terminal.  
2. Run an invalid CLI command.  
3. Observe log generation.  
4. Verify that error details are captured with timestamp and level.  
5. Close terminal.

### Expected Result

- Error is logged with descriptive message and proper format.
