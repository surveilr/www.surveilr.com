# Fleetfolio EAA – Executive Summary (Sample)

**Customer:** ExampleCorp, Inc.  
**Engagement ID:** ENG-2025-001  
**Date:** 2025-08-15  

---

## Purpose

This assessment was conducted using the Fleetfolio Enterprise Assets Assessment (EAA) runbook to evaluate ExampleCorp’s
externally facing digital footprint. The focus was on identifying potential exposures, outdated technologies, and security
misconfigurations in authorized scope.

---

## Key Findings

- **Critical Issues Identified**
  - An expired TLS certificate on the corporate portal.
  - A critical vulnerability (RCE) detected in the public API service.

- **High-Risk Exposures**
  - A database server accessible from the internet.
  - Legacy web and database software (Apache 2.2, MySQL 5.5).

- **Medium Severity**
  - Outdated WordPress CMS on the public blog.
  - Several sites vulnerable to clickjacking.

- **Low Severity / Informational**
  - Directory listings visible on a file server.
  - Support for weak TLS protocols and ciphers.
  - Multiple unused or legacy subdomains discovered.

---

## Risk Assessment

- **Overall Risk Level:** High  
- **Business Impact:** The critical and high-severity issues could allow attackers to compromise sensitive systems or data.  
- **Likelihood:** Elevated, given the presence of outdated and internet-exposed services.  

---

## Recommendations

1. **Immediate Remediation**
   - Renew and replace the expired TLS certificate.
   - Patch or mitigate the API vulnerability (apply vendor updates or temporarily disable the service if necessary).

2. **Short-Term Actions**
   - Restrict public access to the database server.  
   - Upgrade or retire outdated Apache and MySQL instances.  
   - Apply security patches to WordPress and other CMS platforms.  

3. **Medium-Term Actions**
   - Decommission or secure unused subdomains.  
   - Address clickjacking with appropriate HTTP headers.  
   - Enforce TLS 1.2+ and disable weak ciphers.  

---

## Conclusion

ExampleCorp maintains a moderate internet-facing footprint, but several critical and high-severity findings expose the
organization to elevated risk. By prioritizing remediation of TLS and API vulnerabilities, and systematically addressing
legacy systems and misconfigurations, ExampleCorp can significantly reduce its attack surface.

---
