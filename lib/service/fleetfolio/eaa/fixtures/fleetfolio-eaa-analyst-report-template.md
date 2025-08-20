# Fleetfolio EAA – Analyst Report Template

This template is intended to help analysts structure their findings after running the
`fleetfolio-eaa-pentest-lite.runme.md` runbook. Copy this template into your preferred format
(Markdown, Word, etc.) and fill in details as you analyze each artifact.

---

## Customer Information

- **Customer Name:**  
- **Engagement ID / Authorization Ticket:**  
- **Date of Assessment:**  
- **Analyst(s):**  

## Scope Summary

- **Domains in Scope:**  
- **IP Ranges in Scope:**  
- **Key URLs/APIs:**  
- **Exclusions:**  

## Executive Summary

Provide a non-technical summary of key findings, their impact, and high-level recommendations.

---

## Detailed Findings

### Subfinder – Subdomain Discovery
- **Artifact:** `/var/fleetfolio/eaa/subfinder/subfinder.jsonl`
- **Summary:** (Number of subdomains found, unexpected assets, shadow IT indications)
- **Key Observations:**  
  -  
  -  
- **Recommendations:**  

### dnsx – DNS Resolution
- **Artifact:** `/var/fleetfolio/eaa/dnsx/dnsx.jsonl`
- **Summary:** (Resolvable domains, IP mapping, unexpected third-party infrastructure)
- **Key Observations:**  
  -  
- **Recommendations:**  

### httpx – HTTP Probing
- **Artifact:** `/var/fleetfolio/eaa/httpx/httpx.jsonl`
- **Summary:** (Live web services, response codes, titles, headers)
- **Key Observations:**  
  -  
- **Recommendations:**  

### WhatWeb – Technology Fingerprinting
- **Artifact:** `/var/fleetfolio/eaa/whatweb/*.json`
- **Summary:** (CMS/framework versions, outdated technologies)
- **Key Observations:**  
  -  
- **Recommendations:**  

### Naabu – Open Port Scanning
- **Artifact:** `/var/fleetfolio/eaa/naabu/naabu.jsonl`
- **Summary:** (Open ports, unexpected services)
- **Key Observations:**  
  -  
- **Recommendations:**  

### Nmap – Service Enumeration
- **Artifacts:** `/var/fleetfolio/eaa/nmap/services.xml`, `/var/fleetfolio/eaa/nmap/services.json`
- **Summary:** (Detected service versions, risky protocols)
- **Key Observations:**  
  -  
- **Recommendations:**  

### OpenSSL – TLS Certificate Review
- **Artifacts:** `/var/fleetfolio/eaa/tls/*.txt`
- **Summary:** (Certificate validity, SANs, weak algorithms)
- **Key Observations:**  
  -  
- **Recommendations:**  

### Nuclei – Vulnerability Templates
- **Artifact:** `/var/fleetfolio/eaa/nuclei/nuclei.jsonl`
- **Summary:** (Findings by severity, matched templates)
- **Key Observations:**  
  -  
- **Recommendations:**  

### Katana – Crawled Endpoints (Optional)
- **Artifact:** `/var/fleetfolio/eaa/katana/katana.jsonl`
- **Summary:** (Discovered paths, APIs, hidden endpoints)
- **Key Observations:**  
  -  
- **Recommendations:**  

### tlsx – TLS Metadata (Optional)
- **Artifact:** `/var/fleetfolio/eaa/tls/tlsx.jsonl`
- **Summary:** (Structured TLS insights, ciphers, protocols)
- **Key Observations:**  
  -  
- **Recommendations:**  

---

## Risk Ratings

Summarize issues by severity level:

- **Critical:**  
- **High:**  
- **Medium:**  
- **Low:**  
- **Informational:**  

## Conclusion and Next Steps

Provide a wrap-up of the assessment, remediation guidance, and recommended follow-ups.

---
