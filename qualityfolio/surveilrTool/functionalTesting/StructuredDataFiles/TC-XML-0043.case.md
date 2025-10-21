---
FII: "TC-XML-0043"
groupId: "GRP-0002"
title: "XML Ingestion – Basic Valid File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Test parsing of a simple XML file with a single root and child nodes.

### Test Steps
1. Prepare a simple valid XML file with root and 1–2 child nodes.  
2. Run `surveilr ingest files --file valid.xml`.  

### Expected Result
- Exit code `0`; log shows `OK`; parsed data matches input nodes.
