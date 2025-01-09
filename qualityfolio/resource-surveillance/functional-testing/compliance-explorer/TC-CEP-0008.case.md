---
FII: "TC-CEP-0008"
groupId: GRP-001
title: "US HIPAA Detail View Links navigation check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"
---

### Description

Verify that US HIPAA Detail View Links navigate properly and verify that the title "US HIPAA Controls" is visible on the US HIPAA Detail View Links navigation page.

### Steps

1. Check whether the URL get loaded (https://www.surveilr.com/pattern/) then select compliance explorer pattern and click on 'Live demo' button.
2. Wait for page load.
3. Starting SCF controlmenu Navigation Check.
4. Capture navigated page title text.
5. Starting US HIPAA Detail View Navigation Check.
6. Capture navigated page title text.
7. Close-browser

### Expected Outcome

- Clicking "Detail View" should open additional information or a new page with details for the US HIPAA compliance standard.
