---
title: Guide to surveilr Evidence Collection and Integration
home:
  ItGovernance:
    category: "evidence-collection"
description:  surveilr is an extendable file system inspector used for performing surveillance of machine resources. It is designed to walk through resources like file systems and generate an SQLite database, which can then be consumed by any computing environment that supports SQLite. This guide walks you through the necessary steps to collect evidence from cloud platforms and systems, ensuring that data is captured and stored in a structured format for further analysis.
enableEditButton: true
---

#  `surveilr` Evidence Collection and Integration Guide for SOC 2 Type 1 Compliance

## Overview
To support your SOC 2 Type 1 compliance efforts, we are providing a set of streamlined, open-source-based tools to collect critical evidence from your AWS cloud infrastructure and connected devices.

This guide outlines the necessary steps to collect and deliver a structured database containing resource configuration and system state data. We will analyze this database and produce a detailed report to support your compliance documentation.

### Tools used:

- **Steampipe** and **cnquery** for querying cloud and device configurations
- **surveilr** for ingesting and consolidating collected data into an SQLite database

Once the process is complete, securely share the generated SQLite file (`resource-surveillance.sqlite.db`) with us for review.

## **Evidence Collection Workflow**

- **Tool Installation**: Set up Steampipe, CNquery, AWS CLI, and surveilr on a centralized machine or server.
- **Data Collection**: Authenticate to AWS and execute predefined queries using Steampipe and CNquery.
- **Ingestion with surveilr**: Use surveilr to ingest collected data and create an SQLite database (RSSD).
- **Data Submission**: Share the generated SQLite database with our team for analysis.

## Prerequisites

Before starting, ensure that the following tools are installed on a **centralized machine or server** (e.g., EC2 instance, on-premises server, or local machine):

