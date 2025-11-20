---
FII: "TC-IMAP-0027"
groupId: "GRP-0004"
title: "VS Code closed normally during IMAP watch"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate that when VS Code is closed normally, the IMAP watch terminates cleanly without leaving background processes.

### Preconditions
- IMAP watch running in VS Code terminal.

### Test Steps
1. Start IMAP watch.
2. Close VS Code normally without stopping the terminal.

### Expected Result
- Watch process terminates cleanly.
- No background or orphaned Surveilr processes remain.
