---
FII: "TC-EXL-0005"
groupId: "GRP-0005"
title: "Handle Corrupted Excel File Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Excel"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
Check Surveilr’s behavior when attempting to upload a corrupted or invalid Excel file.

### Test Steps
1. Attempt to upload a corrupted `.xls` or `.xlsx` file.  
2. Observe Surveilr’s system response and error message.  

### Expected Result
- Upload is rejected gracefully.  
- System displays a clear error message such as “Invalid file format or corrupted file.”  
- No crash or unhandled exception occurs.
