import { SQLa } from "../std/deps.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

export function tapViewDefinition<
    ViewName extends string,
    Context extends SQLa.SqlEmitContext,
    DomainQS extends SQLa.SqlDomainQS,
>(
    viewName: ViewName,
    vdOptions?:
        & ViewDefnOptions<ViewName, Any, Any, Context>
        & Partial<emit.EmbeddedSqlSupplier>,
) {
    return (
        literals: TemplateStringsArray,
        ...expressions: SQLa.SqlPartialExpression<Context>[]
    ) => {
        const { isTemp, isIdempotent = true, embeddedSQL = SQLa.SQL } =
            vdOptions ??
                {};
        const ssPartial = SQLa.untypedSelect<Any, Context>({ embeddedSQL });
        const selectStmt = ssPartial(literals, ...expressions);
        const viewDefn:
            & ViewDefinition<ViewName, Context, DomainQS>
            & emit.SqlSymbolSupplier<Context>
            & emit.SqlTextLintIssuesPopulator<Context> = {
                isValid: selectStmt.isValid,
                viewName,
                isTemp,
                isIdempotent,
                domains: [], // in unsafe, the domains are not known
                populateSqlTextLintIssues: (lintIssues, steOptions) =>
                    selectStmt.populateSqlTextLintIssues(
                        lintIssues,
                        steOptions,
                    ),
                sqlSymbol: (ctx) =>
                    ctx.sqlNamingStrategy(ctx, {
                        quoteIdentifiers: true,
                        qnss: vdOptions?.sqlNS,
                    }).viewName(viewName),
                SQL: (ctx) => {
                    const { sqlTextEmitOptions: steOptions } = ctx;
                    const rawSelectStmtSqlText = selectStmt.SQL(ctx);
                    const viewSelectStmtSqlText = steOptions.indentation(
                        "create view select statement",
                        rawSelectStmtSqlText,
                    );
                    // use this naming strategy when schema/namespace might be necessary
                    const ns = ctx.sqlNamingStrategy(ctx, {
                        quoteIdentifiers: true,
                        qnss: vdOptions?.sqlNS,
                    });
                    // by default we create for ANSI/SQLite/"other"
                    // deno-fmt-ignore
                    let create = `CREATE ${isTemp ? "TEMP " : ""}VIEW ${ isIdempotent ? "IF NOT EXISTS " : ""}${ns.viewName(viewName)} AS\n${viewSelectStmtSqlText}`;
                    if (
                        emit.isPostgreSqlDialect(ctx.sqlDialect)
                    ) {
                        // deno-fmt-ignore
                        create = `CREATE ${ isIdempotent ? "OR REPLACE " : ""}${isTemp ? "TEMP " : ""}VIEW ${ns.viewName(viewName)} AS\n${viewSelectStmtSqlText}`;
                    } else if (
                        emit.isMsSqlServerDialect(ctx.sqlDialect)
                    ) {
                        // deno-fmt-ignore
                        create = `CREATE ${ isIdempotent ? "OR ALTER " : ""}${isTemp ? "TEMP " : ""}VIEW ${ns.viewName(viewName)} AS\n${viewSelectStmtSqlText}`;
                    }
                    return vdOptions?.before
                        ? ctx.embeddedSQL<Context>(
                            vdOptions.embeddedStsOptions,
                        )`${[
                            vdOptions.before(viewName, vdOptions),
                            create,
                        ]}`.SQL(ctx)
                        : create;
                },
            };
        return {
            ...viewDefn,
            selectStmt,
            drop: (options?: { ifExists?: boolean }) =>
                dropView(viewName, options),
        };
    };
}
