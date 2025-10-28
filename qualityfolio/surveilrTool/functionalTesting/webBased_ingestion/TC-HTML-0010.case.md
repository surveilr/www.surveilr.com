---
FII: "TC-HTML-0010"
groupId: "GRP-0008"
title: "Ingest HTML Missing Body Tag"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify ingestion behavior when HTML page is missing <body> tags.

### Test Steps
1. Provide HTML page without <body> tags.  
2. Trigger ingestion.  
3. Monitor logs for warnings or errors.

### Expected Result
- Surveilr logs warning about missing body tag.  
- Content ingested partially without crash.
