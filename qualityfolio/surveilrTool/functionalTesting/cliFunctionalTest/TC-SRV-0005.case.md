---
FII: "TC-SRV-0005"
groupId: "GRP-0001"
title: "Check - CLI Dry-Run Option"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Command-Line Interface"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that CLI commands with the `--dry-run` flag simulate execution without making actual changes.

### Test Steps

1. Open a terminal or command prompt.  
2. Run a command with the dry-run option, e.g., `surveilr status --dry-run`.  
3. Review the console output to see simulated results.  
4. Close the terminal.

### Expected Result

- The CLI shows what would happen without changing any system state.  
