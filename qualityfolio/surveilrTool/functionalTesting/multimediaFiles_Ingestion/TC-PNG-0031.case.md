---
FII: "TC-PNG-004"
groupId: "GRP-0009"
title: "Upload multiple PNG images at once"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy/unhappy"
---

### Description
- Validate batch upload functionality with multiple valid and invalid PNG images.

### Test Steps
1. Select a batch containing both valid and invalid PNG images.  
2. Upload all at once using the Surveiler interface.  
3. Review ingestion results and performance metrics.

### Expected Result
- All valid images are ingested successfully.  
- Errors are logged for invalid images without affecting valid ones.
