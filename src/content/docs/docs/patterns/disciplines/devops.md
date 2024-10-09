---
title: DevOps Engineers
description: explanation on how DevOps engineers  make use of surveilr.
---

:::tip[Tip]
- **SQLite3 CLI Tool**: The example queries on this page use **`SQLite v3.45`**. There may be slight differences if you're using an older version.
:::

## Introduction
DevOps engineers play a crucial role in ensuring that a company's infrastructure, deployment processes, and operational practices are aligned with security, privacy, safety, and regulatory compliance policies. Resource surveillance (`surveilr`) helps DevOps engineers validate adherence to these policies by extracting compliance evidence from machine attestation artifacts, simplifying the process of maintaining compliance without the need for manual documentation.

## Capturing Compliance Evidence with `surveilr`

`surveilr` provides several types of [ingestion](/docs/core/cli/ingest-commands/files#ingest-files) [commands](/docs/core/cli/cli-commands) for DevOps engineers to execute. These commands captures compliance evidence from [Work Product Artifacts (WPAs)](/docs/core/concepts/work-product-artifacts/) and store them in a [Resource Surveillance State Database (RSSD)](/docs/core/concepts/resource-surveillance/) named `resource-surveillance.sqlite.db`, under the [uniform_resource](/docs/standard-library/rssd-schema/uniform_resource/) table. 

### Evidence Types

- **Compliance Evidence**: Shows adherence to policies.
- **Non-Compliance Evidence**: Highlights deviations from policies.


### Common Commands

- To [ingest files](/docs/core/cli/ingest-commands/files#ingest-files) in the current directory:
  ```bash
  $ surveilr ingest files
  ```

- Testing shell [tasks](/docs/core/cli/ingest-commands/tasks/)

  ```bash
  $ cat <filename> | surveilr ingest tasks
  ```

- To run queries in RSSDs:
  ```sql
  sqlite3 resource-surveillance.sqlite.db "SELECT * FROM..."
  ```


## Examples of Work Product Artifacts (WPAs)
### Infrastructure Compliance

A company's policy might state: "All infrastructure must be provisioned and maintained according to best practices and regulatory standards." This policy includes the following requirements:

- Use Infrastructure as Code (IaC) tools like Terraform or Ansible.
- Regularly update infrastructure components to the latest versions.
- Perform routine security audits and patches.

#### Using `surveilr` for Policy Compliance and Evidence Capture
To automate tasks related to security audits and updates, DevOps engineers can utilize `surveilr` commands to streamline compliance validation:

1. Security Audits:

    - Execute CNQuery scans using predefined packs for AWS inventory and Linux incident response:

        ```bash
        $ cat cloud-cnquery.jsonl | surveilr ingest tasks
        ``` 

        This command ingests tasks from a JSONL file (`cloud-cnquery.jsonl`) that includes CNQuery tasks to scan AWS and Linux environments for security compliance.

2. Remote Server Integration:

    - [Merge](http://localhost:4321/docs/core/admin/merge/) data from remote servers into a consolidated RSSD using:
  
        ```bash
        $ surveilr admin merge
        ```

        This command merges data collected from various remote servers, creating an aggregated RSSD, which can be queried for compliance evidence.


#### SQL Query for Verification of Infrastructure Compliance
```sql
SELECT 
    d.state_sysinfo -> 'host_name' AS 'Host Name',
    i.infrastructure_component AS 'Component',
    i.version AS 'Version',
    i.compliance_status AS 'Compliance Status',
    i.last_update_date AS 'Last Update Date'
FROM 
    infrastructure_compliance i
JOIN 
    device d ON i.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Component | Version | Compliance Status | Last Update Date |
| ---------- | --------- | ------- | ----------------- | ---------------- |
| HostName_1 | Terraform | 1.1.0   | Compliant         | 2024-06-01       |
| HostName_2 | Ansible   | 2.10.7  | Compliant         | 2024-06-10       |

#### Non-compliance Evidence

| Host Name  | Component | Version | Compliance Status | Last Update Date |
| ---------- | --------- | ------- | ----------------- | ---------------- |
| HostName_1 | Terraform | 0.12.0  | Non-Compliant     | 2024-05-15       |
| HostName_2 | Ansible   | 2.9.6   | Non-Compliant     | 2024-06-01       |


### CI/CD Pipeline
A company's policy mandates that all code deployments pass through a CI/CD pipeline, including testing and security scanning stages, and automation of deployment processes. This policy includes the following requirements:

- Use CI/CD tools like GitLab CI, or GitHub Actions.
- Ensure pipelines include testing and security scanning stages.
- Automate deployment processes.

#### Using `surveilr` for Policy Compliance and Evidence Capture
Here are examples of how `surveilr` commands can be applied to enhance compliance and operational efficiency:

1. **Penetration Toolkit Integration:**

    - Automate security assessments using tools like Nmap via GitHub Actions:
        ```yaml
            name: Network Scan Workflow
            on:
            push:
            workflow_dispatch:

            jobs:
            build:
                runs-on: ubuntu-latest
                timeout-minutes: 30
                steps:
                - uses: actions/checkout@v2

                - name: Generate result file
                    run: |
                    sudo -E bash -x nmap-pentest.sh
                    env:
                    ENDPOINTS: ${{ vars.ENDPOINTS }}

                - name: Upload ZIP to S3
                    uses: NotCoffee418/s3-zip-upload@v1.4
                    env:
                    AWS_SECRET_ID: ${{ secrets.AWS_SECRET_ID }}
                    AWS_SECRET_KEY: ${{ secrets.AWS_SECRET_KEY }}
                    BUCKET_NAME: ${{ secrets.BUCKET_NAME }}
                    AWS_REGION: us-east-1
                    SOURCE_MODE: ZIP
                    SOURCE_PATH: /home/nmap/result/
                    DEST_FILE: nmap.zip
         ```

        This workflow automates network scans using Nmap and uploads results to an S3 bucket, which can then be merged with the ARSSD for compliance evidence using `surveilr`.

2. **Assurance GitLab CI/CD Integration:**

   - Use GitLab CI/CD to manage and deploy assurance databases (`ATC assurance.db`) to `suite.opsfolio.com`:
        ```yaml
        variables:
        OPSFOLIO_SERVER: <server_name>

        stages:
        - generate

        build:
        image: denoland/deno:latest
        stage: generate
        before_script:
            - apt-get update && apt-get install -y sqlite3 openssh-client 
            - eval $(ssh-agent -s)
            - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
            - mkdir -p ~/.ssh
            - chmod 700 ~/.ssh   
        script:
            - rm -rf assurance-merge/content/*
            - cd fcr
            - ./fcr.omc.sqla.ts sql --dest ../assurance-merge/content/fcr-opsfolio.auto.sqla.sql
            - cd ../hetzner
            - ./hetzner.omc.sqla.ts sql --dest ../assurance-merge/content/hetzner-opsfolio.auto.sqla.sql
            - cd ../digital-ocean
            - ./digital-ocean.omc.sqla.ts sql --dest ../assurance-merge/content/do-opsfolio.auto.sqla.sql
            - cd ../assurance-merge
            - deno run --allow-read --allow-write assurance_merge_sqls.ts
            - deno run --allow-env --allow-read --allow-run assurance_generate_db.ts
            - scp -o StrictHostKeyChecking=no aggregated-assurance.db ${OPSFOLIO_SERVER_SSH_USER}@${OPSFOLIO_SERVER}:~
            - ssh -p 22 -o StrictHostKeyChecking=no -t ${OPSFOLIO_SERVER_SSH_USER}@${OPSFOLIO_SERVER} "echo ${OPSFOLIO_SERVER_SSH_USER_PASSWORD} |sudo -S su - root -c 'bash -i /opt/suite-opsfolio-com/assurance.sh'"
        ```

        This GitLab CI/CD pipeline automates the generation and deployment of assurance databases (`aggregated-assurance.db`) to `suite.opsfolio.com`, leveraging `surveilr` to maintain compliance and generate evidence for audits.

#### SQL Query for Verification of CI/CD Pipeline Compliance

```sql
SELECT 
    d.name AS 'Host Name',
    c.pipeline_name AS 'Pipeline Name',
    c.status AS 'Pipeline Status',
    c.last_run_date AS 'Last Run Date',
    c.security_scan_passed AS 'Security Scan Passed'
FROM 
    cicd_compliance c
JOIN 
    device d ON c.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Pipeline Name     | Pipeline Status | Last Run Date | Security Scan Passed |
| ---------- | ----------------- | --------------- | ------------- | -------------------- |
| HostName_1 | Build and Deploy  | Successful      | 2024-06-01    | Yes                  |
| HostName_2 | Integration Tests | Successful      | 2024-06-10    | Yes                  |

#### Non-compliance Evidence

| Host Name  | Pipeline Name     | Pipeline Status | Last Run Date | Security Scan Passed |
| ---------- | ----------------- | --------------- | ------------- | -------------------- |
| HostName_1 | Build and Deploy  | Failed          | 2024-05-15    | No                   |
| HostName_2 | Integration Tests | Failed          | 2024-06-01    | No                   |



1. **GitHub Integration:**

    - Use `surveilr` to ingest configuration data from GitHub repositories:
        ```bash
        $ surveilr ingest plm -d="dbname.sqlite.db" -e="yes" -b 200 github -o "organization_name" -r "repository_name" -s "open"
        ```
        This command imports configuration data (`plm`) from GitHub repositories (`organization_name/repository_name`) into the SQLite database (`dbname.sqlite.db`). It ensures configurations are captured and stored for compliance validation.

2. **Jira Integration:**

    - Similarly, integrate with Jira to manage configuration data:
        ```bash
        $ surveilr ingest plm -d "dbname.sqlite.db" -e "<yes/no>" -b <batch size/count> jira -o "<jira_account_url>" -p "project_name" -u "jira_user" -k "<jira_api_key>"
        ```

        This command imports project lifecycle management (PLM) data from Jira (`jira_account_url/project_name`) into the SQLite database (`dbname.sqlite.db`). It supports batch ingestion (`-b`) and optionally includes or excludes archived data (`-e`). This integration ensures configurations tracked in Jira are compliant with organizational standards.



### Monitoring and Logging
A company's policy mandates that all systems must have monitoring and logging enabled using tools like Prometheus or Grafana, with centralized logging via ELK stack, and alerts set up for critical events.This policy includes the following requirements:

- Use monitoring tools like Prometheus or Grafana.
- Implement centralized logging with tools like ELK stack.
- Set up alerts for critical events.

#### Using `surveilr` for Policy Compliance and Evidence Capture
Integrate `surveilr` commands to gather alerts and ensure compliance with monitoring and logging policies:

1. **IMAP Integration for Alerts Collection:**
    - Collect alerts from monitoring tools (e.g., Prometheus or Grafana) and send them to email addresses. Use `surveilr` to ingest these alerts into the RSSD:
        ```bash
        $ surveilr ingest imap -f "folder_name" -b 20 -e="<yes/no>" microsoft-365 -i="<client_id>" -s="<client_secret>" -m <mode>
        ```
        This command retrieves alerts from an IMAP mailbox (`folder_name`) associated with Microsoft 365 email service, using credentials (`client_id, client_secret`), and stores them in the RSSD. It facilitates compliance monitoring and evidence collection for alert management.

2. **GitHub Integration:**

    - Use `surveilr` to ingest configuration data from GitHub repositories:
        ```bash
        $ surveilr ingest plm -d="dbname.sqlite.db" -e="yes" -b 200 github -o "organization_name" -r "repository_name" -s "open"
        ```
        This command retrieves data from GitHub repositories (`organization_name/repository_name`) into the SQLite database (`dbname.sqlite.db`).It facilitates compliance monitoring and evidence collection of github tickets.

3. **Jira Integration:**

    - Similarly, integrate with Jira to manage configuration data:
        ```bash
        $ surveilr ingest plm -d "dbname.sqlite.db" -e "<yes/no>" -b <batch size/count> jira -o "<jira_account_url>" -p "project_name" -u "jira_user" -k "<jira_api_key>"
        ```

        This command imports project lifecycle management (PLM) data from Jira (`jira_account_url/project_name`) into the SQLite database (`dbname.sqlite.db`). It supports batch ingestion (`-b`) and optionally includes or excludes archived data (`-e`). 



#### SQL Query for Verification of Monitoring and Logging Compliance

```sql

SELECT 
    d.name AS 'Host Name',
    m.monitoring_tool AS 'Monitoring Tool',
    m.logging_tool AS 'Logging Tool',
    m.alerts_enabled AS 'Alerts Enabled',
    m.last_check_date AS 'Last Check Date'
FROM 
    monitoring_logging m
JOIN 
    device d ON m.device_id = d.device_id;
```

#### Compliance Evidence
| Host Name  | Monitoring Tool | Logging Tool | Alerts Enabled | Last Check Date |
| ---------- | --------------- | ------------ | -------------- | --------------- |
| HostName_1 | Prometheus      | ELK Stack    | Yes            | 2024-06-01      |
| HostName_2 | Grafana         | ELK Stack    | Yes            | 2024-06-10      |

#### Non-compliance Evidence
| Host Name  | Monitoring Tool | Logging Tool | Alerts Enabled | Last Check Date |
| ---------- | --------------- | ------------ | -------------- | --------------- |
| HostName_1 | Prometheus      | None         | No             | 2024-05-15      |
| HostName_2 | None            | ELK Stack    | No             | 2024-06-01      |


### Security Compliance
A company's policy might state: "All systems must adhere to security best practices and undergo regular security assessments." This policy includes the following requirements:

- Implement security controls like firewalls and intrusion detection systems.
- Conduct regular vulnerability assessments and penetration tests.
- Ensure compliance with security standards like ISO 27001 or NIST.

#### Using `surveilr` for Policy Compliance and Evidence Capture
Utilize `surveilr` commands to enforce and verify security compliance measures:

1. UDI PGP:
    - UDI PostgreSQL Proxy for remote SQL is a CLI tool starts up a server which pretends to be PostgreSQL but proxies its SQL to other CLI commands (called SQL Suppliers).
  
        ```bash
        $ surveilr udi pgp -c ./config-full.ncl
        ```
        This initiates the surveilr tool to perform operations related to UDI-PGP. You can now use psql to send a query to the daemon.

        for example:

        ```sql
        psql -h <hostname> -p <port> -U <username> -d <db_name> -c "select cpu_type, cpu_brand, hardware_vendor, hardware_model from system_info"
        ```

#### SQL Query for Verification of Security Compliance Compliance

```sql

SELECT 
    d.name AS 'Host Name',
    s.security_control AS 'Security Control',
    s.assessment_date AS 'Assessment Date',
    s.compliance_status AS 'Compliance Status',
    s.findings AS 'Findings'
FROM 
    security_compliance s
JOIN 
    device d ON s.device_id = d.device_id;
```

#### Compliance Evidence
| Host Name  | Security Control    | Assessment Date | Compliance Status | Findings |
| ---------- | ------------------- | --------------- | ----------------- | -------- |
| HostName_1 | Firewall            | 2024-06-01      | Compliant         | None     |
| HostName_2 | Intrusion Detection | 2024-06-10      | Compliant         | None     |

#### Non-compliance Evidence
| Host Name  | Security Control    | Assessment Date | Compliance Status | Findings            |
| ---------- | ------------------- | --------------- | ----------------- | ------------------- |
| HostName_1 | Firewall            | 2024-05-15      | Non-Compliant     | Open Ports          |
| HostName_2 | Intrusion Detection | 2024-06-01      | Non-Compliant     | Outdated Signatures |


By following these structured queries and ensuring the storage of evidence in the RSSD, DevOps engineers can systematically monitor and ensure adherence to company policies using `surveilr`.