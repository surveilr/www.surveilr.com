---
FII: "TC-IMAP-0012"
groupId: "GRP-0004"
title: "Incorrect file count (n+1)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "count"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate ingestion count when expected number of emails differs.

### Preconditions
- Inbox contains exactly n test emails.

### Test Steps
1. Confirm there are n emails.
2. Run ingestion command.
3. Review ingestion summary/logs.

### Expected Result
- System ingests exactly n emails without producing invalid extra entries.