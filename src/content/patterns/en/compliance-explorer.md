---
title: "Compliance Explorer"
description: "Web-based user interface that lists and displays SCF controls Aggregator and Explorer"
main:
  id: 8
  content: |
    The Compliance Explorer Pattern for surveilr ingests SCF controls and create a web-based user interface that lists and displays SCF controls Aggregator and Explorer.
  imgCard: "@/images/pattern/compliance-explorer-pattern-ss-1.avif"
  imgMain: "@/images/pattern/compliance-explorer-pattern-ss-2.avif"
  imgAlt: "Compliance Explorer"
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
  title: "Compliance Content Aggregator and Explorer"
  subTitle: |
    The compliance Explorer Pattern for surveilr ingests SCF data files and allows querying, quality metrics, and exploration of those files. surveilr ingests SCF data (represented as CSVfiles), stores it securely in a local SQL database, prepares SQL views for convenient querying, generates metrics of the FHIR content, and has an easy to use Web UI with options to filter, search, and visualize various healthcare records.
  btnTitle: "Use the SQL"
  btnURL: "/lib/pattern/compliance-explorer/package.sql"
descriptionList:
  - title: "Explore SCF data"
    subTitle: "Easily search, filter, and interact with SCF Controls in CSV dowladable format."
  - title: "Quality Assurance"
    subTitle: "Ensure SCF Controls data meets your organization's standards with built-in checks."
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
    subTitle: "Validates SCF Controls definitions, ensuring structural and standards compliance."
specificationsRight:
  - title: "Ingests SCF bundles"
    subTitle: "Supports ingestion of SCF Bundles, including Transaction and Searchset types, enabling batch data imports and API-driven retrieval."
  - title: "Advanced metadata indexing"
    subTitle: "Extracts and indexes metadata such as resource identifiers, timestamps, and provenance information for querying and audit trails."
  - title: "Supports custom mappings"
    subTitle: "Allows for custom mappings and transformations to align non-standard FHIR implementations with the core schema."
  - title: "Extension and profile exploration"
    subTitle: "Provides full access to FHIR extensions and profiles for custom elements and jurisdiction-specific constraints."
blueprints:
  first: "@/images/pattern/compliance-explorer-pattern-ss-3.avif"
  second: "@/images/pattern/compliance-explorer-pattern-ss-1.avif"
liveDemo:
  btnTitle: "Live Demo"
  btnURL: "https://eg.surveilr.com/lib/pattern/compliance-explorer/"
---
