import { callable as c, path, SQLa, ws } from "../deps.ts";
import { SurveilrSqlNotebook } from "./rssd.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

/**
 * Represents the structure of a SQL page file with path and content.
 * Resource Surveillance (`surveilr`) creates `sqlpage_files` table as part of RSSD init.
 */
export interface SqlPagesFileRecord {
  /**
   * A text or string field that stores the file path or identifier. This
   * path is used to reference the file within the SQLPage application, allowing it
   * to be served or accessed as needed by SQLPage.
   */
  readonly path: string;
  /** A CLOB-ish field that contains the content that SQLPage will serve. */
  readonly content: string;
  /** the method that generated the content */
  readonly method: c.Callable<TypicalSqlPageNotebook, Any>;
}

/**
 * Type representing the initialization options for shell component configuration.
 *
 * @property path - The path for the page
 * @property shellStmts - The `SELECT 'shell' as component` SQL statements
 * @property breadcrumbsFromNavStmts - The `SELECT 'breadcrumbs' as component` SQL statements when we want automatic breadcrumbs from page's navigation decorator
 * @property pageTitleFromNavStmts - The `SELECT 'text' as component` SQL statements when we want automatic title from navigation decorator
 */
export type PathShellConfig = {
  readonly path: string;
  readonly shellStmts:
    | "do-not-include"
    | ((spfr: SqlPagesFileRecord) => string | string[]);
  readonly breadcrumbsFromNavStmts:
    | "no"
    | ((spfr: SqlPagesFileRecord) => string | string[]);
  readonly pageTitleFromNavStmts:
    | "no"
    | ((spfr: SqlPagesFileRecord) => string | string[]);
};

/**
 * Type representing a decorated shell method, which includes the shell
 * initialization options and additional metadata about the method to
 * which the shell config is attached.
 *
 * @property methodName - The name of the method.
 * @property methodFn - The function of the method.
 * @property methodCtx - The context of the method decorator.
 */
export type DecoratedShellMethod =
  & Partial<PathShellConfig>
  & {
    readonly methodName: string;
    readonly methodFn: Any;
    readonly methodCtx: ClassMethodDecoratorContext<TypicalSqlPageNotebook>;
  };

/**
 * Decorator function for shell configuration. This decorator adds metadata to
 * the method it decorates, which can then be used to generate SQLPage shell components.
 * It stores the ShellInit instance in method's class `shell` instance.
 *
 * @param shellInit - The initialization options for the shell config.
 * @returns A decorator function that adds metadata to the method.
 *
 * @example
 * class MyNotebook extends TypicalSqlPageNotebook {
 *   @shell({ ... })
 *   "index.sql"() {
 *     // method implementation
 *   }
 * }
 *
 * - **Default Path**: If no path is provided, it defaults to methodName.
 */
export function shell(
  shellInit: { readonly eliminate?: boolean } & Partial<PathShellConfig>,
) {
  const isRoot = (path: string) => path === "/" ? true : false;

  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<TypicalSqlPageNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    if (shellInit.eliminate) {
      methodCtx.addInitializer(function () {
        this.shellEliminated.add(methodName);
      });
      return;
    }

    let path = shellInit.path ?? `/${methodName}`;

    // special handling for path indexes so searches are easier in table
    if (path.endsWith("index.sql")) {
      path = path.substring(0, path.length - "index.sql".length);
    }
    // the "path" is used to search/locate a nav item so shouldn't have trailing slash
    if (!isRoot(path) && path.endsWith("/")) {
      path = path.substring(0, path.length - 1);
    }

    const drm: DecoratedShellMethod = {
      ...shellInit,
      path,
      methodName,
      methodFn,
      methodCtx,
    };

    methodCtx.addInitializer(function () {
      this.shellDecorated.set(methodName, drm);
    });

    // return void so that decorated function is not modified
  };
}

