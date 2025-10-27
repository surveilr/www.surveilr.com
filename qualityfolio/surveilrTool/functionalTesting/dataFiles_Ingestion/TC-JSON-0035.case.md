---
FII: "TC-JSON-0035"
groupId: "GRP-0002"
title: "Missing Fields Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate Surveilr’s handling of JSON files missing optional fields.

### Test Steps
1. Prepare a JSON file omitting optional fields.  
2. Run `surveilr ingest files --input missing_fields.json`.  

### Expected Result
- Exit code `0`.  
- Missing fields are handled gracefully.  
- Logs indicate successful ingestion.
