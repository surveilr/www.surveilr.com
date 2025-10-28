---
FII: "TC-WORD-0021"
groupId: "GRP-0005"
title: "Validate File Size Limit for Word Document"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miseable"
---

### Description
- Validate Surveilr’s behavior when uploading a Word document that exceeds the allowed file size limit.

### Test Steps
1. Create or obtain a Word file larger than the maximum upload size.  
2. Attempt to upload it in Surveilr.  

### Expected Result
- Upload is rejected.  
- An appropriate message such as **“File exceeds maximum size limit”** is displayed.  
- System remains responsive.
