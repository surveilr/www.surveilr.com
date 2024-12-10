---
title: "Diabetes Research Hub Study Pattern"
description: "A seamless integration for converting study files and generating metrics, visual insights  for diabetes research."
main:
  id: 5
  content: |
    The Diabetes Research Hub (DRH) pattern simplifies the ingestion of CGM (Continuous Glucose Monitoring) files and supporting datasets. It allows seamless conversion to SQLite databases, executing advanced queries, and generating visual insights such as AGP (Ambulatory Glucose Profile) graphs and key metrics like J-Index, GRI, and more.
  imgCard: "@/images/pattern/research-study-explorer-pattern-ss-3.avif"
  imgMain: "@/images/pattern/research-study-explorer-pattern-ss-4.avif"
  imgAlt: "Diabetes Research Hub Workflow"
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
  title: "Diabetes Research Hub Study Pattern"
  subTitle: |
    This pattern enables researchers to ingest CGM data and related datasets into SQLite databases for dynamic querying and visualizing results. By using DRH's standardized workflow, researchers can process datasets to derive critical insights such as daily glucose profiles, AGP graphs, and metrics like J-Index and GRI, supporting in-depth diabetes research.
  btnTitle: "Explore SQL Workflow"
  btnURL: "/lib/pattern/research-study-explorer/package.sql"
descriptionList:
  - title: "Standardized CGM Data Integration"
    subTitle: "DRH supports the ingestion of study data from CGM files and associated participant datasets, transforming them into structured SQLite databases."
  - title: "Advanced Metrics Calculation"
    subTitle: "Automatically compute critical diabetes metrics like AGP, J-Index, and GRI for in-depth participant insights."
  - title: "Dynamic Query Execution"
    subTitle: "DRH allows querying datasets to generate participant-level reports, group-level summaries, and graphical visualizations."
  - title: "Visualization Ready"
    subTitle: "Supports rendering of AGP graphs, daily glucose profiles, and statistical summaries using SQLite views and integrated visualization tools."
specificationsLeft:
  - title: "Secure and Scalable"
    subTitle: "Handles large datasets securely, ensuring participant data integrity and compliance with research standards."
  - title: "Cross-Study Comparison"
    subTitle: "Facilitates comparisons across studies by standardizing CGM data ingestion and processing workflows."
  - title: "Automated Data Validation"
    subTitle: "Detects anomalies and validates data integrity for robust research outputs."
specificationsRight:
  - title: "Comprehensive Metrics"
    subTitle: "Calculates a wide range of metrics, including mean glucose, glucose variability, and risk indicators."
  - title: "Custom Study Reports"
    subTitle: "Generates customizable participant and study-level reports with visual insights."
  - title: "Enhanced Collaboration"
    subTitle: "Provides exportable results and insights for collaboration across institutions and teams."
blueprints:
  first: "@/images/pattern/research-study-explorer-pattern-ss-5.avif"
  second: "@/images/pattern/research-study-explorer-pattern-ss-2.avif"
  # third: "@/images/pattern/research-study-explorer-pattern-ss-3.avif"
  # fourth: "@/images/pattern/research-study-explorer-pattern-ss-4.avif"
  # fifth: "@/images/pattern/research-study-explorer-pattern-ss-5.avif"
liveDemo:
  btnTitle: "Live Demo"
  btnURL: "https://eg.surveilr.com/lib/pattern/research-study-explorer/"
---
