---
FII: "TC-YML-0055"
groupId: "GRP-0002"
title: "Parse Multiple YAML Documents in Single File"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["YAML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate Surveilr can handle multiple YAML documents in a single file.

### Test Steps
1. Prepare a YAML file with multiple `---` separated documents.  
2. Run `surveilr ingest files --file multi_docs.yaml`.  

### Expected Result
- All documents are parsed correctly; exit code `0`; logs confirm all documents processed.
