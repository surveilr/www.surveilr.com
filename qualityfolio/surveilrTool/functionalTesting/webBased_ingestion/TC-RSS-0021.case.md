---
FII: "TC-RSS-0021"
groupId: "GRP-0008"
title: "Ingest RSS Feed with Invalid Items"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["RSS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify ingestion when feed contains items with missing or invalid metadata.

### Test Steps
1. Provide RSS feed with items missing `<title>` or `<link>`.  
2. Trigger ingestion.  
3. Monitor logs for item-level errors.

### Expected Result
- Invalid items skipped or logged as errors.  
- Other valid items ingested successfully.  
- System remains stable.
