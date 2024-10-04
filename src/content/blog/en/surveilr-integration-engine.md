---
title: "surveilr: A Local-First, Edge-based SQL-Centric Integration Engine"
metaTitle: "A Local-First, Edge-based SQL-Centric Integration Engine"
description: "Discover how surveilr can be used as an integration engine."
author: "Pradeep Narayanan"
authorImage: "@/images/blog/pradeep-narayanan.avif"
authorImageAlt: "Avatar Description"
pubDate: 2024-09-27
cardImage: "@/images/blog/surveilr-integration-engine.avif"
cardImageAlt: "surveilr based integration"
readTime: 5
tags: ["integration"]
---


In today’s data-driven world, businesses, especially in healthcare, need efficient ways to manage and integrate data across multiple systems. `surveilr` is designed to address these needs. It's a stateful data preparation and integration platform that allows systems to seamlessly operate on common data in a local-first, edge-based, and SQL-centric manner.
Here’s what that means and why it’s crucial:

## Why surveilr’s Architecture Matters?

### Local-First:
Unlike traditional platforms where data is sent to the cloud for processing, `surveilr` prioritizes local data handling. Data is prepared and processed locally before being transmitted to cloud or central servers, reducing latency and enhancing control over sensitive information.
### Edge-Based:
`surveilr` focuses on processing data as close to its source as possible. This means data is collected, processed, and sometimes even analyzed on devices near the point of collection, such as workstations, mobile phones, or local servers, minimizing the need for centralization.
### Stateful: 
`surveilr` doesn’t just pass data between systems—it stores it in a universal schema with full SQL querying capabilities. This means data can be analyzed, processed, and queried at any stage of the pipeline, giving users unparalleled control and flexibility.
### SQL-Centric:
Data is structured to be fully queryable via SQL. This allows for orchestrated workflows and seamless data manipulation, making it easier to integrate, process, and analyze large datasets.
### Agility:
You can easily configure queries, data models, or applications without the need for pre-planning. In addition to SQL queries, the data ingestion and integration strategy is well suited to support real-time analytics, , and machine learning.
### Speed:
Keeping data in a raw state also makes it available for use far faster since you don’t have to perform time-intensive tasks such as transforming the data and developing additional table(s) and view(s) until you define the business question(s) that need to be addressed.

##  `surveilr` Features and Use Cases

The various functional components/layers of the **Resource Surveillance Integration Engine** (`surveilr`) are given below,

| Components/Layers | Details |
|-------------------|----------|
| Acquisition of Content (Data) | Steps involves in the content acquisition i.e preparation of the files/data for ingestion. In addition to the local files, we can use technologies such as WebDAV, SFTP, AWS S3, Git and Virtual Printer capabilities are the part of this layer. |
| Advanced Data Acquisition Layer | This layer helps users for enhanced data preparation using Capturable Executables(CEs). With the support of processing instructions (PI) Capturable Executables(CEs) further helps the user to prepare data with specific message standards like JSON, plain/text etc |
| Message format/standard Support | The Resource Surveillance & Integration Engine supports a wide range of standards like HL7, FHIR, JSON, and XML but can also handle a variety of file types for exchange, such as CSV, Excel, or custom formats. |
| Stateful Ingestion | Involves the steps of ingesting and processing data into a structured universal schema with full SQL querying support. surveilr leverages state tables to track the status of ingested files, ensuring that files are not re-ingested unless changes are detected. This approach prevents redundant ingestion, optimizes performance, and supports incremental updates. By maintaining the state of ingested data, surveilr ensures efficient data management, scalability, and transparency, while also providing a clear audit trail of the ingestion history. |
| Web UI for Viewing Ingested Data Locally | Resource Surveillance & Integration Engine (`surveilr`) provides a Web UI component that allows users to view ingested data in real time and access data processed offline |
| Data Synchronization and Aggregation | The Data Synchronization and Aggregation phase involves systematically synchronizing and aggregating the ingested and processed data into a central data store. This ensures the data is ready for advanced analytics, reporting, and integration with other supporting systems. |


## surveilr’s Ingestion/Integration Pipeline

surveilr’s architecture supports both **real-time** and **offline/batch processing**, enabling scalable and flexible data integration for various sectors. This approach allows businesses to optimize **performance, security, and reliability**, while adapting to their specific processing needs.

### Real-Time and Offline Processing

- **Real-Time Processing:** `surveilr` can handle live data streams, processing information as it arrives.
- **Offline/Batch Processing:** For larger data sets or delayed ingestion, `surveilr` supports batch processing, allowing for data to be ingested and analyzed at scheduled intervals.

### Improved Reliability

By storing and batch-processing data at the **edge**, `surveilr` ensures continuous operation even when central systems are temporarily unavailable, making it ideal for mission-critical environments like healthcare and financial services.

### Security and Compliance

Regardless of the ingestion method—real-time or batch uploads— `surveilr` employs stringent security protocols, anonymizing or de-identifying sensitive data before transmission to central systems. This ensures compliance with **HIPAA** and other regulatory frameworks.

## Separation of Content Acquisition and Stateful Ingestion

`surveilr` differentiates between **data acquisition** and **stateful ingestion**, allowing for modular control and optimized data handling. This separation enhances both **real-time** and **batch processing**, ensuring efficient data capture and transformation.

### Content Acquisition Methods

Data is collected via multiple acquisition methods, including:

**WebDAV:** Enables file uploads to designated ingestion folders for seamless integration with source systems.

**Virtual Printers:** Captures print jobs like reports or documents and stores them for later ingestion.

**API, Direct Uploads, Local File Systems:** Supports real-time API data feeds and batch uploads from sources like **SFTP, Amazon S3, Git**, and **IMAP**.

