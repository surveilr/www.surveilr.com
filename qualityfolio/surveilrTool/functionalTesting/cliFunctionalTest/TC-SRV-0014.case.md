---
FII: "TC-SRV-0014"
groupId: "GRP-0001"
title: "Verify - surveilr notebooks --help displays maintenance subcommands"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["notebooks", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that `surveilr notebooks --help` displays the correct help content for notebook maintenance utilities.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr notebooks --help`.  
3. Review the displayed content.  
4. Confirm that maintenance subcommands and usage syntax are visible.

### Expected Result

- The CLI lists all notebook-related maintenance commands, including descriptions and usage examples.