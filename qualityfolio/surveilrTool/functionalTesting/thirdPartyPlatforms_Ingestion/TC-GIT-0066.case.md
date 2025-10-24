---
FII: "TC-GIT-0066"
groupId: "GRP-0006"
title: "Mixed Encoding Files Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate ingestion of files with mixed encodings (UTF-8, Latin1, binary mislabelled as text).

### Test Steps
1. Run file ingest on repo containing mixed encoding files.  
2. Inspect `uniform_resource` for encoding and content integrity.  

### Expected Result
- Files ingested safely without data loss.  
- Metadata reflects correct encoding.  
- No failures due to encoding issues.
