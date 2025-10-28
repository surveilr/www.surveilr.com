---
FII: "TC-GIT-0057"
groupId: "GRP-0006"
title: "Binary File Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of binary files such as images or archives.

### Test Steps
1. Run file ingest on repo containing binaries.  
2. Verify `uniform_resource` for file size, MIME type, and checksum.  

### Expected Result
- Binary files ingested correctly.  
- Provenance includes binary metadata.
