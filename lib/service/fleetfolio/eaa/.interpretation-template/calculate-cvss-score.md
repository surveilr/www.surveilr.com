# CVSS 4.0 Score Calculation

> This document explains each CVSS 4.0 metric in depth, gives guidance and examples for choosing values, and describes how to capture evidence and calculate/interpret the final score. Use this as a checklist when building a vulnerability finding to ensure the CVSS rating is accurate, repeatable, and defensible.

## Exploitability Metrics (how an attacker reaches and uses the vulnerability)
For each metric below include: **chosen value**, **rationale (short)**, and **evidence (logs/PoC/screenshots)**.

- **Attack Vector:** *(Network / Adjacent / Local / Physical)*  
  - **Guidance:** Choose the broadest location from which an attacker can perform the exploit.  
    - *Network* — Exploitable remotely over the internet or WAN (e.g., public webapp RCE, exposed API).  
    - *Adjacent* — Requires network adjacency (same VLAN/subnet, Bluetooth range, ARP poisoning).  
    - *Local* — Must have local access or an account on the host (e.g., local file parsing bug).  
    - *Physical* — Requires physical access to device/hardware (e.g., bootloader bypass, USB attack).  
  - **Example:** `Network` — vulnerability accessible via public API endpoint.  
  - **Evidence:** Endpoint URL, screenshots of remote exploit attempt, request/response logs.

- **Privileges Required:** *(None / Low / High)*  
  - **Guidance:** What level of privileges does the attacker need before exploitation? Consider default/least-privileged accounts as "Low".  
    - *None* — no credentials required.  
    - *Low* — a non-privileged or ordinary user account.  
    - *High* — administrative/root-level credentials.  
  - **Example:** `Low` — attacker must be an authenticated user to trigger the bug (regular account).  
  - **Evidence:** Account role used in PoC, access control policy snippets, authentication logs.

- **Attack Complexity:** *(Low / High)*  
  - **Guidance:** Does exploitation require special conditions, unusual configuration, race conditions, or precise timing?  
    - *Low* — straightforward exploitation, works reliably across default configurations.  
    - *High* — requires specific environment, user timing, or rare preconditions.  
  - **Example:** `High` — exploit only works when service X is in debug mode and a race window is present.  
  - **Evidence:** Steps to reproduce showing fragility, failure/success rates.

- **User Interaction:** *(None / Passive / Active)*  
  - **Guidance:** Does exploitation require a legitimate user to take an action? If yes, how involved?  
    - *None* — no user involved (server-side RCE triggered by external input).  
    - *Passive* — user must do a low-effort action (open a file, view content) but not knowingly facilitate the attack.  
    - *Active* — user must perform an explicit/targeted action (click a link in email, accept a prompt).  
  - **Example:** `Passive` — user needs only to open a crafted document in a viewer.  
  - **Evidence:** Phishing email sample, PoC demonstrating action required.

- **Attack Requirements:** *(None / Present)*  
  - **Guidance:** Are additional preconditions required beyond the above (e.g., physical token present, prior compromise, specific OS patch level)?  
    - *None* — no special environmental requirements.  
    - *Present* — extra requirements exist; describe them clearly.  
  - **Example:** `Present` — requires the victim to have an outdated plugin installed (version X.Y).  
  - **Evidence:** Plugin version checks, environmental scan showing required state.

## Vulnerable System Impact Metrics (immediate impact on the vulnerable component)
For each metric state: **selected value**, **explanation of impacted confidentiality/integrity/availability**, and **evidence**.

- **Confidentiality:** *(None / Low / High)*  
  - **Guidance:** Does exploitation allow disclosure of sensitive information stored/accessible by the vulnerable component?  
    - *None* — no confidentiality impact.  
    - *Low* — limited data exposure or partial disclosure of non-sensitive fields.  
    - *High* — full disclosure of sensitive data (PII, credentials, secrets).  
  - **Example:** `High` — exploit returns database dump with customer PII.  
  - **Evidence:** Sample redacted data, query results, file listings.

- **Integrity:** *(None / Low / High)*  
  - **Guidance:** Does the vulnerability permit modification, corruption, or tampering with data or code on the vulnerable component?  
    - *None* — no integrity impact.  
    - *Low* — limited/moderate ability to alter non-critical data.  
    - *High* — complete alteration or replacement of critical data or code (e.g., altering transaction records).  
  - **Example:** `High` — attacker can modify billing records to change amounts.  
  - **Evidence:** PoC demonstrating write/update operations, logs showing modified entries.

