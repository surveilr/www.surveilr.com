---
FII: "TC-TXT-0016"
groupId: "GRP-0003"
title: "Check - Large Plain Text File Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that Surveilr handles large `.txt` files (~10 MB) without crashing.

### Test Steps
1. Prepare a large `.txt` file (~10 MB).  
2. Upload via Surveilr UI or CLI.  
3. Monitor upload progress.  
4. Verify all lines are loaded correctly.

### Expected Result
- File uploads successfully.  
- Content matches original file completely.
