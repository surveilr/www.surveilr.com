---
FII: "TC-IMAP-0012"
groupId: "GRP-0004"
title: "Folder Size Limit Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate Surveilr’s behavior when the number of emails exceeds the designated folder size limit.

### Test Steps
1. Fetch a large number of emails exceeding folder threshold.  
2. Observe folder storage and logs.  

### Expected Result
- Surveilr warns about folder overflow.  
- Emails are stored without corruption.  
- System continues processing remaining emails.
