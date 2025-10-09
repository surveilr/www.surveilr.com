# CMMC Scoping in the Cloud Era: Three Level 1 Scenarios

## What Is Scoping, and Why Does It Matter?

For defense contractors, CMMC Level 1 is the entry point to proving compliance with federal cybersecurity rules. It covers 15 basic security requirements drawn from [FAR 52.204-21](https://www.acquisition.gov/far/52.204-21) and is meant to safeguard Federal Contract Information (FCI), which is the routine but still sensitive data shared between contractors and the Department of Defense (DoD).

The very first step in preparing for a CMMC Level 1 self-assessment is scoping. Scoping means defining which people, systems, facilities, and vendors are responsible for processing, storing, or transmitting FCI, and therefore must be assessed against the 15 practices. According to [32 CFR § 170.19](https://www.ecfr.gov/current/title-32/subtitle-A/chapter-I/subchapter-G/part-170/subpart-D/section-170.19):

> “Prior to performing a Level 1 self-assessment, the OSA must specify the CMMC Assessment Scope.”

The rule further clarifies:

* **In scope**: “OSA information systems which process, store, or transmit FCI are in scope for CMMC Level 1 and must be self-assessed against applicable CMMC security requirements.”
* **Out of scope**: “OSA information systems which do not process, store, or transmit FCI are outside the scope for CMMC Level 1. An endpoint hosting a VDI client configured to not allow any processing, storage, or transmission of FCI… is considered out-of-scope.”
* **Specialized assets**: IoT devices, OT, GFE, and similar systems are *not* assessed against Level 1 requirements.
* **Scoping considerations**: "OSAs should consider the people, technology, facilities, and External Service Providers (ESP) within its environment that process, store, or transmit FCI."

That’s the letter of the regulation. But what does it mean in practice? To answer that, let’s walk through three common scenarios, one cloud-based, one with an MSP, and one with internal infrastructure, to see how Level 1 scoping would apply.

## Scenario 1: Cloud Infrastructure

**The setup**:
A 40-person defense contractor has migrated nearly all of its IT into the cloud. The team collaborates using Microsoft 365 for email, file sharing, and project management. SharePoint hosts engineering documents, OneDrive syncs files to local laptops, and Exchange Online handles contract communications with subcontractors.

The decision to go cloud-first was driven by business needs: the contractor wanted to avoid the cost of running on-premises servers, support remote work, and simplify IT management. Leadership assumed that “the cloud is secure” and that vendor certifications would take care of compliance obligations.

**Scoping implications**:

* The Microsoft 365 environment is in scope as an External Service Provider (ESP) that processes FCI. This provider’s compliance posture is already well-documented through public certifications.
* However, every employee laptop ("endpoint") that syncs OneDrive files or sends/receives contract emails is in scope, because FCI is stored or transmitted there.
* Out-of-scope assets include personal devices used only for internet browsing with no FCI access.

**Actionable steps**:

1. **Apply the 15 practices to endpoints, including**:

   * Control system access (AC.L1-B.1.I).
   * Ensure anti-malware is running (SI.L1-B.1.XIII).
   * Keep laptops patched (SI.L1-B.1.XII).
2. **Document facilities and people**: Even if infrastructure is cloud-hosted, the people who access FCI and the facilities they work in are part of scope.
3. **Include ESPs in scope documentation**: Note that Microsoft 365 processes FCI and must be part of your scoping records.
4. **Consider long-term VDI adoption**: A properly configured VDI client keeps FCI within the hosted environment and marks endpoints as out-of-scope. For small firms, this can be a powerful way to shrink audit burden over time. Consult our guide to setting up VDI [here](https://www.opsfolio.com/blog/vdi-azure-csa-cmmc/). 

**Lesson**: Cloud doesn’t eliminate scoping. It reshapes it. Contractors must still apply the 15 controls to endpoints and explicitly document ESPs like Microsoft. The risk of skipping this step is assuming the vendor “does compliance” for you, when in reality the government holds you accountable for your environment.

For cloud-first contractors, Opsfolio CaaS ensures every endpoint is accounted for and evidence from ESPs is integrated into your scoping documentation so nothing falls through the cracks.

## Scenario 2: Managed Service Provider (MSP)

**The setup**:
A 70-person machine shop with multiple DoD contracts outsources IT to a local Managed Service Provider (MSP). The MSP manages Active Directory, maintains email filtering, applies patches, and runs nightly backups. The shop’s leadership likes the model because they don’t have internal IT staff. When asked about compliance, the owner says: “That’s what we pay the MSP for.”

**Scoping implications**:

* The company’s workstations and any on-premises servers storing FCI are in scope.
* The MSP itself is an External Service Provider with administrative access to systems that handle FCI. That makes them part of the scoping considerations.
* Specialized shop-floor equipment (IoT sensors, CNC controllers) is not in scope for Level 1 if it doesn’t store FCI.

**Actionable steps**:

1. **Document the MSP in scope**: Identify them as an ESP with privileged access.
2. **Get contractual assurance**: Confirm in writing that the MSP maintains the 15 Level 1 practices. For example:
   * They enforce unique user IDs (IA.L1-B.1.V).
   * They sanitize or destroy media storing FCI after use (MP.L1-B.1.VII).
   * They update anti-virus and apply patches (SI.L1-B.1.XII).
3. **Maintain local accountability**: Even with an MSP, the contractor must still produce evidence for the self-assessment for example, backup logs or patch reports.

**Lesson**: You cannot outsource responsibility. The MSP can implement and operate controls, but the contractor must show assessors that those controls exist. A weak MSP relationship creates scoping risk: if they don’t document or align practices, your audit suffers.

Opsfolio CaaS fills the gap between MSP service and regulatory proof: our engineers ensure evidence is collected, documented, and ready for audit, even when your MSP is focused on day-to-day IT.

## Scenario 3: Internal Infrastructure

**The setup**:
A 25-person R\&D contractor maintains an on-premises file server in its main office. Engineering data and contract files are stored locally, and employees access them from desktop PCs. The facility also includes IoT devices on the shop floor and government-furnished test equipment. Leadership chose this setup because they wanted complete control over sensitive data, and legacy engineering workflows are tightly tied to the local network.

**Scoping implications**:

* The file server and all desktops that access FCI are in scope.
* The facility itself is in scope, since physical security is part of Level 1.
* IoT devices and government-furnished equipment are specialized assets and not part of the Level 1 assessment scope.

**Actionable steps**:

1. **Apply the 15 practices to desktops and server, including**:

   * Limit access to authorized users (AC.L1-B.1.I).
   * Require strong authentication (IA.L1-B.1.VI).
   * Regularly update software and apply patches (SI.L1-B.1.XII).
2. **Secure the facility**: Control access to server rooms and office spaces (PE.L1-B.1.VIII).
3. **Document out-of-scope systems**: Create a simple diagram that shows IoT and test equipment are logically separated and don’t store FCI.

**Lesson**: Scoping includes people and facilities, not just IT systems. Specialized assets don’t need to be assessed, but you must clearly demonstrate they don’t process FCI. Documentation is as important as controls.

Opsfolio CaaS centralizes evidence and diagrams for internal setups, so when the assessor asks where FCI lives, you have one clean package ready to present.

## Scoping as the Foundation of Level 1

CMMC Level 1 scoping is straightforward but essential. You must identify all systems that handle FCI, exclude those that don’t, and consider specialized assets, people, facilities, and ESPs. Each of the scenarios above illustrates how different business models change what’s in scope and how the 15 practices apply.

The cost of getting scoping wrong isn’t abstract. Over-scoping leads to wasted effort and inflated audit costs, while under-scoping creates compliance gaps that put contracts at risk. And CEOs should remember: they are ultimately responsible for the accuracy of their compliance attestations. Misrepresentation could expose the company and its leadership to liability under the False Claims Act.

At Opsfolio CaaS, we don’t just advise; our engineers own the compliance process. We help with policy authoring, scoping documentation, and evidence centralization, and we stay engaged until certification is passed. For contractors without a compliance team, Opsfolio makes the difference between uncertainty and confidence.

---

## Quick Action Checklist

* [ ] **Identify FCI flows**: Map where contract information is processed, stored, or transmitted.
* [ ] **Classify assets**: Separate in-scope systems (handling FCI) from out-of-scope and specialized assets.
* [ ] **List ESPs**: Document cloud providers and MSPs that touch FCI. Confirm their compliance posture.
* [ ] **Apply the 15 practices**: Ensure that every in-scope system meets the basic CMMC controls.
* [ ] **Document exclusions**: Create diagrams or notes to prove why certain systems are out of scope.
* [ ] **Centralize evidence**: Collect policies, logs, and diagrams in one place to prepare for self-assessment.
