---
FII: "TC-XML-0049"
groupId: "GRP-0002"
title: "Malformed XML – Missing Closing Tag"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Test error handling when an XML closing tag is missing.

### Test Steps
1. Create XML missing a closing tag.  
2. Run `surveilr ingest files --file missing_closing.xml`.  

### Expected Result
- Exit code ≠ 0; log shows clear error for malformed XML.
