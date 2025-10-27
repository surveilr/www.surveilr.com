---
FII: "TC-XML-0044"
groupId: "GRP-0002"
title: "XML Ingestion – Nested Elements"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure XML with multiple nested elements is parsed correctly.

### Test Steps
1. Prepare XML with multiple nested levels.  
2. Run `surveilr ingest files --file nested.xml`.  

### Expected Result
- Exit code `0`; hierarchy preserved; all nested elements parsed correctly.
