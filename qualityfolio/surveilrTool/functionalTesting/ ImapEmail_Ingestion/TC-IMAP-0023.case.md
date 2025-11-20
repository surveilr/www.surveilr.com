---
FII: "TC-IMAP-0023"
groupId: "GRP-0004"
title: "Draft email ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "drafts"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate ingestion does not include draft emails.

### Preconditions
- Prepare a draft email in Gmail → Drafts.

### Test Steps
1. Run ingestion pointing to all default folders.
2. Inspect ingested messages.

### Expected Result
- Draft messages are not ingested.

