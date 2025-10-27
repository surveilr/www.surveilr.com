---
FII: "TC-XML-0051"
groupId: "GRP-0002"
title: "Empty XML File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Ensure the system handles empty XML files gracefully.

### Test Steps
1. Create an empty XML file.  
2. Run `surveilr ingest files --file empty.xml`.  

### Expected Result
- Exit code ≠ 0 or handled gracefully; log indicates empty file.
