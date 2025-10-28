---
FII: "TC-GLAB-0071"
groupId: "GRP-0006"
title: "Ingestion Fails Due to Invalid GitLab Token"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["GitLab"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify that the system handles invalid authentication tokens gracefully during GitLab task ingestion.

### Test Steps
1. Connect Surveiler to GitLab with an expired or invalid token.
2. Trigger task ingestion.

### Expected Result
- Ingestion fails with a clear error message (e.g., "Authentication failed").
- No partial data is ingested.
- User can retry after fixing the token.
