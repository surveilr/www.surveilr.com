---
FII: "TC-SRV-0041"
groupId: "GRP-0001"
title: "Validate surveilr snmp device discovery"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["snmp"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that the SNMP device discovery command lists available network devices.

### Test Steps
1. Run `surveilr snmp discover`.  
2. Observe console output.  

### Expected Result
- CLI lists discovered SNMP devices with host and OID information.

