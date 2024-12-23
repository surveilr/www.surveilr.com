import {
  FullConfig,
  Reporter,
  Suite,
  TestCase,
  TestError, // Ensure TestError is imported for error handling
  TestResult,
} from "@playwright/test/reporter";
import * as fs from "fs";
import * as path from "path";
import { testcaseDetails } from "../testcase_details/home"; // Adjust the path as needed

class CustomJsonReporter implements Reporter {
  private outputDir: string;

  constructor() {
    this.outputDir = path.resolve(__dirname, "JSON"); // Folder name 'JSON'

    // Ensure the directory exists
    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
      console.log(`Directory created: ${this.outputDir}`);
    }
  }

  onBegin(config: FullConfig, suite: Suite) {
    console.log("Test run started...");
  }

  onTestEnd(test: TestCase, result: TestResult) {
    const testSteps: any[] = [];
    let overallError = ""; // Store aggregated error messages
    let hasFailedStep = false; // Flag to track if any step failed

    // Process each test step
    result.steps.forEach((step, index) => {
      let stepName = step.title;

      // Replace "Before Hooks" and "After Hooks" with meaningful names
      if (stepName === "Before Hooks") {
        stepName = "Load-Url";
      } else if (stepName === "After Hooks") {
        stepName = "Close-browser";
      }

      const stepStartTime = new Date(step.startTime).toISOString(); // Step start time
      const stepEndTime = new Date(
        new Date(step.startTime).getTime() + step.duration,
      ).toISOString(); // Step end time
      const stepDurationInSeconds = (step.duration / 1000).toFixed(2); // Duration in seconds

      const stepResult: any = {
        step: index + 1,
        stepname: stepName,
        status: step.error ? "failed" : "passed",
        start_time: stepStartTime,
        end_time: stepEndTime,
      };

      // Include error details if step failed
      if (step.error) {
        stepResult.Error = step.error.message;
        overallError += `Step ${index + 1}: ${step.error.message}\n`;
        hasFailedStep = true; // Mark as failed if any step has an error
      }

      testSteps.push(stepResult);
    });

    // Determine final test status based on step failures
    const finalStatus = hasFailedStep ? "failed" : "passed";

    // Test-level metadata
    const startTime = new Date(result.startTime).toISOString();
    const endTime = new Date(
      new Date(result.startTime).getTime() + result.duration,
    ).toISOString();
    const durationInSeconds = (result.duration / 1000).toFixed(2);

    // Fetch additional test details from external data
    const testCaseDetail = testcaseDetails.find((detail) =>
      test.title.includes(detail.description)
    );

    const testResult: any = {
      // test_case_fii: testCaseDetail ? testCaseDetail.run_id : test.title,
      test_case_fii: testCaseDetail ? testCaseDetail.id : "UNKNOWN",
      run_id: testCaseDetail ? testCaseDetail.run_id : "UNKNOWN",
      title: testCaseDetail ? testCaseDetail.title : test.title,
      status: finalStatus, // Use the determined final status
      start_time: startTime,
      end_time: endTime,
      total_duration: `${durationInSeconds} seconds`,
      steps: testSteps,
    };

    if (hasFailedStep) {
      testResult.error = `Errors encountered:\n${overallError.trim()}`;
    }

    // Generate a unique filename for each test case
    const testFileName = `${testCaseDetail.id}.run-1.result.json`;
    const testFilePath = path.join(this.outputDir, testFileName);

    try {
      fs.writeFileSync(testFilePath, JSON.stringify(testResult, null, 2));
      console.log(`Test case JSON report created: ${testFilePath}`);
    } catch (error) {
      console.error("Failed to write JSON report for test case:", error);
    }

    //     // Create the summary file in Markdown format
    //     // Create the run summary file in Markdown format
    //     const summaryContent = `
    // ---
    // FII: "${testResult.run_id}"
    // test_case_fii: "${testCaseDetail.id}"
    // run_date: "${new Date().toISOString().split("T")[0]}"
    // environment: "Production"
    // ---
    // ### Run Summary
    // -  Status: ${
    //       testResult.status.charAt(0).toUpperCase() + testResult.status.slice(1)
    //     }

    // -  Notes: ${
    //       hasFailedStep
    //         ? `Errors encountered:\n${overallError.trim()}`
    //         : "All steps executed successfully."
    //     }

    // `;

    //     const summaryFileName = `${testCaseDetail.id}.run.md`;
    //     const summaryFilePath = path.join(this.outputDir, summaryFileName);

    //     try {
    //       fs.writeFileSync(summaryFilePath, summaryContent.trim());
    //       console.log(`Summary file created: ${summaryFilePath}`);
    //     } catch (error) {
    //       console.error("Failed to write summary file:", error);
    //     }

    //     // Create the testcase file in Markdown format
    //     const testcaseContent = `
    // ---
    // FII: "${testCaseDetail ? testCaseDetail.id : "UNKNOWN"}"
    // title: "${testCaseDetail ? testCaseDetail.title : "UNKNOWN"}"
    // created_by: "arun-ramanan@netspective.in"
    // created_at: "${new Date().toISOString().split("T")[0]}"
    // tags: ["${testCaseDetail ? testCaseDetail.tags : "UNKNOWN"}"]
    // priority: "${testCaseDetail ? testCaseDetail.test_type : "UNKNOWN"}"
    // ---

    // ### Description
    // ${testCaseDetail ? testCaseDetail.description : "UNKNOWN"}

    // ### Steps
    // ${testSteps.map((step, index) => `${index + 1}. ${step.stepname}`).join("\n")}

    // ### Expected Outcome
    // •  ${testCaseDetail ? testCaseDetail.result : "UNKNOWN"}

    // ### Expected Results
    // <query-result>select x from y</query-result>
    // `;

    //     const testcaseFileName = `${testCaseDetail.id}.case.md`;
    //     const testcaseFilePath = path.join(this.outputDir, testcaseFileName);

    //     try {
    //       fs.writeFileSync(testcaseFilePath, testcaseContent.trim());
    //       console.log(`Test case file created: ${testcaseFilePath}`);
    //     } catch (error) {
    //       console.error("Failed to write test case file:", error);
    //     }
  }
}

export default CustomJsonReporter;