- **Availability:** *(None / Low / High)*  
  - **Guidance:** Does exploitation degrade or deny service for the vulnerable component?  
    - *None* — no availability impact.  
    - *Low* — limited disruption (performance degradation, temporary errors).  
    - *High* — complete denial of service of a critical function.  
  - **Example:** `Low` — exploit causes intermittent crashes requiring a service restart.  
  - **Evidence:** Crash logs, resource utilization graphs during PoC.

## Subsequent System Impact Metrics (impact to other systems beyond the vulnerable component)
These capture how the vulnerability enables compromise of neighboring or dependent systems.

- **Confidentiality:** *(None / Low / High)*  
  - **Guidance:** Can the exploit be pivoted to access sensitive data on other systems? Consider lateral movement and data exfiltration paths.  
  - **Example:** `High` — compromised host contains credentials that unlock database servers.  
  - **Evidence:** Harvested credentials, successful access to downstream resources.

- **Integrity:** *(None / Low / High)*  
  - **Guidance:** Can attacker tamper with data or processes on additional systems (e.g., modify ledger entries, tamper with CI/CD pipelines)?  
  - **Example:** `Low` — attacker can modify logs on adjacent hosts but not business-critical data.  
  - **Evidence:** Demonstrated remote commands altering files on other hosts.

- **Availability:** *(None / Low / High)*  
  - **Guidance:** Could exploitation lead to denial or degradation of services beyond the vulnerable component (e.g., cluster-wide outage)?  
  - **Example:** `High` — exploit allows deletion of database replicas, resulting in cluster unavailability.  
  - **Evidence:** Cluster state changes, deletion events, outage simulation logs.

## Vector (CVSS vector string & supporting info)
- **Construct the Vector String:**  
  - Build the standard CVSS 4.0 vector using selected metrics. Example format (illustrative):  
    ```
    CVSS:4.0/AV:N/PR:L/AC:H/UI:Passive/AR:Present/IS:.../SS:...
    ```  
  - Include the exact string in your finding so readers and tools can reproduce the score calculation.

- **Supporting Notes:**  
  - Provide a short paragraph explaining how you derived each metric, referencing evidence. This makes the score defensible to auditors and clients.  
  - Note any assumptions or uncertainties (e.g., “Assumed default configuration; if MFA enforced, PR would be None”).

## Scoring, Severity Interpretation & Reporting Guidance

- **How the score is calculated:**  
  - CVSS 4.0 uses the selected Exploitability + Impact + Subsequent Impact metrics to compute a base score. Document the final numeric base score and derived severity band (e.g., None, Low, Medium, High, Critical) per CVSS 4.0 thresholds.  
  - If Temporal or Environmental metrics are being used, clearly list them and show adjusted scores.

- **Severity guidance (example bands):**  
  - *None:* 0.0  
  - *Low:* 0.1 – 3.9  
  - *Medium:* 4.0 – 6.9  
  - *High:* 7.0 – 8.9  
  - *Critical:* 9.0 – 10.0  
  > (Confirm threshold mapping against official CVSS 4.0 guidance used by your org.)

- **Document assumptions & configuration dependencies:**  
  - If the rating depends on a specific configuration (e.g., default install, admin console enabled), highlight it. Provide an alternative score when the environment differs.

## Examples (sample filled vectors)

1. **Public API RCE returning DB records**  
   - AV: Network, PR: None, AC: Low, UI: None, AR: None  
   - Vulnerable System Impact: C=High, I=High, A=High  
   - Subsequent Impact: C=High, I=High, A=High  
   - **Vector (example):** `CVSS:4.0/AV:N/PR:N/AC:L/UI:N/AR:N/VS:C,H,H/SS:C,H,H`  
   - **Notes:** Remote unauthenticated RCE allowed database dump. Evidence: sanitized dump hash, PoC request.

2. **Authenticated file upload parsing bug requiring user to open file**  
   - AV: Network, PR: Low, AC: High, UI: Passive, AR: Present (specific plugin)  
   - Vulnerable System Impact: C=Low, I=Low, A=None  
   - Subsequent Impact: C=None, I=Low, A:Low  
   - **Vector (example):** `CVSS:4.0/AV:N/PR:L/AC:H/UI:Passive/AR:Present/VS:L,L,N/SS:N,L,L`  
   - **Notes:** Requires authenticated user and specific plugin version; less severe, but viable in targeted scenarios.

---
