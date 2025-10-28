---
FII: "TC-JPEG-003"
groupId: "GRP-0009"
title: "Upload a corrupted JPEG image"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["JPEG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate how the system handles ingestion of corrupted JPEG files without crashing.

### Test Steps
1. Prepare a corrupted JPEG image (invalid header or truncated data).  
2. Attempt to upload it through the Surveiler interface.  
3. Monitor logs and system behavior during ingestion.

### Expected Result
- Upload fails gracefully with a proper error message.  
- System logs the error and remains stable.
