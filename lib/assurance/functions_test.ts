import { assertEquals } from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";


Deno.test("surveilr specific functions", async (t) => {
  await t.step("surveilr --version", async () => {
    const versionResult = await $`surveilr --version`
      .stdout("piped");
    assertEquals(
      versionResult.code,
      0,
      "❌ Error: Failed to check status.",
    );
    let version = versionResult.stdout;
    version = version.split(" ")[1].trim();

    const result = await $`surveilr shell --cmd "SELECT surveilr_version();"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr version function.",
    );
    const stdout = result.stdoutJson;
    const value = JSON.parse(stdout[0][Object.keys(stdout[0])[0]]);
    const surveilr_version = value["surveilr"];
    assertEquals(surveilr_version, version);
  });

  await t.step("mask", async () => {
    const result = await $`surveilr shell --cmd "SELECT mask('1234567890');"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr mask function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "*********");
  });
});

Deno.test("ast functions", async (t) => {
  await t.step("markdown to ast url", async () => {
    const url =
      `https://raw.githubusercontent.com/surveilr/www.surveilr.com/refs/heads/main/lib/assurance/test-fixtures/README.md`;
    const mdResult =
      await $`surveilr shell --cmd "select surveilr_markdown_uri_ast(${url}) as json_ast"`
        .stdout("piped");
    assertEquals(
      mdResult.code,
      0,
      "❌ Error: Failed to check status.",
    );
  });
});

// TODO: uncomment when 1.5.0 is released

// Deno.test("eval function: execute arbitrary SQL and returns the result as string", async (t) => {
//   await t.step(
//     "basic select",
//     async () => {
//       const result = await $`surveilr shell --cmd "select eval('select 42')"`
//         .stdout("piped");
//       assertEquals(
//         result.code,
//         0,
//         "❌ Error: Failed to select basic eval integer.",
//       );
//       const stdout = result.stdoutJson;
//       const value = stdout[0][Object.keys(stdout[0])[0]];
//       assertEquals(value, "42");
//     },
//   );

//   await t.step("integer additions", async () => {
//     const result = await $`surveilr shell --cmd "select eval('select 10 + 32')"`
//       .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "42");
//   });

//   await t.step("absolutes", async () => {
//     const result =
//       await $`surveilr shell --cmd "select eval('select abs(-42)')"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "42");
//   });

//   await t.step("string selections", async () => {
//     const result =
//       await $`surveilr shell --cmd "select eval('select ''hello''')"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval strings.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "hello");
//   });
// });

// Deno.test("eval function: joins multiple result values", async (t) => {
//   await t.step("default separator", async () => {
//     const result = await $`surveilr shell --cmd "select eval('select 1, 2, 3')"`
//       .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "1 2 3");
//   });

//   await t.step("custom separator", async () => {
//     const result =
//       await $`surveilr shell --cmd "select eval('select 1, 2, 3', '|')"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "1|2|3");
//   });
// });

// Deno.test("eval function: Joins multiple result rows into a single string", async (t) => {
//   await t.step("default separator", async () => {
//     const result =
//       await $`surveilr shell --cmd "select eval('select 1; select 2; select 3;')"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "1 2 3");
//   });

//   await t.step("custom separator", async () => {
//     const result =
//       await $`surveilr shell --cmd "select eval('select 1, 2, 3; select 4, 5, 6; select 7, 8, 9;')"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to select basic eval integer.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "1 2 3 4 5 6 7 8 9");
//   });
// });

// Deno.test("text functions", async (t) => {
//   await t.step("text_substring", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_substring('hello world', 7);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_substring function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "world");
//   });

//   await t.step("text_substring_end", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_substring('hello world', 7, 5);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_substring function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "world");
//   });

//   await t.step("text_slice positive start", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_slice('hello world', 7);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_slice function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "world");
//   });

//   await t.step("text_slice negative start and end", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_slice('hello world', -5, -2);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_slice function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "wor");
//   });

//   await t.step("text_right", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_right('hello world', 5);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_right function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "world");
//   });

//   await t.step("text_index", async () => {
//     const result =
//       await $`surveilr shell --cmd "select text_index('hello yellow', 'ello');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr text_index function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, 2);
//   });
// });

// Deno.test("regexp functions", async (t) => {
//   await t.step("regexp_like", async () => {
//     const result =
//       await $`surveilr shell --cmd "select regexp_like('the year is 2021', '[0-9]+');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr regexp_like function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, 1);
//   });

//   await t.step("regexp_substr", async () => {
//     const result =
//       await $`surveilr shell --cmd "select regexp_substr('the year is 2021', '[0-9]+');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr regexp_substr function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "2021");
//   });

//   await t.step("regexp_capture", async () => {
//     const result =
//       await $`surveilr shell --cmd "select regexp_capture('years is 2021', '\d\d(\d\d)', 1);"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr regexp_capture function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, null);
//   });

//   await t.step("regexp_replace", async () => {
//     const result =
//       await $`surveilr shell --cmd "select regexp_replace('the year is 2021', '[0-9]+', '2050');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr regexp_replace function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, "the year is 2050");
//   });
// });

// Deno.test("sqlite_html", async (t) => {
//   await t.step("html_extract", async () => {
//     const result =
//       await $`surveilr shell --cmd "select html_extract('<p> Hello, <b class=x>world!</b> </p>', 'b');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr html_extract function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, `<b class="x">world!</b>`);
//   });

//   await t.step("html_attribute_get", async () => {
//     const result =
//       await $`surveilr shell --cmd "select html_attr_get('<p> <a href="./about"> About<a/> </p>', 'a', 'href');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr html_attribute_get function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, `./about`);
//   });

//   await t.step("html_attribute_get", async () => {
//     const result =
//       await $`surveilr shell --cmd "select html_count('<div> <p>a</p> <p>b</p> <p>c</p> </div>', 'p');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr html_attribute_get function.",
//     );
//     const stdout = result.stdoutJson;
//     const value = stdout[0][Object.keys(stdout[0])[0]];
//     assertEquals(value, 3);
//   });
// });
// // TODO: add a test case to check if it works with a re-direct
// Deno.test("sqlite_url", async (t) => {
//   await t.step("http_get", async () => {
//     const result =
//       await $`surveilr shell --cmd "select request_url, response_status, length(response_body) from http_get('https://google.com');"`
//         .stdout("piped");
//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr http_get function.",
//     );
//     const stdout = result.stdoutJson;
//     const response = stdout[0];
//     assertEquals(response.response_status, `200 OK`);
//   });
// });

// Deno.test("sqlite_lines", async (t) => {
//   const filePath = "out.txt";
//   const fileContent = "Line 1\nLine 2\nLine 3";

//   await Deno.writeTextFile(filePath, fileContent);

//   await t.step("lines_read", async () => {
//     const result =
//       await $`surveilr shell --cmd "select * from lines_read(${filePath});"`
//         .stdout("piped");

//     assertEquals(
//       result.code,
//       0,
//       "❌ Error: Failed to execute surveilr lines_read function.",
//     );

//     const stdout = result.stdoutJson;
//     const response = stdout;

//     const expectedLines = fileContent.split("\n");
//     for (const [index, line] of expectedLines.entries()) {
//       assertEquals(
//         response[index]["line"],
//         line,
//         `❌ Error: Line ${index + 1} does not match.`,
//       );
//     }
//   });

//   await Deno.remove(filePath);
// });
