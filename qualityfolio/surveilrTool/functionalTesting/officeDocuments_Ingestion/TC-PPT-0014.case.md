---
FII: "TC-PPT-0014"
groupId: "GRP-0005"
title: "Handle Corrupted or Incomplete PowerPoint File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PowerPoint"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
Check Surveilr’s response to a corrupted `.ppt` or `.pptx` file upload.

### Test Steps
1. Attempt to upload a corrupted PowerPoint file.  
2. Observe the system response during the upload.  

### Expected Result
- Upload fails gracefully.  
- Surveilr displays a meaningful error message (e.g., “Invalid or corrupted PowerPoint file”).  
- System stability is maintained (no crash or hang).
