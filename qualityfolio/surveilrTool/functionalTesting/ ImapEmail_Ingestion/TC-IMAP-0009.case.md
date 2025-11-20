---
FII: "TC-IMAP-0009"
groupId: "GRP-0004"
title: "Multi-part email ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "mime"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of multi-part MIME email (HTML + text + attachments).

### Preconditions
- A multi-part MIME email exists.

### Test Steps
1. Ensure MIME email is present.
2. Run IMAP ingestion.
3. Inspect parsing of each MIME component.

### Expected Result
- All MIME body parts are processed correctly.