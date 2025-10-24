---
FII: "TC-WEB-0023"
groupId: "GRP-0008"
title: "Ingest Website with Incomplete Pages"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["WEB"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify ingestion when some website pages have missing HTML structure or content.

### Test Steps
1. Provide website with pages missing <body> or key content.  
2. Trigger crawling and ingestion.  
3. Monitor logs for warnings or errors.

### Expected Result
- Pages partially ingested.  
- Warnings logged for incomplete content.  
- System does not crash.
