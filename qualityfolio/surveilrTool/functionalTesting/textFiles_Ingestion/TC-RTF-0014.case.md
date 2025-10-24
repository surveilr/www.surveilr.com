---
FII: "TC-RTF-0014"
groupId: "GRP-0003"
title: "Check - RTF Mixed Content Rendering"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["RTF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate correct rendering of RTF files containing a combination of text formatting, tables, images, and embedded objects.

### Test Steps
1. Prepare an RTF file containing text formatting, tables, images, and embedded objects.  
2. Upload the file via Surveilr.  
3. Open and render the file.  
4. Inspect all elements for correct rendering.

### Expected Result
- All supported content types are rendered correctly.  
- Unsupported content is logged gracefully without affecting other content.
