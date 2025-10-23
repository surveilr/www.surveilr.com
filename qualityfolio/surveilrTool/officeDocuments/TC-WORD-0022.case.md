---
FII: "TC-WORD-0022"
groupId: "GRP-0005"
title: "Search Within Word Document Content"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Manual"
tags: ["Word"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr search can identify and retrieve Word documents containing specific text.

### Test Steps
1. Upload a Word file with known text content.  
2. Use the global search bar in Surveilr.  
3. Enter a keyword present in the document.  

### Expected Result
- The Word file appears in the search results.  
- Search highlights the correct document and snippet.
