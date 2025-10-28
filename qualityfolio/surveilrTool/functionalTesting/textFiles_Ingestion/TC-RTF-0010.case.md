---
FII: "TC-RTF-0010"
groupId: "GRP-0003"
title: "Check - RTF Tables Rendering"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate correct parsing and display of tables in RTF files.

### Test Steps
1. Prepare an RTF file containing tables of various sizes and structures.  
2. Upload the file via Surveilr.  
3. Open and render the file in the viewer.  
4. Inspect table layout and content accuracy.

### Expected Result
- Tables are rendered correctly without misalignment.  
- Unsupported table features are logged gracefully.
