---
FII: "TC-IMAP-0014"
groupId: "GRP-0004"
title: "Status filter failure"
created_by: "arun-ramanan@netspectives.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "filters"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate behavior when status filter does not behave correctly.

### Preconditions
- Prepare mailbox with both read and unread emails.

### Test Steps
1. Run ingestion with varying status filters (read/unread).
2. Verify filter behavior against actual mailbox contents.

### Expected Result
- Filter selections are applied correctly.

