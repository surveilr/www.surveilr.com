---
title: "osQuery Integration Pattern"
description: "Surface surveilr RSSD tables via osQuery"
main:
  id: 4
  content: |
    The surveilr osQuery Integration Pattern provides a seamless method to integrate any surveilr-managed database into osQuery using the Automatic Table Construction (ATC) pattern. This allows organizations to query and analyze data from a variety of sources—collected and standardized within surveilr—via osQuery’s SQL interface.
  imgCard: "@/images/pattern/osquery-pattern.avif"
  imgMain: "@/images/pattern/osquery-pattern.avif"
  imgAlt: "osQuery Integration Pattern"
tabs:
  - id: "tabs-with-card-item-1"
    dataTab: "#tabs-with-card-1"
    title: "Description"
  - id: "tabs-with-card-item-2"
    dataTab: "#tabs-with-card-2"
    title: "Capabilities"
  - id: "tabs-with-card-item-3"
    dataTab: "#tabs-with-card-3"
    title: "Screenshots"
longDescription:
  title: "osQuery Integration Pattern"
  subTitle: |
    By leveraging the ATC JSON pattern, users can automatically surface custom tables in osQuery to interact directly with the content stored in surveilr's Resource Surveillance State Database (RSSD). This enables osQuery to dynamically join data from multiple sources (emails, logs, compliance evidence, PLM/CRM systems, etc.), providing powerful querying capabilities for security audits, compliance reporting, and decision-making.
  btnTitle: "Use the SQL"
  btnURL: "/lib/pattern/osquery/package.sql"
descriptionList:
  - title: "Unified Data Access"
    subTitle: "The integration allows organizations to leverage surveilr as a universal data aggregator, pulling from a multitude of data sources. osQuery users benefit from this by gaining a unified interface to query all of the data—regardless of where it originally came from—using standard SQL."
  - title: "Edge-Based Security"
    subTitle: "Since surveilr employs a local-first, edge-based approach, sensitive data is handled securely at the source, before it is ever integrated into the central system or osQuery tables. This enhances data security by reducing the risks associated with transferring sensitive information over networks."
  - title: "Seamless Extensibility with ATC"
    subTitle: "The Automatic Table Construction (ATC) pattern simplifies extending osQuery’s capabilities. No need to write complex C++ extensions or plugins. Instead, users define custom tables in JSON format, making it easy to add new data sources or modify the structure of the tables without redeploying osQuery."
specificationsLeft:
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
specificationsRight:
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
  - title: "Capability"
    subTitle: "Capability Description"
blueprints:
  first: "@/images/pattern/osquery-pattern-ss-2.avif"
  second: "@/images/pattern/osquery-pattern-ss-1.avif"  
---
