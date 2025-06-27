#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * queries.sql.ts - osQuery Management Server Query Aggregator
 * ===========================================================
 *
 * Central orchestrator for all osQuery monitoring queries in the Surveilr RSSD system.
 * Aggregates security monitoring capabilities across multiple domains into unified SQL output
 * for comprehensive endpoint surveillance, compliance monitoring, and threat detection.
 *
 * Monitoring Domains:
 * - Docker: Container infrastructure, images, networks, and daemon monitoring
 * - Security Compliance: Access controls, user permissions, and policy validation
 * - Inventory: Asset management, software tracking, and hardware monitoring
 * - Network Monitoring: Network interfaces, connections, and traffic analysis
 * - File Audit: File system changes, permissions, and integrity monitoring
 * - User-Process Mapping: User-process correlation and privilege tracking
 * - Antivirus: Security software detection and endpoint protection validation
 *
 * Code Architecture:
 * - Imports seven specialized query classes from ./queries/ directory
 * - SQL() function instantiates all query classes and calls cnb.TypicalCodeNotebook.SQL()
 * - Each class extends TypicalCodeNotebook with @osQueryMsCell decorated methods
 * - Generated SQL creates code_notebook_cell entries with governance metadata
 * - Main execution block outputs joined SQL statements for surveilr shell consumption
 *
 * Output Format:
 * - Produces INSERT statements for code_notebook_kernel and code_notebook_cell tables
 * - Includes query metadata: execution intervals, platform targets, jq filters
 * - Ready for direct execution by surveilr shell or database ingestion
 * - Supports compliance requirements: PCI DSS, HIPAA, SOX, ISO 27001
 */

import { codeNB as cnb } from "./deps.ts";

import { OsqueryDockerQueries } from "./queries/osquery-docker-queries.ts";
import { OsquerySecurityComplianceQueries } from "./queries/osquery-security-compliance-queries.ts";
import { OsqueryInventoryQueries } from "./queries/osquery-inventory-queries.ts";
import { OsqueryNetworkMonitoringQueries } from "./queries/osquery-network-monitoring-queries.ts";
import { OsqueryFileAuditQueries } from "./queries/osquery-file-audit-queries.ts";
import { OsqueryUserProcessMappingQueries } from "./queries/osquery-user-process-mapping-queries.ts";
import { OsqueryAntivirusQueries } from "./queries/osquery-antivirus-queries.ts";

async function SQL() {
  return await cnb.TypicalCodeNotebook.SQL(
    new OsqueryDockerQueries(),
    new OsquerySecurityComplianceQueries(),
    new OsqueryInventoryQueries(),
    new OsqueryNetworkMonitoringQueries(),
    new OsqueryFileAuditQueries(),
    new OsqueryUserProcessMappingQueries(),
    new OsqueryAntivirusQueries(),
  );
}


if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}