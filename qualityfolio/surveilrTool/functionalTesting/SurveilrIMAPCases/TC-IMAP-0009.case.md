---
FII: "TC-IMAP-0009"
groupId: "GRP-0004"
title: "Classify Email Attachments Correctly"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that email attachments retrieved via IMAP are classified correctly in Surveilr.

### Test Steps
1. Fetch emails with attachments via IMAP.  
2. Identify the file type of each attachment.  
3. Store attachments in Surveilr according to file type.

### Expected Result
- PDFs → Office Documents  
- CSV/Excel → Structured Data Files  
- Images → Misc/Image Files  
- All attachments are stored in the proper folder.