/**
 * Type representing the configuration options for a navigation route.
 *
 * @property path - The path for the route, this the search key when location routes.
 * @property caption - The human friendly name of the route.
 * @property namespace - The namespace for the route, defaults to 'prime'.
 * @property parentPath - The parent path for hierarchical navigation if it's a child.
 * @property siblingOrder - The order of this route among its siblings (for sorting).
 * @property url - The URL for the route if different than the path when displaying in UI.
 * @property abbreviatedCaption - A shorter version of the caption (e.g. for breadcrumbs).
 * @property title - The title for the route (e.g. for page headings).
 * @property description - A description of the route (e.g. for describing in lists or tooltips).
 */
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
};

/**
 * Type representing a decorated route method, which includes the route
 * initialization options and additional metadata about the method to
 * which the route is attached.
 *
 * @property methodName - The name of the method.
 * @property methodFn - The function of the method.
 * @property methodCtx - The context of the method decorator.
 */
export type DecoratedRouteMethod =
  & RouteConfig
  & {
    readonly methodName: string;
    readonly methodFn: Any;
    readonly methodCtx: ClassMethodDecoratorContext<
      TypicalSqlPageNotebook
    >;
  };

/**
 * Given a method name like "x/y/abc.sql" return the navigation path of the
 * method name; there's special handling for "/x/index.sql" being replaced by
 * `/x`.
 * @param methodName the method name from a Class source
 * @param isRoot how to check whether it's the root or not
 */
export function methodNameNavPath(
  methodName: string,
  isRoot = (path: string) => path === "/" ? true : false,
) {
  let path = `/${methodName}`;

  // special handling for path indexes so searches are easier in table
  if (path.endsWith("index.sql")) {
    path = path.substring(0, path.length - "index.sql".length);
  }

  // the "path" is used to search/locate a nav item so shouldn't have trailing slash
  if (!isRoot(path) && path.endsWith("/")) {
    path = path.substring(0, path.length - 1);
  }

  return path;
}

/**
 * Decorator function for navigation routes. This decorator adds metadata to
 * the method it decorates, which can then be used to generate navigation routes.
 * It stores the RouteInit instance in method's class `navigation` instance.
 *
 * @param route - The initialization options for the route.
 * @returns A decorator function that adds metadata to the method.
 *
 * @example
 * class MyNotebook extends TypicalSqlPageNotebook {
 *   @navigation({
 *     caption: 'Home',
 *     title: 'Homepage',
 *     description: 'The main page of the notebook'
 *   })
 *   index() {
 *     // method implementation
 *   }
 * }
 *
 * - **Default Path**: If no path is provided, it defaults to `/${methodName}`.
 * - **Index Path Handling**: If the path ends with `index.sql`, this part is removed to make searches easier.
 * - **Trailing Slash Removal**: If the path is not the root (`/`) and ends with a slash, the trailing slash is removed.
 * - **URL Generation**: If no URL is provided, a default URL is generated based on the path.
 *
 * Decorators in TypeScript and JavaScript are special functions that can be
 * attached to classes, methods, accessors, properties, or parameters. They
 * allow you to add metadata or modify behavior. In this example, the
 * `navigation` decorator adds route metadata to methods, which can then be
 * used for generating navigation routes.
 */
export function navigation(
  route: Omit<RouteConfig, "path"> & Partial<Pick<RouteConfig, "path">>,
) {
  const isRoot = (path: string) => path === "/" ? true : false;

  return function (
    methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<TypicalSqlPageNotebook>,
  ) {
    const methodName = String(methodCtx.name);
    const path = route.path ?? methodNameNavPath(methodName);
    const drm: DecoratedRouteMethod = {
      ...route,
      path,
      url: route.url ??
        (isRoot(path) ? path : (path.endsWith(".sql") ? path : `${path}/`)),
      methodName,
      methodFn,
      methodCtx,
    };

    methodCtx.addInitializer(function () {
      this.navigation.set(drm.path, drm);
    });

    // return void so that decorated function is not modified
  };
}

