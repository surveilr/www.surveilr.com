---
title: "Orchestration with JavaScript and Python"
metaTitle: "Advanced Orchestration with TypeScript, JavaScript, Python, and Other Languages"
description: "Explore how to use surveilr RSSDs with TypeScript, JavaScript, Python, Rust, C/C++, Zig and Other Languages"
author: "Shahid N. Shah"
authorImage: "@/images/blog/shahid-shah.avif"
authorImageAlt: "Shahid Shah"
pubDate: 2024-10-11
cardImage: "@/images/blog/advanced-polyglot-orchestration.avif"
cardImageAlt: "Lightweight ETL"
readTime: 3
tags: ["etl", "elt"]
---

The **Resource Surveillance & Integration Engine**, known as `surveilr`, offers extensive built-in capabilities for ingestion, ETL, ELT, and other integration tasks. Many of these tasks can be orchestrated declaratively within **SQL** using the SQLite ecosystem alongside the extension functions and virtual tables provided by `surveilr`. By leveraging the versatility of SQLite, `surveilr` can handle a range of transformations, integrations, and data workflows, all from within the database itself.

However, there are scenarios where more complex orchestration is needed—tasks that require imperative programming, advanced logic, or capabilities beyond what `surveilr` provides out of the box. In such cases, languages like **TypeScript** and **JavaScript** (using **Deno** or **NodeJS**), **Python**, and many others that support SQLite integration come to the rescue. The [**Resource Surveillance State Database (RSSD)**](/docs/core/concepts/resource-surveillance/), which is an opinionated **SQLite** database, provides a strong foundation for multi-modal ingestion and transformation, making it ideal for advanced orchestration using external languages and tools.

In this blog post, we will explore advanced orchestration strategies using various languages to complement `surveilr`. We will provide examples from a compliance and evidence-gathering perspective, using [`uniform_resource`](/docs/core/concepts/uniform-resource/) and related tables to demonstrate how to manage resources, track provenance, and execute sophisticated integration workflows. One of the key strengths of the [RSSD](/docs/core/concepts/resource-surveillance/) format is that it is fully portable across different language ecosystems, which allows developers to use the tools and languages best suited for their specific orchestration needs.

## Orchestration with Declarative SQL in `surveilr`

