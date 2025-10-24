---
FII: "TC-GIT-0068"
groupId: "GRP-0006"
title: "Large Single File Exceeds Limit"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr behavior when a file exceeds maximum allowed size.

### Test Steps
1. Run file ingest on a repo containing an extremely large file.  
2. Observe session logs and `uniform_resource` table.  

### Expected Result
- File skipped or pointer recorded.  
- Session logs indicate file size limit exceeded.  
- Other files ingested successfully.
