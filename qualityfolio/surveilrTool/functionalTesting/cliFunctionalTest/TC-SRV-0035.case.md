---
FII: "TC-SRV-0035"  
groupId: "GRP-0001"  
title: "Validate Exit Code Consistency Across Environments"  
created_by: "arun-ramanan@netspective.in"  
created_at: "2025-10-20"  
test_type: "Automation"  
tags: ["Exit Code"]  
priority: "High"  
test_cycles: ["1.0"]  
scenario_type: "validation path"  
---

### Description

- Validate that exit codes remain consistent for the same command across Dev, QA, and Staging environments.

### Test Steps

1. Execute an invalid command (`surveilr invalid-command`) in Dev, QA, and Staging.  
2. Compare exit codes.  

### Expected Result

- Exit code values are consistent across all environments.