This flexible acquisition process allows `surveilr` to handle both **on-demand** data streams and **scheduled** batch uploads.

### Stateful Ingestion Process

Once acquired, the data moves to the **stateful ingestion layer**, where it undergoes transformation, enrichment, and validation. This process prepares the data for immediate analysis or later batch processing, ensuring that all data is structured and queryable.

**File Ingestion:** `surveilr` scans directories, extracting and storing metadata in the **Resource Surveillance State Database (RSSD)**.

**Task Ingestion:** Automates shell tasks, converting output into structured data.

**IMAP Email Ingestion:** Retrieves emails and converts them into structured JSON data for ingestion.

## Advanced Data Processing: Capturable Executables (CEs)

`surveilr` uses **Capturable Executables (CEs)** to enhance its data ingestion and transformation pipelines. These scripts allow for automated tasks, including:

- **Transformation:** Converts raw data into standardized formats.
- **Automation:** Triggers real-time or scheduled tasks.
- **Validation:** Ensures that all ingested data meets quality and regulatory standards.

The file-naming conventions for CEs help determine the expected output format, such as JSON or plain text, enabling users to tailor ingestion processes to specific requirements.

## Data Quality and Governance

Once processed, data is stored in the **Resource Surveillance State Database (RSSD)**, a universal schema that ensures consistency across datasets. The RSSD facilitates easy querying, analysis, and integration into external systems, data warehouses, or business intelligence platforms.

- **Stateful Context Management:** Tracks data throughout its lifecycle, ensuring continuity and version control.
- **Data Synchronization and Aggregation:** Surveilr synchronizes real-time and batch data, ensuring that all information is available for advanced analytics and reporting.

## Web UI for Data Visualization and Auditing

`surveilr` provides a Web UI for users to view ingested data in real-time or access processed offline data. Key features include:

- **Data Visualization:** The Web UI module enable easy configurable web components to view the ingested data locally.
- **Querying Capabilities:** Full SQL querying support enables users to extract and analyze data from both real-time and batch ingestion sources.
- **Audit and Traceability:** The UI includes tracking features that provide visibility into both real-time and batch data flows, ensuring compliance and security audits are easily conducted.

## Data Synchronization and Aggregation

The Data Synchronization and Aggregation phase is the final and critical step in the surveilr pipeline. After data has been ingested and processed through various stages, this phase ensures that the data is systematically synchronized and aggregated into a central data store. This final step consolidates both real-time and batch-processed data, making it accessible for advanced analytics, reporting, and integration with other supporting systems.

### Key Functions

- **Data Synchronization:** Ensures real-time and batch data are consistently updated in the central repository.
- **Data Aggregation:** Consolidates data from different sources into a unified structure.
- **Data Transformation:** Applies transformations to standardize data formats, ensure consistency, and enrich the data (e.g., merging fields, calculating metrics). The data transformation also includes anonymizing sensitive information before the transmission.

### Advanced Analytics and Reporting

Consolidated data enables sophisticated analysis and reporting through:

- **Business Intelligence (BI):** Data visualization tools and dashboards.
- **Predictive Analytics:** Analyzes historical data to forecast trends.
- **Custom Reporting:** Generates tailored reports based on user requirements.

### Integration with Other Systems

 `surveilr` facilitates data exchange across different systems through:

- **APIs:** Provides APIs for external systems to access aggregated data.
- **Data Export:** Exports data in formats like CSV and JSON.

### Data Quality and Governance

`surveilr` maintains accuracy, consistency, and reliability through:

- **Data Validation:** Ensures data correctness before synchronization.
- **Audit Trails:** Tracks changes and updates to maintain transparency.
- **Compliance:** Adheres to data privacy and regulatory standards such as GDPR and HIPAA.

## Data Flow Overview of surveilr based Integration Pipeline

The `surveilr` platform operates as a sophisticated data integration and processing system, employing a local-first, edge-based approach with SQL at its core. Let's explore how data flows through this comprehensive platform.

### Data Acquisition

The data journey begins with multiple acquisition pathways:

- **Traditional File Systems:** Direct access to local OS file systems
- **Cloud Integration:** Connection to cloud storage services like AWS S3
- **Web Protocols:** Support for WebDAV for web-based file management
- **Secure Transfer:** SFTP capabilities for secure data transmission
- **Document Conversion:** Virtual printers enabling digital document conversion

### Data Ingestion and Transformation

Once acquired, data passes through robust ingestion pipelines:

- Multiple Format Support:

    - Structured data: JSON, XML, CSV
    - Industry protocols: HL7, FHIR, EDI

- Data Transformation:

    - Conversion into queryable formats, primarily JSON
    - Optimization through columnar storage formats like Parquet
    - Focus on enhancing analytics and reporting capabilities

### System Integration and Storage

Data flows seamlessly between various systems:

- Integration Points:
    - PLM systems (GitHub, Jira)
    - ERP systems
    - Messaging platforms
- Data Storage and Processing:
     - Custom SQL tables
      - Built-in SQL views
    - Multiple database support:
        - SQLite,PostgreSQL,MySQL,Cloud-based systems (DuckDB)
### User Interaction Layer

The data flow culminates in two primary interfaces:

- Surveilr Web UI:
    - SQL query execution
    - Content management capabilities
- Console Interface:
    - SQL navigation tools
    - Orchestration features
    - Audit functionality

## Looking Ahead
As edge computing continues to evolve, surveilr's local-first, stateful approach to data integration positions it as a powerful tool for organizations looking to optimize their data processing and integration pipelines. Whether you're dealing with healthcare data, infrastructure monitoring, or complex content assembly, surveilr provides the flexibility, security, and performance needed in today's data landscape.

Ready to transform your data integration strategy? Explore `surveilr` and experience the power of local-first, edge-based, SQL centric data processing engine.