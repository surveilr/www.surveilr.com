---
FII: "TC-TXT-0017"
groupId: "GRP-0003"
title: "Check - Small Plain Text File Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Plain Text"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that a small `.txt` file uploads successfully and content is displayed correctly.

### Test Steps
1. Prepare a small `.txt` file (~1 KB).  
2. Upload via Surveilr UI or CLI.  
3. Observe upload process and completion message.  
4. Verify that content matches the original file.

### Expected Result
- File uploads successfully.  
- Content is displayed correctly without truncation or corruption.
