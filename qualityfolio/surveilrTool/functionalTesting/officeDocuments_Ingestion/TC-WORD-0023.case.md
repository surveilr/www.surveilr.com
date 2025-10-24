---
FII: "TC-WORD-0023"
groupId: "GRP-0005"
title: "Manage Versions of Word Document"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Manual"
tags: ["Word"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr maintains version history when a Word document is re-uploaded.

### Test Steps
1. Upload a Word file.  
2. Upload an updated version of the same file.  
3. Check version history in the document details panel.  

### Expected Result
- Both versions are listed in version history.  
- The system indicates the latest version clearly.  
- Older versions remain accessible for download or review.
