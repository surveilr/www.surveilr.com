---
FII: "TC-SRV-0004"
groupId: "GRP-0001"
title: "Check - CLI Logs Command"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr logs` command fetches CLI logs correctly.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr logs --last 10`.  
3. Review the console output for the last 10 log entries.  
4. Close the terminal.

### Expected Result

- The CLI displays the last 10 log entries including timestamps and command statuses.  
