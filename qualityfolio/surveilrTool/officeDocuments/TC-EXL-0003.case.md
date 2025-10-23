---
FII: "TC-EXL-0003"
groupId: "GRP-0005"
title: "Handle Excel File with Multiple Sheets"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Excel"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Validate Surveilr’s ability to process Excel files containing multiple sheets.

### Test Steps
1. Upload an Excel file (`.xlsx`) containing multiple sheets.  
2. Wait for Surveilr to finish processing.  
3. Open the file detail view and verify the sheet-level information.  

### Expected Result
- All sheets are detected correctly.  
- No missing or corrupted sheet data.  
- Metadata and preview are consistent with source content.
