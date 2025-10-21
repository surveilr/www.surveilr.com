---
FII: "TC-YML-0061"
groupId: "GRP-0002"
title: "Empty YAML File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Check behavior when an empty YAML file is ingested.

### Test Steps
1. Create an empty YAML file.  
2. Run `surveilr ingest files --file empty.yaml`.  

### Expected Result
- CLI returns appropriate error or warning; exit code `!= 0`.
