---
FII: "TC-TXT-0018"
groupId: "GRP-0003"
title: "Check - Plain Text File with Special Characters"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that `.txt` files containing special symbols or Unicode characters display correctly.

### Test Steps
1. Prepare a `.txt` file with special characters (@,#,$,%, Unicode).  
2. Upload via Surveilr UI or CLI.  
3. Verify content renders correctly.

### Expected Result
- Special characters render correctly.  
- No errors or corrupted characters.
