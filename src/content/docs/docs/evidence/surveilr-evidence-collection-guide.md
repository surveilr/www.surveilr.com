---
title: Guide to surveilr Evidence Collection and Integration
home:
  ItGovernance:
    category: "evidence-collection"
description:  surveilr is an extendable file system inspector used for performing surveillance of machine resources. It is designed to walk through resources like file systems and generate an SQLite database, which can then be consumed by any computing environment that supports SQLite. This guide walks you through the necessary steps to collect evidence from cloud platforms and systems, ensuring that data is captured and stored in a structured format for further analysis.
enableEditButton: true
---


## Evidence Collection Workflow

To effectively collect data from cloud platforms like **AWS**, **Azure**, and others, we utilize tools such as **Steampipe** and **CNquery**. These tools interact with cloud infrastructure, retrieve necessary data, and store it in an **RSSD SQLite** format for subsequent querying and analysis.

### Workflow Overview:

1. **Steampipe and CNquery Configuration**: Retrieve data from cloud platforms using the tools and save the queries in **JSONL** format for ingestion.
2. **Ingestion into surveilr**: Use the **surveilr ingest tasks** process to import the JSONL files into the surveilr system and convert them into an SQLite database format.
3. **SQLite Database**: The resulting SQLite database can be accessed, queried, and analyzed as needed.

### To begin the process, execute the following command to ingest the data directly into surveilr:

```bash
cat cloud-steampipe-surveilr.jsonl | surveilr ingest tasks
```

This command ensures that cloud platform data are ingested and stored in the **RSSD SQLite** format for later use.

---

## Prerequisites

Before proceeding, ensure the necessary tools are installed on your system (main server). These tools are essential for interacting with cloud platforms and local systems.

---

Thank you for the clarification. Based on your input, I will revise the installation instructions for **surveilr** to make it clear that **surveilr** only needs to be installed on the main server and not on other nodes.

Here’s how you can update the instructions in your README:

---

### 1. **surveilr Installation**

Ensure **surveilr** is installed on your **main server** before running the command `cat cloud-steampipe-surveilr.jsonl | surveilr ingest tasks`.

You **do not** need to install **surveilr** on other nodes (servers). It only needs to be installed on the main server where the data ingestion process occurs.

To install **surveilr** on the main server, use one of the following methods:

#### Default Installation:
```bash
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | sh
```

#### Custom Installation Path:
```bash
SURVEILR_HOME="$HOME/bin" curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | sh
```

Alternatively, you can use [eget](https://github.com/zyedidia/eget) to install **surveilr**:

```bash
eget opsfolio/releases.opsfolio.com --asset tar.gz
```

For help on using **surveilr** commands:

```bash
surveilr --version                 # Get version info
surveilr --help                    # CLI help
surveilr --completions fish | source # Shell completions for easier usage
```

---

### 2. **AWS CLI Installation**

To install **AWS CLI**, follow these steps based on your operating system.

#### Linux:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### macOS:
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### Windows:
```bash
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

For more information, refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions).

---

### 3. **Steampipe Installation**

Steampipe is used for querying cloud services, requiring plugins for each cloud provider. Follow the steps below for installation:

#### macOS:
```bash
brew install turbot/tap/steampipe
```

#### Linux/Windows (WSL2):
```bash
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
```

After installation, install the necessary plugins for your cloud provider, e.g., AWS:

```bash
steampipe plugin install aws
```

For more information, refer to the [Steampipe Plugin Documentation](https://steampipe.io/docs/managing/plugins#managing-plugins).

Configuration details are saved in the following directory:

```bash
~/.steampipe/config/
```

A sample configuration for **AWS** (`aws.spc`):

```bash
connection "aws" {
  plugin = "aws"
  regions = ["us-xxxx"]
  access_key = "AKxxxxxxxxxxxxxxxxxxH"
  secret_key = "fSxxxxxxxxxxxxxxxxxxxx7t"
}
```

To start the service:

```bash
steampipe service start
```

---

### 4. **CNquery Installation**

CNquery is another tool for querying system configurations. To install it, use the commands below:

#### Linux and macOS:
```bash
bash -c "$(curl -sSL https://install.mondoo.com/sh)"
```

#### Windows:
```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1/cnquery'));
Install-Mondoo -Product cnquery;
```

To run queries, use:

```bash
cnquery run TARGET -c "QUERY"
```

Example to list services and their statuses on a local system:

```bash
cnquery run local -c "services.list { name running }"
```

For more information, refer to the [CNquery Documentation](https://mondoo.com/docs/cnquery/index.html).

---

## **surveilrctl** Setup

**surveilrctl** automates the setup of **osQuery** and the connection of nodes to the **osQuery management server** initiated by **surveilr osquery-ms**. It simplifies installation, certificate retrieval, and node configuration.

### **Quick Installation for surveilrctl**

#### Linux & macOS:
```bash
SURVEILR_HOST=https://your-host curl -sL surveilr.com/surveilrctl.sh | bash
```

#### Windows:
To install **surveilrctl** on **Windows**, run:

```powershell
irm https://surveilr.com/surveilrctl.ps1 | iex
```

For automatic setup:

```powershell
$env:SURVEILR_HOST="https://your-host"; irm https://surveilr.com/surveilrctl.ps1 | iex
```

**Note:** Ensure to run PowerShell as Administrator on **Windows**.

### **surveilrctl Setup**

To set up **surveilrctl** and connect a node to an **osQuery management server**, use the following command:

```bash
surveilrctl setup --uri https://your-host
# Example:
surveilrctl setup --uri https://osquery-ms.example.com
```

If the server requires **Basic Authentication**, use:

```bash
surveilrctl setup --uri https://osquery-ms.example.com --username admin --password securepass
```

To specify **custom file paths** for certificates and secrets:

```bash
surveilrctl setup --uri https://osquery-ms.example.com \
  --cert-path /path/to/cert.pem \
  --secret-path /path/to/secret.txt
```

To **upgrade** to the latest version of **surveilrctl**:

```bash
surveilrctl upgrade
```

---

## **Opsfolio Penetration Toolkit**

The **Opsfolio Penetration Toolkit** is a comprehensive suite of tools for penetration testing. It includes **Nmap** for network discovery and security audits. The toolkit is fully automated via **GitHub Actions**, allowing scheduled tests without manual intervention.

### **Key Features:**

- **Automated Testing**: Runs on GitHub-managed remote runners, enabling regular tests without manual effort.
- **Comprehensive Toolset**: Includes **Nmap** for network discovery and security audits.
- **Centralized Reporting**: Aggregates Nmap XML outputs into a single SQLite database for efficient querying and reporting.
- **Advanced Querying**: Use SQL to query and analyze the data stored in the SQLite database.

### **Configuring Variables in GitHub**

To set up variables for the Nmap penetration testing workflow:

1. Go to your GitHub repository.
2. Navigate to **Settings > Secrets and variables > Actions**.
3. Under **Variables**, click **New repository variable**.
4. Name the variable `ENDPOINTS` and enter values in the format:
   `hostname|ipaddress or domain_name|boundary`.
   - Example: `EC2_PRIME|19x.xx.xx.x7|AWS_EC2`
5. Click **Add variable**.



