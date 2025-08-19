Here's an example TypeScript spec: a single source of type-safe truth to generate all downstream configs from it. Below is a production‑ready Deno CLI (`reliability.conf.ts`) that:

* Defines strong types for SLOs, SLIs, Never Events, alerting routes, and environment overrides.
* Keeps all business rules in `const` objects (checked into Git).
* Emits Prometheus alert rules, Alertmanager routes, OpenTelemetry Collector pipelines, generic synthetic checks, and the canonical `never-events` registry in YAML/JSON/TOML/XML—straight to STDOUT.
* Uses JSR modules only (Cliffy and Deno std libs).

You can drop this into your repo and start generating configs immediately.

```ts
#!/usr/bin/env -S deno run --allow-read --allow-env

/**
 * reliability.conf.ts
 *
 * Canonical, strongly-typed reliability spec & config emitter for Opsfolio.
 * One source of truth → many loosely-coupled tool configs (YAML/JSON/TOML/XML).
 *
 * Usage examples:
 *   ./reliability.conf.ts --help
 *   ./reliability.conf.ts emit prometheus-rules --env prod > opsfolio.rules.yaml
 *   ./reliability.conf.ts emit alertmanager --env prod > alertmanager.yaml
 *   ./reliability.conf.ts emit otel-collector --env prod > otel-collector.yaml
 *   ./reliability.conf.ts emit synthetics --env prod --format json > synthetics.json
 *   ./reliability.conf.ts emit never-events --format yaml > never-events.yaml
 *   ./reliability.conf.ts list targets
 */

import { Command } from "jsr:@cliffy/command@1.0.0";
import { stringify as yamlStringify } from "jsr:@std/yaml@1.0.5";
import { stringify as tomlStringify } from "jsr:@std/toml@1.0.0";

/* =========================
 * 1) Canonical Types
 * ========================= */

type Env = "dev" | "uat" | "prod" | "bc";
type Severity = "critical" | "high" | "medium" | "low";
type Detector =
  | "synthetic_http"
  | "promql"
  | "promql_ratio"
  | "promql_abs";

type NotifyChannel = "pagerduty" | "sms" | "email";

interface SLI_Ratio {
  kind: "ratio";
  numeratorMetric: string;      // prom metric or OTel view name
  denominatorMetric: string;
  window: string;               // e.g., "5m", "10m"
  labels?: Record<string, string>;
}

interface SLI_Latency {
  kind: "latency";
  metric: string;               // histogram name
  thresholdMs: number;          // good-bucket threshold
  p?: 50 | 90 | 95 | 99;        // optional percentile for SLI definition
  labels?: Record<string, string>;
  window: string;
}

interface SLI_Availability {
  kind: "availability";
  metric: string;               // e.g., synthetic_ok_total
  badMetric?: string;           // optional explicit bad counter
  window: string;
  labels?: Record<string, string>;
}

type SLI = SLI_Ratio | SLI_Latency | SLI_Availability;

interface SLO {
  id: string;
  description: string;
  targetPercent: number;     // 99.9, 99.95 etc.
  windowDays: number;        // 30, 28, etc.
  sli: SLI;
  appliesTo: Env[];
}

interface NeverEvent {
  id: string;
  description: string;
  detector: Detector;
  // Generic fields; only some apply depending on detector
  targetUrl?: string;                 // for synthetic_http
  expr?: string;                      // for promql
  numerator?: string;                 // for promql_ratio
  denominator?: string;               // for promql_ratio
  absMetric?: string;                 // for promql_abs
  threshold?: number | string;        // numeric or duration e.g., "5m"
  window?: string;                    // e.g., "10m"
  severity: Severity;
  notify: NotifyChannel[];
  runbook: string;                    // path/URL to runbook
  sloRef: string;                     // link to SLO.id
  dashboard?: string;                 // grafana dashboard ref
  labels?: Record<string, string>;
  appliesTo: Env[];
}

interface Alerting {
  // Use env vars to avoid committing secrets
  pagerDutyRoutingKeyEnv: string;   // e.g., "PAGERDUTY_ROUTING_KEY"
  smsWebhookEnv?: string;           // e.g., "SMS_WEBHOOK_URL" (optional)
  emailTo: string;                  // distro list for non-paging alerts
}

interface OtelCollectorExports {
  tracesEndpoint: string;    // Tempo or vendor
  metricsExporter?: "prometheus"; // we default to Prometheus scrape
  logsEndpoint?: string;     // Loki or vendor
}

interface EnvironmentSpec {
  env: Env;
  region?: string;
  alerting: Alerting;
  otel: OtelCollectorExports;
  // any environment-specific label defaults (added to alerts)
  defaultLabels?: Record<string, string>;
}

/* =========================
 * 2) Canonical Spec (Business Rules)
 *    — All config below is the single source of truth —
 * ========================= */

// 2.1 SLOs (examples focused on current priorities)
const SLOS: readonly SLO[] = [
  {
    id: "WebAvailability",
    description: "www.opsfolio.com returns 2xx on key endpoints",
    targetPercent: 99.95,
    windowDays: 30,
    sli: {
      kind: "availability",
      metric: "synthetic_ok_total",
      window: "5m",
      labels: { check: "web_root" },
    },
    appliesTo: ["prod", "bc"],
  },
  {
    id: "ChatAvailability",
    description: "Chat requests succeed within 5s",
    targetPercent: 99.9,
    windowDays: 30,
    sli: {
      kind: "ratio",
      numeratorMetric: "chat_success_total",
      denominatorMetric: "chat_requests_total",
      window: "10m",
      labels: { route: "/api/chat" },
    },
    appliesTo: ["prod", "bc", "uat"],
  },
  {
    id: "CmmcAssessmentAvailability",
    description: "CMMC Assessment API responds 2xx within 3s",
    targetPercent: 99.9,
    windowDays: 30,
    sli: {
      kind: "ratio",
      numeratorMetric: "api_http_requests_total{route=~\"/api/cmmc/.*\",status=~\"2..\"}",
      denominatorMetric: "api_http_requests_total{route=~\"/api/cmmc/.*\"}",
      window: "10m",
    },
    appliesTo: ["prod", "bc", "uat"],
  },
  {
    id: "AuthSuccessRate",
    description: "Valid sign-in attempts succeed",
    targetPercent: 99.9,
    windowDays: 30,
    sli: {
      kind: "ratio",
      numeratorMetric: "auth_success_total",
      denominatorMetric: "auth_requests_total",
      window: "10m",
    },
    appliesTo: ["prod", "bc", "uat"],
  },
];

// 2.2 Never Events (examples)
const NEVER_EVENTS: readonly NeverEvent[] = [
  {
    id: "SITE_DOWN",
    description: "www.opsfolio.com returns 5xx/timeouts > 5 minutes",
    detector: "synthetic_http",
    targetUrl: "https://www.opsfolio.com/health",
    threshold: "5m",
    window: "1m",
    severity: "critical",
    notify: ["pagerduty", "sms", "email"],
    runbook: "runbooks/site_down.md",
    sloRef: "WebAvailability",
    dashboard: "dashboards/web_overview.json",
    labels: { service: "web", feature: "root" },
    appliesTo: ["prod", "bc"],
  },
  {
    id: "CMMC_ASSESSMENT_UNAVAILABLE",
    description: ">5% 5xx for CMMC endpoints over 15m",
    detector: "promql",
    expr:
      "sum(rate(api_http_requests_total{route=~\"/api/cmmc/.*\",status=~\"5..\"}[5m])) / sum(rate(api_http_requests_total{route=~\"/api/cmmc/.*\"}[5m])) > 0.05",
    window: "15m",
    severity: "critical",
    notify: ["pagerduty", "sms"],
    runbook: "runbooks/cmmc_api.md",
    sloRef: "CmmcAssessmentAvailability",
    dashboard: "dashboards/cmmc.json",
    labels: { service: "cmmc-api" },
    appliesTo: ["prod", "bc", "uat"],
  },
  {
    id: "CHAT_BACKEND_FAILURE",
    description: ">10% chat failures over 10m",
    detector: "promql_ratio",
    numerator: "rate(chat_failures_total[10m])",
    denominator: "rate(chat_requests_total[10m])",
    threshold: 0.10,
    window: "10m",
    severity: "critical",
    notify: ["pagerduty", "sms"],
    runbook: "runbooks/chat_backend.md",
    sloRef: "ChatAvailability",
    dashboard: "dashboards/chat.json",
    labels: { service: "chat" },
    appliesTo: ["prod", "bc", "uat"],
  },
  {
    id: "AUTH_ERRORS_SPIKE",
    description: "Auth failure rate > 5% over 10m",
    detector: "promql_ratio",
    numerator: "rate(auth_failures_total[10m])",
    denominator: "rate(auth_requests_total[10m])",
    threshold: 0.05,
    window: "10m",
    severity: "high",
    notify: ["pagerduty", "email"],
    runbook: "runbooks/auth.md",
    sloRef: "AuthSuccessRate",
    dashboard: "dashboards/auth.json",
    labels: { service: "auth" },
    appliesTo: ["prod", "bc", "uat"],
  },
  {
    id: "DB_UNREACHABLE",
    description: "DB connectivity errors > 0 over 2m",
    detector: "promql_abs",
    absMetric: "increase(db_errors_total{type=\"connectivity\"}[2m])",
    threshold: 0,
    window: "2m",
    severity: "critical",
    notify: ["pagerduty", "sms"],
    runbook: "runbooks/database.md",
    sloRef: "WebAvailability",
    dashboard: "dashboards/db.json",
    labels: { service: "db" },
    appliesTo: ["prod", "bc", "uat"],
  },
];

// 2.3 Environment catalog
const ENVS: readonly EnvironmentSpec[] = [
  {
    env: "prod",
    region: "us-east-1",
    alerting: {
      pagerDutyRoutingKeyEnv: "PAGERDUTY_ROUTING_KEY",
      smsWebhookEnv: "SMS_WEBHOOK_URL",
      emailTo: "eng-leads@opsfolio.com",
    },
    otel: {
      tracesEndpoint: "https://tempo.opsfolio.com:4317",
      metricsExporter: "prometheus",
      logsEndpoint: "https://loki.opsfolio.com",
    },
    defaultLabels: { env: "prod" },
  },
  {
    env: "bc",
    region: "us-east-1",
    alerting: {
      pagerDutyRoutingKeyEnv: "PAGERDUTY_ROUTING_KEY_BC",
      smsWebhookEnv: "SMS_WEBHOOK_URL_BC",
      emailTo: "eng-leads@opsfolio.com",
    },
    otel: {
      tracesEndpoint: "https://tempo-bc.opsfolio.com:4317",
      metricsExporter: "prometheus",
      logsEndpoint: "https://loki-bc.opsfolio.com",
    },
    defaultLabels: { env: "bc" },
  },
  {
    env: "uat",
    region: "eu-central-1",
    alerting: {
      pagerDutyRoutingKeyEnv: "PAGERDUTY_ROUTING_KEY_UAT",
      emailTo: "eng-leads@opsfolio.com",
    },
    otel: {
      tracesEndpoint: "https://tempo-uat.opsfolio.com:4317",
      metricsExporter: "prometheus",
    },
    defaultLabels: { env: "uat" },
  },
  {
    env: "dev",
    region: "eu-central-1",
    alerting: {
      pagerDutyRoutingKeyEnv: "PAGERDUTY_ROUTING_KEY_DEV",
      emailTo: "eng@opsfolio.com",
    },
    otel: {
      tracesEndpoint: "http://localhost:4317",
      metricsExporter: "prometheus",
    },
    defaultLabels: { env: "dev" },
  },
];

/* =========================
 * 3) Selectors & Utilities
 * ========================= */

function byEnv<T extends { appliesTo: Env[] }>(items: readonly T[], env: Env): T[] {
  return items.filter((i) => i.appliesTo.includes(env));
}

function envSpec(env: Env): EnvironmentSpec {
  const found = ENVS.find((e) => e.env === env);
  if (!found) throw new Error(`Unknown env: ${env}`);
  return found;
}

type OutFormat = "yaml" | "json" | "toml" | "xml";

function emit(data: unknown, format: OutFormat): string {
  switch (format) {
    case "yaml":
      return yamlStringify(data);
    case "json":
      return JSON.stringify(data, null, 2);
    case "toml":
      return tomlStringify(data as Record<string, unknown>);
    case "xml":
      // Minimal XML emitter (for illustrative targets)
      return toXml(data);
    default:
      throw new Error(`Unsupported format: ${format}`);
  }
}

function toXml(data: unknown, indent = 0, name = "root"): string {
  const pad = "  ".repeat(indent);
  if (data === null || data === undefined) return `${pad}<${name}/>\n`;
  if (typeof data !== "object") return `${pad}<${name}>${escapeXml(String(data))}</${name}>\n`;
  if (Array.isArray(data)) {
    return data.map((v) => toXml(v, indent, name)).join("");
  }
  let out = `${pad}<${name}>\n`;
  for (const [k, v] of Object.entries(data)) {
    out += toXml(v, indent + 1, k);
  }
  out += `${pad}</${name}>\n`;
  return out;
}

function escapeXml(s: string) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/* =========================
 * 4) Generators (Targets)
 * ========================= */

// 4.1 Canonical never-events (tool-agnostic registry)
function genNeverEvents(env: Env) {
  const items = byEnv(NEVER_EVENTS, env);
  return {
    version: 1,
    env,
    never_events: items.map((n) => ({
      id: n.id,
      description: n.description,
      detector: n.detector,
      target: n.targetUrl,
      expr: n.expr,
      numerator: n.numerator,
      denominator: n.denominator,
      absMetric: n.absMetric,
      threshold: n.threshold,
      window: n.window,
      severity: n.severity,
      notify: n.notify,
      runbook: n.runbook,
      slo: n.sloRef,
      dashboard: n.dashboard,
      labels: { ...(envSpec(env).defaultLabels ?? {}), ...(n.labels ?? {}) },
    })),
  };
}

// 4.2 Prometheus alert rules
function genPrometheusRules(env: Env) {
  const items = byEnv(NEVER_EVENTS, env);
  const rules = items.map((n) => {
    let expr: string;
    switch (n.detector) {
      case "promql":
        expr = n.expr ?? "vector(0)";
        break;
      case "promql_ratio":
        expr = `(${n.numerator}) / (${n.denominator}) > ${n.threshold}`;
        break;
      case "promql_abs":
        // absMetric is already a prom expr; compare against threshold
        expr = `${n.absMetric} > ${n.threshold}`;
        break;
      case "synthetic_http":
        // Assume a synthetic counter exists: synthetic_fail_total{check="<id>"}
        // Alert if failures increase for the duration
        expr = `increase(synthetic_fail_total{check="${n.id}"}[${n.window ?? "5m"}]) > 0`;
        break;
      default:
        expr = "vector(0)";
    }
    const forWindow = typeof n.threshold === "string" ? n.threshold : n.window ?? "5m";
    const labels = {
      severity: n.severity,
      never_event: n.id,
      ...(envSpec(env).defaultLabels ?? {}),
      ...(n.labels ?? {}),
    };
    const annotations = {
      summary: n.description,
      runbook: n.runbook,
      slo: n.sloRef,
      dashboard: n.dashboard ?? "",
    };
    return {
      alert: n.id,
      expr,
      for: forWindow,
      labels,
      annotations,
    };
  });

  return {
    groups: [
      {
        name: `opsfolio-${env}-never-events`,
        rules,
      },
    ],
  };
}

// 4.3 Alertmanager routing
function genAlertmanager(env: Env) {
  const a = envSpec(env).alerting;
  const receivers: Record<string, unknown>[] = [
    {
      name: "pagerduty",
      pagerduty_configs: [
        { routing_key: `$${a.pagerDutyRoutingKeyEnv}` }, // interpolated by your CD system or envsubst
      ],
    },
    {
      name: "email",
      email_configs: [{ to: a.emailTo }],
    },
  ];
  if (a.smsWebhookEnv) {
    receivers.push({
      name: "sms",
      webhook_configs: [{ url: `$${a.smsWebhookEnv}` }],
    });
  }

  // Route critical/high → pagerduty (+sms if configured); others → email
  const route = {
    receiver: "email",
    routes: [
      {
        receiver: "pagerduty",
        matchers: ['severity="critical"'],
      },
      {
        receiver: "pagerduty",
        matchers: ['severity="high"'],
      },
      ...(a.smsWebhookEnv
        ? [{ receiver: "sms", matchers: ['severity="critical"'] }]
        : []),
    ],
  };

  return { route, receivers };
}

// 4.4 OpenTelemetry Collector pipeline
function genOtelCollector(env: Env) {
  const o = envSpec(env).otel;
  const hasLogs = !!o.logsEndpoint;

  const doc: Record<string, unknown> = {
    receivers: {
      otlp: { protocols: { http: {}, grpc: {} } },
    },
    processors: {
      batch: {},
      memory_limiter: {},
      tail_sampling: {
        decision_wait: "5s",
        policies: [
          { name: "errors", type: "status_code", status_codes: ["ERROR"] },
          { name: "slow", type: "latency", threshold_ms: 2000 },
        ],
      },
    },
    exporters: {
      otlp: { endpoint: o.tracesEndpoint },
      ...(o.metricsExporter === "prometheus"
        ? { prometheus: { endpoint: "0.0.0.0:9464" } }
        : {}),
      ...(hasLogs ? { loki: { endpoint: o.logsEndpoint } } : {}),
    },
    service: {
      pipelines: {
        traces: {
          receivers: ["otlp"],
          processors: ["memory_limiter", "batch", "tail_sampling"],
          exporters: ["otlp"],
        },
        metrics: {
          receivers: ["otlp"],
          processors: ["batch"],
          exporters: o.metricsExporter === "prometheus" ? ["prometheus"] : [],
        },
        ...(hasLogs
          ? {
              logs: {
                receivers: ["otlp"],
                processors: ["batch"],
                exporters: ["loki"],
              },
            }
          : {}),
      },
    },
  };

  return doc;
}

// 4.5 Generic HTTP synthetic checks (tool-agnostic JSON)
function genSynthetics(env: Env) {
  const items = byEnv(NEVER_EVENTS, env).filter((n) => n.detector === "synthetic_http");
  return {
    version: 1,
    env,
    http_checks: items.map((n) => ({
      id: n.id,
      name: n.description,
      url: n.targetUrl!,
      method: "GET",
      intervalSeconds: 60,
      timeoutSeconds: 10,
      successCriteria: { statusCode: 200 },
      severity: n.severity,
      labels: { ...(envSpec(env).defaultLabels ?? {}), ...(n.labels ?? {}) },
    })),
  };
}

/* =========================
 * 5) CLI
 * ========================= */

const SUPPORTED_TARGETS = [
  "never-events",
  "prometheus-rules",
  "alertmanager",
  "otel-collector",
  "synthetics",
] as const;

type Target = typeof SUPPORTED_TARGETS[number];

function render(target: Target, env: Env, format: OutFormat): string {
  switch (target) {
    case "never-events":
      return emit(genNeverEvents(env), format);
    case "prometheus-rules":
      return emit(genPrometheusRules(env), "yaml"); // Prometheus wants YAML
    case "alertmanager":
      return emit(genAlertmanager(env), "yaml"); // Alertmanager wants YAML
    case "otel-collector":
      return emit(genOtelCollector(env), "yaml"); // Collector wants YAML
    case "synthetics":
      return emit(genSynthetics(env), format);    // JSON/YAML/TOML/XML ok
    default:
      throw new Error(`Unknown target: ${target}`);
  }
}

await new Command()
  .name("reliability.conf.ts")
  .version("1.0.0")
  .description("Opsfolio reliability config generator (canonical TypeScript → tool configs)")
  .command("list")
  .description("List available targets")
  .action(() => {
    console.log(JSON.stringify({ targets: SUPPORTED_TARGETS }, null, 2));
  })
  .command("emit")
  .description("Emit config for a target")
  .arguments("<target:string>")
  .option("--env <env:string>", "Environment (dev|uat|prod|bc)", { default: "prod" })
  .option("--format <fmt:string>", "Output format (yaml|json|toml|xml)", { default: "yaml" })
  .action((opts, targetArg: string) => {
    const env = opts.env as Env;
    const fmt = opts.format as OutFormat;
    if (!["dev", "uat", "prod", "bc"].includes(env)) {
      console.error(`Invalid --env: ${env}`);
      Deno.exit(2);
    }
    if (!SUPPORTED_TARGETS.includes(targetArg as Target)) {
      console.error(`Unknown target: ${targetArg}. Try "list" to see options.`);
      Deno.exit(2);
    }
    const out = render(targetArg as Target, env, fmt);
    console.log(out);
  })
  .parse(Deno.args);
```

