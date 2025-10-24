---
FII: "TC-WORD-0024"
groupId: "GRP-0005"
title: "Delete Uploaded Word Document"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate deletion of uploaded Word files from Surveilr.

### Test Steps
1. Locate an uploaded Word file.  
2. Click **Delete** and confirm.  
3. Refresh the document list.  

### Expected Result
- File is removed from the system.  
- It no longer appears in the document listing or search results.
