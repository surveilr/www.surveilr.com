---
title: What is Resource Surveillance?
description: Introduction to Surveilr, a resource-surveillance CLI tool.
---

### Resource Surveillance & Integration Engine (`surveilr`) for Critical Systems

Organizations in industries such as finance, energy, healthcare,
pharmaceuticals, aerospace, and cybersecurity must aggregate data from multiple
sources to navigate complex evidence-driven decision-making processes and meet
stringent regulatory compliance requirements.

The **Resource Surveillance & Integration Engine**&mdash;more conveniently
referred to as **`surveilr`** (pronounced "_surveiler_")&mdash; is designed to
address modern challenges by providing a centralized platform for evidence
surveillance and data aggregation, enabling organizations to securely collect,
analyze and audit critical evidentiary data from across their systems.

**`surveilr`** is an advanced platform designed to streamline data integration
across your organization, with a special focus on **evidence** data &mdash;
proving whether policies are being followed or whether systems are meeting key
standards. Whether you’re dealing with regulatory requirements, compliance
audits, or patient data privacy, **`surveilr`** makes the complex task of
managing machine attestation data much easier.

💬 [Ask questions about `surveilr` via ChatGPT](https://chatgpt.com/g/g-ra0bKz5rY-surveilr-assistant).
💬 [How does surveilr differ from ESBs, API Connectors, and other Integration Tools?](https://github.com/surveilr/help.surveilr.com/discussions/1)

### How `surveilr` Works

- **Stateful Data Integration**: Unlike simple data transfer tools, `surveilr`
  doesn’t just move information between systems. It stores and organizes data in
  a way that is standardized, making it easy to query and manage.

- **Local-First, Edge-Based**: `surveilr` processes data as close as possible to
  where it is collected—on local devices, laptops, or edge systems. This reduces
  the need for unnecessary data transfers, keeping sensitive data secure by
  handling it locally before sending it to a central location.

- **SQL-Centric**: `surveilr` uses the power of SQL, a universal database
  language, to ensure your data can be accessed, searched, and analyzed
  efficiently.

### Why Does This Matter?

For industries like **regulatory science**, **cybersecurity**, and
**healthcare**, **`surveilr`** ensures that critical data—whether it's
regulatory reports, cybersecurity logs, or patient records—can be managed safely
and efficiently. It supports **secure data transmission** and guarantees that
sensitive information is anonymized or de-identified when needed, helping your
organization remain compliant with **HIPAA**, **GDPR** and other data protection
standards.

### Key Benefits

- **Streamlined Compliance**: `surveilr` ensures that all compliance evidence is
  collected, organized, and ready for audit, saving time and reducing human
  error.

- **Data Security**: `surveilr`’s edge-based approach ensures data stays secure
  by limiting unnecessary movement of sensitive information. Only what’s needed
  is transferred to central servers, reducing exposure and risks.

- **Interoperability**: `surveilr` integrates seamlessly with your existing
  systems, whether it’s email, databases, or software like GitHub or Jira,
  ensuring a smooth exchange of information across platforms.

- **Scalability**: Whether you're handling a small team or a large enterprise,
  `surveilr`’s flexible architecture adapts to your needs, providing a secure,
  efficient solution that grows with your organization.

### Why `surveilr` is So Widely Applicable

One of the key reasons **`surveilr`** is so widely applicable across industries
is because it’s a **complete SQL-based data aggregation and orchestration
platform**. At its core is an opinionated, superbly designed **universal
relational database schema** that can handle content from almost any source.
This powerful schema, coupled with **`surveilr`’s content assembler**, allows it
to support not only industry-neutral formats like:

- **Text**
- **JSON**
- **XML**
- **Excel**
- **Parquet**
- **CSV**

but also industry-specific formats such as:

- **X.12 (Electronic Data Interchange)**
- **HL7 v2 (Healthcare Messaging Standard)**
- **FHIR (Fast Healthcare Interoperability Resources)**

In today’s digital landscape, most of the data that businesses rely on to make
decisions is scattered across a multitude of systems. Data might be locked away
in **emails**, **product lifecycle management (PLM) systems** such as GitHub,
GitLab, Jira, or Asana, or **project management systems** like Trello,
Monday.com, and others. Similarly, **systems of record** such as **Customer
Relationship Management (CRM) systems** (like Salesforce or HubSpot),
**Enterprise Resource Planning (ERP) systems** (like SAP or Oracle), and
**Electronic Health Records (EHRs)** in the healthcare industry house vital
information that’s critical for decision making.

However, this data is not always readily accessible in one place. Pulling
together information from these siloed systems to get a unified view for
decision making is an enormous challenge for most organizations. **`surveilr`**
steps in to bridge this gap by acting as a **universal data aggregator**,
capable of pulling data from multiple, disparate sources and organizing it in a
way that is **instantly queryable**.

A single **edge-based binary** of `surveilr` can securely pull data from these
sources—be it emails, PLM systems, CRMs, ERPs, or specialized industry
formats—and prepare it for **uniform querying** using SQL-friendly tools.
Whether you are trying to aggregate evidence from multiple **SaaS platforms**,
gather information from **log files**, or collate data from a variety of
**knowledgebases** and **local files**, `surveilr` makes it possible to bring
all that information into a cohesive, structured format.

This capability is particularly valuable because it **eliminates the need for
complex data migrations** or manual data extraction efforts, which are often
costly and time-consuming. By supporting both **local-first** processing and
**cloud-based deployments**, `surveilr` provides the flexibility to process
sensitive data behind firewalls, anonymize or clean it if necessary, and then
share or store it securely. The ability to consolidate **human-generated** and
**machine-generated** evidence into a single **uniform format** makes audits,
compliance checks, and decision-making far easier and more effective.

By using `surveilr` as a **universal data aggregator**, businesses can
confidently prepare and share data across internal and external systems with the
peace of mind that it has been properly processed, anonymized, and secured.

Get started with `surveilr` [here](/docs/core/quick-start)