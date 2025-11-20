---
FII: "TC-IMAP-0025"
groupId: "GRP-0004"
title: "Timezone mismatch"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "timezone"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate timestamp consistency across IMAP, ingestion, and UI storage.

### Preconditions
- Test email with known timezone offset.

### Test Steps
1. Run ingestion.
2. Compare stored timestamps against source timestamps.
3. Validate timezone normalization.

### Expected Result
- Timestamps remain consistent and properly converted across zones.