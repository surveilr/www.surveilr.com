<!-- Fleetfolio EAA – Executive Summary Slides -->
<!-- Built for Reveal.js -->

# Fleetfolio EAA  
### Executive Summary  
ExampleCorp, Inc. – ENG-2025-001  
2025-08-15

---

## Purpose

- Evaluate ExampleCorp’s external-facing assets.  
- Identify exposures, outdated technologies, and misconfigurations.  
- Provide prioritized recommendations for remediation.  

---

## Key Findings – Critical

- ❗ Expired TLS certificate on corporate portal.  
- ❗ Critical Remote Code Execution (RCE) vulnerability in public API.  

---

## Key Findings – High

- Database server exposed directly to the internet.  
- Legacy software detected: Apache 2.2, MySQL 5.5.  

---

## Key Findings – Medium

- Outdated WordPress CMS on blog.  
- Clickjacking vulnerabilities across several sites.  

---

## Key Findings – Low / Informational

- Public file server with directory listing enabled.  
- Support for weak TLS protocols (TLS 1.0) and ciphers.  
- Multiple unused or legacy subdomains discovered.  

---

## Risk Assessment

- **Overall Risk:** High  
- **Business Impact:** Compromise of sensitive systems and data possible.  
- **Likelihood:** Elevated, due to outdated and internet-exposed services.  

---

## Recommendations – Immediate

- Renew/replace expired TLS certificate.  
- Patch or mitigate API vulnerability (disable service if necessary).  

---

## Recommendations – Short Term

- Restrict public access to database server.  
- Upgrade or retire outdated Apache/MySQL servers.  
- Patch WordPress and other CMS instances.  

---

## Recommendations – Medium Term

- Decommission or secure unused subdomains.  
- Add HTTP headers to prevent clickjacking.  
- Enforce TLS 1.2+ and disable weak ciphers.  

---

## Conclusion

- ExampleCorp has a **moderate internet footprint**.  
- Several critical and high findings create **elevated risk**.  
- Prioritized remediation of TLS and API issues, plus systematic upgrades, will greatly reduce attack surface.  

---

# Thank You  
Questions?
