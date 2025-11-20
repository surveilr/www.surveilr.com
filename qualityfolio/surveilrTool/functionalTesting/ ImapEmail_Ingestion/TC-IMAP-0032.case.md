---
FII: "TC-IMAP-0032"
groupId: "GRP-0004"
title: "Watch stops mid-email during VS Code close"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate no partial ingestion when a large email is being processed and VS Code is closed.

### Preconditions
- Large email begins ingestion.

### Test Steps
1. Start IMAP watch.
2. Begin ingesting a large email.
3. Close VS Code mid-process.

### Expected Result
- No partial files remain.
- No duplicates on next run.
