---
  FII: "TC-CEP-0004"
  groupId: GRP-001
  title: "SCF Control page breadcrumb navigation check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Verify that the breadcrumbs on the SCF Control page navigate correctly.

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/)
  2. Navigate to compliance explorer link.
  3. Wait for page load.
  4. Starting SCF controlmenu Navigation Check.
  5. Capture navigated page title text.
  6. Verify Breadcrumb Container is Visible.
  7. Check Breadcrumb Item 1: Home\n\t\n    \n\t\tSCF Controls
  8. Close-browser
    
  ### Expected Outcome
  -   The breadcrumbs on the SCF Control page  should navigate correctly.