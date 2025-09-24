#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Code Notebook System
 * 
 * This recreates the SQLa-based decorator system (@migratableCell, @docsCell, etc.)
 * but uses Drizzle ORM instead of SQLa for INSERT generation
 */

import { SQL, inlinedSQL } from "../../universal/sql-text.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

const surveilrSpecialMigrationNotebookName = "ConstructionSqlNotebook" as const;

// Type representing a decorated cell method with Drizzle-based metadata
export type DrizzleDecoratedCell = {
  readonly methodName: string;
  readonly methodFn: Any;
  readonly methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>;
  readonly cellName?: string;
  readonly description?: string;
  readonly notebookName: string;
  readonly kernelId: string;
  readonly cellGovernance?: string; // JSON string for osQuery governance
};

/**
 * Base class for Drizzle-based code notebooks
 * Equivalent to TypicalCodeNotebook but uses Drizzle instead of SQLa
 */
export class DrizzleCodeNotebook {
  readonly notebookName: string;
  readonly migratableCells: Map<string, DrizzleDecoratedCell> = new Map();
  
  constructor(notebookName: string = "rssd-init") {
    this.notebookName = notebookName;
  }

  // Drizzle equivalent of SQLa's SQL template method
  SQL(strings: TemplateStringsArray, ...values: unknown[]) {
    return SQL(strings, ...values);
  }

  // Generate SQL for all decorated methods (equivalent to TypicalCodeNotebook.SQL())
  // Note: Kernel INSERTs should be handled separately to ensure proper FK constraint ordering
  static async SQL(...sources: DrizzleCodeNotebook[]) {
    const allInserts: string[] = [];

    // Note: Kernel inserts are now handled separately in bootstrapDDL() to ensure
    // proper ordering - kernels must exist before cells reference them

    // Generate cell inserts for each notebook
    for (const notebook of sources) {
      for (const [methodName, decoratedCell] of notebook.migratableCells) {
        try {
          // Get the interpretable code by calling the method
          const interpretableCode = await decoratedCell.methodFn.apply(notebook);
          const codeString = typeof interpretableCode === 'object' && interpretableCode.text 
            ? interpretableCode.text() 
            : String(interpretableCode);

          const cellId = DrizzleCodeNotebook.generateUlid();

          // Generate INSERT statement for this cell using SQL template
          const cellInsert = DrizzleCodeNotebook.generateCellInsert({
            cellId,
            notebookKernelId: decoratedCell.kernelId,
            notebookName: decoratedCell.notebookName,
            cellName: decoratedCell.cellName || methodName,
            description: decoratedCell.description,
            interpretableCode: codeString,
            interpretableCodeHash: await DrizzleCodeNotebook.gitLikeHash(codeString),
            cellGovernance: decoratedCell.cellGovernance,
          });

          allInserts.push(cellInsert);
        } catch (error) {
          console.warn(`Failed to process cell ${methodName}:`, error);
        }
      }
    }

    // Note: code_notebook_state entries are generated dynamically during execution,
    // not at bootstrap time (following original lifecycle.sql.ts pattern)

    return allInserts;
  }

  // Generate kernel INSERT statements using SQL template system
  static generateKernelInserts(): string[] {
    const kernels = [
      { id: 'Documentation', name: 'Documentation', description: null, mimeType: 'text/plain', fileExtn: '.txt' },
      { id: 'SQL', name: 'SQLite SQL Statements', description: null, mimeType: 'application/sql', fileExtn: '.sql' },
      { id: 'AI LLM Prompt', name: 'Generative AI Large Language Model Prompt', description: null, mimeType: 'text/plain', fileExtn: '.llm-prompt.txt' },
      { id: 'Text Asset (.puml)', name: 'Text Asset (.puml)', description: null, mimeType: 'text/plain', fileExtn: '.puml' },
      { id: 'Text Asset (.rs)', name: 'Text Asset (.rs)', description: null, mimeType: 'text/plain', fileExtn: '.rs' }
    ];

    return kernels.map(kernel => {
      return inlinedSQL(SQL`INSERT INTO "code_notebook_kernel" (
        "code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", 
        "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", 
        "deleted_at", "deleted_by", "activity_log"
      ) VALUES (
        ${kernel.id}, ${kernel.name}, ${kernel.description}, ${kernel.mimeType}, ${kernel.fileExtn},
        NULL, NULL, CURRENT_TIMESTAMP, (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), 
        NULL, NULL, NULL, NULL, NULL
      ) ON CONFLICT DO UPDATE SET  
        kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), 
        description = COALESCE(EXCLUDED.description, description), 
        mime_type = COALESCE(EXCLUDED.mime_type, mime_type), 
        file_extn = COALESCE(EXCLUDED.file_extn, file_extn), 
        "updated_at" = CURRENT_TIMESTAMP, 
        "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user')`);
    });
  }

  // Generate cell INSERT statement using SQL template system
  private static generateCellInsert(cellData: {
    cellId: string;
    notebookKernelId: string;
    notebookName: string;
    cellName: string;
    description?: string;
    interpretableCode: string;
    interpretableCodeHash: string;
    cellGovernance?: string;
  }): string {
    return inlinedSQL(SQL`INSERT INTO "code_notebook_cell" (
      "code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", 
      "cell_governance", "interpretable_code", "interpretable_code_hash", "description", 
      "arguments", "created_at", "created_by", "updated_at", "updated_by", 
      "deleted_at", "deleted_by", "activity_log"
    ) VALUES (
      ${cellData.cellId}, ${cellData.notebookKernelId}, ${cellData.notebookName}, ${cellData.cellName},
      ${cellData.cellGovernance || null}, ${cellData.interpretableCode}, ${cellData.interpretableCodeHash}, ${cellData.description},
      NULL, CURRENT_TIMESTAMP, (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'),
      NULL, NULL, NULL, NULL, NULL
    ) ON CONFLICT DO UPDATE SET
      interpretable_code = EXCLUDED.interpretable_code,
      interpretable_code_hash = EXCLUDED.interpretable_code_hash,
      description = COALESCE(EXCLUDED.description, description),
      cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance),
      "updated_at" = CURRENT_TIMESTAMP,
      "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user')`);
  }


