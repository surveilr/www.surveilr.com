---
FII: "TC-IMAP-0034"
groupId: "GRP-0004"
title: "Long-running watch interrupted by VS Code restart"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate system behavior when a long-running watch session is interrupted.

### Preconditions
- Watch must run for extended time.

### Test Steps
1. Start long-running IMAP watch.
2. Restart VS Code.

### Expected Result
- No orphaned Surveilr processes remain.
- Watch can start cleanly again.
