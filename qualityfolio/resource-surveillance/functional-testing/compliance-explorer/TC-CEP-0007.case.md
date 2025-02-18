---
FII: "TC-CEP-0007"
groupId: GRP-001
title: "Verify NIST Section Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"
---

### Description

Check that the NIST block is displayed with the following details:
Geography: Universal
Source: SCF
Act: Health Insurance Portability and Accountability Act (HIPAA)
Version: 2024
Published/Last Reviewed Date/Year: 2024-04-01 00:00:00+00

### Steps

1. Check whether the URL get loaded (https://www.surveilr.com/pattern/) then select compliance explorer pattern and click on 'Live demo' button.
2. Wait for page load.
3. Starting SCF controlmenu Navigation Check.
4. Capture navigated page title text.
5. Verify NIST Block title Visibility.
6. Verify NIST Block Visibility.
7. Close-browser

### Expected Outcome

- All information for "NIST" should be displayed accurately
