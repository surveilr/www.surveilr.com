---
FII: "TC-SRV-0016"
groupId: "GRP-0001"
title: "Validate - missing subcommand for notebooks command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["notebooks", "cli", "error-handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Ensure the CLI shows a usage or error message when the `notebooks` command is executed without a required subcommand.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute the command `surveilr notebooks`.  
3. Observe the CLI output.

### Expected Result

- The CLI should show an error message indicating a missing subcommand or display usage help for the `notebooks` command.