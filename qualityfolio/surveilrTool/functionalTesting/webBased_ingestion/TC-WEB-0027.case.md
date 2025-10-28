---
FII: "TC-WEB-0027"
groupId: "GRP-0008"
title: "Ingest Website with Internal Links"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["WEB"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Surveilr correctly follows and ingests internal links within the website.

### Test Steps
1. Provide a website with multiple internal pages.  
2. Trigger crawling and ingestion.  
3. Monitor that internal pages are captured in correct structure.

### Expected Result
- Internal pages ingested and stored correctly.  
- Link hierarchy preserved.
