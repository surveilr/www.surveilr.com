import { callable as c, SQLa, yaml } from "../deps.ts";
import { SurveilrSqlNotebook } from "./rssd.ts";

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
 * Decorator function to mark a test case as "skiped" in TAP.
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
 * ### Example Usage
 *
 * ```typescript
 * class MyTestSuite extends TestSuiteNotebook {
 *   // because this method ends in `DDL` it means it'll be emitted before tests
 *   setupDDL() {
 *      return this.SQL`
 *        -- Create a table for testing purposes
 *        CREATE TABLE users (
 *          id INTEGER PRIMARY KEY AUTOINCREMENT,
 *          name TEXT NOT NULL,
 *          age INTEGER NOT NULL
 *        );
 *        -- Insert some sample data into the table
 *        INSERT INTO users (name, age) VALUES ('Alice', 30);
 *        INSERT INTO users (name, age) VALUES ('Bob', 25);
 *      `;
 *   }
 *
 *   // because this is not decorated with @isNotTestCase() it will be a test case;
 *   // simple single-clause assertion with SQL expression and "pass" message;
 *   // automatically generates "fail" message
 *   first_test() {
 *     return this.assertThat`
 *        SELECT COUNT(*) AS user_count
 *          FROM users
 *         WHERE name = 'Alice'`
 *       .case(`user_count = 1`, `User "Alice" exists in the table`);
 *   }
 *
 *   // because this is decorated with @isNotTestCase() it will be a regular method
 *   @isNotTestCase()
 *   aUsefulMethod() {
 *     // whatever you want
 *   }
 * 
 *   // because this is not decorated with @isNotTestCase() it will be a test case;
 *   // simple single-clause assertion with SQL expression with separate pass
 *   // and fail messages
 *   second_test() {
 *     return this.assertThat`
 *        SELECT COUNT(*) AS user_count
 *          FROM users
 *         WHERE name = 'Charlie'`
 *        .case(`user_count = 1`, `User "Charlie" exists in the table`,
 *              `User "Charlie" does not exist in the table # TODO: Implement user creation for "Charlie"`),
 *   }
 *
 *   // because it's decorated with @skip() will be a marked as a "skipped" test case
 *   @skip()
 *   third_test_skip() {
 *     return this.skip(`
 *        SELECT COUNT(*) AS user_count
 *          FROM users
 *         WHERE name = 'Eve'`,
 *        `Skipping test for user "Eve"`);
 *   }
 *
 *   // because this is not decorated with @isNotTestCase() it will be a test case;
 *   // multiple assertions, first with TAP `---` attributes
 *   last_test() {
 *     return
 *       this.assertThat`
 *         SELECT age, LENGTH(name) AS name_length
 *           FROM users
 *          WHERE name = 'Bob'`
 *         .case(`age = 25`, `"Bob" is 25 years old`,
 *               { expr: `"Bob" is not 25 years old`,
 *                 diags: { 
 *                   'expected' : 25,
 *                   'got': "` || age || `", // `...` signifies "break out of SQL literal"
 *                 }
 *               })
 *         .case(`name_length = 3`, `"Bob" has a 3-character name`);
 *   }
 * }
 *
 * // Create an instance of the notebook
 * const notebook = new MyTestSuite();
 *
 * // Generate SQL statements from the notebook methods
 * const sqlStatements = await TestSuiteNotebook.SQL(notebook);
 *
 * // Outputs SQL including the test suite TAP wrapper
 * console.log(sqlStatements);
 * ```
 *
 * ### Fetching and Using External Code
 *
 * The `TestSuiteNotebook` class also provides utility functions, such as `fetchText()`, to fetch external
 * code or data that can be used within the notebook's cells, making it flexible and extensible for various
 * use cases.
 *
 * @example
 * // Example for fetching external code
 * const externalCode = await TestSuiteNotebook.fetchText("https://example.com/code.sql");
 * console.log(externalCode);
 * ```
 */
