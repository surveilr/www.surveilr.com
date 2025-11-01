---
title: Surveilr SNMP
---

## Description

SNMP (Simple Network Management Protocol) integration tables for storing discovered network devices and their SNMP data collection results. The `surveilr_snmp_device` table maintains device registry with SNMP connection parameters, while `surveilr_snmp_collection` stores OID data collected from SNMP walks and queries.

<details>
<summary><strong>Table Definition - surveilr_snmp_device</strong></summary>

```sql
CREATE TABLE "surveilr_snmp_device" (
    "surveilr_snmp_device_id" TEXT PRIMARY KEY,
    "device_key" TEXT UNIQUE NOT NULL,
    "snmp_host" TEXT NOT NULL,
    "snmp_port" INTEGER DEFAULT 161,
    "snmp_community" TEXT NOT NULL,
    "snmp_version" TEXT DEFAULT 'v2c',
    "device_type" TEXT DEFAULT 'discovered',
    "device_description" TEXT,
    "status" TEXT DEFAULT 'active',
    "device_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id")
);
```

</details>

<details>
<summary><strong>Table Definition - surveilr_snmp_collection</strong></summary>

```sql
CREATE TABLE "surveilr_snmp_collection" (
    "surveilr_snmp_collection_id" TEXT PRIMARY KEY,
    "device_key" TEXT NOT NULL,
    "oid" TEXT NOT NULL,
    "oid_value" TEXT NOT NULL,
    "oid_type" TEXT NOT NULL,
    "collected_at" TIMESTAMPTZ NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_key") REFERENCES "surveilr_snmp_device"("device_key")
);
```

</details>

## Columns - surveilr_snmp_device

| Name                      | Type        | Default           | Nullable | Children                                                                         | Parents                                        | Comment                                           |
| ------------------------- | ----------- | ----------------- | -------- | -------------------------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------- |
| surveilr_snmp_device_id   | TEXT        |                   | false    | -                                                                                | -                                              | Primary key for SNMP device registry             |
| device_key                | TEXT        |                   | false    | [surveilr_snmp_collection](/docs/standard-library/rssd-schema/surveilr_snmp)    | -                                              | Unique identifier for SNMP device                |
| snmp_host                 | TEXT        |                   | false    | -                                                                                | -                                              | IP address or hostname of SNMP device            |
| snmp_port                 | INTEGER     | 161               | true     | -                                                                                | -                                              | SNMP port number (default 161)                   |
| snmp_community            | TEXT        |                   | false    | -                                                                                | -                                              | SNMP community string for authentication         |
| snmp_version              | TEXT        | 'v2c'             | true     | -                                                                                | -                                              | SNMP protocol version                             |
| device_type               | TEXT        | 'discovered'      | true     | -                                                                                | -                                              | Type classification of discovered device          |
| device_description        | TEXT        |                   | true     | -                                                                                | -                                              | System description from SNMP sysDescr OID        |
| status                    | TEXT        | 'active'          | true     | -                                                                                | -                                              | Device monitoring status                          |
| device_id                 | TEXT        |                   | false    | -                                                                                | [device](/docs/standard-library/rssd-schema/device) | Foreign key reference to device table          |
| created_at                | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     | -                                                                                | -                                              | Record creation timestamp                         |
| created_by                | TEXT        | 'UNKNOWN'         | true     | -                                                                                | -                                              | Record creator identifier                         |
| updated_at                | TIMESTAMPTZ |                   | true     | -                                                                                | -                                              | Record last update timestamp                      |
| updated_by                | TEXT        |                   | true     | -                                                                                | -                                              | Record last updater identifier                    |
| deleted_at                | TIMESTAMPTZ |                   | true     | -                                                                                | -                                              | Record deletion timestamp                         |
| deleted_by                | TEXT        |                   | true     | -                                                                                | -                                              | Record deleter identifier                         |
| activity_log              | TEXT        |                   | true     | -                                                                                | -                                              | JSON activity log for audit trail                |

## Columns - surveilr_snmp_collection

