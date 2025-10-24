---
FII: "TC-HTML-0012"
groupId: "GRP-0008"
title: "Ingest HTML with Broken Links"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify ingestion when HTML contains broken links.

### Test Steps
1. Provide HTML with <a> tags pointing to broken URLs.  
2. Trigger ingestion.  
3. Monitor logs for warnings.

### Expected Result
- Content ingested successfully.  
- Broken links logged but do not block ingestion.
