# Fleetfolio: Next-Generation Infrastructure Assurance

Fleetfolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, Fleetfolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).

## What Fleetfolio Does

Fleetfolio ensures that organizations know:

- ✅ **What assets should exist** (Expectation)
- ✅ **What assets actually exist** (Discovery)
- ✅ **Where gaps exist** (Compliance & Security Analysis)

Fleetfolio is the missing link between infrastructure monitoring, security, and compliance. Instead of relying on guesswork, it provides a data-driven, evidence-based approach to asset assurance.

🔹 Ensure your infrastructure is exactly what it should be
🔹 Detect security risks before they cause damage
🔹 Stay compliant with industry standards automatically

Many organizations struggle with shadow IT, compliance violations, and operational blind spots due to a lack of infrastructure assurance. Fleetfolio helps by providing comprehensive infrastructure assurance through three integrated database types.

## Database Architecture

Fleetfolio operates using three main database types that work together to provide complete infrastructure visibility and compliance monitoring:

### 1. 🔍 osQuery Databases

Contains **system monitoring and security data** collected from endpoints:

- System information (hostname, OS, hardware specs)
- Running processes and installed software
- Network configurations and connections
- Security policies and user accounts
- File system changes and access logs

### 2. ☁️ Cloud Databases

Contains **cloud infrastructure and service data** from various cloud providers:

- Cloud instances and virtual machines
- Storage buckets and databases
- Network configurations and security groups
- IAM roles and permissions
- Service configurations and billing data

### 3. 📋 Infrastructure Assurance Databases

Contains **expected evidence and compliance data** (when available):

- Predefined asset expectations and policies
- Compliance rules and governance frameworks
- Audit trails and evidence collection
- Risk assessments and remediation workflows

## Getting Started: Database Setup

### Step 1: Generate Evidence Databases

Before using Fleetfolio, you need to generate the required databases containing your infrastructure evidence. Follow the comprehensive guide for evidence collection:

📖 **Official Evidence Collection Guide**: <https://www.surveilr.com/docs/evidence/surveilr-evidence-collection-guide/>

This guide covers:

- Setting up osQuery agents for system monitoring
- Configuring cloud data collection from AWS, Azure, GCP
- Collecting infrastructure assurance evidence
- Best practices for data collection and storage

### Step 2: Merge Multiple Databases

Once you have generated separate databases (osQuery, cloud, infrastructure assurance), you need to merge them into a single unified database for Fleetfolio analysis.

#### Merge Command

```bash
surveilr admin merge -p "asset%" -p "boundary%" -p "assignment%" -p "graph%"
```

#### What Each Pattern Matches

These patterns match table names that start with the specified prefixes:

- **`asset%`** - Merges all tables starting with "asset" (e.g., asset_inventory, asset_config, asset_metadata)
- **`boundary%`** - Merges all tables starting with "boundary" (e.g., boundary_network, boundary_zones)
- **`assignment%`** - Merges all tables starting with "assignment" (e.g., assignment_ownership, assignment_responsibility)
- **`graph%`** - Merges all tables starting with "graph" (e.g., graph_relationships, graph_dependencies)

#### Prerequisites

Before running the merge command:

1. **Ensure all source databases are accessible** in the current directory or provide full paths
2. **Backup your databases** before merging (the operation modifies the target database)
3. **Verify database integrity** by running basic queries on each source database
4. **Check available disk space** as merged databases can be significantly larger

#### Example Merge Workflow

```bash
# Navigate to your evidence directory
cd /path/to/your/evidence/databases

# Verify your databases exist
ls -la *.db

# Create a backup (recommended)
cp resource-surveillance.sqlite.db resource-surveillance-backup.sqlite.db

# Run the merge operation
surveilr admin merge -p "asset%" -p "boundary%" -p "assignment%" -p "graph%"

# After merging, the result is saved as resource-surveillance-aggregated.sqlite.db
# Rename it to the standard name for FleetFolio
mv resource-surveillance-aggregated.sqlite.db resource-surveillance.sqlite.db

# Verify the merge was successful
surveilr shell -c "SELECT COUNT(*) FROM sqlite_master WHERE type='table';"
```

**Important Note**: After running the merge command, the merged database is created as `resource-surveillance-aggregated.sqlite.db`. You should rename this to `resource-surveillance.sqlite.db` to ensure Fleetfolio can access it properly.

### Step 3: Launch Fleetfolio Web UI

After merging your databases, you can launch the Fleetfolio web interface to analyze your infrastructure assurance data.

## Key Benefits

### 🔍 Identifying Reliability Issues

If an expected asset (server, VM, container) is missing, it could indicate a
downtime event, misconfiguration, or failure. Fleetfolio flags missing assets,
allowing teams to respond before they impact operations.

### 🛡️ Detecting Unauthorized Assets

If an asset is found but was not expected, it could be a security risk—such as a
rogue machine, unauthorized cloud instance, or compromised system. Fleetfolio
detects unauthorized assets in real time.