/**
 * Decorator function for navigation routes in the `prime` namespace. This is
 * just a type-safe convenience wrapper to ensure proper namespace is used.
 */
export function navigationPrime(
  route:
    & Omit<RouteConfig, "path" | "namespace">
    & Partial<Pick<RouteConfig, "path">>,
) {
  return navigation({
    ...route,
    namespace: "prime",
  });
}

/**
 * Decorator function for top-level navigation routes in the `prime` namespace.
 * This is just a type-safe convenience wrapper to ensure proper parentPath is
 * used.
 */
export function navigationPrimeTopLevel(
  route: Omit<RouteConfig, "path" | "parentPath" | "namespace">,
) {
  return navigationPrime({
    ...route,
    parentPath: "/",
  });
}

/**
 * Represents the base class for all RSSD SQLPage notebooks (which generate SQLPage content).
 * This class is used to populate SQLPage content for Web UIs in RSSD databases eliminating
 * the need for storing SQLPage content in the file system.
 *
 * The `TypicalSqlPageNotebook` class is designed to manage the generation of SQLPage files
 * and handle their upsertion into the `sqlpage_files` table. It provides various utilities
 * for SQLPage content management, including breadcrumb generation, shell configuration, and
 * page title handling. This class is meant to be subclassed to create specific notebooks that
 * generate SQL content to be served by SQLPage.
 *
 * Key Features:
 * - **Shell and Navigation Management**: The class handles the configuration and decoration
 *   of shell components and navigation routes, making it easier to create and manage SQL pages
 *   with complex navigation structures.
 * - **SQL Generation**: The class provides methods for generating SQL pagination, handling
 *   breadcrumbs, and managing active page titles.
 * - **Reflection-Based Utilities**: Includes methods to reflect on the call stack and extract
 *   path components, which are useful for generating SQL based on the method names in subclasses.
 *
 * @example
 * class MyNotebook extends TypicalSqlPageNotebook {
 *   constructor() {
 *     super();
 *   }
 *
 *   @shell({ path: "/index.sql" })
 *   index() {
 *     return this.SQL`SELECT * FROM my_table;`;
 *   }
 *
 *   @navigation({
 *     caption: "Home",
 *     title: "Homepage",
 *     description: "The main page of the notebook"
 *   })
 *   index() {
 *     return this.SQL`SELECT * FROM my_table;`;
 *   }
 * }
 *
 * // Create an instance of the notebook
 * const notebook = new MyNotebook();
 *
 * // Generate SQL statements from the notebook methods
 * const sqlStatements = await TypicalSqlPageNotebook.SQL(notebook);
 *
 * // Outputs SQL including the notebook-specific shell and navigation configurations
 * console.log(sqlStatements);
 */
