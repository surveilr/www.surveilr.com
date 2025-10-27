---
FII: "TC-JPEG-004"
groupId: "GRP-0009"
title: "Upload multiple JPEG images at once"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy/unhappy"
---

### Description
- Validate batch ingestion functionality with multiple valid and invalid JPEG images.

### Test Steps
1. Select a batch of JPEG images including both valid and invalid files.  
2. Perform a multi-file upload in the Surveiler interface.  
3. Monitor ingestion logs and performance metrics.

### Expected Result
- All valid images are successfully ingested.  
- Errors are logged for invalid ones without affecting others.
