---
FII: "TC-SRV-0027"
groupId: "GRP-0001"  
title: "Validate Exit Code on Invalid File Input"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "unhappy path"  
---

### Description

- Validate that Surveilr CLI returns a non-zero exit code when an invalid file or corrupt format is provided.

### Test Steps

1. Execute `surveilr import --file invalid.json`.  
2. Observe CLI error message and capture exit code.  

### Expected Result

- Exit code = 3  
- Output contains `Invalid file format` or `File not found`.