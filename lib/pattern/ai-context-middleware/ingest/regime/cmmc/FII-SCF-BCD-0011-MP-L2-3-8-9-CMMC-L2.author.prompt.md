---
title: "Author Prompt: Data Backup and Integrity Verification Policy"
weight: 1
description: "Establishes a framework for recurring data backups and integrity verification to ensure operational continuity and compliance with recovery objectives."
publishDate: "2025-09-29"
publishBy: "CMMC Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "MP.L2-3.8.9"
control-question: "Does the organization create recurring backups of data, software and/or system images, as well as verify the integrity of these backups, to ensure the availability of the data to satisfying Recovery Time Objectives (RTOs) and Recovery Point Objectives (RPOs)?"
fiiId: "FII-SCF-BCD-0011"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Business Continuity & Disaster Recovery"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: MP.L2-3.8.9 (FII: FII-SCF-BCD-0011). 

The policy document must follow this structure:

## Introduction
- Provide an overview of the policy and its importance in ensuring data availability.

## Policy Statement
- Clearly state the organization's commitment to creating recurring backups and verifying their integrity.

## Scope
- Define the scope of the policy, explicitly including all relevant entities and environments such as cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit data.

## Responsibilities
- Define specific, task-level duties for each role involved in the backup process, using **Action Verb + Frequency** format.

## Evidence Collection Methods
1. REQUIREMENT:
   - Explain the control requirement regarding backups and integrity verification.
   
2. MACHINE ATTESTATION:
   - Suggest practical, automatable methods for evidence collection, such as using automated scripts to verify backup integrity and ingesting logs into Surveilr.

3. HUMAN ATTESTATION:
   - Describe the exact actions, artifacts, and ingestion methods for human attestations, such as a manager signing off on backup verification reports.

## Verification Criteria
- Provide clear, measurable criteria for compliance validation, directly tied to the **KPIs/SLAs** defined in the previous section.

## Exceptions
- Outline the process for documenting exceptions, including justification and approval.

## Lifecycle Requirements
- Detail the **Data Retention** periods for evidence and the mandatory frequency for policy review and update (**Annual Review**).

## Formal Documentation and Audit
- Require workforce member acknowledgment of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

### References
- Include a single References section at the end of the document, ensuring that no References subsections appear within individual policy sections. 

Ensure that the policy maximizes machine attestability by providing concrete examples of automated evidence collection and verification methods. All sections must be clear, robust, and compliant with the requirements outlined, with a focus on operational detail and specificity.