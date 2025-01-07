---
  FII: "TC-CEP-0011"
  groupId: GRP-001
  title: "US HIPAA Controls Tables-Title sorting check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Ensure that sorting functionality associated with control code, title, domain, control description, requirement are functioning properly on US HIPAA Controls page

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/).
  2. Navigate to compliance explorer link.
  3. Starting SCF controlmenu Navigation Check.
  4. Capture navigated page title text.
  5. Navigate to the US HIPAA Detail View page.
  6. Sort the Title column in ascending order.
  7. Sort the Title column in descending order.
  8. Close-browser

  ### Expected Outcome
  -   Sorting should work correctly, allowing users to sort controls by different criteria.