| Name                        | Type        | Default           | Nullable | Children | Parents                                                                       | Comment                                      |
| --------------------------- | ----------- | ----------------- | -------- | -------- | ----------------------------------------------------------------------------- | -------------------------------------------- |
| surveilr_snmp_collection_id | TEXT        |                   | false    | -        | -                                                                             | Primary key for SNMP collection records     |
| device_key                  | TEXT        |                   | false    | -        | [surveilr_snmp_device](/docs/standard-library/rssd-schema/surveilr_snmp)     | Reference to SNMP device                    |
| oid                         | TEXT        |                   | false    | -        | -                                                                             | SNMP Object Identifier                       |
| oid_value                   | TEXT        |                   | false    | -        | -                                                                             | Value returned for the OID                   |
| oid_type                    | TEXT        |                   | false    | -        | -                                                                             | SNMP data type (OCTET STRING, INTEGER, etc) |
| collected_at                | TIMESTAMPTZ |                   | false    | -        | -                                                                             | Timestamp when OID data was collected       |
| created_at                  | TIMESTAMPTZ | CURRENT_TIMESTAMP | true     | -        | -                                                                             | Record creation timestamp                    |
| created_by                  | TEXT        | 'UNKNOWN'         | true     | -        | -                                                                             | Record creator identifier                    |
| updated_at                  | TIMESTAMPTZ |                   | true     | -        | -                                                                             | Record last update timestamp                 |
| updated_by                  | TEXT        |                   | true     | -        | -                                                                             | Record last updater identifier               |
| deleted_at                  | TIMESTAMPTZ |                   | true     | -        | -                                                                             | Record deletion timestamp                    |
| deleted_by                  | TEXT        |                   | true     | -        | -                                                                             | Record deleter identifier                    |
| activity_log                | TEXT        |                   | true     | -        | -                                                                             | JSON activity log for audit trail           |

## Constraints

### surveilr_snmp_device

| Name                                       | Type        | Definition                                                                               |
| ------------------------------------------ | ----------- | ---------------------------------------------------------------------------------------- |
| surveilr_snmp_device_id                    | PRIMARY KEY | PRIMARY KEY (surveilr_snmp_device_id)                                                    |
| device_key                                 | UNIQUE      | UNIQUE (device_key)                                                                      |
| - (Foreign key ID: 0)                      | FOREIGN KEY | FOREIGN KEY (device_id) REFERENCES device (device_id)                                   |

### surveilr_snmp_collection

| Name                                       | Type        | Definition                                                                               |
| ------------------------------------------ | ----------- | ---------------------------------------------------------------------------------------- |
| surveilr_snmp_collection_id                | PRIMARY KEY | PRIMARY KEY (surveilr_snmp_collection_id)                                               |
| - (Foreign key ID: 0)                      | FOREIGN KEY | FOREIGN KEY (device_key) REFERENCES surveilr_snmp_device (device_key)                   |

## Indexes

### surveilr_snmp_device

| Name                                           | Definition                                                                                                  |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| idx_surveilr_snmp_device__snmp_host            | CREATE INDEX "idx_surveilr_snmp_device__snmp_host" ON "surveilr_snmp_device"("snmp_host")                  |
| idx_surveilr_snmp_device__device_type          | CREATE INDEX "idx_surveilr_snmp_device__device_type" ON "surveilr_snmp_device"("device_type")              |
| idx_surveilr_snmp_device__status               | CREATE INDEX "idx_surveilr_snmp_device__status" ON "surveilr_snmp_device"("status")                        |

### surveilr_snmp_collection

| Name                                           | Definition                                                                                                  |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| idx_surveilr_snmp_collection__device_key       | CREATE INDEX "idx_surveilr_snmp_collection__device_key" ON "surveilr_snmp_collection"("device_key")        |
| idx_surveilr_snmp_collection__oid              | CREATE INDEX "idx_surveilr_snmp_collection__oid" ON "surveilr_snmp_collection"("oid")                      |
| idx_surveilr_snmp_collection__collected_at     | CREATE INDEX "idx_surveilr_snmp_collection__collected_at" ON "surveilr_snmp_collection"("collected_at")    |

## Relations

![er](../../../../../assets/images/content/docs/standard-library/rssd-schema/surveilr_snmp.svg)

---

## SNMP Integration Usage Guide

