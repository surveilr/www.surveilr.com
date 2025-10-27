# New Engagement

## Engagement Details

- **Name:**  
  The formal name of the engagement, typically a project code, contract identifier, or descriptive label.  
  *Example:* "Red Team Simulation – Q1 2025", "PCI-DSS Web Application Penetration Test", or "Advanced Persistent Threat (APT) Simulation Exercise."  
  The name should align with internal tracking systems, statements of work (SOW), or client references.  

- **Client:**  
  Full legal name of the client organization. Include relevant business units, subsidiaries, or specific departments in scope.  
  *Example:* "Acme Corporation – Global IT Division", "BankXYZ – Retail Banking Operations."  
  This ensures clarity when multiple entities or subsidiaries are involved.  

- **Test Window:**  
  Exact duration of the engagement, including start and end dates. Specify testing hours if there are operational restrictions (e.g., business hours only, after-hours allowed, 24/7 permissible).  
  *Example:* "01 March 2025 – 15 March 2025, with permitted testing Monday–Friday, 7 PM–7 AM (off-peak hours)."  

- **Type of Test:**  
  Clearly state the nature of the engagement, such as:  
  - External Network Penetration Test  
  - Internal Network Penetration Test  
  - Red Team Engagement (full-scope adversary simulation)  
  - Web Application Penetration Test  
  - Mobile Application Security Test (Android/iOS)  
  - Social Engineering Assessment (phishing, vishing, physical access)  
  - Cloud Security Assessment (Azure, AWS, GCP)  
  This classification determines methodology and resource allocation.  

- **Objective:**  
  The high-level purpose of the engagement.  
  *Examples:*  
  - Assess the resilience of %%CLIENT_NAME%% against targeted external attacks.  
  - Test Blue Team’s ability to detect and respond to simulated adversary behavior.  
  - Validate the security of core banking applications and identify vulnerabilities before exploitation by real-world attackers.  
  - Ensure compliance with PCI-DSS, HIPAA, or other regulatory frameworks.  
  Objectives should be SMART (Specific, Measurable, Achievable, Relevant, Time-bound).  

- **Scope:**  
  Explicit list of systems, applications, networks, or environments included in testing. Define:  
  - Domains, subdomains, and URLs (e.g., `portal.client.com`, `api.client.com/v1/*`).  
  - IP ranges (e.g., `192.168.10.0/24`).  
  - Cloud environments (e.g., AWS production tenant).  
  - Internal assets reachable through VPN or on-site testing.  
  - Out-of-scope assets (to avoid disruption or unauthorized testing).  
  This section must be as precise as possible to prevent scope creep or ambiguity.  

- **Credentials/Access Information:**  
  Any pre-shared credentials, test accounts, VPN tokens, or API keys provided by the client for authenticated testing.  
  - *Example:* "Two non-privileged domain accounts for internal testing, one admin account for validation of privilege escalation attempts."  
  If no credentials are provided, explicitly state “Black-box testing – no credentials supplied.”  
  Secure storage and handling procedures must be followed (e.g., passwords stored in encrypted vaults, limited team access).  

- **Special Instructions/Restrictions:**  
  Client-provided limitations, operational considerations, or testing rules of engagement.  
  *Examples:*  
  - “No denial-of-service testing permitted.”  
  - “Avoid testing production payment gateways between 9 AM – 6 PM IST.”  
  - “Report all critical findings within 24 hours of discovery.”  
  - “Use only client-approved IP ranges for external testing.”  
  - “Phishing campaigns must exclude executive leadership.”  
  These restrictions balance security objectives with business continuity and safety.  
