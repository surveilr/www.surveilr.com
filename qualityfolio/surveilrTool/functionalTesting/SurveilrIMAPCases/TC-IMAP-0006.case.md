---
FII: "TC-IMAP-0006"
groupId: "GRP-0004"
title: "Fetch Email Headers Only"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr can fetch only the headers (subject, sender, timestamp) of emails.

### Test Steps
1. Connect to IMAP server.  
2. Fetch email headers only.  
3. Store headers as structured data (CSV/JSON).  

### Expected Result
- Email headers are correctly stored in CSV/JSON.  
- No email body content is retrieved.
