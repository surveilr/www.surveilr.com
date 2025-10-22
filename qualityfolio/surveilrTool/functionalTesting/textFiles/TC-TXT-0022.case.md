---
FII: "TC-TXT-0022"
groupId: "GRP-0003"
title: "Check - Multiple Large Plain Text Files Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "performance"
---
### Description
- Validate Surveilr handles multiple large `.txt` files without performance issues.

### Test Steps
1. Prepare 3-5 large `.txt` files.  
2. Upload consecutively via CLI/UI.  
3. Monitor performance and responsiveness.

### Expected Result
- Application remains responsive.  
- No crashes or errors.
