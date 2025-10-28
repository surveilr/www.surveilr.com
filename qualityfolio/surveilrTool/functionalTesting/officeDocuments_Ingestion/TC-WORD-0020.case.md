---
FII: "TC-WORD-0020"
groupId: "GRP-0005"
title: "Upload Corrupted or Invalid Word Document"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify Surveilr's error handling when uploading corrupted or invalid Word documents.

### Test Steps
1. Attempt to upload a corrupted `.docx` file (e.g., incomplete or renamed non-Word file).  
2. Observe the upload behavior.  

### Expected Result
- Upload fails gracefully.  
- Error message such as **“Invalid or corrupted file format”** is shown.  
- No crash or UI freeze occurs.
