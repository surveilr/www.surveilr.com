---
FII: "TC-TXT-0015"
groupId: "GRP-0003"
title: "Check - Empty Plain Text File Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate that empty `.txt` files are handled gracefully.

### Test Steps
1. Prepare an empty `.txt` file.  
2. Attempt upload via Surveilr.  
3. Observe system response.

### Expected Result
- Application warns: "File is empty" or equivalent.  
- No crash occurs.
