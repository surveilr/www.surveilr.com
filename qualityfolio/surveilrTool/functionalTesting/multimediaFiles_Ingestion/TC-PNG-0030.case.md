---
FII: "TC-PNG-003"
groupId: "GRP-0009"
title: "Upload a corrupted PNG image"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate system stability and logging when uploading a corrupted PNG file.

### Test Steps
1. Prepare a corrupted PNG image (invalid structure or missing chunks).  
2. Upload the file through Surveiler.  
3. Check system behavior and logs during processing.

### Expected Result
- Upload fails gracefully with an appropriate error message.  
- System logs the error and remains stable.
