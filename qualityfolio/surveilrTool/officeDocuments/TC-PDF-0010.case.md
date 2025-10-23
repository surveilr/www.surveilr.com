---
FII: "TC-PDF-0010"
groupId: "GRP-0005"
title: "Validate Large PDF File Upload (Performance)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PDF"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "performance"
---

### Description
Assess Surveilr’s ability to handle large PDF uploads (e.g., 100+ pages or >100MB) without performance degradation.

### Test Steps
1. Upload a large multi-page PDF file (>100MB).  
2. Observe system response time during upload and parsing.  
3. Verify stability and responsiveness post-upload.  

### Expected Result
- Upload completes within acceptable performance limits.  
- No timeout or system freeze occurs.  
- Metadata extraction and preview generation succeed for large files.
