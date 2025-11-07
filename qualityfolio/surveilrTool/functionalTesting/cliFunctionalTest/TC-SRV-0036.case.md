---
FII: "TC-SRV-0036"
groupId: "GRP-0001"
title: "Validate surveilr osquery-ms handling of unavailable service"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osquery-ms"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify that the CLI handles osquery-ms service unavailability gracefully.

### Test Steps
1. Stop or disable osquery-ms service.  
2. Run `surveilr osquery-ms status`.  
3. Observe the error output.

### Expected Result
- CLI displays `Error: connection refused` or a similar error message.
