---
FII: "TC-PNG-006"
groupId: "GRP-0009"
title: "Upload PNG with missing metadata"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---

### Description
- Validate PNG ingestion behavior when metadata fields are missing or incomplete.

### Test Steps
1. Prepare a PNG image with stripped or missing metadata.  
2. Upload through the Surveiler ingestion interface.  
3. Review stored metadata after upload.

### Expected Result
- Image is successfully ingested.  
- System assigns default metadata automatically.
