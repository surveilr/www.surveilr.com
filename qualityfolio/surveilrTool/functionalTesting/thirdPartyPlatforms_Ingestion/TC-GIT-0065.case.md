---
FII: "TC-GIT-0065"
groupId: "GRP-0006"
title: "Poison Filenames Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr handles path traversal, extremely long, or Unicode filenames safely.

### Test Steps
1. Run file ingest on a repo containing files with `../`, emojis, or >4096 character paths.  
2. Check `uniform_resource` entries.  
3. Observe session logs for normalization warnings.

### Expected Result
- Filenames normalized safely.  
- No directory escapes or filesystem corruption.  
- Session completes successfully.