  // Utility functions
  private static generateUlid(): string {
    const timestamp = Date.now().toString(36).toUpperCase();
    const randomPart = Math.random().toString(36).substring(2, 12).toUpperCase();
    return `01${timestamp}${randomPart}`.substring(0, 26);
  }

  private static async gitLikeHash(content: string): Promise<string> {
    const header = `blob ${content.length}\0`;
    const hashHex = Array.from(
      new Uint8Array(
        await crypto.subtle.digest(
          "SHA-1",
          new TextEncoder().encode(header + content),
        ),
      ),
    ).map((b) => b.toString(16).padStart(2, "0")).join("");
    return hashHex;
  }
}

/**
 * Drizzle equivalent of @migratableCell decorator
 * Creates cells in "ConstructionSqlNotebook" for DDL/DML migration
 */
export function migratableCellDrizzle(init?: {
  description?: string;
  cellName?: string;
}) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: surveilrSpecialMigrationNotebookName,
      kernelId: "SQL",
    };

    methodCtx.addInitializer(function () {
      this.migratableCells.set(methodName, decoratedCell);
    });

    // return void so that decorated function is not modified
  };
}

/**
 * Drizzle equivalent of @docsCell decorator
 * Creates documentation cells
 */
export function docsCellDrizzle(init?: {
  description?: string;
  cellName?: string;
}) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: "rssd-init",
      kernelId: "Documentation",
    };

    methodCtx.addInitializer(function () {
      if (!this.migratableCells) {
        (this as any).migratableCells = new Map();
      }
      this.migratableCells.set(methodName, decoratedCell);
    });
  };
}

/**
 * Drizzle equivalent of @llmPromptCell decorator
 * Creates AI prompt cells
 */
export function llmPromptCellDrizzle(init?: {
  description?: string;
  cellName?: string;
}) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: "rssd-init",
      kernelId: "AI LLM Prompt",
    };

    methodCtx.addInitializer(function () {
      if (!this.migratableCells) {
        (this as any).migratableCells = new Map();
      }
      this.migratableCells.set(methodName, decoratedCell);
    });
  };
}

/**
 * Drizzle equivalent of @osQueryMsCell decorator
 * Creates osQuery Management Server cells with governance configuration
 */
export function osQueryMsCellDrizzle(
  init?: {
    description?: string;
    cellName?: string;
  },
  targets: string[] = ["darwin", "windows", "linux"],
  singleton: boolean = false,
  extraFilters: string[] = [],
) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    
    // osQuery cell governance configuration (equivalent to original osQueryMsCellGovernance)
    const cellGovernance = JSON.stringify({
      "osquery-ms-interval": 60,
      "results-uniform-resource-store-jq-filters": [
        "del(.calendarTime, .unixTime, .action, .counter)",
        ...extraFilters,
      ],
      "results-uniform-resource-captured-jq-filters": [
        "{calendarTime, unixTime}",
      ],
      targets,
      singleton,
    });

    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: "osQuery Management Server (Prime)",
      kernelId: "SQL",
      cellGovernance,
    };

    methodCtx.addInitializer(function () {
      if (!this.migratableCells) {
        (this as any).migratableCells = new Map();
      }
      this.migratableCells.set(methodName, decoratedCell);
    });
  };
}

/**
 * Drizzle equivalent of @osQueryMsPolicyCell decorator  
 * Creates osQuery Management Server Policy cells
 */
export function osQueryMsPolicyCellDrizzle(
  init?: {
    description?: string;
    cellName?: string;
  },
  targets: string[] = ["darwin", "windows", "linux"],
  singleton: boolean = false,
) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    
    const cellGovernance = JSON.stringify({
      "osquery-ms-interval": 60,
      "results-uniform-resource-store-jq-filters": [
        "del(.calendarTime, .unixTime, .action, .counter)",
      ],
      "results-uniform-resource-captured-jq-filters": [
        "{calendarTime, unixTime}",
      ],
      targets,
      singleton,
    });

    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: "osQuery Management Server (Policy)",
      kernelId: "SQL",
      cellGovernance,
    };

    methodCtx.addInitializer(function () {
      if (!this.migratableCells) {
        (this as any).migratableCells = new Map();
      }
      this.migratableCells.set(methodName, decoratedCell);
    });
  };
}

/**
 * Drizzle equivalent of @textAssetCell decorator
 * Creates text asset cells for .puml, .rs, etc. files
 */
export function textAssetCellDrizzle(
  fileExtn: string,
  kernelName: string,
  init?: {
    description?: string;
    cellName?: string;
  }
) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleCodeNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    
    const decoratedCell: DrizzleDecoratedCell = {
      methodName,
      methodFn,
      methodCtx,
      cellName: init?.cellName || methodName,
      description: init?.description,
      notebookName: "rssd-init",
      kernelId: kernelName,
    };

    methodCtx.addInitializer(function () {
      if (!this.migratableCells) {
        (this as any).migratableCells = new Map();
      }
      this.migratableCells.set(methodName, decoratedCell);
    });
  };
}