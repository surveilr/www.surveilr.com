---
FII: "TC-GIT-0054"
groupId: "GRP-0006"
title: "Tag and Release Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of Git tags and releases.

### Test Steps
1. Execute file ingest command on repo with releases and tags.  
2. Check `uniform_resource` for tag metadata and release assets.  
3. Confirm completeness of commit linkage.

### Expected Result
- Tags and releases ingested.  
- Assets correctly stored or pointers recorded.  
- Metadata includes version info.
