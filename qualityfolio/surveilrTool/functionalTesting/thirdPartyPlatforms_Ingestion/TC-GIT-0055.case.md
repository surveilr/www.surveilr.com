---
FII: "TC-GIT-0055"
groupId: "GRP-0006"
title: "LFS Pointer Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of Git LFS pointer files or resolved objects.

### Test Steps
1. Run file ingest on repo containing LFS files.  
2. Verify pointer files or actual LFS content in `uniform_resource`.  
3. Check metadata for size and checksum.

### Expected Result
- LFS pointers resolved or stored as configured.  
- Provenance includes LFS info.
