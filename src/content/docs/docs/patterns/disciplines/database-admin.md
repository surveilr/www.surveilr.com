---
title: Database Administrators
description: explanation on how database administrators make use of surveilr.
---


<!-- :::tip[Tip]
- **SQLite3 CLI Tool**: The example queries on this page use **`SQLite v3.45`**. There may be slight differences if you're using an older version.
:::

## Introduction
DevOps engineers are responsible for ensuring the smooth deployment and operation of applications. This includes preparing environments, managing CI/CD pipelines, performing database migrations, and monitoring application performance. `Surveilr` helps DevOps engineers validate adherence to these processes by extracting compliance evidence from machine attestation artifacts, simplifying the process of maintaining compliance without the need for manual documentation.


## Ensuring Compliance

DevOps engineers can execute a [task ingestion command](https://docs.opsfolio.com/surveilr/reference/ingest/tasks/) to ingest all files in the current working directory. These files are stored in a [Resource Surveillance State Database (RSSD)](/surveilr/reference/concepts/resource-surveillance) named `resource-surveillance.sqlite.db`, under the [uniform_resource](/surveilr/reference/db/surveilr-state-schema/uniform_resource) table.

### Evidence Types

- **Compliance Evidence**: Shows adherence to policies.
- **Non-Compliance Evidence**: Highlights deviations from policies.

### Common Commands

To automate the execution of shell tasks written in a file you may use the below format:

```bash
$ cat <file_name> | surveilr ingest tasks
```

To run queries in [RSSDs](/surveilr/reference/concepts/resource-surveillance):

```bash
$ sqlite3 resource-surveillance.sqlite.db "SELECT * FROM..."
```

## Examples of Work Product Artifacts (WPAs)

### Network Device Configuration

Network devices are critical components that require secure configuration and management to protect against threats. `surveilr` assists in verifying compliance with network device security policies by capturing and storing relevant data in the Resource Surveillance State Database (RSSD), facilitating streamlined monitoring and auditing processes without manual documentation.

Network device configuration must adhere to standard security practices and principles, including:

- Restricting access to network devices to authorized personnel.
- Hardening the operating systems supporting network devices.
- Applying comprehensive management tools for configuration and monitoring.
- Regularly updating network devices to mitigate vulnerabilities.
- Monitoring network devices to ensure ongoing security.

#### Using `surveilr` for Compliance Verification

To ensure compliance with network device security policies, `surveilr` gathers and stores data using osqueryi, cnquery, steampipe etc and the command `$ cat device.jsonl | surveilr ingest tasks`. This data is stored into RSSD file that can be queried for verification.

#### SQL Query for Verification of Network Device Configuration

```sql
SELECT
    d.device_name AS 'Device Name',
    d.device_type AS 'Device Type',
    d.security_principles AS 'Security Principles',
    d.access_restrictions AS 'Access Restrictions',
    d.patch_management AS 'Patch Management',
    d.routing_changes AS 'Routing Changes',
    d.configuration_review AS 'Configuration Review'
FROM
    network_device_configuration d;
```

#### Compliance Evidence

| Device Name | Device Type | Security Principles | Access Restrictions | Patch Management | Routing Changes  | Configuration Review |
| ----------- | ----------- | ------------------- | ------------------- | ---------------- | ---------------- | -------------------- |
| Router_1    | Router      | Yes                 | Limited to Staff    | Up to Date       | Reviewed Monthly | Completed            |
| Switch_1    | Switch      | Yes                 | Limited Access      | Up to Date       | Reviewed Weekly  | Completed            |

#### Non-compliance Evidence

| Device Name | Device Type | Security Principles | Access Restrictions | Patch Management | Routing Changes | Configuration Review |
| ----------- | ----------- | ------------------- | ------------------- | ---------------- | --------------- | -------------------- |
| Router_2    | Router      | No                  | Open Access         | Outdated         | Not Reviewed    | Not Completed        |
| Switch_2    | Switch      | No                  | Open Access         | Outdated         | Not Reviewed    | Not Completed        |

By utilizing `surveilr` to collect and analyze this data, organizations can ensure that network devices maintain compliance with established security standards and effectively mitigate risks associated with network vulnerabilities.



### Monitoring and Logging with IMAP Integration

Monitoring and logging are essential for tracking operational metrics and alerts within an organization. `Surveilr` supports IMAP integration for monitoring email alerts and logging of critical services.

#### Using `surveilr imap` for Alert Monitoring

By using IMAP integration with `surveilr`, organizations can monitor alerts from services like ClamAV, PSAD, CPU usage, disk space, and more, and send alerts to designated email addresses.

#### Command for IMAP Integration

```bash
$surveilr ingest imap -f "folder_name" -b 20 -e="<yes/no>" microsoft-365 -i="<client_id>" -s="<client_secret>" -m <mode>
```

#### SQL Query for IMAP Integration

To query alerts related to various services and system metrics:

```sql
SELECT
    m.alert_subject AS 'Alert Subject',
    m.alert_content AS 'Alert Content',
    m.sender_email AS 'Sender Email',
    m.timestamp AS 'Timestamp'
FROM
    imap_alerts m
WHERE
    m.alert_subject LIKE '%ClamAV%'
    OR m.alert_subject LIKE '%PSAD%'
    OR m.alert_subject LIKE '%CPU%'
    OR m.alert_subject LIKE '%Disk Space%'
    -- Add more conditions as needed for specific alerts
    AND m.status = 'Unread';
```

#### Example of IMAP Integration

| Alert Subject         | Alert Content                | Sender Email        | Timestamp           |
| --------------------- | ---------------------------- | ------------------- | ------------------- |
| ClamAV Virus Detected | Virus found in file xyz.pdf  | alert@example.com   | 2024-06-26 10:00:00 |
| PSAD Alert            | Intrusion attempt detected   | admin@example.com   | 2024-06-26 09:30:00 |
| High CPU Usage Alert  | CPU usage exceeds threshold  | monitor@example.com | 2024-06-26 09:00:00 |
| Low Disk Space Alert  | Disk space is critically low | admin@example.com   | 2024-06-26 08:30:00 |

By leveraging `surveilr` for IMAP integration, organizations can efficiently monitor alerts across various services and system metrics, ensuring timely response to critical incidents and maintaining operational integrity.


### Automating Script Execution with CE (Capturable Executables)

Capturable Executables (CE) in `surveilr` allow for automating script execution and capturing the output into a Resource Surveillance State Database (RSSD). This process streamlines monitoring and compliance verification by ensuring that script outputs are consistently logged and stored for analysis.

#### Using `surveilr ingest files` for Script Automation

To automate script execution and capture outputs into an RSSD, place your script file in the designated folder with a specific naming convention:
- If the script is in shell (sh) format, name it `file_name.surveilr[output_format].sh`.
- If the script is in TypeScript (ts) format, name it `file_name.surveilr[output_format].ts`.

#### Example Command for Script Automation

```bash
$cd <path/of/the/folder>
$surveilr ingest files
```


#### SQL Query for Verification of Script Output

To query and verify the output captured from automated scripts:

```sql
SELECT
    s.script_name AS 'Script Name',
    s.execution_date AS 'Execution Date',
    s.execution_result AS 'Execution Result'
FROM
    script_execution s
WHERE
    s.script_name LIKE '%.surveilr[output_format].%'
ORDER BY
    s.execution_date DESC;
```

#### Example of Script Execution

| Script Name                  | Execution Date      | Execution Result                 |
| ---------------------------- | ------------------- | -------------------------------- |
| myfile.surveilr-SQL.sh       | 2024-06-26 10:00:00 | SQL script executed successfully |
| script2.surveilr-JSON.ts     | 2024-06-25 15:30:00 | JSON data captured               |
| batch_script.surveilr-CSV.sh | 2024-06-24 09:45:00 | CSV file generated               |

By utilizing `surveilr` to automate script execution and capture outputs into an RSSD, organizations can maintain comprehensive records of script executions, facilitating auditability and compliance with operational procedures. -->
