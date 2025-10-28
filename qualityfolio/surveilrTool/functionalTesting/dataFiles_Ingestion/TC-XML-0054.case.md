---
FII: "TC-XML-0054"
groupId: "GRP-0002"
title: "Unsupported File Extension Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Ensure ingestion fails for non-XML files renamed with `.xml` extension.

### Test Steps
1. Rename a non-XML file (e.g., CSV) to `.xml`.  
2. Run `surveilr ingest files --file fake.xml`.  

### Expected Result
- Exit code ≠ 0; error indicates invalid XML file.
