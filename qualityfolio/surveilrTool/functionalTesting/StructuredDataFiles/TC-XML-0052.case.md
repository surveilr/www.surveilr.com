---
FII: "TC-XML-0052"
groupId: "GRP-0002"
title: "Large XML File Performance"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["XML"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Test performance and correctness with a very large XML file.

### Test Steps
1. Prepare a large XML file (thousands of nodes).  
2. Run `surveilr ingest files --file large.xml`.  

### Expected Result
- Exit code `0`; all nodes parsed; performance acceptable.
