---
FII: "TC-SRV-0040"
groupId: "GRP-0001"
title: "Verify surveilr snmp --help displays SNMP help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["snmp"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that SNMP command help menu is shown properly.

### Test Steps
1. Open terminal.  
2. Run `surveilr snmp --help`.  
3. Observe the CLI output.  

### Expected Result
- CLI displays SNMP discovery and monitoring usage details.