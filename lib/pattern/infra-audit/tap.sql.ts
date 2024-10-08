import { tapNB } from "../../std/notebook/mod.ts";
type TestCaseContext = tapNB.TestCaseContext;
export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases

    "Check if a view 'tenant_based_control_regime' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "tenant_based_control_regime";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'tenant_based_control_regime' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"tenant_based_control_regime_count">(ctx)`
            SELECT COUNT(*) AS tenant_based_control_regime_count FROM tenant_based_control_regime`
            .greaterThan("tenant_based_control_regime_count", 0);
    }

    "Check if a view 'audit_session_control' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_session_control";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_session_control' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_session_control_count">(ctx)`
            SELECT COUNT(*) AS audit_session_control_count FROM audit_session_control`
            .greaterThan("audit_session_control_count", 0);
    }

    "Check if a view 'audit_session_list' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_session_list";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_session_list' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_session_list_count">(ctx)`
            SELECT COUNT(*) AS audit_session_list_count FROM audit_session_list`
            .greaterThan("audit_session_list_count", 0);
    }

    "Check if a view 'query_result' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "query_result";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'query_result' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"query_result_count">(ctx)`
            SELECT COUNT(*) AS query_result_count FROM query_result`
            .greaterThan("query_result_count", 0);
    }

    "Check if a view 'audit_session_info' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_session_info";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_session_info' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_session_info_count">(ctx)`
            SELECT COUNT(*) AS audit_session_info_count FROM audit_session_info`
            .greaterThan("audit_session_info_count", 0);
    }

    "Check if a view 'evidence_query_result' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence_query_result";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence_query_result' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_query_result_count">(ctx)`
            SELECT COUNT(*) AS evidence_query_result_count FROM evidence_query_result`
            .greaterThan("evidence_query_result_count", 0);
    }

    "Check if a view 'audit_session_control_group' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_session_control_group";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_session_control_group' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_session_control_group_count">(ctx)`
            SELECT COUNT(*) AS audit_session_control_group_count FROM audit_session_control_group`
            .greaterThan("audit_session_control_group_count", 0);
    }

    "Check if a view 'audit_control_evidence' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_control_evidence";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_control_evidence' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_control_evidence_count">(ctx)`
            SELECT COUNT(*) AS audit_control_evidence_count FROM audit_control_evidence`
            .greaterThan("audit_control_evidence_count", 0);
    }

    "Check if a view 'policy' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "policy";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'policy' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"policy_count">(ctx)`
            SELECT COUNT(*) AS policy_count FROM policy`
            .greaterThan("policy_count", 0);
    }

    "Check if a view 'evidence' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_count">(ctx)`
            SELECT COUNT(*) AS evidence_count FROM evidence`
            .greaterThan("evidence_count", 0);
    }

    "Check if a view 'evidence_evidenceresult' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence_evidenceresult";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence_evidenceresult' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_evidenceresult_count">(ctx)`
            SELECT COUNT(*) AS evidence_evidenceresult_count FROM evidence_evidenceresult`
            .greaterThan("evidence_evidenceresult_count", 0);
    }

    "Check if a view 'evidence_customtag' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence_customtag";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence_customtag' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_customtag_count">(ctx)`
            SELECT COUNT(*) AS evidence_customtag_count FROM evidence_customtag`
            .greaterThan("evidence_customtag_count", 0);
    }

    "Check if a view 'evidence_anchortag' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence_anchortag";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence_anchortag' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_anchortag_count">(ctx)`
            SELECT COUNT(*) AS evidence_anchortag_count FROM evidence_anchortag`
            .greaterThan("evidence_anchortag_count", 0);
    }

    "Check if a view 'evidence_imagetag' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "evidence_imagetag";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'evidence_imagetag' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"evidence_imagetag_count">(ctx)`
            SELECT COUNT(*) AS evidence_imagetag_count FROM evidence_imagetag`
            .greaterThan("evidence_imagetag_count", 0);
    }

    "Check if a view 'audit_session_control_status' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "audit_session_control_status";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'audit_session_control_status' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"audit_session_control_status_count">(ctx)`
            SELECT COUNT(*) AS audit_session_control_status_count FROM audit_session_control_status`
            .greaterThan("audit_session_control_status_count", 0);
    }

    "Check if a view 'control_group' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "control_group";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'control_group' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"control_group_count">(ctx)`
            SELECT COUNT(*) AS control_group_count FROM control_group`
            .greaterThan("control_group_count", 0);
    }

    "Check if a view 'control' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "control";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'control' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"control_count">(ctx)`
            SELECT COUNT(*) AS control_count FROM control`
            .greaterThan("control_count", 0);
    }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
    const SQL = await tapNB.TestSuiteNotebook.SQL(
        new SyntheticTestSuite("synthetic_test_suite"),
    );

    console.log(SQL.join("\n"));
    console.log(`SELECT * FROM synthetic_test_suite;`);
}
