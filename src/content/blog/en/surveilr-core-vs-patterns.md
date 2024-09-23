---
title: "The surveilr Ecosystem: Core and Patterns"
description: "surveilr's flexibility to adapt to a wide range of industries, disciplines, and use cases"
author: "Shahid N. Shah"
authorImage: "@/images/blog/shahid-shah.avif"
authorImageAlt: "Shahid Shah"
pubDate: 2024-02-06
cardImage: "@/images/blog/surveilr-core-vs-patterns-abstract.avif"
cardImageAlt: "Top view mechanical tools arrangement"
readTime: 4
tags: ["pattern", "ecosystem", "core" ]
---

At the heart of **`surveilr`** is the flexibility to adapt to a wide range of industries, disciplines, and use cases. This adaptability is enabled through a combination of the **`surveilr` Core** engine and a modular approach to **Patterns**.

## `surveilr` Core
`surveilr` Core is the core engine, a single binary that handles the heavy lifting of collecting, aggregating, and processing evidence data. While incredibly powerful, `surveilr` Core itself is **agnostic to specific use cases** and does not have built-in awareness of business needs. It’s a flexible tool designed to work with many different data sources and workflows.

## `surveilr` Patterns
This flexibility comes to life through **`surveilr` Patterns**, which are **web-based libraries** of **SQL Packages** that can be mixed and matched to extend the functionality of `surveilr` Core. These Patterns fall into several categories:

- **Universal Patterns**: Designed to apply across all industries, such as general compliance tracking, security monitoring, or operational auditing. These are foundational packages that can be useful in any organizational context.
  
- **Industry Patterns**: Tailored to the needs of specific sectors, such as **healthcare**, which may require managing **EHR data** for HIPAA compliance, or **finance**, which might need specialized handling of **ERP data** to meet SOX standards. These packages provide industry-specific workflows and file formats.

- **Discipline Patterns**: These focus on the needs of specific professional roles or functions, such as **software engineers**, **QA teams**, **regulatory compliance officers**, and **cybersecurity professionals**. For example, a Discipline Pattern for **cybersecurity** professionals might automate threat detection, security log aggregation, and incident reporting, while a Discipline Pattern for **QA** might focus on quality tracking and product lifecycle management.

## Service Patterns
In addition to Universal, Industry, and Discipline Patterns, `surveilr` also offers **Service Patterns**, which provide a **self-contained, highly opinionated application or service** for specific use cases. A **Service Pattern** is a culmination of **Universal**, **Industry**, and **Discipline** Patterns, blended together to form a complete solution that can operate as a standalone service.

For example, a **Healthcare Security Compliance Service Pattern** might combine **Universal Patterns** for security monitoring, an **Industry Pattern** for handling **EHR data**, and a **Discipline Pattern** designed for **regulatory compliance** officers. The result is a full-service application that can be deployed with minimal configuration, offering a focused solution that meets the needs of healthcare organizations looking to secure patient data and comply with regulatory standards.

## Composability and Flexibility
`surveilr` Patterns are delivered as **composable SQL Packages**, allowing organizations to customize their use of `surveilr` by selecting the appropriate Patterns for their needs. For example, a financial services company could combine a **Universal Pattern** for compliance reporting with an **Industry Pattern** specific to finance, and add a **Discipline Pattern** for software engineers to track system performance.

## Benefits of the `surveilr` Core + Patterns Strategy

- **Flexibility**: With the ability to choose from Universal, Industry, Discipline, and Service Patterns, organizations can customize `surveilr` to meet their exact requirements without modifying the Core engine.
  
- **Efficiency**: Service Patterns provide a ready-to-use, opinionated solution that is designed to be deployed quickly for specific applications, reducing the need for manual setup or configuration.

- **Scalability**: As business needs evolve, new Patterns can be added or existing ones modified without disrupting existing workflows, making `surveilr` scalable and adaptable over time.

- **Comprehensive Use Case Support**: Whether an organization needs basic compliance tracking or a full-service application, `surveilr` Patterns offer the flexibility to create complex solutions from individual components.

---

With the combination of **`surveilr` Core** and the modular **Patterns** approach—including **Universal**, **Industry**, **Discipline**, and **Service Patterns**—`surveilr` enables organizations to confidently prove **security**, **quality**, and **compliance** with **auditable**, **queryable**, and **machine-attestable evidence** while scaling and adapting to specific needs.
