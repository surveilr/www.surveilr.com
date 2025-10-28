---
FII: "TC-PDF-0008"
groupId: "GRP-0005"
title: "Handle Encrypted or Password-Protected PDF File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PDF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
Verify Surveilr’s response to encrypted or password-protected PDFs during upload and parsing.

### Test Steps
1. Attempt to upload a password-protected PDF file.  
2. Observe Surveilr’s handling and displayed error message.  

### Expected Result
- Surveilr detects encryption and halts parsing.  
- Displays appropriate error message (e.g., “Password-protected files are not supported”).  
- System remains stable without crash or hang.
