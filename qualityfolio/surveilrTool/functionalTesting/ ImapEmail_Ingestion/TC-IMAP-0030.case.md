---
FII: "TC-IMAP-0030"
groupId: "GRP-0004"
title: "Terminal killed manually inside VS Code"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate IMAP watch shutdown behavior when the integrated terminal is manually killed.

### Preconditions
- IMAP watch is active.

### Test Steps
1. Start IMAP watch.
2. Kill the VS Code terminal instance.

### Expected Result
- Surveilr logs clean exit of watch session.
- No orphaned processes remain.
