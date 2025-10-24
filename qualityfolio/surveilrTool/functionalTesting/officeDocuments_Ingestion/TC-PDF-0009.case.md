---
FII: "TC-PDF-0009"
groupId: "GRP-0005"
title: "Validate PDF with Embedded Media and Links"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PDF"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Ensure Surveilr correctly handles PDFs that contain embedded media (audio, video) and hyperlinks.

### Test Steps
1. Upload a PDF containing hyperlinks and embedded multimedia.  
2. Monitor the parsing process and preview rendering.  
3. Inspect the metadata and verify embedded content detection.  

### Expected Result
- Upload succeeds without parsing errors.  
- Embedded media and hyperlinks are recognized in metadata.  
- Surveilr does not attempt to render or execute embedded content.
