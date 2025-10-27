---
FII: "TC-JPEG-006"
groupId: "GRP-0009"
title: "Upload JPEG with missing metadata"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate system handling of JPEG uploads missing metadata such as EXIF or GPS tags.

### Test Steps
1. Prepare a JPEG image stripped of metadata.  
2. Upload it through the Surveiler ingestion interface.  
3. Check how metadata is displayed post-ingestion.

### Expected Result
- Image is successfully ingested.  
- System assigns default metadata where missing.
