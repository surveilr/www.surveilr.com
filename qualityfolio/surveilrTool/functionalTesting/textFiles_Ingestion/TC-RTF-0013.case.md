---
FII: "TC-RTF-0013"
groupId: "GRP-0003"
title: "Check - RTF Corrupted File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr’s handling of corrupted or partially formatted RTF files.

### Test Steps
1. Prepare an RTF file that is partially corrupted or invalid.  
2. Upload the file via Surveilr.  
3. Attempt to open and render the file.  
4. Observe application behavior and error messages.

### Expected Result
- Surveilr shows a clear error message.  
- Application does not crash or hang.
