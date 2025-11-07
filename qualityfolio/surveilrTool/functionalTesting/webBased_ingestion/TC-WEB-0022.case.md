---
FII: "TC-WEB-0022"
groupId: "GRP-0008"
title: "Ingest Website with Broken Links"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["WEB"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify ingestion when the website contains broken or dead links.

### Test Steps
1. Provide website with pages containing broken links. 
 curl -o ./broken_links_page.html https://www.eddymens.com/blog/page-with-broken-pages-for-testing-53049e870421
2. Ingest the downloaded page using Surveilr
surveilr ingest ./broken_links_page.html
 
### Expected Result
- Pages ingested successfully.  
- Broken links logged but do not block ingestion.
