---
FII: "TC-PDF-00027
groupId: "GRP-0005"
title: "Handle Scanned PDF (Image-based) Files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PDF"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Ensure Surveilr can process image-based scanned PDFs and extract basic metadata successfully.

### Test Steps
1. Upload a scanned PDF file (image-based).  
2. Wait for the system to parse the document.  
3. Observe the extracted metadata and content preview.  

### Expected Result
- File uploads successfully.  
- Surveilr identifies the document as scanned (image-based).  
- Metadata (title, size, page count) is captured even if text is not extractable.
