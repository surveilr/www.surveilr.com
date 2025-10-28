---
FII: "TC-SRV-0002"
groupId: "GRP-0001"
title: "Check - CLI Help Command Output"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the Surveilr CLI displays a complete help menu listing all available flags, subcommands, and usage examples when executing the help command.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr --help`.  
3. Review the console output for all available subcommands, flags, and usage examples.  
4. Close the terminal.

### Expected Result

- The help menu is displayed in the console.  
- All supported subcommands and parameters are listed with usage examples.  
