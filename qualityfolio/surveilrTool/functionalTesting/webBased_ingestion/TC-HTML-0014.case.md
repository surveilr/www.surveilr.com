---
FII: "TC-HTML-0014"
groupId: "GRP-0008"
title: "Ingest HTML Exceeding Max Size Limit"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify Surveilr rejects HTML pages exceeding maximum size limit.

### Test Steps
1. Provide extremely large HTML page (e.g., >100MB).  
2. Trigger ingestion.  
3. Monitor logs for errors.

### Expected Result
- Ingestion rejected due to size limit.  
- Error logged; system does not crash.
