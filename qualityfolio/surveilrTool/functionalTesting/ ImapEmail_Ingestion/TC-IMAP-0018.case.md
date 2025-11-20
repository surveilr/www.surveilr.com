---
FII: "TC-IMAP-0018"
groupId: "GRP-0004"
title: "Duplicate ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "duplicates"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate that repeated runs do not re-ingest the same emails.

### Preconditions
- A fixed set of test emails exists.

### Test Steps
1. Run ingestion.
2. Run again without modifying mailbox.
3. Compare ingestion results.

### Expected Result
- No duplicates are generated; system tracks previously ingested mails.

