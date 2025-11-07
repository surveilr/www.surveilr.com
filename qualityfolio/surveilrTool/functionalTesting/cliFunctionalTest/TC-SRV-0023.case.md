---
FII: "TC-SRV-0023"
groupId: "GRP-0001"
title: "Verify - surveilr upgrade --help displays upgrade options"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["upgrade", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that `surveilr upgrade --help` correctly lists all available upgrade options and usage syntax.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr upgrade --help`.  
3. Observe the output.  
4. Verify that upgrade-related options and flags are displayed.

### Expected Result

- The CLI displays available upgrade options, including version selection and upgrade instructions.
