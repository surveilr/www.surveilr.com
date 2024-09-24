---
title: "FHIR Explorer"
description: "HL7 FHIR Content Aggregator and Explorer"
main:
  id: 1
  content: |
    The FHIR Explorer Pattern for surveilr ingests healthcare FHIR JSON files and allows querying, quality metrics, and exploration of those files.
  imgCard: "@/images/pattern/fhir-explorer-pattern-ss-1.avif"
  imgMain: "@/images/pattern/fhir-explorer-pattern.avif"
  imgAlt: "FHIR Explorer"
tabs:
  - id: "tabs-with-card-item-1"
    dataTab: "#tabs-with-card-1"
    title: "Overview"
  - id: "tabs-with-card-item-2"
    dataTab: "#tabs-with-card-2"
    title: "Capabilities"
  - id: "tabs-with-card-item-3"
    dataTab: "#tabs-with-card-3"
    title: "Screenshots"
longDescription:
  title: "HL7 FHIR Content Aggregator and Explorer"
  subTitle: |
    The FHIR Explorer Pattern for surveilr ingests healthcare FHIR JSON files and allows querying, quality metrics, and exploration of those files. surveilr ingests healthcare FHIR data (represented as JSON files), stores it securely in a local SQL database, prepares SQL views for convenient querying, generates metrics of the FHIR content, and has an easy to use Web UI with options to filter, search, and visualize various healthcare records.
  btnTitle: "Use the SQL"
  btnURL: "/lib/pattern/fhir-explorer/package.sql"
descriptionList:
  - title: "Explore FHIR data"
    subTitle: "Easily search, filter, and interact with healthcare records in FHIR format."
  - title: "Quality Assurance"
    subTitle: "Ensure FHIR data meets your organization's standards with built-in checks."
  - title: "Visualize insights"
    subTitle: "Quickly analyze healthcare records with intuitive tools and data quality and compliance with real-time metrics and reporting."
specificationsLeft:
  - title: "Multiple FHIR versions"
    subTitle: "Ingests FHIR JSON files conforming to FHIR versions R4 and DSTU2, ensuring compatibility with the most widely adopted healthcare data standards."
  - title: "Wide resource coverage"
    subTitle: "Ingests a wide range of FHIR resources, including Patient, Observation, Encounter, MedicationRequest, Practitioner, Condition, and Procedure."
  - title: "Handles large data volumes"
    subTitle: "Supports batch ingestion to handle large volumes of FHIR data efficiently in a local workstation or server."
  - title: "Automatic schema validation"
    subTitle: "Validates FHIR resources against FHIR schema definitions, ensuring structural and standards compliance."
specificationsRight:
  - title: "Ingests FHIR bundles"
    subTitle: "Supports ingestion of FHIR Bundles, including Transaction and Searchset types, enabling batch data imports and API-driven retrieval."
  - title: "Advanced metadata indexing"
    subTitle: "Extracts and indexes metadata such as resource identifiers, timestamps, and provenance information for querying and audit trails."
  - title: "Supports custom mappings"
    subTitle: "Allows for custom mappings and transformations to align non-standard FHIR implementations with the core schema."
  - title: "Extension and profile exploration"
    subTitle: "Provides full access to FHIR extensions and profiles for custom elements and jurisdiction-specific constraints."
blueprints:
  first: "@/images/pattern/fhir-explorer-pattern-ss-3.avif"
  second: "@/images/pattern/fhir-explorer-pattern-ss-1.avif"
---
