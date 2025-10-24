---
FII: "TC-JPEG-005"
groupId: "GRP-0009"
title: "Upload JPEG image with unsupported color profile"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate system behavior when ingesting JPEGs with unsupported or uncommon color profiles.

### Test Steps
1. Prepare a JPEG with a non-standard color profile (e.g., CMYK).  
2. Attempt to upload it into Surveiler.  
3. Observe how the system processes or warns about the image.

### Expected Result
- System either converts the image to a supported profile or shows a clear warning.  
- No data corruption occurs.
