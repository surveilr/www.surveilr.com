import { callable as c, SQLa, ws, yaml } from "../deps.ts";
import { SurveilrSqlNotebook, unindentedText } from "./rssd.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

// see https://testanything.org/tap-specification.html
// TODO: see https://github.com/netspective-labs/sql-aide/tree/main/lib/tap for
//       more ideas and implement them all in SQL TAP generator
//       - add @comment() to add TAP `# ...` comments above test cases
//       - implement @skip() to add TAP `# skip` directives
//       - support TAP nested subtests using fluent API
//       - add @TODO() to add `TODO` TAP directive
//       - add `Bail out!`

/**
 * Decorator function to not treat a method as a test case.
 * @returns A decorator function that adds metadata to the method.
 *
 * @example
 * class MyNotebook extends TestSuiteNotebook {
 *   @isNotTestCase()
 *   someMethodThatIsNotATestCase() {
 *     // method implementation
 *   }
 * }
 */
export function isNotTestCase() {
  return function (
    _methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<TestSuiteNotebook>,
  ) {
    methodCtx.addInitializer(function () {
      this.methodIsNotTestCase.add(String(methodCtx.name));
    });
    // return void so that decorated function is not modified
  };
}

/**
 * Decorator function to mark a test case as "skipped" in TAP.
 * @returns A decorator function that adds metadata to the method.
 *
 * @example
 * class MyNotebook extends TestSuiteNotebook {
 *   @skip()
 *   "my test case"() {
 *     // method implementation
 *   }
 * }
 */
export function skip() {
  return function (
    _methodFn: Any,
    methodCtx: ClassMethodDecoratorContext<TestSuiteNotebook>,
  ) {
    methodCtx.addInitializer(function () {
      this.tapSkipMethodNames.add(String(methodCtx.name));
    });
    // return void so that decorated function is not modified
  };
}

export class AssertThat<ColumnName extends string>
  implements SQLa.SqlTextSupplier<SQLa.SqlEmitContext> {
  readonly cases: {
    readonly when: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
    readonly then: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext> | {
      readonly expr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
      readonly diags: Record<string, unknown>;
    };
    readonly otherwise?:
      | string
      | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>
      | {
        readonly expr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
        readonly diags: Record<string, unknown>;
      };
    readonly selectCaseExpr: (
      index: string,
    ) => SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
  }[] = [];

  constructor(
    readonly ctx: TestCaseContext,
    readonly body: string,
    readonly emitCtx: SQLa.SqlEmitContext,
  ) {
  }

  diags(d: Record<string, unknown>) {
    return yaml.stringify(d, { skipInvalid: true });
  }

  sqlExpr(
    expr: number | string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
    tcIndex: string,
  ) {
    return (typeof expr === "number"
      ? String(expr)
      : typeof expr === "string"
      ? expr
      : expr.SQL(this.emitCtx))
      .replaceAll("tcIndex", String(tcIndex));
  }

  sqlExprOrLiteral(
    suppliedExpr:
      | number
      | string
      | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>
      | {
        readonly expr:
          | number
          | string
          | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
      },
    tcIndex: string,
  ) {
    const e = typeof suppliedExpr === "object" && "expr" in suppliedExpr
      ? suppliedExpr.expr
      : suppliedExpr;
    return (typeof e === "number"
      ? String(e)
      : typeof e === "string"
      ? SQLa.typicalQuotedSqlLiteral(e)[1].replaceAll("`", "'") // ` means "break out of SQL literal"
      : e.SQL(this.emitCtx)).replaceAll("tcIndex", String(tcIndex));
  }

  selectCaseExpr(
    when: typeof this.cases[number]["when"],
    then: typeof this.cases[number]["then"],
    otherwise?: typeof this.cases[number]["otherwise"],
  ) {
    const exprOrLit = (
      state: string,
      suppliedExpr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext> | {
        readonly expr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
        readonly diags: Record<string, unknown>;
      },
      tcIndex: string,
    ) => {
      const [_, d] = typeof suppliedExpr === "object" && "expr" in suppliedExpr
        ? [suppliedExpr.expr, suppliedExpr.diags]
        : [suppliedExpr, undefined];
      const expr = `'${state} ${tcIndex} ' || (` +
        this.sqlExprOrLiteral(suppliedExpr, tcIndex) + ")";
      return d
        ? `${expr} || ${
          SQLa.typicalQuotedSqlLiteral(
            `\n  ---\n  ${this.diags(d).replaceAll("\n", "\n  ")}...`,
          )[1].replaceAll("`", "'") // ` means "break out of SQL literal"
        }`
        : expr;
    };
    return (index: string) => ({
      SQL: () =>
        `SELECT CASE WHEN ${this.sqlExpr(when, index)} THEN ${
          exprOrLit("ok", then, index)
        } ELSE ${
          exprOrLit("not ok", otherwise ?? then, index)
        } END AS ${this.ctx.tapResultColName} FROM test_case`,
    });
  }

  SQL() {
    // deno-fmt-ignore
    return unindentedText`
    -- ${this.ctx.index}: ${this.ctx.name}
    "${this.ctx.name}" AS (
      WITH test_case AS (
        ${this.body}
      )
      ${this.cases.map((tc, subTcIndex) => tc.selectCaseExpr(this.cases.length > 1 ? `${this.ctx.index}.${subTcIndex+1}` : String(this.ctx.index)).SQL(this.emitCtx)).join("\nUNION ALL\n")}
    )`;
  }

  case(
    when: typeof this.cases[number]["when"],
    then: typeof this.cases[number]["then"],
    otherwise?: typeof this.cases[number]["otherwise"],
  ) {
    this.ctx.casesCount++;
    const c = {
      when,
      then,
      otherwise,
      selectCaseExpr: this.selectCaseExpr(when, then, otherwise),
    };
    this.cases.push(c);
    return this; // we use the builder pattern for fluent assertions
  }

  equals(
    colName: ColumnName,
    value: number | string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
  ) {
    this.case(
      `${colName} = ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} is ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} should be ${
        this.sqlExpr(value, String(this.ctx.index))
      }, is \` || ${colName} || \` instead`,
    );
    return this; // we use the builder pattern for fluent assertions
  }

  greaterThan(
    colName: ColumnName,
    value: number | string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
  ) {
    this.case(
      `${colName} > ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} is greater than ${
        this.sqlExpr(value, String(this.ctx.index))
      }`,
      `${colName} should be greater than ${
        this.sqlExpr(value, String(this.ctx.index))
      }, is \` || ${colName} || \` instead`,
    );
    return this; // return this to chain calls
  }

  lessThan(
    colName: ColumnName,
    value: number | string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
  ) {
    this.case(
      `${colName} < ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} is less than ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} should be less than ${
        this.sqlExpr(value, String(this.ctx.index))
      }, is \` || ${colName} || \` instead`,
    );
    return this; // return this to chain calls
  }

  startsWith(
    colName: ColumnName,
    value: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
  ) {
    this.case(
      `${colName} LIKE '${this.sqlExpr(value, String(this.ctx.index))}%'`,
      `${colName} starts with ${this.sqlExpr(value, String(this.ctx.index))}`,
      `${colName} should start with ${
        this.sqlExpr(value, String(this.ctx.index))
      }, is \` || ${colName} || \` instead`,
    );
    return this; // return this to chain calls
  }
}

