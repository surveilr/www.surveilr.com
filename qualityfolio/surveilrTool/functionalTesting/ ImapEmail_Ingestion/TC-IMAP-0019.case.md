---
FII: "TC-IMAP-0019"
groupId: "GRP-0004"
title: "Malformed subject encoding"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "encoding"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate system behavior when email subject contains invalid/corrupted Base64 encoding.

### Preconditions
- Send email with malformed encoded subject header.

### Test Steps
1. Verify malformed subject email exists.
2. Run ingestion.
3. Review subject parsing.

### Expected Result
- Subject is sanitized gracefully without breaking ingestion.