---
FII: "TC-JPEG-008"
groupId: "GRP-0009"
title: "Upload JPEG with special characters in filename"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---

### Description
- Validate filename handling and encoding for JPEG uploads containing special characters.

### Test Steps
1. Prepare a valid JPEG image with special characters in its filename (e.g., `test@#$.jpeg`).  
2. Upload it through Surveiler.  
3. Verify that the image is correctly displayed and logged.

### Expected Result
- Image is successfully ingested without filename errors.  
- Filename with special characters is preserved and displayed properly.
