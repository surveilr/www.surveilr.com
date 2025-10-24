---
FII: "TC-XML-0045"
groupId: "GRP-0002"
title: "XML Attributes Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that attributes on XML elements are correctly parsed.

### Test Steps
1. Create XML with elements containing attributes.  
2. Run `surveilr ingest files --file attributes.xml`.  

### Expected Result
- Exit code `0`; attributes appear correctly in parsed output.
