---
FII: "TC-SRV-0042"
groupId: "GRP-0001"
title: "Validate SNMP authentication error handling in surveilr snmp"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["snmp"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify proper error handling when invalid SNMP credentials are used.

### Test Steps
1. Run `surveilr snmp discover` with invalid SNMP key.  
2. Observe the output.  

### Expected Result
- CLI displays `authentication failed` or similar error message.

