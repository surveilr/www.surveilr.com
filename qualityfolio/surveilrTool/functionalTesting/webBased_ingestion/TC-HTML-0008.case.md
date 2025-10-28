---
FII: "TC-HTML-0008"
groupId: "GRP-0008"
title: "Ingest HTML with Images and Tables"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Surveilr correctly ingests HTML containing images and table structures.

### Test Steps
1. Provide HTML with <img> tags and <table> elements.  
2. Trigger ingestion.  
3. Monitor logs for parsing status.

### Expected Result
- HTML content, images, and tables stored correctly.  
- Content is accessible without parsing errors.
