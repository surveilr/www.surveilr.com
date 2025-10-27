---
FII: "TC-XML-0048"
groupId: "GRP-0002"
title: "Special Characters Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate handling of &, <, >, ", ' characters in XML content.

### Test Steps
1. Prepare XML with elements containing special characters.  
2. Run `surveilr ingest files --file special_chars.xml`.  

### Expected Result
- Exit code `0`; special characters correctly interpreted or escaped.
