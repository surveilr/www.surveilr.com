#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-inventory-queries.ts - Asset and Infrastructure Inventory Management
 * ===========================================================================
 *
 * Provides comprehensive asset inventory and infrastructure monitoring capabilities
 * for Linux systems. Tracks database services, scheduled tasks, network configuration,
 * and system information for asset management, compliance, and operational oversight.
 *
 * Inventory Monitoring Capabilities:
 * - Database service discovery and process tracking (MySQL, PostgreSQL)
 * - Scheduled task inventory through crontab analysis for automation tracking
 * - Network service inventory via listening ports and active service detection
 * - Network interface configuration and addressing for infrastructure mapping
 * - System hardware and software inventory for asset management
 * - Performance metrics collection for capacity planning and optimization
 *
 * Asset Management Features:
 * - Service discovery and dependency mapping for infrastructure documentation
 * - Network topology mapping through interface and port analysis
 * - Scheduled task tracking for automation and maintenance oversight
 * - System configuration baseline establishment for change management
 * - Compliance reporting for asset tracking and security auditing
 * - Performance monitoring for resource utilization and capacity planning
 *
 * Code Architecture:
 * - OsqueryInventoryQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-inventory" notebook identifier for categorization
 * - Query methods target osQuery tables: processes, crontab, listening_ports, interface_*
 * - Platform targeting: ["linux"] for Linux-specific system and network monitoring
 *
 * Query Methods:
 * 1. MySQL Process Inventory - MySQL database service discovery and tracking
 * 2. PostgreSQL Process Inventory - PostgreSQL database service monitoring
 * 3. Cron Job Inventory - Scheduled task and automation tracking
 * 4. Listening Ports Inventory - Network service discovery and port monitoring
 * 5. Interface Addresses Inventory - Network addressing and configuration
 * 6. Interface Details Inventory - Network interface performance and configuration
 * 7. SystemInfo - Complete system hardware and software inventory
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryInventoryQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-inventory");
  }

  @osQueryMsCell({
    description: "Inventory: List MySQL database processes",
  }, ["linux"])
  "Osquery MySQL Process Inventory"() {
    return `SELECT name, path FROM processes WHERE name LIKE 'mysqld%';`;
  }

  @osQueryMsCell({
    description: "Inventory: List PostgreSQL database processes",
  }, ["linux"])
  "Osquery PostgreSQL Process Inventory"() {
    return `SELECT name, path FROM processes WHERE name LIKE 'postgres%';`;
  }

  @osQueryMsCell({
    description: "Inventory: List all cron jobs (Scheduled Tools and Tasks)",
  }, ["linux"])
  "Osquery Cron Job Inventory"() {
    return `SELECT event, minute, hour, day_of_month, month, day_of_week, command, path FROM crontab;`;
  }

  @osQueryMsCell({
    description:
      "Network Inventory: List all listening ports (in-scope services)",
  }, ["linux"])
  "Osquery Listening Ports Inventory"() {
    return `SELECT pid, port, protocol, family, address, path FROM listening_ports;`;
  }

  @osQueryMsCell({
    description: "Network Inventory: List of interface addresses",
  }, ["linux"])
  "Osquery Interface Addresses Inventory"() {
    return `SELECT interface,address,mask,broadcast,point_to_point,type FROM interface_addresses;`;
  }

  @osQueryMsCell({
    description: "Network Inventory: Detailed interface configuration",
  }, ["linux"])
  "Osquery Interface Details Inventory"() {
    // Note: Includes network performance metrics (ierrors, oerrors, idrops, odrops) for monitoring
    // interface health and identifying potential network issues or capacity problems
    return ` SELECT
          interface,
          mac,
          type,
          mtu,
          link_speed,
          ierrors,
          oerrors,
          idrops,
          odrops
        FROM interface_details;`;
  }

  @osQueryMsCell({
    description: "Osquery SystemInfo",
  }, ["linux"])
  "Osquery SystemInfo"() {
    return `SELECT *  from system_info;`;
  }
}
