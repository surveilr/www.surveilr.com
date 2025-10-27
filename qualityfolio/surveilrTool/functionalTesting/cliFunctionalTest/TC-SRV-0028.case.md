---
FII: "TC-SRV-0028"
groupId: "GRP-0001"  
title: "Validate Exit Code on Permission Denied Error"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "Medium"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that the Surveilr CLI exits with a non-zero code when permission is denied to access a file or directory.

### Test Steps

1. Run `surveilr export --path /restricted`.  
2. Observe output and exit code.  

### Expected Result

- Exit code = 4  
- Output shows `Permission denied`.
md
Copy code
