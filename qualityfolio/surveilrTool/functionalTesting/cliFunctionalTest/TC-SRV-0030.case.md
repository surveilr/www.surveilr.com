---
FII: "TC-SRV-0030"
groupId: "GRP-0001"  
title: "Validate surveilr doctor behavior under corrupted environment"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["doctor"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate CLI behavior when key environment variables are missing or corrupted.

### Test Steps
1. Temporarily remove or unset key environment variables.  
2. Run `surveilr doctor`.  
3. Observe output logs.

### Expected Result
- CLI displays relevant warnings or error messages gracefully without crashing.
