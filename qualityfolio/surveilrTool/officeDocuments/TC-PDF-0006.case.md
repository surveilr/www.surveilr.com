---
FII: "TC-PDF-0006"
groupId: "GRP-0005"
title: "Upload and Parse PDF File in Surveilr"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PDF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Validate that Surveilr can upload and parse standard PDF files correctly without data loss or format corruption.

### Test Steps
1. Navigate to the file upload module in Surveilr.  
2. Select a valid `.pdf` file and upload it.  
3. Wait for processing to complete.  
4. Verify that metadata and preview are displayed.  

### Expected Result
- File uploads successfully.  
- Surveilr displays file name, type, and size correctly.  
- PDF content preview and metadata extraction complete without errors.
