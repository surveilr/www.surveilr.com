---
FII: "TC-SRV-0006"
groupId: "GRP-0001"
title: "Check - CLI Unknown Command Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "negative path"
---

### Description

- Validate that the CLI handles unknown commands gracefully by displaying a descriptive error message.

### Test Steps

1. Open a terminal or command prompt.  
2. Run an invalid command, e.g., `surveilr unknowncommand`.  
3. Review the console output for the error message.  
4. Close the terminal.

### Expected Result

- The CLI displays a descriptive error (e.g., `Unknown command`) and usage instructions.  
