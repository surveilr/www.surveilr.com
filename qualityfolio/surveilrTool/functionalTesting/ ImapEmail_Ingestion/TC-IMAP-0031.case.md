---
FII: "TC-IMAP-0031"
groupId: "GRP-0004"
title: "Duplicate watch sessions created after VS Code reopens"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate duplicate IMAP watch sessions are prevented after VS Code restart.

### Preconditions
- Active watch session before closing VS Code.

### Test Steps
1. Start IMAP watch.
2. Close VS Code.
3. Reopen VS Code and start watch again.

### Expected Result
- Surveilr prevents duplicate watch sessions or warns user.
