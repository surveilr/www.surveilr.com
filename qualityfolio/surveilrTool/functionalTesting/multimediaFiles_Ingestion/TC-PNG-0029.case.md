---
FII: "TC-PNG-002"
groupId: "GRP-0009"
title: "Upload a PNG image exceeding size limit"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate handling of oversized PNG uploads exceeding system size limits.

### Test Steps
1. Select a PNG file larger than the maximum allowed size.  
2. Attempt to upload it through the Surveiler interface.  
3. Observe the error or response message.

### Expected Result
- Upload fails with a clear and descriptive error message.  
- Image is not partially saved or corrupted in storage.