export class TypicalSqlPageNotebook
  extends SurveilrSqlNotebook<SQLa.SqlEmitContext> {
  readonly shellEliminated: Set<string> = new Set();
  readonly shellDecorated: Map<PathShellConfig["path"], DecoratedShellMethod> =
    new Map();
  // navigation will be automatically filled by @navigation decorators
  readonly navigation: Map<RouteConfig["path"], DecoratedRouteMethod> =
    new Map();
  readonly formattedSQL: boolean = true;

  /**
   * Generates SQL pagination logic including initialization, debugging variables,
   * and rendering pagination controls for SQLPage.
   *
   * @param config - The configuration object for pagination.
   * @param config.varName - Optional function to customize variable names.
   * @param config.tableOrViewName - The name of the table or view to paginate. This is required if `countSQL` is not provided.
   * @param config.countSQL - Custom SQL supplier to count the total number of rows. This is required if `tableOrViewName` is not provided.
   *
   * @returns An object containing methods to initialize pagination variables,
   *          debug variables, and render pagination controls.
   *
   * @example
   * const paginationConfig = {
   *   varName: (name) => `custom_${name}`,
   *   tableOrViewName: 'my_table'
   * };
   * const paginationInstance = pagination(paginationConfig);
   * - required: paginationInstance.init() should be placed into a SQLa template to initialize SQLPage pagination;
   * - optional: paginationInstance.debugVars() should be placed into a SQLa template to view var values in web UI;
   * - required: paginationInstance.renderSimpleMarkdown() should be placed into SQLa template to show the next/prev pagination component in simple markdown;
   */
  pagination(
    config:
      & { varName?: (name: string) => string }
      & ({ readonly tableOrViewName: string; readonly countSQL?: never } | {
        readonly tableOrViewName?: never;
        readonly countSQL: SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
      }),
  ) {
    // `n` renders the variable name for definition, $ renders var name for accessor
    const n = config.varName ?? ((name) => name);
    const $ = config.varName ?? ((name) => `$${n(name)}`);
    return {
      init: () => {
        const countSQL = config.countSQL
          ? config.countSQL
          : this.SQL`SELECT COUNT(*) FROM ${config.tableOrViewName}`;
        return this.SQL`
          SET ${n("total_rows")} = (${countSQL.SQL(this.emitCtx)});
          SET ${n("limit")} = COALESCE(${$("limit")}, 50);
          SET ${n("offset")} = COALESCE(${$("offset")}, 0);
          SET ${n("total_pages")} = (${$("total_rows")} + ${
          $("limit")
        } - 1) / ${$("limit")};
          SET ${n("current_page")} = (${$("offset")} / ${$("limit")}) + 1;`;
      },

      debugVars: () => {
        return this.SQL`
          SELECT 'text' AS component,
              '- Start Row: ' || ${$("offset")} || '\n' ||
              '- Rows per Page: ' || ${$("limit")} || '\n' ||
              '- Total Rows: ' || ${$("total_rows")} || '\n' ||
              '- Current Page: ' || ${$("current_page")} || '\n' ||
              '- Total Pages: ' || ${$("total_pages")} as contents_md;`;
      },

      renderSimpleMarkdown: () => {
        return this.SQL`
          SELECT 'text' AS component,
              (SELECT CASE WHEN ${
          $("current_page")
        } > 1 THEN '[Previous](?limit=' || ${$("limit")} || '&offset=' || (${
          $("offset")
        } - ${$("limit")}) || ')' ELSE '' END) || ' ' ||
              '(Page ' || ${$("current_page")} || ' of ' || ${
          $("total_pages")
        } || ") " ||
              (SELECT CASE WHEN ${$("current_page")} < ${
          $("total_pages")
        } THEN '[Next](?limit=' || ${$("limit")} || '&offset=' || (${
          $("offset")
        } + ${$("limit")}) || ')' ELSE '' END)
              AS contents_md;`;
      },
    };
  }

  upsertNavSQL(...nav: RouteConfig[]) {
    const literal = (text?: string | number) =>
      typeof text === "number"
        ? text
        : text
        ? this.emitCtx.sqlTextEmitOptions.quotedLiteral(text)[1]
        : "NULL";
    // deno-fmt-ignore
    return this.SQL`
      INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description)
      VALUES
          ${nav.map(n => `(${[n.namespace, n.parentPath, n.siblingOrder ?? 1, n.path, n.url, n.caption, n.abbreviatedCaption, n.title, n.description].map(v => literal(v)).join(', ')})`).join(",\n    ")}
      ON CONFLICT (namespace, parent_path, path)
      DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;`
  }

  shellConfig(spfr: SqlPagesFileRecord) {
    if (this.shellEliminated.has(spfr.path)) return null;

    const defaults: PathShellConfig = {
      path: spfr.path,
      shellStmts: () =>
        `SELECT 'dynamic' AS component, sqlpage.run_sql('shell/shell.sql') AS properties;`,
      breadcrumbsFromNavStmts: () =>
        this.breadcrumbsSQL(methodNameNavPath(spfr.path)),
      pageTitleFromNavStmts: "no",
    };

    const result = this.shellDecorated.get(spfr.path);
    if (result) {
      // if a @shell() decorates a method, that's got the "overrides"
      return {
        ...defaults,
        ...result,
      };
    } else {
      return defaults;
    }
  }

  /**
   * Assume caller's method name contains "path/path/file.sql" format, reflect
   * the method name in the call stack and extract path components from the
   * method name in the stack trace.
   *
   * @param [level=2] - The stack trace level to extract the method name from. Defaults to 2 (immediate parent).
   * @returns An object containing the absolute path, base name, directory path, and file extension, or undefined if unable to parse.
   */
  sqlPagePathComponents(level = 2) {
    // Get the stack trace using a new Error object
    const stack = new Error().stack;
    if (!stack) {
      return undefined;
    }

    // Split the stack to find the method name
    const stackLines = stack.split("\n");
    if (stackLines.length < 3) {
      return undefined;
    }

    // Parse the method name from the stack trace
    const methodLine = stackLines[level].trim();
    const methodNameMatch = methodLine.match(/at (.+?) \(/);
    if (!methodNameMatch) {
      return undefined;
    }

    // Get the full method name including the class name
    const fullMethodName = methodNameMatch[1];

    // Extract the method name by removing the class name
    const className = this.constructor.name;
    const methodName = fullMethodName.startsWith(className + ".")
      ? fullMethodName.substring(className.length + 1)
      : fullMethodName;

    // assume methodName is now a proper sqlpage_files.path value
    return {
      methodName,
      absPath: "/" + methodName,
      basename: path.basename(methodName),
      path: "/" + path.dirname(methodName),
      extension: path.extname(methodName),
    };
  }

  breadcrumbsSQL(
    activePath: string,
    ...additional: ({ title: string; titleExpr?: never; link?: string } | {
      title?: never;
      titleExpr: string;
      link?: string;
    })[]
  ) {
    // deno-fmt-ignore
    return ws.unindentWhitespace(`
        SELECT 'breadcrumb' as component;
        WITH RECURSIVE breadcrumbs AS (
            SELECT
                COALESCE(abbreviated_caption, caption) AS title,
                COALESCE(url, path) AS link,
                parent_path, 0 AS level,
                namespace
            FROM sqlpage_aide_navigation
            WHERE namespace = 'prime' AND path = '${activePath.replaceAll("'", "''")}'
            UNION ALL
            SELECT
                COALESCE(nav.abbreviated_caption, nav.caption) AS title,
                COALESCE(nav.url, nav.path) AS link,
                nav.parent_path, b.level + 1, nav.namespace
            FROM sqlpage_aide_navigation nav
            INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
        )
        SELECT title, link FROM breadcrumbs ORDER BY level DESC;`) +
      (additional.length
        ? (additional.map((crumb) => `\nSELECT ${crumb.title ? `'${crumb.title}'` : crumb.titleExpr} AS title, '${crumb.link ?? "#"}' AS link;`))
        : "");
  }

  /**
   * Assume caller's method name contains "path/path/file.sql" format, reflect
   * the method name in the call stack and assume that's the path then compute
   * the breadcrumbs.
   * @param additional any additional crumbs to append
   * @returns the SQL for active breadcrumbs
   */
  activeBreadcrumbsSQL(
    ...additional: ({ title: string; titleExpr?: never; link?: string } | {
      title?: never;
      titleExpr: string;
      link?: string;
    })[]
  ) {
    return this.breadcrumbsSQL(
      this.sqlPagePathComponents(3)?.path ?? "/",
      ...additional,
    );
  }

  /**
   * Assume caller's method name contains "path/path/file.sql" format, reflect
   * the method name in the call stack and assume that's the path then compute
   * the page title.
   * @returns the SQL for page title
   */
  activePageTitle() {
    const literal = (text: string) =>
      this.emitCtx.sqlTextEmitOptions.quotedLiteral(text)[1];
    const activePPC = this.sqlPagePathComponents(3);
    return this.SQL`
          SELECT 'title' AS component, (SELECT COALESCE(title, caption)
              FROM sqlpage_aide_navigation
             WHERE namespace = 'prime' AND path = ${
      literal(activePPC?.absPath ?? "/")
    }) as contents;
    `;
  }

  /**
   * Assume caller's method name contains "path/path/file.sql" format, reflect
   * the method name in the call stack and assume that's the path then create a
   * link to the page's source in /console/sqlpage-files/*.
   * @returns the SQL for linking to this page's source
   */
  activePageSource() {
    const activePPC = this.sqlPagePathComponents(3);
    const methodName = activePPC?.methodName.replaceAll("'", "''") ?? "??";
    return this.SQL`
        SELECT 'text' AS component,
               '[View ${methodName}](/console/sqlpage-files/sqlpage-file.sql?path=${methodName})' as contents_md;
  `;
  }

  /**
   * Generate SQL from "method-based" notebooks. Any method that ends in "*.sql"
   * (case sensitive) will be assumed to generate SQL that will be upserted into
   * sqlpage_files and any method name that ends in "DQL" or "DML" or "DDL" (also
   * case sensitive) will be assumed to be general SQL that will be included before
   * all the sqlpage_file upserts.
   * @param sources list of one or more instances of TypicalSqlPageNotebook subclasses
   * @returns an array of strings which are the SQL statements
   */
  static async SQL(...sources: TypicalSqlPageNotebook[]) {
    // commonNB emits SQL before all other SQL from any notebooks passed in
    const commonNB = new (class extends TypicalSqlPageNotebook {
      commonDDL() {
        return this.SQL`
          -- ${this.tsProvenanceComment(import.meta.url)}
          -- idempotently create location where SQLPage looks for its content
          CREATE TABLE IF NOT EXISTS "sqlpage_files" (
            "path" VARCHAR PRIMARY KEY NOT NULL,
            "contents" TEXT NOT NULL,
            "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
          );`;
      }
    })();

    // select all "callable" methods from across all notebooks
    const cc = c.callablesCollection<TypicalSqlPageNotebook, Any>(
      commonNB,
      ...sources,
    );
    const arbitrarySqlStmts = await Promise.all(
      cc.filter({
        include: [/SQL$/, /DQL$/, /DML$/, /DDL$/],
      }).map(async (cell) =>
        await cell.source.instance.methodText(cell as Any)
      ),
    );

    const sqlPageFileUpserts = await Promise.all(
      cc.filter({ include: [/\.sql$/, /\.json$/] })
        .map(
          async (method) => {
            const notebook = method.source.instance;
            let spfr: SqlPagesFileRecord = {
              method: method as Any,
              path: String(method.callable),
              content: await notebook.methodText(method as Any),
            };
            const shell = notebook.shellConfig(spfr);
            if (shell) {
              spfr = {
                ...spfr,
                // deno-fmt-ignore
                content: ws.unindentWhitespace(`
              ${shell.shellStmts !== "do-not-include" ? shell.shellStmts(spfr): "-- not including shell"}
              ${shell.breadcrumbsFromNavStmts !== "no" ? shell.breadcrumbsFromNavStmts(spfr): "-- not including breadcrumbs from sqlpage_aide_navigation"}
              ${shell.pageTitleFromNavStmts !== "no" ? shell.pageTitleFromNavStmts(spfr) : "-- not including page title from sqlpage_aide_navigation"}

              ${spfr.content}
            `),
              };
            }
            const escapedPath = spfr.path.replace(/'/g, "''");
            const escapedContent = spfr.content.replace(/'/g, "''");
            return notebook.formattedSQL == false
              ? `INSERT INTO sqlpage_files (path, contents, last_modified) VALUES ('${escapedPath}', '${escapedContent}', CURRENT_TIMESTAMP) ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;`
              : `INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (\n      '${escapedPath}',\n      '${escapedContent}',\n      CURRENT_TIMESTAMP)\n  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;`;
          },
        ),
    );
    return [...arbitrarySqlStmts, ...sqlPageFileUpserts];
  }
}
