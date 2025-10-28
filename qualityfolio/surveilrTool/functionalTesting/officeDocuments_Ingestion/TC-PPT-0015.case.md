---
FII: "TC-PPT-0015"
groupId: "GRP-0005"
title: "Validate Large PowerPoint File Upload (Performance Test)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PowerPoint"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "performance"
---

### Description
Assess Surveilr’s ability to handle large PowerPoint files (e.g., >50MB) efficiently without timeout or failure.

### Test Steps
1. Prepare a `.pptx` file of size above 50MB.  
2. Upload the file using the Surveilr upload interface.  
3. Monitor the upload progress and response time.  

### Expected Result
- Upload completes within acceptable time limits.  
- No timeout or parsing failure occurs.  
- System remains responsive throughout the process.