export class TestSuiteNotebook
  extends SurveilrSqlNotebook<SQLa.SqlEmitContext> {
  readonly methodIsNotTestCase: Set<string> = new Set();
  readonly tapSkipMethodNames: Set<string> = new Set();
  constructor(readonly notebookName: string) {
    super();
  }

  diags(d: Record<string, unknown>) {
    return yaml.stringify(d, { skipInvalid: true });
  }

  get assertThat() {
    const cases: {
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
    return (
      ...args: Parameters<ReturnType<typeof SQLa.SQL<SQLa.SqlEmitContext>>>
    ) => {
      const SQL = (tcName: string, tcIndex: number) => {
        const testCaseBodySQL = SQLa.SQL<SQLa.SqlEmitContext>(this.ddlOptions)(
          ...args,
        );
        // deno-fmt-ignore
        return this.SQL`
            -- ${tcIndex}: ${tcName}
            "${tcName}" AS (
              WITH test_case AS (
                ${testCaseBodySQL.SQL(this.emitCtx)}
              )
              ${cases.map((tc, index) => tc.selectCaseExpr(cases.length > 1 ? `${tcIndex}.${index+1}` : String(tcIndex)).SQL(this.emitCtx)).join("\nUNION ALL\n")}
            )`.SQL(this.emitCtx);
      };
      const result = {
        isAssertion: true,
        SQL,
        cases,
        case: (
          when: typeof cases[number]["when"],
          then: typeof cases[number]["then"],
          otherwise?: typeof cases[number]["otherwise"],
        ) => {
          const expr = (
            expr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>,
            tcIndex: string,
          ) => {
            return (typeof expr === "string" ? expr : expr.SQL(this.emitCtx))
              .replaceAll("tcIndex", String(tcIndex));
          };
          const exprOrLit = (
            state: string,
            suppliedExpr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext> | {
              readonly expr: string | SQLa.SqlTextSupplier<SQLa.SqlEmitContext>;
              readonly diags: Record<string, unknown>;
            },
            tcIndex: string,
          ) => {
            const [e, d] =
              typeof suppliedExpr === "object" && "expr" in suppliedExpr
                ? [suppliedExpr.expr, suppliedExpr.diags]
                : [suppliedExpr, undefined];
            const expr = `'${state} ${tcIndex} ' || (` +
              (typeof e === "string"
                ? SQLa.typicalQuotedSqlLiteral(e)[1].replaceAll("`", "'") // ` means "break out of SQL literal"
                : e.SQL(this.emitCtx)).replaceAll("tcIndex", String(tcIndex)) +
              ")";
            return d
              ? `${expr} || ${
                SQLa.typicalQuotedSqlLiteral(
                  `\n  ---\n  ${this.diags(d).replaceAll("\n", "\n  ")}...`,
                )[1].replaceAll("`", "'") // ` means "break out of SQL literal"
              }`
              : expr;
          };
          cases.push({
            when,
            then,
            otherwise,
            selectCaseExpr: (index) => ({
              SQL: () =>
                `SELECT CASE WHEN ${expr(when, index)} THEN ${
                  exprOrLit("ok", then, index)
                } ELSE ${
                  exprOrLit("not ok", otherwise ?? then, index)
                } END AS tap_result FROM test_case`,
            }),
          });
          // use "builder" pattern to chain multiple `.case` so return the object
          return result;
        },
      };
      return result;
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

    const testCases = await Promise.all(
      cc.filter({
        include: (c, instance) =>
          instance.methodIsNotTestCase.has(String(c))
            ? false
            : arbitrarySqlStmtRegEx.test(String(c)) == false,
      }).map(
        async (c) => {
          const assertion = await c.call() as ReturnType<
            TestSuiteNotebook["assertThat"]
          >;
          return {
            notebook: c.source.instance,
            tcName: String(c.callable),
            friendlyName: String(c.callable).replace(/_test$/, ""),
            assertion,
            isValid: typeof assertion === "object" && assertion["isAssertion"],
          };
        },
      ),
    );

    const valid = testCases.filter((tc) => tc.isValid);
    const totalCases = valid.reduce(
      (total, tc) => total + tc.assertion.cases.length,
      0,
    );

    // deno-fmt-ignore
    return [
      ...arbitrarySqlStmts,
      ...testCases.filter((tc) => !tc.isValid).map(tc => `-- Test Case "${tc.tcName}" did not return an assertThat instance (is ${typeof tc.assertion} instead)`),
      `CREATE VIEW "${sources[0]?.notebookName}" AS`,
      `    WITH`,
      `        tap_version AS (SELECT 'TAP version 14' AS tap_result),`,
      `        tap_plan AS (SELECT '1..${totalCases}' AS tap_result),`,
      `        ${valid.map((tc, index) => tc.assertion.SQL(tc.tcName, index + 1))}`,
      `    SELECT tap_result FROM tap_version`,
      `    UNION ALL`,
      `    SELECT tap_result FROM tap_plan`,
      `    UNION ALL`,
      `    ${valid.map((tc) => `SELECT tap_result FROM "${tc.tcName}"`).join("\n    UNION ALL\n")};`,
    ];
  }
}
