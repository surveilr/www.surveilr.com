---
FII: "TC-WORD-0019"
groupId: "GRP-0005"
title: "Download Word Document"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Manual"
tags: ["Word"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate the ability to download Word documents from Surveilr with integrity intact.

### Test Steps
1. Select an uploaded Word file in Surveilr.  
2. Click **Download**.  
3. Open the downloaded file locally.  
4. Compare the content and formatting with the original file.  

### Expected Result
- The downloaded file opens successfully in Microsoft Word.  
- Content, formatting, and file properties match the original version.
