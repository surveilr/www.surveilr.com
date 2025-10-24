---
FII: "TC-RSS-0018"
groupId: "GRP-0008"
title: "Ingest RSS Feed with Invalid Format"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["RSS"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify Surveilr behavior when RSS feed format is invalid or malformed.

### Test Steps
1. Provide RSS feed with broken XML or missing `<item>` tags.  
2. Trigger ingestion.  
3. Monitor logs for errors.

### Expected Result
- System logs parsing errors.  
- Ingestion fails gracefully.  
- No crash occurs.
