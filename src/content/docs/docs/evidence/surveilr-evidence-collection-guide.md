```yaml
title: Guide to surveilr Evidence Collection and Integration
home:
  ItGovernance:
    category: "evidence-collection"
description:  surveilr is an extendable file system inspector used for performing surveillance of machine resources. It is designed to walk through resources like file systems and generate an SQLite database, which can then be consumed by any computing environment that supports SQLite. This guide walks you through the necessary steps to collect evidence from cloud platforms and systems, ensuring that data is captured and stored in a structured format for further analysis.
enableEditButton: true
```

---

# Evidence Collection Workflow

To effectively collect data from cloud platforms like **AWS**, **Azure**, and others, we use tools like **Steampipe** and **CNquery**. These tools allow you to interact with cloud infrastructure and systems, retrieve necessary data, and store it in an **RSSD SQLite** format for later querying and analysis.

The following steps outline how to collect and process the required evidence:

1. **Steampipe and CNquery Configuration**: Retrieve data from your cloud platforms using the tools, and then save the results in a JSONL file format.
2. **Ingestion into surveilr**: Use the **surveilr ingest tasks** process to import the JSONL files into the surveilr system and convert them into an SQLite database format.
3. **SQLite Database**: The resulting SQLite database can then be accessed, queried, and analyzed as needed.

To begin the process, use the following command to ingest the data directly into surveilr:

```bash
cat cloud-steampipe-surveilr.jsonl | surveilr ingest tasks
```

This will ensure both server and cloud platform data are ingested and stored in the **RSSD SQLite** format for further use.

---

## **Prerequisites**

### **Tool Installation**

Before starting, make sure you have the necessary tools installed on your system. These tools will help you interact with cloud platforms and your local systems.

---

### **1. AWS CLI**

#### **Linux**
To install the AWS CLI on Linux, run the following commands:

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
```

#### **macOS**
For macOS, use the following:

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### **Windows**
On Windows, run:

```bash
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

For more information, refer to the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions).

---

### **2. Steampipe**

Steampipe is used to query cloud services, and it requires specific plugins for each cloud provider. Here's how to install and configure Steampipe:

#### **MacOS**

```bash
brew install turbot/tap/steampipe
```

#### **Linux/Windows (WSL2)**

```bash
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
```

Once Steampipe is installed, you'll need to install the appropriate plugins for your cloud service. For example, to install the AWS plugin, use:

```bash
steampipe plugin install aws
```

For more details, refer to the [steampipe-plugins documentation](https://steampipe.io/docs/managing/plugins#managing-plugins).

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

### **3. CNquery**

CNquery is another tool that helps query system configurations. Here's how to install it:

#### **Linux and macOS**

```bash
bash -c "$(curl -sSL https://install.mondoo.com/sh)"
```

#### **Windows**

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1/cnquery'));
Install-Mondoo -Product cnquery;
```

For more information, refer to the [CNquery documentation](https://mondoo.com/docs/cnquery/index.html).

To run queries, use:

```bash
cnquery run TARGET -c "QUERY"
```

For example, to list services and their statuses on a local system:

```bash
cnquery run local -c "services.list { name running }"
```

---

## **surveilrctl**

**surveilrctl** is used to automate the setup of **osQuery** and the connection of nodes to the **osQuery management server** initiated by **surveilr osquery-ms**. This tool simplifies installation, certificate retrieval, and node configuration.

### **Quick Installation**

#### **Linux & macOS**

For automatic installation and setup, use this one-liner:

```bash
SURVEILR_HOST=https://your-host curl -sL surveilr.com/surveilrctl.sh | bash
```

#### **Windows**

To install **surveilrctl** on **Windows**, run:

```powershell
irm https://surveilr.com/surveilrctl.ps1 | iex
```

For automatic setup:

```powershell
$env:SURVEILR_HOST="https://your-host"; irm https://surveilr.com/surveilrctl.ps1 | iex
```

**Note:** For **Windows**, ensure you run PowerShell as Administrator.

---

## **Opsfolio Penetration Toolkit**

The Opsfolio Penetration Toolkit is a comprehensive suite of tools designed for penetration testing. It includes tools like **Nmap** for network discovery and security audits. The toolkit is fully automated using **GitHub Actions**, enabling scheduled tests without manual intervention.

### **Key Features:**

- **Automated Testing**: The toolkit runs on GitHub-managed remote runners, facilitating regular tests without manual intervention.
- **Comprehensive Toolset**: Includes **Nmap** for network discovery and security audits.
- **Centralized Reporting**: Aggregates Nmap XML outputs into a single SQLite database for efficient querying and reporting.
- **Advanced Querying**: Use SQL to query and analyze the data stored in the SQLite database.

### **Configuring Variables in GitHub:**

To set up variables for the Nmap penetration testing workflow:

1. Go to your repository on GitHub.
2. Navigate to **Settings > Secrets and variables > Actions**.
3. Under **Variables**, click **New repository variable**.
4. Name the variable `ENDPOINTS` and enter values in the format:
   `hostname|ipaddress or domain_name|boundary`.
   - Example: `EC2_PRIME|19x.xx.xx.x7|AWS_EC2`
5. Click **Add variable**.
