---
FII: "TC-RTF-0011"
groupId: "GRP-0003"
title: "Check - RTF Embedded Images Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate correct parsing and rendering of embedded images in RTF files.

### Test Steps
1. Prepare an RTF file containing embedded images of different types.  
2. Upload the file via Surveilr.  
3. Open and render the file.  
4. Verify that images are displayed properly.

### Expected Result
- Supported image types are displayed correctly.  
- Unsupported images are logged without crashing the application.
