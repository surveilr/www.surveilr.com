---
FII: "TC-IMAP-0029"
groupId: "GRP-0004"
title: "OS kills entire VS Code session while IMAP watch is active"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr handles OS-level termination of VS Code safely.

### Preconditions
- IMAP watch running in VS Code.

### Test Steps
1. Start IMAP watch.
2. Kill VS Code using Task Manager/System Monitor.

### Expected Result
- Surveilr process ends cleanly.
- No partial or corrupt ingestion occurs.