Before diving into advanced orchestration techniques, it is important to understand the power of **declarative SQL** within `surveilr`. The [**`uniform_resource`**](/docs/core/concepts/uniform-resource/) table and the constellation of [related tables](/docs/core/concepts/uniform-resource#related-tables) provide a robust framework for resource ingestion and metadata tracking. By utilizing SQL and built-in virtual tables, many integration workflows can be managed with ease.

For example, consider a compliance use case where a set of [files must be ingested](https://www.surveilr.com/docs/core/cli/ingest-commands/files/), tracked, and audited:

```sql
INSERT INTO uniform_resource (uniform_resource_id, device_id, ingest_session_id, uri, content_digest, nature, size_bytes, created_at)
VALUES (
    'UR12345',
    'DEVICE6789',
    'SESSION001',
    '/data/finance/report.pdf',
    'sha256:abcd1234...',
    'document',
    204800,
    CURRENT_TIMESTAMP
);
```

In this example, a new [resource](/docs/core/concepts/resource/) is ingested and registered with all relevant metadata, including [**device**](/docs/standard-library/rssd-schema/device/), [**ingestion session**](docs/standard-library/rssd-schema/ur_ingest_session/), **content digest** for data integrity, and **URI** for identification. With `surveilr`'s built-in capabilities, this can be automated for bulk ingestion using declarative SQL commands and virtual tables.

## The Need for Advanced Orchestration

While declarative SQL can handle many integration tasks, there are situations that demand more **complex orchestration**. Examples include:

- **Conditional Logic and Error Handling**: Declarative SQL can struggle with advanced branching logic or error handling that might be required in some workflows.
- **External API Integrations**: Integrating with third-party services often requires REST API calls, authentication, and handling dynamic response data.
- **Complex Data Transformations**: Some transformations, especially those involving external data sources, may be more suited to procedural programming.
- **Evidence Gathering and Compliance**: In a compliance context, workflows often need dynamic checks, branching, and the ability to communicate with external systems to gather and verify evidence.

In these cases, the power of **imperative programming** becomes essential. This is where languages like **TypeScript**, **JavaScript**, **Python**, and others play a crucial role.

## TypeScript and JavaScript for Orchestration

Languages like TypeScript and JavaScript, running on **Deno** or **NodeJS**, provide rich libraries and tools for advanced orchestration, making them ideal for expanding the capabilities of `surveilr`.

Consider a scenario where we want to orchestrate a compliance check for a set of resources ingested into the **`uniform_resource`** table. This compliance check involves verifying that each resource has been properly signed off and validated against an external system.

Here is an example using TypeScript and NodeJS:

```typescript
import sqlite3 from 'sqlite3';
import axios from 'axios';

const db = new sqlite3.Database('rssd.db');

// Fetch all resources that need compliance verification
db.all(`SELECT uniform_resource_id, uri, content_digest FROM uniform_resource WHERE nature = 'document' AND verified IS NULL`, async (err, rows) => {
    if (err) throw err;

    for (const row of rows) {
        try {
            // Simulate an external API call to verify the resource
            const response = await axios.post('https://compliance-check.example.com/verify', {
                uri: row.uri,
                digest: row.content_digest
            });

            if (response.data.verified) {
                db.run(`UPDATE uniform_resource SET verified = 1 WHERE uniform_resource_id = ?`, row.uniform_resource_id);
                console.log(`Resource ${row.uniform_resource_id} verified successfully.`);
            } else {
                console.error(`Verification failed for resource ${row.uniform_resource_id}`);
            }
        } catch (apiError) {
            console.error(`Error verifying resource ${row.uniform_resource_id}:`, apiError);
        }
    }
});
```

In this example, we are using TypeScript to orchestrate a **verification workflow** that involves an external compliance API. Each resource is verified, and the **`uniform_resource`** table is updated accordingly. The combination of **NodeJS** for asynchronous operations and **SQLite** for data persistence makes this type of orchestration both powerful and flexible.

## Python for Advanced Integration Workflows

**Python** is another great choice for advanced orchestration, particularly due to its extensive ecosystem of libraries for data processing, compliance, and orchestration. Python’s **sqlite3** module allows seamless interaction with the RSSD database, and its rich set of packages like **requests** and **pandas** allows for powerful data integration capabilities.

Consider a scenario where we need to orchestrate an **ETL process** that reads resource data, transforms it, and exports it for further analysis. Here’s an example using Python:

```python
import sqlite3
import requests
import pandas as pd

# Connect to the RSSD SQLite database
db_connection = sqlite3.connect('rssd.db')
cursor = db_connection.cursor()

# Extract resources that need transformation
cursor.execute("SELECT uniform_resource_id, uri, content FROM uniform_resource WHERE nature = 'log' AND transformed IS NULL")
resources = cursor.fetchall()

# Transform each resource and send to external compliance system
for resource in resources:
    resource_id, uri, content = resource
    # Perform some transformation
    transformed_content = content.decode('utf-8').upper()  # Example transformation: converting to uppercase

    # Send the transformed content to an external system
    response = requests.post('https://api.external-system.com/ingest', json={'uri': uri, 'content': transformed_content})
    if response.status_code == 200:
        # Update the resource as transformed
        cursor.execute("UPDATE uniform_resource SET transformed = 1 WHERE uniform_resource_id = ?", (resource_id,))
        db_connection.commit()
        print(f"Resource {resource_id} transformed and ingested successfully.")
    else:
        print(f"Failed to ingest transformed content for resource {resource_id}.")

# Close the connection
db_connection.close()
```

In this Python script, we extract logs from the **`uniform_resource`** table, perform a transformation, and send the transformed content to an external system for further processing. Python's versatility and simplicity make it an excellent choice for such ETL tasks, especially when combined with **SQLite** for local persistence.

## Multi-Language Integration for Compliance and Evidence Gathering

When dealing with compliance and evidence gathering, there is often a need to combine different tools and languages to meet complex requirements. The **RSSD** format, being an SQLite database, makes this integration seamless across ecosystems.

For instance, an **evidence-gathering workflow** could start with data ingestion using SQL and `surveilr`, followed by resource transformation and validation using **Python**, and finally, advanced reporting and data visualization using **JavaScript** with frameworks like **D3.js** or **Chart.js**.

Consider the following scenario:

- **Ingestion and Tracking**: Use `surveilr` to ingest documents into the `uniform_resource` table, capturing metadata like the ingestion session, device, and content hash for integrity.
- **Validation with Python**: Validate document signatures against a compliance database using Python scripts, updating the RSSD database with the results.
- **Advanced Reporting**: Use a JavaScript-based web application to generate compliance reports, visualizing resource status from the `uniform_resource` table using D3.js for an intuitive graphical representation.

This **multi-language approach** allows you to leverage the strengths of each language, providing a highly flexible and scalable solution for orchestration in compliance and cybersecurity environments.

## Conclusion

The **Resource Surveillance & Integration Engine (`surveilr`)** is powerful on its own, allowing you to orchestrate many tasks using declarative SQL and built-in SQLite extensions. However, advanced orchestration often requires additional capabilities—complex logic, integrations, or transformations that benefit from imperative programming.

With the **Resource Surveillance State Database (RSSD)** format being fully portable across different language ecosystems, you can choose the right language and tool for the job, whether it's **TypeScript** for API orchestration, **Python** for data transformation, or **JavaScript** for visualization and reporting.

The **`uniform_resource`** table, with its constellation of related tables, forms the core of resource management, compliance, and evidence tracking. Using languages like **TypeScript**, **JavaScript**, **Python**, and others to orchestrate workflows around RSSD databases can empower you to handle even the most complex compliance and integration challenges.

Do you have use cases that require advanced orchestration? We'd love to hear how you integrate **`surveilr`** with your favorite programming languages to create powerful, compliance-focused workflows.