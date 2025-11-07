---
FII: "TC-SRV-0035"  
groupId: "GRP-0001"  
title: "Validate surveilr osquery-ms connectivity"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osquery-ms"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure that the CLI can connect and retrieve osquery-ms agent status.

### Test Steps
1. Run `surveilr osquery-ms status`.  
2. Review the CLI output.  

### Expected Result
- CLI displays the osquery-ms agent connection and running status.