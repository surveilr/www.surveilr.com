---
FII: "TC-JPEG-002"
groupId: "GRP-0009"
title: "Upload a JPEG image exceeding size limit"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate that oversized JPEG images trigger proper error messages and are not partially ingested.

### Test Steps
1. Select a JPEG file exceeding the configured upload size limit.  
2. Attempt to upload the file through the Surveiler upload interface.  
3. Observe the error or status message returned.

### Expected Result
- Upload fails with a clear and descriptive error message.  
- The image is not partially saved or corrupted in the system.
