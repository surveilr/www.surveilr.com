---
title: Guide to Surveilr Evidence Collection and Integration
home:
  ItGovernance:
    category: "evidence-collection"
description:  surveilr is an extendable file system inspector used for performing surveillance of machine resources. It is designed to walk through resources like file systems and generate an SQLite database, which can then be consumed by any computing environment that supports SQLite.
enableEditButton: true
---

# Evidence Collection Workflow

To effectively collect data from cloud platforms like **AWS**, **Azure**, etc., we use tools like **Steampipe** and **CNquery**. The corresponding JSONL files for these tools are also available in the repository. These JSONL files should be piped into a deno shell task through **surveilr ingest tasks** to generate independent **RSSD SQLite** databases..

Alternatively, instead of using **deno**, you can use this simple command:

```bash
cat cloud-steampipe.jsonl | surveilr ingest tasks
```

This process ensures that both server and cloud platform data are ingested and stored in the **RSSD SQLite** format.

---

## **Prerequisites**

### **Add the User to the Docker Group (Optional)**

Add your user to the Docker group if Docker is installed; otherwise, skip this
step

```bash
sudo usermod -aG docker "$(whoami)"
```

---

## **Tool Installation**

### **1. AWS CLI**

#### Linux
To install the AWS CLI, run the following commands.

```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### macOS

```
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### Windows
```
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

For clarification, refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions) for detailed instructions.

### **2. Steampipe**

Install Steampipe from the [downloads](https://steampipe.io/downloads) page:

#### MacOS
```
brew install turbot/tap/steampipe
```

#### Linux or Windows (WSL2)
```
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
```

Install a plugin for your favorite service (e.g. [AWS](https://hub.steampipe.io/plugins/turbot/aws), [Azure](https://hub.steampipe.io/plugins/turbot/azure), [GCP](https://hub.steampipe.io/plugins/turbot/gcp), etc):

```
steampipe plugin install aws
```

For more details you can refer the [steampipe-plugins](https://steampipe.io/docs/managing/plugins#managing-plugins)

Plugin details are stored in the following directory:

```bash
~/.steampipe/config/
```

Sample configuration for **AWS** (`aws.spc`):

```bash
connection "aws" {
  plugin = "aws"
  regions = ["us-xxxx"]
  access_key = "AKxxxxxxxxxxxxxxxxxxH"
  secret_key = "fSxxxxxxxxxxxxxxxxxxxx7t" }
```

### **3. Cnquery**

Install cnquery with the installation script:

#### Linux and macOS
```
bash -c "$(curl -sSL https://install.mondoo.com/sh)"
```

#### Windows
```
Set-ExecutionPolicy Unrestricted -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1/cnquery'));
Install-Mondoo -Product cnquery;
```

You can refer to the [cnquery documentation](https://mondoo.com/docs/cnquery/index.html) for more information.

#### Install manually
Manual installation packages are available on [GitHub releases](https://github.com/mondoohq/cnquery/releases/latest).


To run standalone queries, use:

```bash
cnquery run TARGET -c "QUERY"
```

For example, to list services and their statuses on the local system:

```bash
cnquery run local -c "services.list { name running }"
```

---

## **surveilrctl**

**surveilrctl** simplifies the installation of **osQuery** and connects nodes to
the **osQuery management server** started by **surveilr osquery-ms**. It
automates the installation, certificate retrieval, enrollment, and configuration
of nodes.

### **Quick Installation**

#### **Linux & macOS**

For automatic installation and setup, use this one-liner:

```bash
SURVEILR_HOST=https://your-host curl -sL surveilr.com/surveilrctl.sh | bash
```

#### **Windows**

To install **surveilrctl** on **Windows**, run the following PowerShell command:

```powershell
irm https://surveilr.com/surveilrctl.ps1 | iex
```

For automatic setup:

```powershell
$env:SURVEILR_HOST="https://your-host"; irm https://surveilr.com/surveilrctl.ps1 | iex
```

Note: For **Windows**, ensure you run PowerShell as Administrator.

---

## **Opsfolio Penetration Toolkit**

The Opsfolio Penetration Toolkit is a comprehensive suite of tools for
penetration testing, including **Nmap** and others, designed to assess the
security posture of networks and endpoints. The toolkit is fully automated using
**GitHub Actions**, enabling scheduled testing of IP addresses or endpoints
defined in GitHub Action variables/secrets.

### **Key Features:**

- **Automated Testing**: Runs on GitHub-managed remote runners, facilitating
  regular tests without manual intervention.
- **Comprehensive Toolset**: Includes tools like **Nmap** for network discovery
  and security audits.
- **Centralized Reporting**: Aggregates Nmap XML outputs into a single SQLite
  database for efficient querying and reporting.
- **Advanced Querying**: Use SQL to query and analyze the data stored in the
  SQLite database.

### **Configuring Variables in GitHub:**

To set up variables for the Nmap pentesting workflow:

1. Go to your repository on GitHub.
2. Navigate to **Settings > Secrets and variables > Actions**.
3. Under **Variables**, click **New repository variable**.
4. Name the variable `ENDPOINTS` and enter values in the format:
   `hostname|ipaddress or domain_name|boundary`.
   - Example: `EC2_PRIME|19x.xx.xx.x7|AWS_EC2`
5. Click **Add variable**.

