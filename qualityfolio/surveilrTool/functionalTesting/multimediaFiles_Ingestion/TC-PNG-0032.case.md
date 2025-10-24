---
FII: "TC-PNG-005"
groupId: "GRP-0009"
title: "Upload PNG with unsupported color depth"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate system behavior when uploading PNGs with unsupported or high color depths.

### Test Steps
1. Prepare a PNG image with unsupported color depth (e.g., 32-bit with alpha not handled).  
2. Upload through Surveiler.  
3. Observe conversion, warnings, or errors.

### Expected Result
- Image is converted to a supported color depth or a warning is shown.  
- No ingestion errors or data loss occur.
