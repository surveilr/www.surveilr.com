module.exports = {
  extends: ["@commitlint/config-conventional"],
  parserPreset: {
    parserOpts: {
      issuePrefixes: ["#"],
    },
  },
  rules: {
    "references-empty": [2, "never"],
  },
};
