---
FII: "TC-IMAP-0011"
groupId: "GRP-0004"
title: "Store Emails in Separate IMAP Folder"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that all emails retrieved via IMAP are stored in a designated separate folder in Surveilr.

### Test Steps
1. Fetch multiple emails via IMAP.  
2. Ensure they are saved in the dedicated IMAP folder.  
3. Verify metadata and classification for attachments.  

### Expected Result
- All emails are stored in the separate IMAP folder.  
- Attachments are correctly classified and stored.
