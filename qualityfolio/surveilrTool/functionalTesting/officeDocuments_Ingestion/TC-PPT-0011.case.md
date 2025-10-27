---
FII: "TC-PPT-0011"
groupId: "GRP-0005"
title: "Upload and Parse PowerPoint (.ppt) File in Surveilr"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PowerPoint"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Validate that Surveilr correctly uploads and parses legacy PowerPoint `.ppt` files.

### Test Steps
1. Navigate to the Surveilr upload module.  
2. Select a valid `.ppt` file from local storage.  
3. Upload and wait for the system to process it.  
4. Check if the document appears with correct name, type, and size.  

### Expected Result
- File uploads successfully.  
- Surveilr displays metadata (file name, type, size).  
- No parsing or compatibility errors occur.
