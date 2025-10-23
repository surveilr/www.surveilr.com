---
FII: "TC-EXL-0001"
groupId: "GRP-0005"
title: "Upload and Parse Excel (.xls) File in Surveilr"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Excel"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Validate that Surveilr correctly uploads and parses `.xls` files without errors.

### Test Steps
1. Navigate to the file upload section in Surveilr.  
2. Select a valid `.xls` file from local storage.  
3. Upload the file and wait for the system to process it.  
4. Check if the file appears in the document list with correct metadata.  

### Expected Result
- File uploads successfully.  
- Surveilr correctly extracts and displays metadata such as file name, type, and size.  
- No parsing or format errors are displayed.
