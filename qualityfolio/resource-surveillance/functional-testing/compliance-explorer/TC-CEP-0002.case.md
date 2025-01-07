---
  FII: "TC-CEP-0002"
  groupId: GRP-001
  title: "Compliance Explorer Dashboard Load Validation"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Verify there are 4 controls loaded on the page:
  1. SCF Controls
  2. Orchestration
  3. Uniform Resource
  4. RSSD Console

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/).
  2. Navigate to compliance explorer link.
  3. Wait for page load.
  4. Count dashboard menu items.
  5. Check subtitle: SCF Controls.
  6. Check subtitle: Orchestration.
  7. Check subtitle: Uniform Resource.
  8. Check subtitle: Console.
  9. Close-browser.

  ### Expected Outcome
  -   All four controls (SCF Controls, Orchestration, Uniform Resource, RSSD Console) should be visible and properly loaded on the page. 