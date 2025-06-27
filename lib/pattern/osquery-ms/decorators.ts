#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * decorators.ts - osQuery Management Server Cell Decorator and Governance
 * =======================================================================
 *
 * Provides the @osQueryMsCell decorator for registering osQuery monitoring methods with
 * execution governance, platform targeting, and result filtering. Central configuration
 * point for all osQuery cell behavior in the Surveilr RSSD monitoring system.
 *
 * Core Functionality:
 * - osQueryMsCell decorator registers query methods with standardized governance rules
 * - Automatic 60-second execution intervals for real-time monitoring
 * - Cross-platform targeting (darwin, windows, linux) with selective execution
 * - jq result filtering to remove timestamps and normalize data structure
 * - Global registry system for decorator context management and cell tracking
 *
 * Governance Configuration:
 * - Execution Interval: 60 seconds (configurable via osquery-ms-interval)
 * - Result Filtering: Removes calendarTime, unixTime, action, counter fields
 * - Captured Metadata: Preserves calendarTime and unixTime for audit trails
 * - Platform Targeting: Supports selective execution based on operating system
 * - Singleton Control: Prevents overlapping executions when enabled
 *
 * Code Architecture:
 * - osQueryMsNotebookName constant defines notebook categorization
 * - osQueryMsCellGovernance object contains default execution and filtering rules
 * - osQueryMsCell() function creates decorated methods with governance metadata
 * - globalRegistry provides decorator context management for method registration
 * - Integration with cnb.sqlCell for SQL generation and notebook management
 *
 * Usage Pattern:
 * @osQueryMsCell({ description: "Query description" }, ["linux"], false, ["custom-filter"])
 * "Method Name"() { return "SELECT * FROM table;" }
 */

import { codeNB as cnb, RssdInitSqlNotebook } from "./deps.ts";

const osQueryMsNotebookName = "osQuery Management Server (Prime)" as const;
const osQueryMsCellGovernance = {
    "osquery-ms-interval": 60,
    "results-uniform-resource-store-jq-filters": [
        "del(.calendarTime, .unixTime, .action, .counter)",
    ],
    "results-uniform-resource-captured-jq-filters": [
        "{calendarTime, unixTime}",
    ],
};

export function osQueryMsCell(
    init?: Omit<
        Parameters<typeof cnb.sqlCell>[0],
        "notebook_name" | "cell_governance"
    >,
    targets: string[] = ["darwin", "windows", "linux"],
    singleton: boolean = false,
    extraFilters: string[] = [],
) {
    const cellGovernance = JSON.stringify({
        ...osQueryMsCellGovernance,
        "results-uniform-resource-store-jq-filters": [
            ...osQueryMsCellGovernance["results-uniform-resource-store-jq-filters"],
            ...extraFilters,
        ],
        targets,
        singleton,
    });

    return cnb.sqlCell<RssdInitSqlNotebook>({
        ...init,
        notebook_name: osQueryMsNotebookName,
        cell_governance: cellGovernance,
    }, (dc, methodCtx) => {
        // Using arrow function to preserve context
        methodCtx.addInitializer(() => {
            // Get access to the instance via closure instead of thisValue
            // Store in a global registry that can be accessed later
            const methodName = String(methodCtx.name); // Explicit conversion to string

            // Access the instance using the global registry approach
            // This is a workaround since we can't directly access the instance
            if (globalRegistry.instance) {
                globalRegistry.instance.migratableCells.set(methodName, dc);
            } else {
                console.error(`Error: No instance available for ${methodName}`);
            }
        });
        // we're not modifying the DecoratedCell
        return dc;
    });
}

// Global registry to support decorator context
export const globalRegistry: {
    instance: { migratableCells: Map<string, cnb.DecoratedCell<"SQL">> } | null;
} = {
    instance: null,
};
