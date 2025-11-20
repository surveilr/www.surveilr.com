---
FII: "TC-IMAP-0035"
groupId: "GRP-0004"
title: "Zombie process detection after VS Code close"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr detects and reports orphaned IMAP watch processes.

### Preconditions
- IMAP watch running before VS Code closes.

### Test Steps
1. Start IMAP watch.
2. Close VS Code abruptly.
3. Attempt to start new watch session.

### Expected Result
- Surveilr detects zombie/orphan processes.
- User receives alert before starting new session.
