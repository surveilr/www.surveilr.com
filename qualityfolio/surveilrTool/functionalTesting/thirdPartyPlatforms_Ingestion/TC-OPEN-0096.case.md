---
FII: "TC-OPEN-0096"
groupId: "GRP-0006"
title: "Invalid Endpoint Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Check ingestion behavior when the OpenProject endpoint URL is invalid or unreachable.

### Test Steps
1. Set up an incorrect OpenProject API URL.  
2. Trigger task ingestion from Surveilr.  
3. Observe connection and log messages.  

### Expected Result
- Ingestion attempt fails gracefully.  
- System logs display clear endpoint or connection error.  
- No partial or corrupted ingestion occurs.
