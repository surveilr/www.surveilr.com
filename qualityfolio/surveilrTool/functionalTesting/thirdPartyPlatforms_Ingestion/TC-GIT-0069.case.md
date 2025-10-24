---
FII: "TC-GIT-0069"
groupId: "GRP-0006"
title: "Missing LFS Objects"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr handles missing Git LFS objects during file ingest.

### Test Steps
1. Run file ingest on repo with missing LFS objects.  
2. Inspect session logs for warnings.  
3. Verify `uniform_resource` entries for missing pointers.

### Expected Result
- Missing LFS objects flagged.  
- Other files ingested successfully.  
- Session logs clearly indicate incomplete objects.
