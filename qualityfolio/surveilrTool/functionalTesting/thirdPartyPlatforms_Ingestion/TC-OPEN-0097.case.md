---
FII: "TC-OPEN-0097"
groupId: "GRP-0006"
title: "Network Timeout During Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate system response when OpenProject is slow or unreachable due to network timeout.

### Test Steps
1. Simulate slow network response from OpenProject API.  
2. Start ingestion from Surveilr.  
3. Observe retry logic or timeout messages.  

### Expected Result
- Ingestion fails after configured timeout.  
- Retry attempts (if any) are logged.  
- System remains stable without crashing.
