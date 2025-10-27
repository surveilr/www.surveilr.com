---
FII: "TC-XRAY-0108"
groupId: "GRP-0006"
title: "Xray API Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveiler behavior when Xray API is slow or unavailable.

### Test Steps
1. Trigger ingestion while Xray server is slow/unavailable.  

### Expected Result
- Timeout error logged.  
- Tasks are not ingested.