- [surveilr](https://github.com/opsfolio/releases.opsfolio.com)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Steampipe](https://steampipe.io/docs/)
- [cnquery](https://mondoo.com/docs/cnquery/index.html)

**Note**: You do *not* need to install these tools on all individual AWS resources (EC2s, etc.).

## Step-by-Step Setup Instructions

### 1. Install surveilr

#### Default Installation:
**Windows:**
```bash
irm https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/refs/heads/main/surveilr/install.ps1 | iex
```

**macOS and Linux:** 
Install in desired path by running any of the following commands:

```bash
# install in current path
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | bash

# Install globally
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="$HOME/bin" bash

# install in preferred path
curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | SURVEILR_HOME="/path/to/directory" bash
```

#### Verification Commands:
```bash
surveilr --version
surveilr --help
```
For more information, refer to the [Installation Guide](https://www.surveilr.com/docs/core/installation/).

---

### 2. Install AWS CLI

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**macOS:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Windows:**
```bash
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### Configure AWS CLI

After installing AWS CLI, you can configure it by running:

```bash
aws configure
```

This command will prompt you to enter the following details:

1. **AWS Access Key ID**
2. **AWS Secret Access Key**
3. **Default region name** (e.g., `us-west-2`)
4. **Default output format** (e.g., `json`)

For more information, please refer to the official AWS documentation on [Configuration and Credential File Settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

---

### **IAM User Permissions and Billing Access**:

To ensure that both **Steampipe** and **cnquery** can retrieve usage data (such as the services being used in your AWS account), the IAM user whose access key and secret you provide must have **billing access** and **account information access** enabled.

#### 1. **Enable IAM Access to Billing (Root User Action)**

This step must be done **once per AWS account** by the **root user**:

1. Go to the **AWS Billing Dashboard**.
2. In the **navigation pane**, choose **Billing preferences**.
3. Check the box for **Activate IAM access to the Billing and Cost Management console**.
4. Click **Save preferences**.

This allows IAM users to access billing data.

#### 2. **Enable Billing Access for the IAM User**

After enabling IAM access to billing, you must ensure that the IAM user (whose **access key** and **secret key** you provide to Steampipe) has the correct permissions to access billing and account data.

To grant permissions:

1. In your **AWS account**, go to the **IAM console**.
2. Select the IAM user that will be used for Steampipe.
3. Under the **Permissions** tab, attach the necessary permissions for billing:

   * Ensure the IAM user has the **`aws-portal`** permissions (or a policy that grants `aws-portal:ViewBilling` and `aws-portal:ViewAccountInfo`).
   * You can attach the following permissions directly or use a predefined AWS managed policy `arn:aws:iam::aws:policy/job-function/Billing`.

   Example IAM policy that grants permissions:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
          "Action": [
        "aws-portal:ViewBilling",
        "aws-portal:ViewUsage",
        "aws-portal:ViewAccount",
        "ce:Get*",
        "budgets:ViewBudget"
        ],
         "Resource": "*"
       }
     ]
   }
   ```

For more details on enabling billing access for IAM users and managing permissions, refer to the official [AWS documentation](https://docs.aws.amazon.com/cost-management/latest/userguide/billing-permissions-ref.html).
       

   * **Note**: The permission `"aws-portal:ViewAccount"` is necessary for retrieving account-related data from the billing system, such as linked accounts, payer account details, and more.

---

### 3. Install Steampipe

Steampipe is used to query cloud services. You need to install the plugins for each cloud provider.

#### macOS:
```bash
brew install turbot/tap/steampipe
```

#### Linux/Windows (WSL2):
```bash
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"
```

After installation, install the necessary plugins for your cloud provider (e.g., AWS):
```bash
steampipe plugin install aws
```

For more information, refer to the [Steampipe Plugin Documentation](https://steampipe.io/docs/managing/plugins#managing-plugins).


Plugin details are stored in the following directory:
```bash
~/.steampipe/config/
```

#### Sample AWS Configuration (`aws.spc`):

After the IAM user is set up with the necessary permissions, configure Steampipe to use the **access key** and **secret key** for the IAM user.

Sample configuration file `aws.spc`:

```bash
connection "aws" {
  plugin = "aws"
  profile = "default"  ## Ensure the profile name matches the one in the AWS credentials file
  regions = ["us-west-2"]   ## Modify this region or add more regions as needed
  access_key = "AKxxxxxxxxxxxxxxxxxxH"
  secret_key = "fSxxxxxxxxxxxxxxxxxxxx7t"
}
```

This configuration tells Steampipe how to authenticate with AWS and which regions to query.

#### To start the Steampipe service:

```bash
steampipe service start
```
---

### 4. Install CNquery

#### Linux & macOS:
```bash
bash -c "$(curl -sSL https://install.mondoo.com/sh)"
```

#### Windows:
```bash
Set-ExecutionPolicy Unrestricted -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1/cnquery'))
Install-Mondoo -Product cnquery
```

To run queries:
```bash
cnquery run TARGET -c "QUERY"
```

Example to list services and their statuses:
```bash
cnquery run local -c "services.list { name running }"
```

Make sure your AWS credentials and region are properly configured for AWS queries.
For more details, refer to the [CNquery Documentation](https://mondoo.com/docs/cnquery/cloud/aws/).

To make use of various query packs, such as the AWS asset inventory and incident response packs, you need to clone the respective `cnquery-packs`. These query packs are available in Mondoo’s [GitHub repo](https://github.com/mondoohq/cnquery-packs).

You can follow these steps:

- Clone the `cnquery-packs` repository to your local `$HOME` directory:

```bash
cd ~
git clone https://github.com/mondoohq/cnquery-packs.git
```

For more details, refer to the [core AWS query packs](https://mondoo.com/docs/cnquery/cloud/aws/account/#analyze-your-environment-with-aws-query-packs)

---

## Data Collection and Ingestion (Cloud)

We will provide you with `.jsonl` files containing specific **Steampipe** and **CNquery** queries.

First, download the `.jsonl` file to your working directory — the same location where you'll be running the `surveilr` ingestion command.

To ingest the queries using **surveilr**, run:

```bash
cat filename.jsonl | surveilr ingest tasks
```

**Example:**

```bash
cat cloud-steampipe-surveilr.jsonl | surveilr ingest tasks
```

**Important**: Replace `filename.jsonl` with the actual name of the **JSONL** file you downloaded and saved. If you saved the file with a different name (e.g., `cloud-query-file.jsonl`), use that file name instead.

This command will produce a **Resource Surveillance State Database (RSSD)** in SQLite format.

---

## Server Data Collection Without Centralized Management

Server-related evidence can be collected using **osquery** and **surveilr**, both of which need to be installed individually on each server. This approach is well-suited for environments where a [centralized management server](#optional-centralized-node-management-advanced) is not required or preferred.

#### Steps for Server Data Collection:

1. **Install osquery and surveilr on Each Server**:


   * To use this alternative method, you need to install both **osquery** and **surveilr** on each server (including droplets, EC2 instances, VMs, etc.).

   * **Install osquery**:

     * For installing **osquery**, follow the installation steps outlined in the [surveilrctl-installation](#quick-installation-on-nodes) . 

   * **Install surveilr**:

     * The installation process for `surveilr` is detailed in the [surveilr-installation](#1-install-surveilr).

2. **Execute the Command to Ingest the Data**:

   * Download the server `.jsonl` file to your working directory — the same location where you'll be running the `surveilr` ingestion command.

   * Once `osquery` and `surveilr` are installed, and the **server-evidence-surveilr.jsonl** file is saved on each server, run the following command to ingest the data into an SQLite database:

   ```bash
   cat server-evidence-surveilr.jsonl | surveilr ingest tasks
   ```

   * **Important**: Replace `server-evidence-surveilr.jsonl` with the actual name of the JSONL file you saved on the server. If you saved it with a different name (e.g., `my-server-evidence.jsonl`), use that file name instead.

   * This command will generate a **Resource Surveillance State Database (RSSD)** in SQLite format, which you can then share with us for analysis.

---

## Centralized Node Management (Advanced)

If you prefer connecting individual EC2 instances or servers directly to a centralized osquery management server, use **surveilrctl** for automated setup.

#### Centralized Node Management Overview:
With the centralized node management method, the osquery-ms server runs on a centralized server, and all servers (including droplets, EC2 instances, VMs, etc.) are connected as nodes using surveilrctl. This method allows you to collect server-related evidence from multiple resources efficiently.

#### Quick Installation on Nodes:

**Linux & macOS:**
```bash
SURVEILR_HOST=https://your-management-server curl -sL surveilr.com/surveilrctl.sh | bash
```

**Windows:**
```bash
irm https://surveilr.com/surveilrctl.ps1 | iex
```

#### Example Setup:
```bash
surveilrctl setup --uri https://osquery-ms.example.com
```
---

### Delivering the SQLite Evidence Database

Once evidence collection is complete, securely share the generated `resource-surveillance.sqlite.db` file using one of the following methods:

* **Google Drive**: Shareable link
* **Dropbox**: Shared folder or link
* **OneDrive, Box**, or other secure file-sharing services

Ensure that the file permissions are set to allow our team to access the file.

### Dumping and Compressing the SQLite Database

To reduce the size of the SQLite database and share it efficiently, you can dump the database as a text file. This can result in significant disk space savings due to the repetitive nature of the SQL statements. Use the following commands for dumping and reconstructing the database:

* To dump the database as a text file:

  ```bash
  sqlite3 my_database.db .dump > my_database.db.txt
  ```

* To reconstruct the database from the text file:

  ```bash
  cat my_database.db.txt | sqlite3 my_reconstructed_database.db
  ```

Additionally, to compress the dumped file and save space, you can use gzip:

* Dump and compress the database:

  ```bash
  sqlite3 explorer.db .dump | gzip -c > explorer.db.txt.gz
  ```

This approach ensures that the SQLite database is both compact and easy to share, while maintaining integrity for future reconstruction.

---

## Additional Toolkit: Penetration Testing (Optional)

For organizations seeking additional assurance, we offer the **Opsfolio Penetration Toolkit**, which includes:

- Automated scheduled security scans (e.g., Nmap) via GitHub Actions
- Centralized SQLite-based reporting
- Custom SQL queries for advanced data analysis

### Configuring Variables in GitHub

1. Go to your GitHub repository.
2. Navigate to **Settings > Secrets and variables > Actions**.
3. Under **Variables**, click **New repository variable**.
4. Name the variable `ENDPOINTS` and enter values in the format:
   `hostname|ipaddress or domain_name|boundary`.

Example:
```bash
EC2_PRIME|19x.xx.xx.x7|AWS_EC2
```

For more details, refer to the [Opsfolio PenTest Toolkit](https://github.com/opsfolio/pentest.opsfolio.com).

---

## Support

Should you encounter any issues during setup or data collection, our technical team is available to assist you.
