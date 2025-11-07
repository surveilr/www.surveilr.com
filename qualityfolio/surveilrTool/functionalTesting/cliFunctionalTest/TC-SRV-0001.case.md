---
FII: "TC-SRV-0001"
groupId: "GRP-0001"
title: "Verify - surveilr admin --help displays admin help menu"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["admin", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr admin --help` command displays the correct help information related to admin and maintenance utilities.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr admin --help`.  
3. Observe the output displayed on the console.  
4. Verify the help section includes usage syntax, available subcommands, and admin-related descriptions.

### Expected Result

- The CLI displays the admin utility help section with proper command syntax, subcommand options, and descriptions without any errors.