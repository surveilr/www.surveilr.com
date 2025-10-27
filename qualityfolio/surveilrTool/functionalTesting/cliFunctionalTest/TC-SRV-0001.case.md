---
FII: "TC-SRV-0001"
groupId: "GRP-0001"
title: "Check - CLI Version Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the Surveilr CLI outputs the correct version when executing the version command.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr --version`.  
3. Review the console output for the current CLI version.  
4. Close the terminal.

### Expected Result

- The CLI outputs the correct version string (e.g., `v1.2.3`).  
