---
FII: "TC-IMAP-0015"
groupId: "GRP-0004"
title: "Invalid password"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "auth"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate authentication failure handling with invalid credentials.

### Preconditions
- Use mailbox but provide incorrect password.

### Test Steps
1. Provide wrong IMAP password.
2. Run ingestion.
3. Observe connection failure behavior.

### Expected Result
- Authentication fails gracefully with clear error message.