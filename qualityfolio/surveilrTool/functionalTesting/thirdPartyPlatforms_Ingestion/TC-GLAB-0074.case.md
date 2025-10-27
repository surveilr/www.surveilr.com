---
FII: "TC-GLAB-0074"
groupId: "GRP-0006"
title: "Ingestion Corrupts Existing Surveiler Tasks"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["GitLab"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify system behavior if ingestion overwrites or corrupts existing tasks due to misconfiguration.

### Test Steps
1. Enable ingestion with “overwrite existing tasks” enabled incorrectly.
2. Trigger ingestion.

### Expected Result
- Existing Surveiler tasks get corrupted or deleted.
- Alert/notification generated about the critical issue.
- Admin intervention required.