export type TestCaseContext = ReturnType<TestSuiteNotebook["testCaseContext"]>;

/**
 * Represents a Test Anything Protocol (TAP) notebook base class that generates
 * SQL for `surveilr` tap test views to handle SQL-focused unit and integration
 * tests. This class is designed to be subclassed to define specific notebooks
 * with methods that generate test cases.
 *
 * - All methods in the subclassed notebook are assumed to be test cases unless
 *   they are decorated with @isNotTestCase(). Each method will supply SQL code
 *   that will be combined and tested as a "SQL test suite".
 * - Methods decorated with @skip() will be skipped and messages appropriately
 *   in the TAP tests suite output.
 * - Methods ending with "DQL", "DML", or "DDL" are assumed to be general
 *   SQL statements that will be included before any of the tests are performed
 *   (e.g. "test setup").
 *
 * @see lib/cookbook/tap.sql.ts for an example
 */
export class TestSuiteNotebook
  extends SurveilrSqlNotebook<SQLa.SqlEmitContext> {
  readonly methodIsNotTestCase: Set<string> = new Set();
  readonly tapSkipMethodNames: Set<string> = new Set();
  constructor(
    readonly notebookName: string,
    readonly tapResultColName = "tap_result",
  ) {
    super();
  }

  diags(d: Record<string, unknown>) {
    return yaml.stringify(d, { skipInvalid: true });
  }

  testCaseContext(name: string, index: number) {
    return {
      name,
      index,
      casesCount: 0,
      tapResultColName: this.tapResultColName,
    };
  }

  /**
   * Generate the SQL for an individual Test Case clause that is part of the
   * "master" Test Suite CTE.
   * @param ctx which test case is being generated
   * @returns a string template literal which supplies the SQL and is wrapped in the CTE
   */
  testCase(ctx: TestCaseContext) {
    return (
      ...args: Parameters<ReturnType<typeof SQLa.SQL<SQLa.SqlEmitContext>>>
    ) => {
      const testCaseBodySQL = SQLa.SQL<SQLa.SqlEmitContext>(this.ddlOptions)(
        ...args,
      );
      ctx.casesCount++;
      // deno-fmt-ignore
      return this.SQL`
        -- ${ctx.index}: ${ctx.name}
        "${ctx.name}" AS (
          ${ws.unindentWhitespace(testCaseBodySQL.SQL(this.emitCtx), true)}
        )`;
    };
  }

  /**
   * Generate the SQL for an individual Test Case clause that is part of the
   * "master" Test Suite CTE when the one or more fluent assertions are implemented
   * as CASE statements.
   * @param ctx which test case is being generated
   * @returns a string template literal which supplies the SQL and is wrapped in the CTE
   */
  assertThat<ColumnName extends string>(ctx: TestCaseContext) {
    return (
      ...args: Parameters<ReturnType<typeof SQLa.SQL<SQLa.SqlEmitContext>>>
    ) => {
      return new AssertThat<ColumnName>(
        ctx,
        SQLa.SQL<SQLa.SqlEmitContext>(this.ddlOptions)(...args).SQL(
          this.emitCtx,
        ),
        this.emitCtx,
      );
    };
  }

  /**
   * Generates SQL statements from TestSuiteNotebook subclasses' method-based "test case" notebooks.
   *
   * This function processes instances of `TestSuiteNotebook` subclasses to generate SQL statements
   * based on methods defined within those subclasses. Methods with names ending in "_test" are assumed
   * to generate text that will generate TAP test cases with the name as everything up to `_test`
   * (which will be stripped), while methods ending in "DQL", "DML", or "DDL" are assumed to be general
   * SQL statements included before the test cases (e.g. for test setup). All other methods are ignored.
   *
   * @param sources - A list of one or more instances of `TestSuiteNotebook` subclasses.
   *
   * @returns A promise that resolves to an array of strings representing the SQL statements.
   *
   * @example
   * // Example usage:
   * const sqlStatements = await SQL(notebookInstance1, notebookInstance2);
   * console.log(sqlStatements); // Outputs an array of SQL statements as strings
   */
  static async SQL(...sources: TestSuiteNotebook[]) {
    // select all "callable" methods from across all notebooks
    const arbitrarySqlStmtRegEx = /(SQL|DQL|DML|DDL)$/;
    const cc = c.callablesCollection<TestSuiteNotebook, Any>(...sources);
    const arbitrarySqlStmts = await Promise.all(
      cc.filter({ include: [arbitrarySqlStmtRegEx] }).map(
        async (c) => await c.source.instance.methodText(c as Any),
      ),
    );

    // test case methods are those that don't have @isNotTestCase are are not
    // methods that end in SQL, DQL, DML or DDL
    const testCaseMethods = cc.filter({
      include: (c, instance) =>
        instance.methodIsNotTestCase.has(String(c))
          ? false
          : arbitrarySqlStmtRegEx.test(String(c)) == false,
    });

    const testCases = await Promise.all(
      testCaseMethods.map(
        async (c, index) => {
          // NOTE: ctx is mutatable (especially the ctx.casesCount)
          const ctx = c.source.instance.testCaseContext(
            String(c.callable),
            index,
          );
          const body = await c.call(ctx) as SQLa.SqlTextSupplier<
            SQLa.SqlEmitContext
          >;
          return {
            ctx,
            notebook: c.source.instance,
            name: String(c.callable),
            body,
          };
        },
      ),
    );

    const valid = testCases.filter((tc) => SQLa.isSqlTextSupplier(tc.body));
    const totalCases = valid.reduce(
      (total, tc) => total + tc.ctx.casesCount,
      0,
    );

    const defaultNB = sources[0];
    const viewName = defaultNB?.notebookName;
    const tapResultColName = defaultNB?.tapResultColName;

    // deno-fmt-ignore
    return [
      ...arbitrarySqlStmts,
      ...testCases.filter((tc) => !SQLa.isSqlTextSupplier(tc.body)).map(tc => `-- Test Case "${tc.name}" did not return SqlTextSupplier instance (is ${typeof tc.body} instead)`),
      `CREATE VIEW "${viewName}" AS`,
      `    WITH`,
      `        tap_version AS (SELECT 'TAP version 14' AS ${tapResultColName}),`,
      `        tap_plan AS (SELECT '1..${totalCases}' AS ${tapResultColName}),`,
      `        ${valid.map((tc) => tc.body.SQL(defaultNB.emitCtx)).join(",\n  ")}`,
      `    SELECT ${tapResultColName} FROM tap_version`,
      `    UNION ALL`,
      `    SELECT ${tapResultColName} FROM tap_plan`,
      `    UNION ALL`,
      `    ${valid.map((tc) => `SELECT ${tapResultColName} FROM "${tc.name}"`).join("\n    UNION ALL\n")};`,
    ];
  }
}
