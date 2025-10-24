---

FII: "TC-CSV-0027"
groupId: "GRP-0002"
title: "Checksum Comparison"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Compare checksum of output CSV against a baseline for the same dataset.

### Test Steps
1. Generate or obtain a baseline CSV checksum.  
2. Ingest CSV file and generate output checksum.  
3. Compare both checksums.  

### Expected Result
- Checksums match for the same dataset.