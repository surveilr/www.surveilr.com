---
FII: "TC-XML-0050"
groupId: "GRP-0002"
title: "Malformed XML – Invalid Structure"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Test error handling for completely invalid XML structures.

### Test Steps
1. Prepare XML with invalid nesting or random text.  
2. Run `surveilr ingest files --file invalid_structure.xml`.  

### Expected Result
- Exit code ≠ 0; descriptive error logged.
