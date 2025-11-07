---
FII: "TC-SRV-0039"
groupId: "GRP-0001"
title: "Validate surveilr osqueryctl handles bad config path"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osqueryctl"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate error handling when an invalid config file path is given.

### Test Steps
1. Run `surveilr osqueryctl config /wrong/path`.  
2. Observe output message.  

### Expected Result
- CLI displays `Error: config file not found`.
