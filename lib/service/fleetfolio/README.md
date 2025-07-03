# FleetFolio: Next-Generation Infrastructure Assurance

FleetFolio is a powerful infrastructure assurance platform built on surveilr
that helps organizations achieve continuous compliance, security, and
operational reliability. Unlike traditional asset management tools that simply
list discovered assets, FleetFolio takes a proactive approach by defining
expected infrastructure assets and verifying them against actual assets found
using osQuery Management Server (MS).

FleetFolio ensures that organizations know:\
✅ What assets should exist (Expectation)\
✅ What assets actually exist (Discovery)\
✅ Where gaps exist (Compliance & Security Analysis)

FleetFolio is the missing link between infrastructure monitoring, security, and
compliance. Instead of relying on guesswork, it provides a data-driven,
evidence-based approach to asset assurance.

🔹 Ensure your infrastructure is exactly what it should be.\
🔹 Detect security risks before they cause damage.\
🔹 Stay compliant with industry standards automatically.

Many organizations struggle with shadow IT, compliance violations, and
operational blind spots due to a lack of infrastructure assurance. FleetFolio
helps by:

### 🔍 Identifying Reliability Issues

If an expected asset (server, VM, container) is missing, it could indicate a
downtime event, misconfiguration, or failure. FleetFolio flags missing assets,
allowing teams to respond before they impact operations.

### 🛡️ Detecting Unauthorized Assets

If an asset is found but was not expected, it could be a security risk—such as a
rogue machine, unauthorized cloud instance, or compromised system. FleetFolio
detects unauthorized assets in real time.

### ✅ Ensuring Compliance & Governance

Regulatory frameworks (e.g., ISO 27001, NIST, SOC 2) require organizations to
track and validate infrastructure components. FleetFolio ensures compliance by
verifying that only approved assets exist and that nothing is missing.

### 🚀 Automating Infrastructure Audits

FleetFolio eliminates the need for manual asset audits by continuously
reconciling expected vs. actual infrastructure and generating real-time reports
for IT, security, and compliance teams.

## How FleetFolio Works

FleetFolio operates in three key steps:

### 1️⃣ Define Expected Assets (via infra-assurance)

FleetFolio uses the infra-assurance framework from surveilr to create a
structured list of expected assets. These include:

- Servers, VMs, and Containers
- Network devices and cloud instances
- Compliance rules (e.g., approved OS versions, configurations)

### 2️⃣ Discover Actual Assets (via osQuery MS)

FleetFolio connects to osQuery MS to collect real-time data on infrastructure.
It pulls detailed system information including:

- Hostname, IPs, MAC addresses
- Installed software & running processes
- OS configurations, kernel versions, and security policies

### 3️⃣ Analyze & Report Compliance

FleetFolio automatically compares expected vs. actual assets and categorizes
them into:

- ✅ Compliant: Expected & Found
- ⚠️ Missing: Expected but Not Found
- 🚨 Unauthorized: Found but Not Expected

This generates audit-ready reports and real-time alerts to ensure complete
visibility and compliance.

## What Makes FleetFolio Unique?

### 🔗 Integrated with surveilr’s infra-assurance

FleetFolio is built using surveilr’s infra-assurance framework, making it part
of a larger evidence-driven compliance ecosystem. This allows seamless
integration with governance policies and IT security standards.

### 🕵️ Proactive, Not Just Reactive

Unlike traditional asset inventory tools that just list assets, FleetFolio
actively monitors for missing or unauthorized assets and provides automated
remediation workflows.

### 📊 Unified Compliance & Security Auditing

FleetFolio bridges the gap between compliance, security, and IT
operations—ensuring that governance policies are actually enforced in real
infrastructure.

### 🌍 Cloud-Native & Scalable

Designed for modern, hybrid infrastructure, FleetFolio supports on-prem, cloud,
and containerized environments without performance trade-offs.

## Who Benefits from FleetFolio?

### 🔹 IT Operations & DevOps

- Ensures that expected servers and services are always running
- Detects misconfigurations before they cause failures
- Automates asset tracking across environments

### 🔹 Security & Compliance Teams

- Detects unauthorized machines or shadow IT
- Enforces governance policies (SOC 2, NIST, ISO 27001, etc.)
- Simplifies audit reporting with real-time compliance checks

### 🔹 Enterprise & Cloud Architects

- Validates infrastructure as code (IaC) deployments
- Ensures that approved configurations are enforced
- Prevents drift between environments (staging vs. production)

### To up WebUI

```bash
# load the "Console" and other menu/routing utilities plus FHIR Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts    
$ SURVEILR_SQLPKG=~/.sqlpkg surveilr shell ./package.sql.ts             # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ SQLPAGE_SITE_PREFIX=/lib/service ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/dms/info-schema.sql to see DMS-specific schema
```

Once you apply `stateless.sql` you can ignore that files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See: [`surveilrctl.ts`](../../std/surveilrctl.ts).

## How to Run the Tests

To execute test and ensure that `surveilr` is functioning correctly:

1. Run the tests using Deno:

   ```bash
   deno test -A  # Executes test
   ```

This process will create an 'assurance' folder, where you can find the files
related to the test, including the database and ingestion folder

The `-A` flag provides all necessary permissions for the tests to run, including
file system access and network permissions.

## Code Formatting and Linting

To maintain consistent code quality and formatting across the FleetFolio
codebase:

### Format Code

```bash
deno fmt  # Formats all TypeScript and JavaScript files
```

### Lint Code

```bash
deno lint  # Checks for code quality issues and potential bugs
```

**Note:** You may see warnings about unsupported compiler options (`baseUrl`,
`paths`) when running `deno lint`. These warnings are expected and can be safely
ignored as Deno uses its own module resolution system.
