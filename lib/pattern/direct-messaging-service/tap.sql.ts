#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { tapNB } from "../../std/notebook/mod.ts";

type TestCaseContext = tapNB.TestCaseContext;

export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
  // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
  // and included in the SQL stream before all the test cases
  "Check if important tables exist"(ctx: TestCaseContext) {
    return this.assertTable(ctx, "sqlpage_aide_navigation", "sqlpage_files");
  }
  "Check if important views exist"(ctx: TestCaseContext) {
    return this.assertView(
      ctx,
      "inbox",
      "mail_content_attachment",
      "patient_observation",
      "patient_detail",
      "author_detail",
    );
  }
  "Ensure at least 1 inbox content exists"(ctx: TestCaseContext) {
    return this.assertThat<"inbox_count">(ctx)`
            SELECT COUNT(*) AS inbox_count FROM inbox`
      .greaterThan("inbox_count", 0);
  }
  "Check for each inbox item, a patient data exists in 'patient_detail'"(
    ctx: TestCaseContext,
  ) {
    const patientDetailView = "patient_detail";
    const inboxView = "inbox";
    return this.assertThat<"patient_count">(ctx)`
      SELECT count(*) as patient_count from ${inboxView} i INNER JOIN ${patientDetailView} WHERE i.id = message_uid`
      .equals(
        "patient_count",
        `(select count(*) as inbox_count from ${inboxView})`,
      );
  }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  const SQL = await tapNB.TestSuiteNotebook.SQL(
    new SyntheticTestSuite("synthetic_test_suite"),
  );
  console.log(SQL.join("\n"));
  console.log(`SELECT * FROM synthetic_test_suite; `);
}
