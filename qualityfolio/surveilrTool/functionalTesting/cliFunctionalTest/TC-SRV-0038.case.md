---
FII: "TC-SRV-0038"
groupId: "GRP-0001"
title: "Validate surveilr osqueryctl configuration execution"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osqueryctl"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify that the CLI successfully applies osquery configuration.

### Test Steps
1. Run `surveilr osqueryctl config`.  
2. Observe console logs.  

### Expected Result
- CLI confirms that configuration is applied successfully.