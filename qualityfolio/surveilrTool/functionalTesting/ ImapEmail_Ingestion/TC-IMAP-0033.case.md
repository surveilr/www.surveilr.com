---
FII: "TC-IMAP-0033"
groupId: "GRP-0004"
title: "Gmail rate-limit triggered during VS Code close"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch", "Gmail"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr behavior when Gmail rate-limits IMAP activity and VS Code is closed.

### Preconditions
- Gmail IMAP throttling is active.

### Test Steps
1. Trigger IMAP rate-limit (excessive fetch operations).
2. Close VS Code during throttled state.

### Expected Result
- Surveilr exits safely.
- No retry loops or stuck sessions.
