---
FII: "TC-RTF-0008"
groupId: "GRP-0003"
title: "Check - RTF Text Formatting"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate correct parsing and rendering of RTF text formatting including bold, italic, and underline.

### Test Steps
1. Prepare an RTF file containing text with bold, italic, and underline formatting.  
2. Upload the file via Surveilr.  
3. Open and render the file in the viewer.  
4. Inspect that formatting is preserved for all text.

### Expected Result
- All text formatting (bold, italic, underline) is rendered correctly without loss.
