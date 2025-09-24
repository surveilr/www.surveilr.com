#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based SQLPage System
 * 
 * This recreates the SQLa-based SQLPage decorator system but uses Drizzle ORM
 * Generates sqlpage_files and sqlpage_aide_navigation INSERT statements
 */

import { DrizzleCodeNotebook } from "./drizzle-notebook.ts";
import { SQL, inlinedSQL } from "../../universal/sql-text.ts";
import { sqlpageFiles, sqlpageAideNavigation } from "../drizzle/models.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

// Type representing navigation route configuration
export type RouteConfig = {
  readonly path: string;
  readonly caption: string;
  readonly namespace?: string;
  readonly parentPath?: string;
  readonly siblingOrder?: number;
  readonly url?: string;
  readonly abbreviatedCaption?: string;
  readonly title?: string;
  readonly description?: string;
  readonly elaboration?: string;
};

// Type representing a decorated navigation method
export type DrizzleDecoratedNavigation = {
  readonly methodName: string;
  readonly methodFn: Any;
  readonly methodCtx: ClassMethodDecoratorContext<DrizzleSqlPageNotebook>;
  readonly routeConfig: RouteConfig;
};

// Type representing a decorated shell method
export type DrizzleDecoratedShell = {
  readonly methodName: string;
  readonly methodFn: Any;
  readonly methodCtx: ClassMethodDecoratorContext<DrizzleSqlPageNotebook>;
  readonly eliminate?: boolean;
};

/**
 * Base class for Drizzle-based SQLPage notebooks
 * Equivalent to TypicalSqlPageNotebook but uses Drizzle instead of SQLa
 */
export class DrizzleSqlPageNotebook extends DrizzleCodeNotebook {
  readonly navigation: Map<string, DrizzleDecoratedNavigation> = new Map();
  readonly shellDecorated: Map<string, DrizzleDecoratedShell> = new Map();
  readonly shellEliminated: Set<string> = new Set();
  
  constructor(notebookName: string = "sqlpage") {
    super(notebookName);
  }

  // Generate navigation DML using Drizzle SQL template system
  navigationDML(): string {
    const navigationEntries = Array.from(this.navigation.values());
    if (navigationEntries.length === 0) return "";
    
    return this.upsertNavSQL(...navigationEntries.map(entry => entry.routeConfig));
  }

  // Drizzle equivalent of upsertNavSQL method
  upsertNavSQL(...nav: RouteConfig[]): string {
    if (nav.length === 0) return "";

    const insertStatements = nav.map(route => {
      return inlinedSQL(SQL`INSERT INTO "sqlpage_aide_navigation" (
        "namespace", "parent_path", "sibling_order", "path", "url", "caption", 
        "abbreviated_caption", "title", "description", "elaboration"
      ) VALUES (
        ${route.namespace || "prime"}, ${route.parentPath || null}, ${route.siblingOrder || 1}, 
        ${route.path}, ${route.url || null}, ${route.caption}, ${route.abbreviatedCaption || null},
        ${route.title || null}, ${route.description || null}, ${route.elaboration || null}
      ) ON CONFLICT (namespace, parent_path, path) DO UPDATE SET 
        title = EXCLUDED.title, 
        abbreviated_caption = EXCLUDED.abbreviated_caption, 
        description = EXCLUDED.description, 
        url = EXCLUDED.url, 
        sibling_order = EXCLUDED.sibling_order`);
    });

    return insertStatements.join(';\n') + ';';
  }

  // Generate SQL for all SQLPage notebooks
  static override async SQL(...sources: DrizzleSqlPageNotebook[]) {
    const allInserts: string[] = [];

    // First, add the sqlpage_files table DDL
    allInserts.push(inlinedSQL(SQL`-- SQLPage files table for web UI content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)`));

    // Generate navigation INSERT statements
    for (const notebook of sources) {
      const navDML = notebook.navigationDML();
      if (navDML) {
        allInserts.push("-- Navigation INSERT statements");
        allInserts.push(navDML);
      }
    }

    // Generate sqlpage_files INSERT statements for methods ending in .sql
    for (const notebook of sources) {
      const methods = Object.getOwnPropertyNames(Object.getPrototypeOf(notebook))
        .filter(name => name.endsWith('.sql') || name.endsWith('.json') || name.endsWith('.js'));

      for (const methodName of methods) {
        try {
          const method = (notebook as any)[methodName];
          if (typeof method === 'function') {
            const content = await method.call(notebook);
            const contentString = typeof content === 'object' && content.text 
              ? content.text() 
              : String(content);

            // Generate INSERT statement for sqlpage_files
            const fileInsert = inlinedSQL(SQL`INSERT INTO "sqlpage_files" (
              "path", "contents", "last_modified"
            ) VALUES (
              ${methodName}, ${contentString}, CURRENT_TIMESTAMP
            ) ON CONFLICT(path) DO UPDATE SET 
              contents = EXCLUDED.contents, 
              last_modified = CURRENT_TIMESTAMP`);

            allInserts.push(fileInsert);
          }
        } catch (error) {
          console.warn(`Failed to process SQLPage method ${methodName}:`, error);
        }
      }
    }

    return allInserts;
  }
}

/**
 * Drizzle equivalent of @navigationPrime decorator
 */
export function navigationPrimeDrizzle(routeConfig: Omit<RouteConfig, "path" | "parentPath">) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleSqlPageNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    const decoratedNav: DrizzleDecoratedNavigation = {
      methodName,
      methodFn,
      methodCtx,
      routeConfig: {
        ...routeConfig,
        path: methodName,
        parentPath: undefined, // Prime navigation has no parent
      },
    };

    methodCtx.addInitializer(function () {
      this.navigation.set(methodName, decoratedNav);
    });
  };
}

/**
 * Drizzle equivalent of @shell decorator
 */
export function shellDrizzle(config?: { eliminate?: boolean }) {
  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<DrizzleSqlPageNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    
    if (config?.eliminate) {
      methodCtx.addInitializer(function () {
        this.shellEliminated.add(methodName);
      });
      return;
    }

    const decoratedShell: DrizzleDecoratedShell = {
      methodName,
      methodFn,
      methodCtx,
      eliminate: config?.eliminate,
    };

    methodCtx.addInitializer(function () {
      this.shellDecorated.set(methodName, decoratedShell);
    });
  };
}