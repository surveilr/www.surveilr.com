---
  FII: "TC-CEP-0008"
  groupId: GRP-001
  title: "US HIPAA Detail View Links navigation check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Verify that US HIPAA Detail View Links navigate properly and verify that the title "US HIPAA Controls" is visible on the US HIPAA Detail View Links navigation page.

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/)
  2. Navigate to compliance explorer link.
  3. Wait for page load.
  4. Starting SCF controlmenu Navigation Check.
  5. Capture navigated page title text.
  6. Starting US HIPAA Detail View Navigation Check.
  7. Capture navigated page title text.
  8. Close-browser

  ### Expected Outcome
  -   Clicking "Detail View" should open additional information or a new page with details for the US HIPAA compliance standard.