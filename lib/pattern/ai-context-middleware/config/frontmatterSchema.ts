import { z, ZodErrorMap, ZodIssue } from "npm:zod";

/**
 * A foundational schema containing properties common to most or all prompt frontmatter.
 * Specific schemas will extend this base to add their unique fields.
 */
const basePromptSchema = z.object({
  id: z.string(),
  title: z.string().describe("title"),
  summary: z.string().optional(),
  "merge-group": z.string(),
  order: z.number(),
  provenance: z.any(), // This is always managed by the processing script.
});

const productSchema = z.object({
  name: z.string().describe("product.name"),
  version: z.string().describe("product.version"),
  features: z.array(z.string().describe("product.features")),
});

// Custom error map
// @ts-ignore
const _customErrorMap = (issue, ctx) => {
  if (issue.code === "too_small" && issue.path.at(-1) === "title") {
    return { message: "The 'title' field is required." };
  }

  if (issue.code === "invalid_type") {
    if (issue.path.at(-1) === "name") {
      return { message: "The 'product.name' field must be a string." };
    }
    if (issue.path.at(-1) === "version") {
      return { message: "The 'product.version' field must be a string." };
    }
    if (issue.path.at(-1) === "features") {
      return { message: "Each entry in 'product.features' must be a string." };
    }
  }

  return { message: ctx.defaultError };
};

/**
 * A central registry of Zod schemas for validating the frontmatter
 * of different prompt merge groups.
 */
export const frontmatterSchemas = {
  /**
   * Extends the base schema with fields specific to test management tasks.
   */
  "task-test-management": basePromptSchema.extend({
    "artifact-nature": z.string().optional(),
    function: z.string().optional(),
    audience: z.string().optional(),
    visibility: z.string().optional(),
    tenancy: z.string().optional(),
    confidentiality: z.string().optional(),
    lifecycle: z.string().optional(),
    product: productSchema.optional(),
  }),

  /**
   * Extends the base schema for CMMC regime-specific instructions.
   */
  "regime-cmmc": basePromptSchema.extend({
    "artifact-nature": z.string().optional(),
    function: z.string().optional(),
    audience: z.string().optional(),
    visibility: z.string().optional(),
    tenancy: z.string().optional(),
    product: productSchema.optional(),
  }),

  // When you add a new schema, it will also extend the base. For example:
  // "new-merge-group": basePromptSchema.extend({
  //   purpose: z.string(),
  //   version: z.string().optional(),
  // }),
};

// You would apply the error map when parsing the schema, not globally
// Example usage (assuming you have a 'data' object to validate):
// const result = basePromptSchema.safeParse(data, { errorMap: _customErrorMap });