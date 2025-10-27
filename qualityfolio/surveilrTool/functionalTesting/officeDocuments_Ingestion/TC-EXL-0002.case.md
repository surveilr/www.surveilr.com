---
FII: "TC-EXL-0002"
groupId: "GRP-0005"
title: "Upload and Parse Excel (.xlsx) File in Surveilr"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Excel"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Ensure Surveilr can correctly handle modern Excel `.xlsx` files.

### Test Steps
1. Open Surveilr and navigate to the upload panel.  
2. Choose a valid `.xlsx` file and upload it.  
3. Wait for Surveilr to complete parsing.  
4. Inspect displayed file metadata and preview content (if supported).  

### Expected Result
- Upload completes successfully.  
- The document metadata is displayed correctly.  
- Surveilr parses data sheets without format errors.
