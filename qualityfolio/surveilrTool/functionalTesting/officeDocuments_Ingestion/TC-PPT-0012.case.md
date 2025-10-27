---
FII: "TC-PPT-0012"
groupId: "GRP-0005"
title: "Upload and Parse PowerPoint (.pptx) File in Surveilr"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PowerPoint"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Ensure Surveilr supports uploading and parsing modern PowerPoint `.pptx` files correctly.

### Test Steps
1. Open Surveilr and access the document upload interface.  
2. Choose a valid `.pptx` file and upload it.  
3. Wait for the file to process.  
4. Verify that the document’s metadata and preview load successfully.  

### Expected Result
- File uploads without issue.  
- Surveilr displays proper file metadata.  
- Preview or metadata extraction completes successfully.
