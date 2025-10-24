---
FII: "TC-TXT-0024"
groupId: "GRP-0003"
title: "Check - Copy-Paste from Uploaded Plain Text File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that text can be copied accurately from an uploaded `.txt` file.

### Test Steps
1. Upload a valid `.txt` file.  
2. Select and copy text.  
3. Paste into another editor.  
4. Compare content with original file.

### Expected Result
- Text copies accurately, including spaces and special characters.
