---
FII: "TC-IMAP-0024"
groupId: "GRP-0004"
title: "Ingest stops on bad email"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "corruption"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate ingestion behavior when encountering a corrupted email.

### Preconditions
- Add a malformed/corrupted email to mailbox.

### Test Steps
1. Run ingestion.
2. Check logs for error handling around corrupted message.

### Expected Result
- System skips corrupted email without halting ingestion.

