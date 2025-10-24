---
FII: "TC-YML-0058"
groupId: "GRP-0002"
title: "Invalid Indentation Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Check that improper indentation in a YAML file is detected and reported.

### Test Steps
1. Create YAML file with inconsistent indentation.  
2. Run `surveilr ingest files --file bad_indent.yaml`.  

### Expected Result
- CLI returns graceful error; exit code `!= 0`; logs indicate `Indentation Error`.