How this maps to your strategy

1. Canonical specification lives in TypeScript
   The `SLOS`, `NEVER_EVENTS`, and `ENVS` `const` arrays (fully typed) are your single source of truth. They encode business rules like Never Events, SLI/SLOs, alert severities, runbook paths, and environment routing.

2. Centralized governance → decentralized configs
   Generators (`genPrometheusRules`, `genAlertmanager`, `genOtelCollector`, `genSynthetics`, `genNeverEvents`) transform the canonical spec into whatever your downstream systems need—without hand‑editing YAML. Teams consume emitted files per environment via CI/CD.

3. Evidence and auditability

* All business logic is committed in Git as TypeScript.
* Outputs are deterministically generated (include this tool in CI and attach the artifacts to releases).
* Runbooks are referenced directly (e.g., `runbooks/site_down.md`) ensuring every alert maps to a documented response.

4. Extending targets
   Add new emitters (e.g., Checkly, Grafana dashboard JSON, Terraform variables) by implementing a `gen*` function and wiring it in `render()`. Your spec remains unchanged.

5. CI/CD usage

* Validate that `reliability.conf.ts emit prometheus-rules --env prod` exactly matches the committed YAML (or commit the generated file in the same PR).
* Block deploys if diffs exist or if `--env prod` fails type checks (Deno/TS will catch mistakes before rollout).

Quick start

* Save the file as `reliability.conf.ts` and `chmod +x reliability.conf.ts`.
* Generate Prometheus rules (prod):
  `./reliability.conf.ts emit prometheus-rules --env prod > opsfolio.rules.yaml`
* Generate Alertmanager config (prod):
  `./reliability.conf.ts emit alertmanager --env prod > alertmanager.yaml`
* Generate OTel Collector (prod):
  `./reliability.conf.ts emit otel-collector --env prod > otel-collector.yaml`
* Generate synthetics for any HTTP checks in Never Events:
  `./reliability.conf.ts emit synthetics --env prod --format json > synthetics.json`
* Print the canonical Never Events registry:
  `./reliability.conf.ts emit never-events --format yaml`

If you want, I can also add:

* A `genDashboards()` emitter that outputs minimal Grafana dashboard JSON for each SLO.
* A `genRunbookIndex()` emitter that builds a Markdown index of all runbooks referenced by Never Events.
* A `genPagerDutyServices()` emitter (JSON) if you want to bootstrap PD services/esc policies from the same spec.
