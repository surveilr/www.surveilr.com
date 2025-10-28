---
FII: "TC-XML-0046"
groupId: "GRP-0002"
title: "XML Namespaces"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure proper parsing of XML namespaces.

### Test Steps
1. Create XML with default and custom namespaces.  
2. Run `surveilr ingest files --file namespaces.xml`.  

### Expected Result
- Exit code `0`; elements mapped correctly to namespaces.