### ✅ Ensuring Compliance & Governance

Regulatory frameworks (e.g., SOC 2 Type I, SOC 2 Type II) require organizations to
track and validate infrastructure components. Fleetfolio ensures compliance by
verifying that only approved assets exist and that nothing is missing.

### 🚀 Automating Infrastructure Audits

Fleetfolio eliminates the need for manual asset audits by continuously
reconciling expected vs. actual infrastructure and generating real-time reports
for IT, security, and compliance teams.

## How Fleetfolio Works

Fleetfolio operates in three key steps:

### 1️⃣ Define Expected Assets (via infra-assurance)

Fleetfolio uses the infra-assurance framework from surveilr to create a
structured list of expected assets. These include:

- Servers, VMs, and Containers
- Network devices and cloud instances
- Compliance rules (e.g., approved OS versions, configurations)

### 2️⃣ Discover Actual Assets (via osQuery MS)

Fleetfolio connects to osQuery MS to collect real-time data on infrastructure.
It pulls detailed system information including:

- Hostname, IPs, MAC addresses
- Installed software & running processes
- OS configurations, kernel versions, and security policies

### 3️⃣ Analyze & Report Compliance

Fleetfolio automatically compares expected vs. actual assets and categorizes
them into:

- ✅ Compliant: Expected & Found
- ⚠️ Missing: Expected but Not Found
- 🚨 Unauthorized: Found but Not Expected

This generates audit-ready reports and real-time alerts to ensure complete
visibility and compliance.

## What Makes Fleetfolio Unique?

### 🔗 Integrated with surveilr’s infra-assurance

Fleetfolio is built using surveilr’s infra-assurance framework, making it part
of a larger evidence-driven compliance ecosystem. This allows seamless
integration with governance policies and IT security standards.

### 🕵️ Proactive, Not Just Reactive

Unlike traditional asset inventory tools that just list assets, Fleetfolio
actively monitors for missing or unauthorized assets and provides automated
remediation workflows.

### 📊 Unified Compliance & Security Auditing

Fleetfolio bridges the gap between compliance, security, and IT
operations—ensuring that governance policies are actually enforced in real
infrastructure.

### 🌍 Cloud-Native & Scalable

Designed for modern, hybrid infrastructure, Fleetfolio supports on-prem, cloud,
and containerized environments without performance trade-offs.

## Who Benefits from Fleetfolio?

### 🔹 IT Operations & DevOps

- Ensures that expected servers and services are always running
- Detects misconfigurations before they cause failures
- Automates asset tracking across environments

### 🔹 Security & Compliance Teams

- Detects unauthorized machines or shadow IT
- Enforces governance policies (SOC 2 Type I/II, NIST, ISO 27001, PCI DSS, etc.)
- Simplifies audit reporting with real-time compliance checks

### 🔹 Enterprise & Cloud Architects

- Validates infrastructure as code (IaC) deployments
- Ensures that approved configurations are enforced
- Prevents drift between environments (staging vs. production)

## Launch Fleetfolio Web UI

Once your databases are merged, you can start the Fleetfolio web interface:

```bash
# Load the Console and Fleetfolio Web UI components
deno run -A ./package.sql.ts | surveilr shell

# Alternative method (equivalent to above)
surveilr shell ./package.sql.ts

# Start surveilr web UI in development mode with auto-reload
SQLPAGE_SITE_PREFIX=/lib/service ../../std/surveilrctl.ts dev

# Access the web interface
# Main UI: http://localhost:9000/
# Schema info: http://localhost:9000/dms/info-schema.sql
```

### Web UI Features

- **Asset Dashboard** - Overview of all discovered and expected assets
- **Compliance Reports** - Real-time compliance status and gap analysis
- **Security Alerts** - Unauthorized assets and security violations
- **Audit Trails** - Complete evidence and change tracking

### Database Access

Once you apply `stateless.sql`, all content will be accessed through views or `*.cached` tables in `resource-surveillance.sqlite.db`. At this point you can:

- **Archive the database**: Rename the SQLite database file for long-term storage
- **External tools**: Use in reporting tools (DBeaver, DataGrip, etc.)
- **Data analysis**: Access with any SQLite-compatible data analysis tools
- **Compliance reporting**: Export data for external compliance and audit reporting

**Database File Management:**

```bash
# The working database after merge and rename
resource-surveillance.sqlite.db

# For archival purposes, you can rename with timestamps
cp resource-surveillance.sqlite.db "resource-surveillance-$(date +%Y%m%d).sqlite.db"

# Or organize by project/environment
cp resource-surveillance.sqlite.db "fleetfolio-production-$(date +%Y%m%d).sqlite.db"
```

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See: [`surveilrctl.ts`](../../std/surveilrctl.ts).

## Code Formatting and Linting

To maintain consistent code quality and formatting across the Fleetfolio
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
