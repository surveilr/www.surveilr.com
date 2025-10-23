---
FII: "TC-WORD-0025"
groupId: "GRP-0005"
title: "Verify Access Control for Word Documents"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Manual"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate access permissions for Word documents in Surveilr.

### Test Steps
1. Upload a Word document as an admin user.  
2. Assign restricted permissions to another user.  
3. Attempt to access the document using the restricted account.  

### Expected Result
- Restricted user cannot view, edit, or delete the document.  
- Admin user retains full control.  
- Proper access-denied message is displayed.
