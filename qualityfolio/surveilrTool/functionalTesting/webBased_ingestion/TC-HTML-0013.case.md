---
FII: "TC-HTML-0013"
groupId: "GRP-0008"
title: "Ingest HTML Containing Malicious Script"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify Surveilr blocks malicious scripts during HTML ingestion.

### Test Steps
1. Provide HTML containing <script> tags with XSS payload.  
2. Trigger ingestion.  
3. Monitor logs for script handling.

### Expected Result
- Malicious scripts blocked.  
- Content ingested safely without executing scripts.
