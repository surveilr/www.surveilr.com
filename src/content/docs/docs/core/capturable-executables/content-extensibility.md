---
title: Content Extensibility with Capturable Executables
description: Unlimited Integration Possibilities with Capturable Executables (CEs)
---

Traditional integration tools like **Enterprise Service Buses (ESBs)**, **API
connectors**, and services like **Zapier** are designed to connect external
systems to each other. They allow data to flow between various platforms,
enabling communication across applications. While these tools are highly
effective at linking systems together, they typically just **move data** from
one system to another without retaining a centralized, **queryable state**. This
is where **Capturable Executables (CEs)** in **`surveilr`** offer a unique
advantage.

**Capturable Executables (CEs)** are focused not just on **connecting systems**
but on **ingesting data** from arbitrary sources, in almost any format, using
**any connector technology or technique**. Unlike typical ESBs or API connectors
that simply transfer data between systems, CEs capture this data and store it in
**`surveilr`'s** stateful **uniform resource** database, where it becomes
**queryable**. This means that instead of simply linking systems, **`surveilr`**
transforms the data into an organized, **evidence-based resource** that can be
used for audits, reports, and decision-making.

**Capturable Executables (CEs)** are custom scripts that can be written in **any
programming language** to connect to various systems, extract or generate data,
and fully integrate that data into **`surveilr`’s** **opinionated universal
database schema**. These scripts allow businesses to customize their integration
processes, ensuring that no matter what system or format the data comes from, it
can be captured, stored, and made available for analysis.

When **`surveilr`** performs an **ingest command**, it typically looks for
files, extracts their content, and stores them as records in a **uniform
resource** table. However, sometimes the data doesn’t already exist in a static
file—it needs to be **generated**. That’s where **CEs** become invaluable. CEs
allow businesses to execute scripts, gather data in real time, and capture the
output for storage in **`surveilr`**.

At the core of **CEs** is the idea that scripts—whether they're simple shell
scripts or complex programs—can be executed by **`surveilr`**, and their
**output** can be captured and treated as part of the evidence warehouse. The
process works like this:

- **Executing Custom Scripts**: When a specific type of file is encountered (for
  example, `abc.surveilr.sh`), **`surveilr`** can execute the script using a
  designated **Capturable Executable (CE)**. The script is run safely, and its
  output (whether JSON, SQL, or other formats) is captured.

- **Storing the Output**: Once the script has run, the output from **STDOUT**
  and any potential error messages from **STDERR** are stored directly into
  **`surveilr`’s uniform resource table**. This allows the generated data to
  become part of the evidence warehouse, where it can be queried, audited, and
  analyzed alongside data from other sources.

- **Processing Instructions (PIs)**: Customization is achieved through
  **Processing Instructions (PIs)** embedded in filenames or passed as arguments
  during execution. For example, a script called `myfile.surveilr-SQL.sh` would
  indicate that the output is **SQL** and should be executed as a **batch SQL
  transaction** within the `surveilr` database.

CEs are a powerful tool because they provide **unlimited integration
possibilities**. Unlike traditional systems that rely on rigid, predefined
connectors, CEs allow businesses to:

- **Ingest from any system**: Whether it’s a legacy application, a modern API,
  or an internal system that doesn’t have a typical connector, a custom CE
  script can be written to extract or generate data and pass it into
  **`surveilr`**.

- **Generate and capture data dynamically**: Not all data comes from static
  files. Sometimes, data needs to be generated in real-time—whether it’s pulling
  information from a database, running a diagnostic tool, or creating complex
  batch files. CEs enable this dynamic data generation.

- **Store output in a standardized format**: No matter what the output of the CE
  script is—JSON, SQL, text, or other formats—**`surveilr`** can capture and
  store it in a **uniform resource table**, making the data easily accessible
  and queryable for business analysts.

The ability to execute scripts and capture their output makes **`surveilr`** a
unique tool for **building an evidence warehouse**. Instead of relying solely on
existing data, CEs allow businesses to **pull in data from custom sources** or
generate new data on the fly. This means that **`surveilr`** can act in a
similar way to API connectors, ESBs, and other integration engines, but with the
added benefit of **fully integrating the data** into a **stateful**,
**queryable** evidence warehouse.

**Capturable Executables (CEs)** empower organizations to create a flexible,
highly customized integration process that not only gathers data but also stores
it in a meaningful, standardized format. With CEs, businesses can break free
from the limitations of traditional connectors and integration tools, giving
them the power to capture, process, and store data from virtually any source,
securely and efficiently.