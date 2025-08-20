# Fleetfolio EAA – Analyst Report (Sample)

This is a **sample analyst report** populated with example findings to illustrate how to use the
Fleetfolio EAA Analyst Report Template. All data below is fictional and for demonstration purposes only.

---

## Customer Information

- **Customer Name:** ExampleCorp, Inc.  
- **Engagement ID / Authorization Ticket:** ENG-2025-001  
- **Date of Assessment:** 2025-08-15  
- **Analyst(s):** Alice Smith, Bob Johnson  

## Scope Summary

- **Domains in Scope:** `example.com`, `example.org`  
- **IP Ranges in Scope:** `203.0.113.0/24`  
- **Key URLs/APIs:** `https://api.example.com/health`, `https://portal.example.org/login`  
- **Exclusions:** `dev.example.com`, `10.0.0.0/8`  

## Executive Summary

The assessment identified a handful of outdated technologies and misconfigured services. Most findings
were of medium severity, with one critical TLS issue related to an expired certificate. The customer’s
attack surface is moderate, but shadow subdomains and exposed administrative endpoints pose risks that
should be addressed quickly.

---

## Detailed Findings

### Subfinder – Subdomain Discovery
- **Artifact:** `/var/fleetfolio/eaa/subfinder/subfinder.jsonl`
- **Summary:** 42 subdomains discovered, including several legacy hosts.  
- **Key Observations:**  
  - `oldmail.example.com` not listed in official inventory.  
  - `vpn.example.org` present despite being excluded from published DNS zones.  
- **Recommendations:** Review and retire unused subdomains to reduce attack surface.

### dnsx – DNS Resolution
- **Artifact:** `/var/fleetfolio/eaa/dnsx/dnsx.jsonl`
- **Summary:** 39/42 subdomains resolved to live IPs.  
- **Key Observations:**  
  - Some subdomains resolve to AWS IPs outside ExampleCorp’s known accounts.  
- **Recommendations:** Confirm ownership of cloud-hosted assets.

### httpx – HTTP Probing
- **Artifact:** `/var/fleetfolio/eaa/httpx/httpx.jsonl`
- **Summary:** 28 live HTTP(S) services identified.  
- **Key Observations:**  
  - `intranet.example.com` exposed publicly with HTTP basic auth.  
  - `files.example.org` returned directory listings.  
- **Recommendations:** Limit access to internal apps, disable directory listing.

### WhatWeb – Technology Fingerprinting
- **Artifact:** `/var/fleetfolio/eaa/whatweb/*.json`
- **Summary:** Detected a mix of Apache, Nginx, and IIS servers.  
- **Key Observations:**  
  - WordPress 5.5 detected on `blog.example.com` (EOL version).  
- **Recommendations:** Upgrade CMS instances to supported versions.

### Naabu – Open Port Scanning
- **Artifact:** `/var/fleetfolio/eaa/naabu/naabu.jsonl`
- **Summary:** Common ports open (80, 443, 22). Unexpected ports (3306, 5900).  
- **Key Observations:**  
  - MySQL (3306) exposed on `db01.example.com`.  
- **Recommendations:** Restrict database access to internal networks only.

### Nmap – Service Enumeration
- **Artifacts:** `/var/fleetfolio/eaa/nmap/services.xml`, `/var/fleetfolio/eaa/nmap/services.json`
- **Summary:** Detected Apache 2.2, OpenSSH 7.2, MySQL 5.5.  
- **Key Observations:**  
  - Apache 2.2 reached end-of-life in 2017.  
- **Recommendations:** Upgrade legacy web and database servers.

### OpenSSL – TLS Certificate Review
- **Artifacts:** `/var/fleetfolio/eaa/tls/*.txt`
- **Summary:** Most certificates valid; one expired.  
- **Key Observations:**  
  - `portal.example.org` certificate expired two months ago.  
- **Recommendations:** Renew and replace expired TLS certificates.

### Nuclei – Vulnerability Templates
- **Artifact:** `/var/fleetfolio/eaa/nuclei/nuclei.jsonl`
- **Summary:** 6 findings across multiple severities.  
- **Key Observations:**  
  - Critical: CVE-2023-12345 (Remote Code Execution) on `api.example.com`.  
  - Medium: Clickjacking on several hosts.  
- **Recommendations:** Patch vulnerable libraries; set proper security headers.

### Katana – Crawled Endpoints (Optional)
- **Artifact:** `/var/fleetfolio/eaa/katana/katana.jsonl`
- **Summary:** 112 additional endpoints discovered.  
- **Key Observations:**  
  - Hidden `/admin/backup` endpoint on `portal.example.org`.  
- **Recommendations:** Protect sensitive endpoints with authentication and authorization.

### tlsx – TLS Metadata (Optional)
- **Artifact:** `/var/fleetfolio/eaa/tls/tlsx.jsonl`
- **Summary:** Identified weak cipher usage on two hosts.  
- **Key Observations:**  
  - TLS 1.0 supported on `legacy.example.com`.  
- **Recommendations:** Disable deprecated protocols and enforce TLS 1.2+.

---

## Risk Ratings

- **Critical:** Expired TLS certificate; Critical RCE CVE on API server.  
- **High:** Database exposed to the internet; outdated Apache and MySQL services.  
- **Medium:** Outdated WordPress; clickjacking.  
- **Low:** Directory listings; unnecessary subdomains.  
- **Informational:** TLS weak ciphers, non-impactful headers.

## Conclusion and Next Steps

ExampleCorp should prioritize addressing the critical API vulnerability and the expired TLS certificate.
Following that, focus on retiring legacy servers, patching outdated CMS instances, and reducing exposed
services. Routine monitoring and asset inventory updates are recommended.

---
