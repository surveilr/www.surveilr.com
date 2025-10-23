---
FII: "TC-TXT-0021"
groupId: "GRP-0003"
title: "Check - Security: Plain Text File with Scripts"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate that `.txt` files containing scripts do not execute.

### Test Steps
1. Prepare a `.txt` file with scripts (<script>alert('test')</script>).  
2. Upload via Surveilr.  
3. Observe behavior.

### Expected Result
- Scripts treated as plain text.  
- No execution occurs.
