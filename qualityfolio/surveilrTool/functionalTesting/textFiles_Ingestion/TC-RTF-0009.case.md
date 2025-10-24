---
FII: "TC-RTF-0009"
groupId: "GRP-0003"
title: "Check - RTF Embedded Objects Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveilr’s handling of embedded objects (charts, OLE objects) in RTF files.

### Test Steps
1. Prepare an RTF file containing embedded objects like charts or OLE elements.  
2. Upload the file via Surveilr.  
3. Open and render the file.  
4. Observe handling of embedded objects.

### Expected Result
- Supported objects are rendered correctly.  
- Unsupported objects are detected and logged gracefully without crashing.
