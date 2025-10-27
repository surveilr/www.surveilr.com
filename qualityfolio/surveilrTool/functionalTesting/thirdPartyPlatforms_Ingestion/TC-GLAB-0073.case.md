---
FII: "TC-GLAB-0073"
groupId: "GRP-0006"
title: "Task Metadata Missing Fields"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["GitLab"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify ingestion behavior if GitLab tasks have missing mandatory fields (e.g., no assignee).

### Test Steps
1. Create tasks in GitLab with missing mandatory fields.
2. Trigger ingestion.

### Expected Result
- Tasks are either skipped or ingested with warnings.
- Logs show skipped/malformed tasks.
