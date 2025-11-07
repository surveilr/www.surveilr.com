---
FII: "TC-SRV-0027"
groupId: "GRP-0001"  
title: "Validate error handling for invalid orchestration SQL"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["orchestrate"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Verify that CLI properly handles invalid SQL during orchestration execution.

### Test Steps
1. Prepare a malformed SQL file `bad.sql`.  
2. Run the command `surveilr orchestrate run bad.sql`.  
3. Review the output message.  

### Expected Result
- CLI displays `Error: invalid SQL syntax` and stops execution gracefully.
