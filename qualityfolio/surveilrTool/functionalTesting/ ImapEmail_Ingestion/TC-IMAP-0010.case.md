---
FII: "TC-IMAP-0010"
groupId: "GRP-0004"
title: "Large attachment ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "attachments", "large-file"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of emails containing large attachments.

### Preconditions
- Email with large attachment is available.

### Test Steps
1. Ensure large-attachment email exists.
2. Run ingestion with attachment extraction enabled.
3. Verify storage output.

### Expected Result
- Large attachment is extracted and stored successfully.