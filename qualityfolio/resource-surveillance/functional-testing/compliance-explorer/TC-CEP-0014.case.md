---
  FII: "TC-CEP-0014"
  groupId: GRP-001
  title: "NIST Detail View Links navigation check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Verify that NIST Detail View Links navigate properly and the title "NIST Controls" is visible on the NIST Controls Detail View Links navigation page.

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/).
  2. Navigate to compliance explorer link.
  3. Starting SCF controlmenu Navigation Check.
  4. Capture navigated page title text.
  5. Starting NIST Detail View Navigation Check.
  6. Capture navigated page title text.
  7. Close-browser

  ### Expected Outcome
  -   Clicking "Detail View" should open additional information or a new page with details for the NIST compliance standard.