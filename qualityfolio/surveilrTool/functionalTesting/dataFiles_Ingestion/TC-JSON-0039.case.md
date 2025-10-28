---
FII: "TC-JSON-0039"
groupId: "GRP-0002"
title: "Duplicate Keys Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Test behavior when JSON contains duplicate keys at the same level.

### Test Steps
1. Prepare JSON file with duplicate keys.  
2. Run `surveilr ingest files --input duplicate_keys.json`.  

### Expected Result
- Parser logs warning or error.  
- Exit code reflects handling (0 if supported, non-zero if not).  
- Last value retained per spec.
