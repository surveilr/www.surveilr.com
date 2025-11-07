---
FII: "TC-SRV-0020"
groupId: "GRP-0001"
title: "Verify - surveilr udi --help displays UDI subcommands"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["udi", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr udi --help` command displays available UDI subcommands and their usage.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr udi --help`.  
3. Observe the output content.  
4. Verify that it lists available subcommands and usage options for Universal Data Infrastructure.

### Expected Result

- The CLI displays help information including all supported UDI commands and their descriptions.