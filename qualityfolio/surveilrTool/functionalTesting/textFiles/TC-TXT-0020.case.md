---
FII: "TC-TXT-0020"
groupId: "GRP-0003"
title: "Check - Corrupted Plain Text File Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "negative path"
---
### Description
- Validate that Surveilr handles corrupted `.txt` files gracefully.

### Test Steps
1. Prepare a `.txt` file with broken encoding or incomplete content.  
2. Attempt upload.  
3. Observe system response.

### Expected Result
- Error message shown.  
- Application does not crash.
