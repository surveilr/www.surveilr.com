---
FII: "TC-SRV-0008"
groupId: "GRP-0001"
title: "Verify - surveilr capturable-exec --help displays CE maintenance usage"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["capturable-exec", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr capturable-exec --help` command correctly displays usage information and available options for Capturable Executables (CE) maintenance utilities.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr capturable-exec --help`.  
3. Observe the console output.  
4. Verify that help content and command descriptions for CE tools are displayed.

### Expected Result

- The CLI should display help information detailing available subcommands and options related to Capturable Executables maintenance.