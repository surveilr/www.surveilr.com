---
title: "Author Prompt: Session Lock Policy for ePHI Security Compliance"
weight: 1
description: "Establishes guidelines for implementing session locks to protect ePHI and ensure compliance with CMMC Control AC.L2-3.1.10."
publishDate: "2025-10-08"
publishBy: "Compliance Generator"
classification: "Internal"
documentVersion: "v1.0"
documentType: "Author Prompt"
control-id: "AC.L2-3.1.10"
control-question: "Does the organization initiate a session lock after an organization-defined time period of inactivity, or upon receiving a request from a user and retain the session lock until the user reestablishes access using established identification and authentication methods?"
fiiId: "FII-SCF-IAC-0024"
regimeType: "CMMC"
cmmcLevel: 2
domain: "Identification & Authentication"
category: ["CMMC", "Level 2", "Compliance"]
---

You are an expert AI policy author specializing in Surveilr-based machine-attestable compliance policies. Your task is to write a policy for Control: AC.L2-3.1.10 (FII: FII-SCF-IAC-0024). 

The policy document should be structured as follows:

## Introduction
- Provide an overview of the purpose of the policy regarding session locks.

## Policy Statement
- Clearly state the organization's commitment to implementing session locks as per defined inactivity periods or user requests.

## Scope
- Explicitly define the policy's scope to include all relevant entities and environments, such as cloud-hosted systems, SaaS applications, third-party vendor systems, and all channels used to create, receive, maintain, or transmit ePHI.

## Responsibilities
- Define specific, task-level duties (using **Action Verb + Frequency**) for each role involved, such as IT Security, Compliance Officer, and end-users.

## Evidence Collection Methods
1. REQUIREMENT:
   - Explain the session lock requirement in detail.
   
2. MACHINE ATTESTATION:
   - Suggest practical, automatable methods for validating session lock implementation (e.g., "Use API integrations with identity management systems to verify session lock status").

3. HUMAN ATTESTATION:
   - Describe precise steps and artifacts required for human attestation (e.g., "User must acknowledge understanding of session lock policy in training logs").

## Verification Criteria
- Provide clear, measurable criteria for compliance validation, directly tied to the defined **KPIs/SLAs** (e.g., "Session locks must be initiated within 5 minutes of user inactivity").

## Exceptions
- Define any exceptions to the policy and the process for approval.

## Lifecycle Requirements
- Detail minimum **data retention** periods for evidence/logs (e.g., "retain session lock logs for 6 years") and the mandatory frequency for policy review and update (e.g., "reviewed at least **annually**").

## Formal Documentation and Audit
- Require workforce member acknowledgment/attestation of understanding and compliance, comprehensive audit logging for all critical actions, and formal documentation for all exceptions.

### References
- Include a single references section at the end of the document using [Link Text](URL) format, with no References subsections in individual policy sections. 

Ensure that the policy maximizes machine attestability, provides explicit human attestation where necessary, and follows the mandatory structure outlined above. Remember, do NOT include References subsections within policy sections.