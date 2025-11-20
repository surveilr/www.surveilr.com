---
FII: "TC-IMAP-0020"
groupId: "GRP-0004"
title: "Inline image handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "CID", "images"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate handling of CID-based inline images.

### Preconditions
- Email containing inline images referenced via CID exists.

### Test Steps
1. Send or locate CID-based inline-image email.
2. Run ingestion.
3. Inspect extracted body and image references.

### Expected Result
- Inline images are processed without corruption.

