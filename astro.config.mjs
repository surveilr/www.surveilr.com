import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";
import compressor from "astro-compressor";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  // https://docs.astro.build/en/guides/images/#authorizing-remote-images
  //site: "https://screwfast.uk",
  site: "https://www.surveilr.com",
  image: {
    domains: ["images.unsplash.com"],
  },
  // i18n: {
  //   defaultLocale: "en",
  //   locales: ["en", "fr"],
  //   fallback: {
  //     fr: "en",
  //   },
  //   routing: {
  //     prefixDefaultLocale: false,
  //   },
  // },
  prefetch: true,
  integrations: [
    tailwind(),
    sitemap({
      i18n: {
        defaultLocale: "en", // All urls that don't contain `fr` after `https://screwfast.uk/` will be treated as default locale, i.e. `en`
        locales: {
          en: "en", // The `defaultLocale` value must present in `locales` keys
          fr: "fr",
        },
      },
    }),
    starlight({
      title: "ScrewFast Docs",
      defaultLocale: "root",
      // https://github.com/withastro/starlight/blob/main/packages/starlight/CHANGELOG.md
      // If no Astro and Starlight i18n configurations are provided, the built-in default locale is used in Starlight and a matching Astro i18n configuration is generated/used.
      // If only a Starlight i18n configuration is provided, an equivalent Astro i18n configuration is generated/used.
      // If only an Astro i18n configuration is provided, the Starlight i18n configuration is updated to match it.
      // If both an Astro and Starlight i18n configurations are provided, an error is thrown.
      locales: {
        root: {
          label: "English",
          lang: "en",
        },
        de: { label: "Deutsch", lang: "de" },
        es: { label: "Español", lang: "es" },
        fa: { label: "Persian", lang: "fa", dir: "rtl" },
        fr: { label: "Français", lang: "fr" },
        ja: { label: "日本語", lang: "ja" },
        "zh-cn": { label: "简体中文", lang: "zh-CN" },
      },
      // https://starlight.astro.build/guides/sidebar/
      sidebar: [               
         {
          label: "Resource Surveillance Core",
          items: [
            {
              label: "Getting Started",
              link: "/surveilr/getting-started",
            },
            {
              label: "How-to",
              items: [
                {
                  label: "Installation Guide",
                  link: "/surveilr/how-to/installation-guide",
                },
                {
                  label: "How to Collect Evidence",
                  link: "/surveilr/how-to/evidence-collection",
                },
                {
                  label: "How to Ingest and Query Large JSON Files",
                  link: "/surveilr/how-to/ingest-and-query-json-files",
                },
                {
                  label: "How to Prepare Evidence at The-Edge",
                  link: "/surveilr/how-to/prepare-evidence-at-the-edge",
                },
                {
                  label: "How to Orchestrate Evidence",
                  link: "/surveilr/how-to/orchestrate-evidence",
                },
                {
                  label:
                    "How to Preview Evidence via surveilr SQLPage Integration",
                  link: "/surveilr/how-to/preview-evidence",
                },
              ],
            },
            {
              label: "Tutorials",
              link: "/surveilr/tutorials",
            },
            {
              label: "Reference",
              collapsed: true,
              items: [
                {
                  label: "Database",
                  collapsed: true,
                  items: [
                    {
                      label: "State Schema",
                      collapsed: true,
                      items: [
                        {
                          label: "State Schema",
                          link: "/surveilr/reference/db/surveilr-state-schema/state_schema",
                        },
                        {
                          label: "Behavior",
                          link: "/surveilr/reference/db/surveilr-state-schema/behavior",
                        },
                        {
                          label: "Device",
                          link: "/surveilr/reference/db/surveilr-state-schema/device",
                        },
                        {
                          label: "Device Party Relationship",
                          link: "/surveilr/reference/db/surveilr-state-schema/device_party_relationship",
                        },
                        {
                          label: "Gender Type",
                          link: "/surveilr/reference/db/surveilr-state-schema/gender_type",
                        },
                        {
                          label: "Orchestration Nature",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_nature",
                        },
                        {
                          label: "Orchestration Session",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session",
                        },
                        {
                          label: "Orchestration Session Log",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_log",
                        },
                        {
                          label: "Orchestration Session Entry",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_entry",
                        },
                        {
                          label: "Orchestration Session Exec",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_exec",
                        },
                        {
                          label: "Orchestration Session Issue",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_issue",
                        },
                        {
                          label: "Orchestration Session Issue Relation",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_issue_relation",
                        },
                        {
                          label: "Orchestration Session State",
                          link: "/surveilr/reference/db/surveilr-state-schema/orchestration_session_state",
                        },
                        {
                          label: "Organization",
                          link: "/surveilr/reference/db/surveilr-state-schema/organization",
                        },
                        {
                          label: "Organization Role",
                          link: "/surveilr/reference/db/surveilr-state-schema/organization_role",
                        },
                        {
                          label: "Organization Role Type",
                          link: "/surveilr/reference/db/surveilr-state-schema/organization_role_type",
                        },
                        {
                          label: "Party",
                          link: "/surveilr/reference/db/surveilr-state-schema/party",
                        },
                        {
                          label: "Party Type",
                          link: "/surveilr/reference/db/surveilr-state-schema/party_type",
                        },
                        {
                          label: "Party Relation",
                          link: "/surveilr/reference/db/surveilr-state-schema/party_relation",
                        },
                        {
                          label: "Party Relation Type",
                          link: "/surveilr/reference/db/surveilr-state-schema/party_relation_type",
                        },
                        {
                          label: "Person",
                          link: "/surveilr/reference/db/surveilr-state-schema/person",
                        },
                        {
                          label: "Uniform Resource",
                          link: "/surveilr/reference/db/surveilr-state-schema/uniform_resource",
                        },
                        {
                          label: "Uniform Resource Transform",
                          link: "/surveilr/reference/db/surveilr-state-schema/uniform_resource_transform",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Resource Path Match Rule ",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_resource_path_match_rule",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Resource Path Rewrite Rule ",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_resource_path_rewrite_rule",
                        },
                        {
                          label: "Uniform Resource Ingest Session",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session",
                        },
                        {
                          label: "Uniform Resource Ingest Session Attachment",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_attachment",
                        },
                        {
                          label: "Uniform Resource Ingest Session Fs Path",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_fs_path",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session Fs Path Entry",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_fs_path_entry",
                        },
                        {
                          label: "Uniform Resource Ingest Session IMAP Account",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_imap_account",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session IMAP Account Folder",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_imap_acct_folder",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session IMAP Account Folder Message",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_imap_acct_folder_message",
                        },
                        {
                          label: "Uniform Resource Ingest Session PLM Account",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_account",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Account Label",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_acct_label",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Account Project",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_acct_project",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Account Project Issue",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_acct_project_issue",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Account Relationship",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_acct_relationship",
                        },
                        {
                          label: "Uniform Resource Ingest Session PLM Comment",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_comment",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Issue Reaction",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_issue_reaction",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Issue Type",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_issue_type",
                        },
                        {
                          label:
                            "Uniform Resource Ingest Session PLM Milestone",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_milestone",
                        },
                        {
                          label: "Uniform Resource Ingest Session PLM Reaction",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_reaction",
                        },
                        {
                          label: "Uniform Resource Ingest Session PLM User",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_plm_user",
                        },
                        {
                          label: "Uniform Resource Ingest Session Task",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_task",
                        },
                        {
                          label: "Uniform Resource Ingest Session UDI-PGP SQL",
                          link: "/surveilr/reference/db/surveilr-state-schema/ur_ingest_session_udi_pgp_sql",
                        },
                      ],
                    },
                    {
                      label: "Notebooks Schema",
                      collapsed: true,
                      items: [
                        {
                          label: "Notebooks Schema",
                          link: "/surveilr/reference/db/surveilr-code-notebooks-schema/notebooks_schema",
                        },
                        {
                          label: "Assurance Schema",
                          link: "/surveilr/reference/db/surveilr-code-notebooks-schema/assurance_schema",
                        },
                        {
                          label: "Code Notebook Cell",
                          link: "/surveilr/reference/db/surveilr-code-notebooks-schema/code_notebook_cell",
                        },
                        {
                          label: "Code Notebook Kernel",
                          link: "/surveilr/reference/db/surveilr-code-notebooks-schema/code_notebook_kernel",
                        },
                        {
                          label: "Code Notebook State",
                          link: "/surveilr/reference/db/surveilr-code-notebooks-schema/code_notebook_state",
                        },
                      ],
                    },
                  ],
                },
                {
                  label: "Ingestion",
                  collapsed: true,
                  items: [
                    {
                      label: "Files Ingestion",
                      link: "/surveilr/reference/ingest/files",
                    },
                    {
                      label: "Tasks Ingestion",
                      link: "/surveilr/reference/ingest/tasks",
                    },
                    {
                      label: "Capturable Executables",
                      link: "/surveilr/reference/ingest/capexec",
                    },
                    {
                      label: "IMAP Emails Ingestion",
                      link: "/surveilr/reference/ingest/imap",
                    },
                  ],
                },
                {
                  label: "Admin",
                  collapsed: true,

                  items: [
                    { label: "Merge", link: "/surveilr/reference/admin/merge" },
                  ],
                },
                {
                  label: "Extending Surveilr",
                  collapsed: true,
                  items: [
                    {
                      label:
                        "Content Extensibility with Capturable Executables",
                      link: "/surveilr/reference/extend/content-extensibility",
                    },
                    {
                      label: "SQL DDL Extensibility with SQL Notebooks",
                      link: "/surveilr/reference/extend/sql-ddl-extensibility",
                    },
                    {
                      label:
                        "Integrated TypeScript programmability and scriptability",
                      link: "/surveilr/reference/extend/integrated-ts",
                    },
                  ],
                },

                {
                  label: "UDI",
                  collapsed: true,
                  items: [
                    {
                      label: "PGP",
                      collapsed: true,
                      items: [
                        {
                          label: "Introduction",
                          link: "/surveilr/reference/udi/pgp/intro",
                        },
                      ],
                    },
                  ],
                },
                {
                  label: "Concepts",
                  collapsed: true,
                  items: [
                    {
                      label: "RSSD",
                      link: "/surveilr/reference/concepts/resource-surveillance",
                    },
                    {
                      label: "WPAs",
                      link: "/surveilr/reference/concepts/work-product-artifacts",
                    },
                  ],
                },
                {
                  label: "Support",
                  collapsed: true,
                  items: [
                    {
                      label: "Filestash",
                      link: "/surveilr/reference/support/filestash",
                    },
                    {
                      label: "RCLONE",
                      link: "/surveilr/reference/support/rclone",
                    },
                  ],
                },

                {
                  label: "CLI Arguments",
                  link: "/surveilr/reference/arguments/cli-arguments",
                },
                {
                  label: "CLI Commands",
                  link: "/surveilr/reference/cli/commands",
                },
                {
                  label: "Aggregating RSSDs",
                  link: "/surveilr/reference/aggregate/aggregating-rssd",
                },
                {
                  label: "Code Notebooks",
                  link: "/surveilr/reference/code-notebooks",
                },
                {
                  label: "Terminologies",
                  link: "/surveilr/reference/terminology/terminologies",
                },
              ],
            },

            {
              label: "Disciplines and WPAs",
              collapsed: true,
              items: [
                {
                  label: "Software Engineers",
                  link: "/surveilr/disciplines/software-engineer",
                },
                {
                  label: "System Engineers",
                  link: "/surveilr/disciplines/system-engineer",
                },
                {
                  label: "QA Engineers",
                  link: "/surveilr/disciplines/qa",
                },
                {
                  label: "Security Analysts/Engineers",
                  link: "/surveilr/disciplines/security-analyst",
                },
                {
                  label: "Compliance Officers",
                  link: "/surveilr/disciplines/compliance-officer",
                },
                {
                  label: "Regulatory Affairs Specialists",
                  link: "/surveilr/disciplines/regulatory-affairs",
                },
                {
                  label: "Project Managers",
                  link: "/surveilr/disciplines/project-manager",
                },
                {
                  label: "Configuration Management Specialists",
                  link: "/surveilr/disciplines/configuration",
                },
                {
                  label: "Database Administrators",
                  link: "/surveilr/disciplines/database-admin",
                },
                {
                  label: "Network Administrators",
                  link: "/surveilr/disciplines/network-admin",
                },
                {
                  label: "DevOps Engineers",
                  link: "/surveilr/disciplines/devops",
                },
                {
                  label: "Technical Writers",
                  link: "/surveilr/disciplines/technical-writer",
                },
                {
                  label: "UI/UX Designers",
                  link: "/surveilr/disciplines/user-experience",
                },
                {
                  label: "Legal Counsel",
                  link: "/surveilr/disciplines/legal-counsel",
                },
                {
                  label: "Subject Matter Experts",
                  link: "/surveilr/disciplines/subject-matter-expert",
                },
                {
                  label: "Customer Support Representatives",
                  link: "/surveilr/disciplines/customer-support",
                },
                {
                  label: "Training and Education Specialists",
                  link: "/surveilr/disciplines/training",
                },
                {
                  label: "Risk Management Specialists",
                  link: "/surveilr/disciplines/risk-management",
                },
                {
                  label: "Incident Response Team Members",
                  link: "/surveilr/disciplines/incident-response",
                },
                {
                  label: "Performance and Reliability Engineers",
                  link: "/surveilr/disciplines/performance-reliability",
                },
                {
                  label: "Procurement Specialists",
                  link: "/surveilr/disciplines/procurement-specialist",
                },
                {
                  label: "Auditors",
                  link: "/surveilr/disciplines/auditors",
                },
                {
                  label: "External Assessors",
                  link: "/surveilr/disciplines/external-assessor",
                },
                {
                  label: "Ethical Hackers",
                  link: "/surveilr/disciplines/ethical-hacker",
                },
                {
                  label: "Penetration Testers",
                  link: "/surveilr/disciplines/penetration-tester",
                },
                {
                  label: "Compliance Automation Specialists",
                  link: "/surveilr/disciplines/compliance-automation",
                },
                {
                  label: "Business Analysts",
                  link: "/surveilr/disciplines/business-analyst",
                },
                {
                  label: "Product Owners",
                  link: "/surveilr/disciplines/product-owner",
                },
                {
                  label: "Product Managers",
                  link: "/surveilr/disciplines/product-managers",
                },
                {
                  label: "Human Factors Engineers",
                  link: "/surveilr/disciplines/human-factors-engineers",
                },
                {
                  label: "System Integrators",
                  link: "/surveilr/disciplines/system-integrators",
                },
                {
                  label: "Change Management Specialists",
                  link: "/surveilr/disciplines/change-management",
                },
                {
                  label: "Legal and Regulatory Consultants",
                  link: "/surveilr/disciplines/legal-consultants",
                },
                {
                  label: "Supply Chain Managers",
                  link: "/surveilr/disciplines/supply-chain-managers",
                },
                {
                  label: "Facilities Managers",
                  link: "/surveilr/disciplines/facilities-managers",
                },
                {
                  label: "Medical Device Specialists",
                  link: "/surveilr/disciplines/medical-device-specialists",
                },
                {
                  label: "Aerospace Engineers",
                  link: "/surveilr/disciplines/aerospace-engineers",
                },
                {
                  label: "Automotive Engineers",
                  link: "/surveilr/disciplines/automotive-engineers",
                },
              ],
            },

            {
              label: "FAQs",
              link: "/surveilr/faq/faqs",
            },
            {
              label: "Roadmap",
              link: "/surveilr/roadmap",
            },
            {
              collapsed: true,
              label: "Releases",
              items: [
                {
                  label: "v0.9.9",
                  link: "/surveilr/releases/v0_9_9",
                },
                {
                  label: "v0.9.10",
                  link: "/surveilr/releases/v0_9_10",
                },
                {
                  label: "v0.9.12",
                  link: "/surveilr/releases/v0_9_12",
                },
                {
                  label: "v0.9.13",
                  link: "/surveilr/releases/v0_9_13",
                },
                {
                  label: "v0.9.14",
                  link: "/surveilr/releases/v0_9_14",
                },
                {
                  label: "v0.9.16",
                  link: "/surveilr/releases/v0_9_16",
                },
                {
                  label: "v0.9.17",
                  link: "/surveilr/releases/v0_9_17",
                },
                {
                  label: "v0.10.0",
                  link: "/surveilr/releases/v0_10_0",
                },
                {
                  label: "v0.10.1",
                  link: "/surveilr/releases/v0_10_1",
                },
                {
                  label: "v0.10.2",
                  link: "/surveilr/releases/v0_10_2",
                },
                {
                  label: "v0.11.0",
                  link: "/surveilr/releases/v0_11_0",
                },
                {
                  label: "v0.13.0",
                  link: "/surveilr/releases/v0_13_0",
                },
                {
                  label: "v0.13.1",
                  link: "/surveilr/releases/v0_13_1",
                },
                {
                  label: "v0.13.2",
                  link: "/surveilr/releases/v0_13_2",
                },
                {
                  label: "v0.13.3",
                  link: "/surveilr/releases/v0_13_3",
                },
                {
                  label: "v0.13.4",
                  link: "/surveilr/releases/v0_13_4",
                },
                {
                  label: "v0.13.5",
                  link: "/surveilr/releases/v0_13_5",
                },
                {
                  label: "v0.13.6",
                  link: "/surveilr/releases/v0_13_6",
                },
                {
                  label: "v0.21.0",
                  link: "/surveilr/releases/v0_21_0",
                },
                {
                  label: "v0.22.1",
                  link: "/surveilr/releases/v0_22_1",
                },
                {
                  label: "v0.23.0",
                  link: "/surveilr/releases/v0_23_0",
                },
              ],
            },
          ],
        },{
          label: "Resource Surveillance Pattern",
          items:[],
        },{
          label: "Resource Surveillance Services",
          items:[],
        },

      ],
      social: {
        github: "https://github.com/surveilr",
      },
      disable404Route: true,
      customCss: ["./src/assets/styles/starlight.css"],
      favicon: "/favicon.ico",
      components: {
        SiteTitle: "./src/components/ui/starlight/SiteTitle.astro",
        Head: "./src/components/ui/starlight/Head.astro",
        MobileMenuFooter: "./src/components/ui/starlight/MobileMenuFooter.astro",
        ThemeSelect: "./src/components/ui/starlight/ThemeSelect.astro",
      },
      head: [
        {
          tag: "meta",
          attrs: {
            property: "og:image",
            content: "https://screwfast.uk" + "/social.webp",
          },
        },
        {
          tag: "meta",
          attrs: {
            property: "twitter:image",
            content: "https://screwfast.uk" + "/social.webp",
          },
        },
      ],
    }),
    compressor({
      gzip: false,
      brotli: true,
    }),
  ],
  output: "static",
  experimental: {
    clientPrerender: true,
    directRenderScript: true,
  },
});
