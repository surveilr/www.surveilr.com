---
FII: "TC-HTML-0011"
groupId: "GRP-0008"
title: "Ingest Empty HTML Page"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify Surveilr rejects empty HTML pages.

### Test Steps
1. Provide an HTML file with no content.  
2. Trigger ingestion.  
3. Monitor logs for ingestion response.

### Expected Result
- Ingestion is rejected with “Empty content” error.  
- No content stored.
