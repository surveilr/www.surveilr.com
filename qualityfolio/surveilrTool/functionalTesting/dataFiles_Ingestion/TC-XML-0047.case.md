---
FII: "TC-XML-0047"
groupId: "GRP-0002"
title: "CDATA Sections Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify CDATA sections are correctly extracted from XML files.

### Test Steps
1. Create XML containing CDATA blocks.  
2. Run `surveilr ingest files --file cdata.xml`.  

### Expected Result
- Exit code `0`; CDATA content preserved as-is.