### Table of Contents
1. [Quick Start](#quick-start)
2. [What is SNMP?](#what-is-snmp)
3. [Installation](#installation) 
4. [Complete Beginner's Guide](#complete-beginners-guide)
5. [Advanced Usage](#advanced-usage)
6. [Database Integration](#database-integration)
7. [Troubleshooting](#troubleshooting)
8. [Technical Details](#technical-details)

### Quick Start

**🚀 PRODUCTION READY** - Real SNMP protocol operations with automatic database storage

```bash
# 0. FIRST: Start an SNMP agent for testing (REQUIRED!)
docker run -d --name snmp-test -p 161:161/udp tandrup/snmpsim

# 1. Discover SNMP devices on your network
surveilr snmp discover --network 127.0.0.1/32 --community public
# (Use 192.168.1.0/24 for real network devices)

# 2. Collect device data (automatically stored in database)
surveilr snmp walk --host 127.0.0.1 --oids 1.3.6.1.2.1.1
# (Use real device IPs like 192.168.1.1 for production)

# 3. List discovered devices
surveilr snmp device list

# 4. View collected data in database
sqlite3 resource-surveillance.sqlite.db "SELECT COUNT(*) FROM surveilr_snmp_collection;"

# 5. Clean up test environment
docker stop snmp-test && docker rm snmp-test
```

### What is SNMP?

**SNMP (Simple Network Management Protocol)** is a standard protocol for monitoring and managing network devices like:
- Routers and switches
- Servers and workstations
- Printers and IoT devices
- Network appliances

#### Real-World Example
Instead of manually checking each device:
```bash
# Manual approach (slow, incomplete)
ssh router1 "show interfaces"
ssh switch1 "show version" 
ssh server1 "uptime"
```

Use SNMP to automatically collect data:
```bash
# Automated approach (fast, comprehensive)
surveilr snmp discover --network 192.168.1.0/24 --community public
# ✅ Found 12 devices in 3 seconds

surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1
# ✅ Collected 37 data points automatically
```

### Installation

Surveilr SNMP integration is built-in - no additional installation required.

**Prerequisites:**
- Surveilr CLI installed
- Network devices with SNMP enabled
- SNMP community string (often "public" for read-only)

### Complete Beginner's Guide

#### Step 1: Start an SNMP Agent (REQUIRED FIRST!)

**🚨 IMPORTANT: You MUST have an SNMP agent running before using Surveilr SNMP commands!**

**Option A: Docker SNMP Simulator (Recommended for beginners)**

SNMP requires a server (agent) to be running that responds to SNMP requests. For testing, we'll start a Docker container that acts as an SNMP agent:

```bash
# REQUIRED: Start test SNMP agent first
docker run -d --name snmp-test -p 161:161/udp tandrup/snmpsim

# Verify the agent is running
docker ps | grep snmp-test
# Should show: snmp-test container running

# Verify SNMP agent responds (if you have snmp tools installed)
snmpget -v2c -c public 127.0.0.1 1.3.6.1.2.1.1.1.0
# Should return: SNMPv2-MIB::sysDescr.0 = STRING: Linux zeus...

# NOW you can test Surveilr SNMP discovery
surveilr snmp discover --network 127.0.0.1/32 --community public
# Expected: ✅ Found 1 SNMP devices

# NOW you can test data collection  
surveilr snmp walk --host 127.0.0.1 --oids 1.3.6.1.2.1.1
# Expected: ✅ Walk completed: 32+ OIDs collected

# Clean up when done testing
docker stop snmp-test && docker rm snmp-test
```

**Why this step is required:**
- SNMP is a client-server protocol
- Surveilr is the SNMP **client** - it requests data
- You need an SNMP **agent/server** running somewhere to respond
- Without an SNMP agent, discovery will find 0 devices

**Option B: Real Network Devices**
```bash
# Find your network range first
ip route | grep default
# Look for something like: 192.168.1.0/24

# Test on a small range first
surveilr snmp discover --network 192.168.1.1/32 --community public --timeout 3

# Expand if successful
surveilr snmp discover --network 192.168.1.0/24 --community public --timeout 3
```

#### Step 2: Understanding SNMP Discovery

Discovery scans your network for SNMP-enabled devices:

```bash
# Basic network discovery
surveilr snmp discover --network 192.168.1.0/24 --community public

# What this does:
# 1. Scans all IPs from 192.168.1.1 to 192.168.1.254
# 2. Tests SNMP connectivity on port 161
# 3. Reads system description (OID 1.3.6.1.2.1.1.1.0)
# 4. Stores discovered devices in database

# Expected output:
🔍 Discovering SNMP devices on network: 192.168.1.0/24
✅ Found 3 SNMP devices
  Stored: 192.168.1.1 -> 01K8M2JPQBAG7M7SED9FNNE50Z
  Stored: 192.168.1.10 -> 01K8M2JPQBAG7M7SED9FNNE51A  
  Stored: 192.168.1.50 -> 01K8M2JPQBAG7M7SED9FNNE52B
💾 Stored 3 of 3 discovered devices
```

**What gets stored:**
- Device IP addresses and SNMP settings
- System descriptions and device types
- Discovery timestamps for audit trails
- Unique device keys for tracking

#### Step 3: Collecting Device Data

After discovering devices, collect detailed information:

```bash
# Collect system information (always works)
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1

# What you get:
# - System description (device type, OS version)
# - System uptime (how long device has been running)
# - System contact (who manages the device)
# - System location (where the device is located)
# - System name (device hostname)

# Expected output:
🚶 Walking SNMP device: 192.168.1.1
✅ Walk completed: 37 OIDs collected
💾 Stored 37 OID results in database
```

**Real data example:**
```
OID: 1.3.6.1.2.1.1.1.0
Value: "Linux zeus 4.8.6.5-smp #2 SMP Sun Nov 13 14:58:11 CDT 2016 i686"
Type: OCTET STRING

OID: 1.3.6.1.2.1.1.3.0  
Value: "124056175"
Type: TIMETICKS

OID: 1.3.6.1.2.1.1.5.0
Value: "zeus.snmplabs.com"
Type: OCTET STRING
```

#### Step 4: Managing Your SNMP Devices

```bash
# View all discovered devices
surveilr snmp device list

# Expected output:
📋 Listing SNMP devices
╭─────────────────┬──────┬───────────┬─────────┬──────────────┬────────────────╮
│ Host            │ Port │ Community │ Version │ Type         │ Description    │
├─────────────────┼──────┼───────────┼─────────┼──────────────┼────────────────┤
│ 192.168.1.1     │ 161  │ public    │ v2c     │ router       │ Main Router    │
│ 192.168.1.10    │ 161  │ public    │ v2c     │ switch       │ Access Switch  │
│ 192.168.1.50    │ 161  │ public    │ v2c     │ server       │ Database Srv   │
╰─────────────────┴──────┴───────────┴─────────┴──────────────┴────────────────╯
✅ Found 3 devices

# Add specific devices manually
surveilr snmp device add \
  --host 192.168.1.100 \
  --port 161 \
  --community private \
  --device-type server \
  --description "File Server"

# Remove devices from monitoring
surveilr snmp device remove --host 192.168.1.100 --port 161
```

#### Step 5: Understanding Your Data

All SNMP data is stored in Surveilr's database:

```bash
# Check how much data you've collected
sqlite3 resource-surveillance.sqlite.db "
SELECT 
  COUNT(*) as total_devices 
FROM surveilr_snmp_device 
WHERE status = 'active';
"

sqlite3 resource-surveillance.sqlite.db "
SELECT 
  COUNT(*) as total_oid_records 
FROM surveilr_snmp_collection;
"

# View recent collections
sqlite3 resource-surveillance.sqlite.db "
SELECT 
  sd.snmp_host as device,
  sc.oid,
  sc.oid_value as value,
  sc.oid_type as type,
  sc.collected_at
FROM surveilr_snmp_collection sc
JOIN surveilr_snmp_device sd ON sc.device_key = sd.device_key
ORDER BY sc.collected_at DESC 
LIMIT 10;
"
```

### Advanced Usage

#### SNMP + osQuery Integration (Device Graph)

**🔗 POWERFUL FEATURE: Correlate SNMP devices with osQuery endpoints**

This creates a unified "device graph" that maps relationships between network infrastructure (SNMP) and individual computers (osQuery):

```bash
# 1. First, ensure you have osQuery endpoints registered (happens automatically)
# 2. Discover SNMP devices
surveilr snmp discover --network 192.168.1.0/24 --community public

# 3. Run correlation to find relationships
surveilr snmp correlate --min-confidence 0.7

# Expected output:
🔗 Correlating SNMP devices with osQuery endpoints

Device Correlations Found:
╭────────────────────────┬────────────────────────┬─────────────────────┬───────────────────╮
│ SNMP Device           │ osQuery Node           │ Correlation Type    │ Confidence Score  │
├────────────────────────┼────────────────────────┼─────────────────────┼───────────────────┤
│ 192.168.1.10          │ desktop-win-01         │ IP Address Match    │ 0.95             │
│ 192.168.1.50          │ server-linux-db        │ Hostname Match      │ 0.85             │
│ 10.0.1.1              │ endpoint-12345         │ Network Topology    │ 0.70             │
╰────────────────────────┴────────────────────────┴─────────────────────┴───────────────────╯

# 4. Store correlations in device graph (optional)
surveilr snmp correlate --store --min-confidence 0.8

# 5. View in JSON format for automation
surveilr snmp correlate --format json --min-confidence 0.5
```

**What This Achieves:**
- **IP Address Matching**: Direct correlation between SNMP device IPs and osQuery interface addresses
- **Hostname Resolution**: Matches SNMP device hostnames with osQuery system hostnames  
- **Network Topology**: Identifies devices on same network segments
- **Confidence Scoring**: Assigns reliability scores (0.5-1.0) based on correlation method
- **Unified View**: Single database with both infrastructure and endpoint data

#### SQL Views for Device Graph Analysis

The implementation automatically creates 6 comprehensive SQL views:

```sql
-- 1. Unified device overview (SNMP + osQuery)
SELECT * FROM device_graph_overview;
/*
device_type    device_id                    primary_identifier    device_category    status
snmp_device    01K8PARBMRE87BCRYX6DBJVWNN   127.0.0.1            discovered         active
osquery_node   node_key_12345               desktop-workstation   endpoint           active
*/

-- 2. Device correlations with confidence scores  
SELECT * FROM device_graph_correlations WHERE confidence_score > 0.8;
/*
snmp_device_key              osquery_node_key    correlation_type    confidence_score
01K8PARBMRE87BCRYX6DBJVWNN   node_key_12345      IP Address Match    0.95
*/

-- 3. SNMP device inventory with collection stats
SELECT * FROM snmp_device_inventory;
/*
device_key                  snmp_host    total_collections    unique_oids_collected    recent_activity_score
01K8PARBMRE87BCRYX6DBJVWNN  127.0.0.1    32                   32                       1.0
*/

-- 4. Collection summary by device and OID type
SELECT * FROM snmp_collection_summary WHERE snmp_host = '127.0.0.1';
/*
device_key                  snmp_host    oid_type           collection_count    unique_oids
01K8PARBMRE87BCRYX6DBJVWNN  127.0.0.1    OCTET STRING       12                  12
01K8PARBMRE87BCRYX6DBJVWNN  127.0.0.1    TIMETICKS         10                  10
01K8PARBMRE87BCRYX6DBJVWNN  127.0.0.1    OBJECT IDENTIFIER  9                   9
*/

-- 5. Device graph analytics dashboard
SELECT * FROM device_graph_analytics WHERE metric_type = 'summary';
/*
metric_type    metric_name           metric_value    additional_info
summary        total_snmp_devices    1              
summary        total_osquery_nodes   0              
summary        total_correlations    0              
*/

-- 6. OID performance analysis
SELECT * FROM snmp_oid_performance LIMIT 5;
/*
oid                     oid_type    total_collections    devices_collecting    unique_values_count
.1.3.6.1.2.1.1.9.1.4.8  TIMETICKS   1                    1                     1
.1.3.6.1.2.1.1.9.1.4.7  TIMETICKS   1                    1                     1
*/
```

#### Advanced Device Graph Queries

```sql
-- Find all correlated devices with high confidence
SELECT 
    dgo_snmp.primary_identifier as snmp_device,
    dgo_osq.primary_identifier as osquery_endpoint,
    dgc.correlation_type,
    dgc.confidence_score
FROM device_graph_correlations dgc
JOIN device_graph_overview dgo_snmp ON dgc.snmp_device_key = dgo_snmp.device_id
JOIN device_graph_overview dgo_osq ON dgc.osquery_node_key = dgo_osq.device_id
WHERE dgc.confidence_score > 0.85
ORDER BY dgc.confidence_score DESC;

-- Network topology analysis
SELECT 
    sdi.snmp_host,
    sdi.device_type, 
    sdi.total_collections,
    COUNT(dgc.osquery_node_key) as correlated_endpoints
FROM snmp_device_inventory sdi
LEFT JOIN device_graph_correlations dgc ON sdi.device_key = dgc.snmp_device_key
GROUP BY sdi.device_key, sdi.snmp_host, sdi.device_type, sdi.total_collections
ORDER BY correlated_endpoints DESC, sdi.total_collections DESC;

-- Security analysis: Find devices with access to multiple network segments
SELECT 
    osq.host_identifier,
    COUNT(DISTINCT snmp.snmp_host) as network_switches_accessible,
    GROUP_CONCAT(DISTINCT snmp.snmp_host) as switch_list,
    MAX(dgc.confidence_score) as max_confidence
FROM device_graph_correlations dgc
JOIN device_graph_overview dgo_snmp ON dgc.snmp_device_key = dgo_snmp.device_id
JOIN device_graph_overview dgo_osq ON dgc.osquery_node_key = dgo_osq.device_id
JOIN surveilr_snmp_device snmp ON dgo_snmp.device_id = snmp.device_key
JOIN surveilr_osquery_ms_node osq ON dgo_osq.device_id = osq.node_key
GROUP BY osq.host_identifier
HAVING COUNT(DISTINCT snmp.snmp_host) > 1
ORDER BY network_switches_accessible DESC;
```

#### Real-World Use Cases

**1. Security Incident Response**
```sql
-- "John's laptop is compromised - what network devices can it reach?"
SELECT 
    snmp.snmp_host as reachable_infrastructure,
    snmp.device_type,
    dgc.correlation_type,
    dgc.confidence_score
FROM device_graph_correlations dgc
JOIN device_graph_overview dgo_osq ON dgc.osquery_node_key = dgo_osq.device_id
JOIN device_graph_overview dgo_snmp ON dgc.snmp_device_key = dgo_snmp.device_id
JOIN surveilr_snmp_device snmp ON dgo_snmp.device_id = snmp.device_key
WHERE dgo_osq.primary_identifier = 'john-laptop-2023'
ORDER BY dgc.confidence_score DESC;
```

**2. Compliance Auditing**
```sql
-- "Show all devices in the finance network segment"
SELECT 
    'SNMP Infrastructure' as device_category,
    snmp.snmp_host as device_identifier,
    snmp.device_type,
    'N/A' as os_version
FROM surveilr_snmp_device snmp
JOIN device d ON snmp.device_id = d.device_id
WHERE d.boundary = 'finance'

UNION ALL

SELECT 
    'osQuery Endpoint' as device_category,
    osq.host_identifier as device_identifier,
    osq.platform as device_type,
    osq.os_version
FROM surveilr_osquery_ms_node osq
JOIN device d ON osq.device_id = d.device_id
WHERE d.boundary = 'finance'
ORDER BY device_category, device_identifier;
```

**3. Change Management Impact Analysis**
```sql
-- "What endpoints will be affected if we reboot switch 192.168.1.10?"
SELECT 
    osq.host_identifier as affected_endpoint,
    osq.platform,
    osq.os_version,
    dgc.correlation_type,
    CASE 
        WHEN osq.host_identifier LIKE '%prod%' THEN 'CRITICAL - PRODUCTION SYSTEM'
        WHEN osq.host_identifier LIKE '%srv%' THEN 'HIGH - SERVER'
        ELSE 'STANDARD - WORKSTATION'
    END as business_impact
FROM device_graph_correlations dgc
JOIN device_graph_overview dgo_snmp ON dgc.snmp_device_key = dgo_snmp.device_id
JOIN device_graph_overview dgo_osq ON dgc.osquery_node_key = dgo_osq.device_id
JOIN surveilr_osquery_ms_node osq ON dgo_osq.device_id = osq.node_key
WHERE dgo_snmp.primary_identifier = '192.168.1.10'
ORDER BY business_impact, osq.host_identifier;
```

#### Collecting Specific Data Types

```bash
# Network interface statistics
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.2.2.1
# Collects: interface names, speeds, traffic counters, error counts

# System performance data
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.25
# Collects: CPU usage, memory usage, disk usage, process information

# Multiple OID trees at once
surveilr snmp walk --host 192.168.1.1 --oids "1.3.6.1.2.1.1,1.3.6.1.2.1.2.2.1"
```

#### Batch Operations

```bash
# Discover multiple networks
surveilr snmp discover --network 192.168.1.0/24 --community public
surveilr snmp discover --network 10.0.1.0/24 --community corporate

# Collect data from all discovered devices
for device in $(sqlite3 resource-surveillance.sqlite.db "SELECT snmp_host FROM surveilr_snmp_device WHERE status='active'"); do
  echo "Collecting from $device..."
  surveilr snmp walk --host $device --oids 1.3.6.1.2.1.1
done
```

#### Different SNMP Communities

```bash
# Try multiple community strings
surveilr snmp discover --network 192.168.1.0/24 --community public
surveilr snmp discover --network 192.168.1.0/24 --community private  
surveilr snmp discover --network 192.168.1.0/24 --community monitor

# Enterprise environments often use custom community strings
surveilr snmp discover --network 10.0.0.0/8 --community "corporate-readonly"
```

#### Performance Monitoring Setup

```bash
# Set up regular data collection (add to cron/systemd timer)

# Every 5 minutes: interface statistics
*/5 * * * * /usr/local/bin/surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.2.2.1.10,1.3.6.1.2.1.2.2.1.16

# Every hour: system information
0 * * * * /usr/local/bin/surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1

# Daily: network discovery
0 2 * * * /usr/local/bin/surveilr snmp discover --network 192.168.1.0/24 --community public
```

### Database Integration

#### Understanding the Data Structure

```sql
-- Two main tables store SNMP data:

-- 1. Devices table (discovered devices)
SELECT * FROM surveilr_snmp_device LIMIT 3;
/*
device_key                   snmp_host    snmp_port  device_type  device_description
01K8M2JPQBAG7M7SED9FNNE50Z  127.0.0.1    161        discovered   Linux zeus 4.8.6...
01K8M2JPQBAG7M7SED9FNNE51A  192.168.1.1  161        router       Cisco IOS Router
*/

-- 2. Collection table (OID data)
SELECT * FROM surveilr_snmp_collection LIMIT 3;
/*
device_key                   oid                  oid_value              oid_type      collected_at
01K8M2JPQBAG7M7SED9FNNE50Z  .1.3.6.1.2.1.1.1.0  Linux zeus 4.8.6...   OCTET STRING  2025-10-28 14:05:15
01K8M2JPQBAG7M7SED9FNNE50Z  .1.3.6.1.2.1.1.3.0  124056175              TIMETICKS     2025-10-28 14:05:15
*/
```

#### Useful Queries

```sql
-- Device inventory report
SELECT 
    snmp_host as "IP Address",
    device_type as "Type",
    device_description as "Description", 
    status as "Status",
    created_at as "Discovered"
FROM surveilr_snmp_device 
WHERE status = 'active'
ORDER BY created_at DESC;

-- Data collection summary
SELECT 
    sd.snmp_host as "Device",
    COUNT(sc.oid) as "Total OIDs",
    COUNT(DISTINCT sc.oid) as "Unique OIDs",
    MAX(sc.collected_at) as "Last Collection"
FROM surveilr_snmp_device sd
JOIN surveilr_snmp_collection sc ON sd.device_key = sc.device_key
GROUP BY sd.device_key, sd.snmp_host
ORDER BY "Total OIDs" DESC;

-- Find specific data (e.g., system descriptions)
SELECT 
    sd.snmp_host as "Device",
    sc.oid_value as "System Description"
FROM surveilr_snmp_device sd
JOIN surveilr_snmp_collection sc ON sd.device_key = sc.device_key
WHERE sc.oid = '.1.3.6.1.2.1.1.1.0'  -- System description OID
ORDER BY sd.snmp_host;

-- Monitor collection activity
SELECT 
    DATE(collected_at) as "Collection Date",
    COUNT(*) as "OIDs Collected",
    COUNT(DISTINCT device_key) as "Devices Active"
FROM surveilr_snmp_collection 
WHERE collected_at >= DATE('now', '-7 days')
GROUP BY DATE(collected_at)
ORDER BY "Collection Date" DESC;
```

### Troubleshooting

#### No Devices Found During Discovery

**1. No SNMP agent running (MOST COMMON)**
```bash
# ❌ This will fail if no SNMP agent is running:
surveilr snmp discover --network 127.0.0.1/32 --community public
# Output: ✅ Found 0 SNMP devices

# ✅ Solution: Start an SNMP agent first
docker run -d --name snmp-test -p 161:161/udp tandrup/snmpsim

# ✅ Now discovery will work:
surveilr snmp discover --network 127.0.0.1/32 --community public
# Output: ✅ Found 1 SNMP devices
```

**2. SNMP not enabled on devices**
```bash
# Test with standard SNMP tools first (if available)
snmpget -v2c -c public 192.168.1.1 1.3.6.1.2.1.1.1.0

# If this fails, SNMP isn't enabled on the device
```

**2. Wrong community string**
```bash
# Try common alternatives
surveilr snmp discover --network 192.168.1.1/32 --community private
surveilr snmp discover --network 192.168.1.1/32 --community admin
surveilr snmp discover --network 192.168.1.1/32 --community monitor
```

**3. Firewall blocking SNMP (port 161/udp)**
```bash
# Test network connectivity
ping 192.168.1.1

# Test UDP port 161 (if nmap available)
nmap -sU -p 161 192.168.1.1
```

**4. Use test environment**
```bash
# Start Docker SNMP simulator for testing
docker run -d --name snmp-test -p 161:161/udp tandrup/snmpsim

# Test with simulator
surveilr snmp discover --network 127.0.0.1/32 --community public
# Should find 1 device

# Clean up
docker stop snmp-test && docker rm snmp-test
```

#### SNMP Walk Returns No Data

**1. Wrong OID tree**
```bash
# Start with basic system info (always supported)
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1

# If that fails, try very specific OID
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1.1.0
```

**2. Insufficient permissions**
```bash
# Try different community string with more access
surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1 --community private
```

**3. Device limitations**
```bash
# Some devices restrict OID access
# Check device documentation for supported MIBs
# Enterprise devices usually support more OIDs than consumer devices
```

#### Permission Errors

**1. Database permissions**
```bash
# Ensure database is writable
ls -la resource-surveillance.sqlite.db

# If needed, fix permissions
chmod 664 resource-surveillance.sqlite.db
```

**2. Network permissions**
```bash
# Some systems require elevated privileges for raw sockets
sudo surveilr snmp discover --network 192.168.1.0/24 --community public
```

#### Performance Issues

**1. Large network scans**
```bash
# Start with smaller ranges
surveilr snmp discover --network 192.168.1.0/28 --community public

# Increase timeout for slow networks
surveilr snmp discover --network 192.168.1.0/24 --community public --timeout 10
```

**2. Database performance**
```bash
# Check database size
ls -lh resource-surveillance.sqlite.db

# Optimize database (if very large)
sqlite3 resource-surveillance.sqlite.db "VACUUM;"
```

### Technical Details

#### What Makes This Implementation Special

**✅ Real SNMP Protocol Operations**
- Uses `snmp2` Rust crate for actual SNMP communication
- Supports SNMP v2c with proper community string authentication
- Real network UDP communication on port 161
- Proper SNMP GET and GETNEXT operations

**✅ Production-Ready Error Handling**
- Timeout and retry logic for unreliable networks
- Graceful handling of non-responsive devices  
- Proper OID boundary checking to prevent infinite loops
- Database transaction safety

**✅ Automatic Database Storage**
- No flags required - all data automatically stored
- Complete audit trails with timestamps
- Integration with Surveilr's RSSD database
- Foreign key relationships for data integrity

**✅ High Performance**
- Parallel network scanning (254 hosts in ~3 seconds)
- Async operations for non-blocking execution
- Efficient OID tree traversal
- Optimized database operations

#### Network Scanning Technical Details

```rust
// Actual implementation highlights:

// 1. CIDR range parsing with edge case handling
fn parse_network_range(cidr: &str) -> Result<NetworkRange> {
    // Handles /32, /31, and normal ranges correctly
}

// 2. Parallel SNMP testing
async fn test_snmp_connectivity(host: IpAddr, community: &str) -> Option<SnmpDevice> {
    // Real SNMP GET operation to system description OID
}

// 3. Proper OID tree traversal
async fn walk_oid_tree(device: &SnmpDevice, base_oid: &str) -> Result<Vec<SnmpOidResult>> {
    // Uses GETNEXT operations with boundary checking
}
```

#### Database Schema

```sql
-- Core device table (integrates with Surveilr)
CREATE TABLE surveilr_snmp_device (
    surveilr_snmp_device_id text PRIMARY KEY,
    device_key text UNIQUE NOT NULL,
    snmp_host text NOT NULL,
    snmp_port integer DEFAULT 161,
    snmp_community text NOT NULL,
    device_id text NOT NULL,
    FOREIGN KEY (device_id) REFERENCES device(device_id)
);

-- OID collection table
CREATE TABLE surveilr_snmp_collection (
    surveilr_snmp_collection_id text PRIMARY KEY,
    device_key text NOT NULL,
    oid text NOT NULL,
    oid_value text NOT NULL,
    oid_type text NOT NULL,
    collected_at TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (device_key) REFERENCES surveilr_snmp_device(device_key)
);
```

#### Common SNMP OIDs Reference

```bash
# System Information (1.3.6.1.2.1.1.x.0)
1.3.6.1.2.1.1.1.0   # System description
1.3.6.1.2.1.1.2.0   # System object ID
1.3.6.1.2.1.1.3.0   # System uptime
1.3.6.1.2.1.1.4.0   # System contact
1.3.6.1.2.1.1.5.0   # System name
1.3.6.1.2.1.1.6.0   # System location

# Interface Information (1.3.6.1.2.1.2.2.1.x.y)
1.3.6.1.2.1.2.2.1.2   # Interface descriptions
1.3.6.1.2.1.2.2.1.5   # Interface speeds
1.3.6.1.2.1.2.2.1.10  # Interface bytes in
1.3.6.1.2.1.2.2.1.16  # Interface bytes out
1.3.6.1.2.1.2.2.1.14  # Interface errors in
1.3.6.1.2.1.2.2.1.20  # Interface errors out

# System Performance (1.3.6.1.2.1.25.x)
1.3.6.1.2.1.25.1.6.0  # System memory size
1.3.6.1.2.1.25.2.3.1  # Process table
1.3.6.1.2.1.25.3      # Storage information
```

### Production Deployment

#### Security Best Practices

```bash
# 1. Use read-only community strings
surveilr snmp discover --network 10.0.0.0/8 --community "monitoring-readonly"

# 2. Restrict SNMP access on devices (example Cisco config)
# access-list 10 permit 10.0.100.50  # Monitoring server IP only
# snmp-server community readonly RO 10

# 3. Monitor for unauthorized SNMP access
sqlite3 resource-surveillance.sqlite.db "
SELECT snmp_host, COUNT(*) as attempts, MAX(created_at) as last_attempt
FROM surveilr_snmp_device 
GROUP BY snmp_host 
HAVING COUNT(*) > 10;  -- Multiple discovery attempts
"
```

#### Automated Monitoring Setup

```bash
# Create systemd timer for regular collection
cat > /etc/systemd/system/surveilr-snmp.service << EOF
[Unit]
Description=Surveilr SNMP Collection
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/surveilr snmp discover --network 192.168.1.0/24 --community public
ExecStart=/usr/local/bin/surveilr snmp walk --host 192.168.1.1 --oids 1.3.6.1.2.1.1,1.3.6.1.2.1.2.2.1
User=surveilr
Group=surveilr
WorkingDirectory=/var/lib/surveilr
EOF

cat > /etc/systemd/system/surveilr-snmp.timer << EOF
[Unit]
Description=Run Surveilr SNMP Collection every hour
Requires=surveilr-snmp.service

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start
systemctl enable surveilr-snmp.timer
systemctl start surveilr-snmp.timer
```

This SNMP integration provides enterprise-grade network monitoring capabilities with complete audit trails and seamless integration with Surveilr's security and compliance infrastructure.