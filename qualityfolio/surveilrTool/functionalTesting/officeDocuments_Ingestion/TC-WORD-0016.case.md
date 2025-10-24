---
FII: "TC-WORD-0016"
groupId: "GRP-0005"
title: "Upload Word Document (.doc, .docx)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate Surveilr supports uploading of Word documents (.doc and .docx) without data corruption or rejection.

### Test Steps
1. Launch Surveilr and log in with valid credentials.  
2. Navigate to **Documents > Upload**.  
3. Select a valid `.doc` or `.docx` file from the local system.  
4. Click **Upload** and observe the progress indicator.  

### Expected Result
- Upload completes successfully.  
- File name and metadata appear in the documents list.  
- A confirmation message such as **“File uploaded successfully”** is displayed.
