# AI Workforce™ Guide for Content Creators



## What is AI Workforce™?

Think of AI Workforce™ as creating a smart library system for all the instructions you give to AI assistants. Instead of typing the same instructions over and over again, you create reusable "prompt modules" that can be mixed and matched to build powerful AI systems for your business.

Just like how you might have templates for emails, contracts, or presentations, AI Workforce™ helps you create templates for AI conversations that are:

- **Consistent** - Everyone gets the same quality of response
- **Reusable** - Write once, use everywhere
- **Trackable** - Know what's working and what isn't
- **Updatable** - Make changes in one place, update everywhere

## Why This Matters for Opsfolio

### Before AI Workforce™

- Each team member writes their own AI prompts
- Inconsistent responses to customers
- No way to track what prompts work best
- Hard to update instructions across all systems
- New team members have to start from scratch

### After AI Workforce™

- Professional, consistent AI responses
- Reusable prompt library saves time
- Track which prompts perform best
- Update once, change everywhere
- New team members get proven prompts instantly

## How It Works: The Simple 5-Step Process

### Step 1: Create the Prompts in  Markdown Files

 Create your AI instructions in regular text files (Markdown format) and save them in the `ai-context-engineering/` folder. Think of it like creating a filing cabinet for your AI instructions.

**The folder structure looks like this:**

```
ai-context-engineering/
├── README.md                  
├── role/                      
│   ├── support-agent.prompt.md
│   └── sales-specialist.prompt.md
├── task/                      
│   ├── ticket-triage.prompt.md
│   └── customer-onboarding.prompt.md
├── regime/                   
│   ├── safety-guidelines.prompt.md
│   └── company-policies.prompt.md
└── .build/                      # Auto-generated exports (don't edit)
    └── anythingllm/            # Ready for AI platform like AnythingLLM to import
```

**File naming follows a specific pattern:**

- `public--cross-tenant--support--role-ctos.prompt.md` (for full prompt modules)
- external--public--cross-tenant--marketing--industry--saas-tech.prompt-snippet.md (for smaller reusable pieces)

### Step 2: Add Information Labels to Each File

At the top of each file, you add a detailed information card that describes exactly how this prompt should be used. Here's what a real Opsfolio prompt file looks like:

```yaml
---
id: opsfolio-<purpose>-<yyyy-mm-dd>
title: "Human-readable title"
summary: "Brief description of what this prompt does"
artifact-nature: prompt-module
function: support                    # support|sales|marketing|success
audience: internal                   # external|internal  
visibility: private                  # public|private
tenancy: cross-tenant               # cross-tenant|tenant-specific
confidentiality: internal          # public|internal|restricted|secret
lifecycle: approved                 # draft|review|approved|deprecated

product:
  name: opsfolio
  version: ">=2.4 <3.0"
  features: ["alerts", "assets"]

channels: ["help-center", "ticketing"]
topics: ["triage", "support-automation"]
tags: ["priority", "classification", "SLA"]
keywords: ["Opsfolio", "support", "ticket"]

# For combining prompts (optional)
merge-group: "support-system"       # Group name for combining
order: 20                          # Order within group

prompt:
  role: "system"                   # system|user|assistant
  intent: "Brief description of prompt purpose"

access-control:
  owner-team: "support"
  allowed-roles: ["support-engineer", "admin"]  
---
```

### Step 3: The System Automatically Organizes Everything

Once you save your files, the surveilr system automatically:

- Ingests the `ai-context-engineering/` folder
- Reads all your information cards
- Creates a searchable database
- Tracks changes and file history
- Keeps everything organized and traceable

*You just run one simple command: `surveilr ingest files` and everything happens automatically!*

### Step 4: Mix and Match Prompts to Create Powerful AI Systems

The system can combine multiple prompt files using "merge groups" to create comprehensive AI assistants. For example:

**Customer Support AI** might combine prompts tagged with:

- `merge-group: "core-system"` - core system prompts
- `merge-group: "support-workflow"` - support workflow procedures
- `merge-group: "opsfolio-features"` - opsfolio features knowledge base

**Sales AI** might combine:

- `merge-group: "core-system"` - Core system prompts
- `merge-group: "sales-process"` - Lead qualification steps
- `merge-group: "objection-handling"` - Common sales objections and responses

The system uses the `order` field in each prompt to determine the sequence of consolidating the prompt, so a support system might be built like:

1. `order: 10` - Company introduction and tone
2. `order: 20` - Support policies and procedures
3. `order: 30` - Specific product troubleshooting steps

### Step 5: Deploy to Your AI Platforms

The final combined prompts get automatically exported to folders like:

- `.build/anythingllm/industry/` - For industry-specific prompts for support chatbots
- `.build/anythingllm/regime/` - For regimes like SOC2, HIPAA, etc.
- `.build/anythingllm/task/` - For prompts for different tasks like author policies, collect evidences etc.

These files can then be imported into AnythingLLM,or any AI system and chatbot can use from there.

## What You Actually Do (The Simple Part)

### Creating a New Prompt File

1. **Create a new text file** in the `ai-context-engineering/` folder using the naming pattern:

   - Example: `internal--cross-tenant--support--handling-refunds.prompt.md`
2. **Add the complete information card** at the top:

   ```yaml
    ---
    id: opsfolio-marketing-value-prop-2025-08-01
    title: "Why Opsfolio for Compliance-Driven Ops"
    summary: "One-pager positioning Opsfolio for regulated industries."
    artifact-nature: case-study
    function: marketing
    audience: external
    visibility: public
    tenancy: cross-tenant
    confidentiality: public
    lifecycle: approved
    product: { name: opsfolio, version: "*" }
    channels: [ website ]
    topics: [ "positioning", "compliance" ]
    tags: [ "marketing", "regulated" ]
    provenance: { source-uri: null, created-by: "user:pm", created-at: "2025-08-01T00:00:00Z" }
    governance: { pii: false, export_ok: true, usage-policy: "may-train-public" }
    access_control: { owner_team: "marketing", allowed-roles: [ "any" ], allowed_tenants: [] }
    rag: { chunking: { strategy: "by_h2", max_tokens: 600 }, canonical: true }
    ---
   ```
3. **Write your AI instructions** below the information card:

   ```markdown
   # Handling Customer Refund Requests

   You are a helpful Opsfolio support representative handling refund requests.

   ## Process Steps

   1. **Acknowledge the request** - Thank the customer for reaching out
   2. **Show empathy** - Acknowledge their concern professionally  
   3. **Gather information** - Request order number, account details, reason for refund
   4. **Check eligibility** - Review against Opsfolio refund policy
   5. **Process or explain** - Either process the refund or clearly explain policy
   6. **Follow up** - Ensure customer satisfaction and offer alternatives if needed

   ## Tone Guidelines
   - Professional and helpful
   - Empathetic to customer concerns
   - Clear about policies and procedures
   - Solution-focused when possible

   ## What NOT to do
   - Never promise refunds outside of policy
   - Don't argue with customers about policy
   - Avoid technical jargon
   - Don't make exceptions without manager approval
   ```
4. **Save the file** with the proper name and extension

### Real Examples from Opsfolio Context

Here are actual examples of how Opsfolio organizes different types of content:

**External Public Marketing Content:**

```
File: external--public--cross-tenant--marketing--value-prop.prompt.md
Purpose: Public-facing content about Opsfolio's value for compliance-driven operations
Audience: Potential customers and website visitors
```

**Internal Sales Playbook:**

```
File: internal--private--cross-tenant--sales--objection-handling.prompt.md
Purpose: Sales team guidance for handling SOC2 budget objections
Audience: Internal sales team only
Confidentiality: Restricted (sales team only)
```

**Customer-Specific Support Runbook:**

```
File: internal--private--tenant-specific--support--acme-alerts.prompt.md
Purpose: Specialized support procedures for ACME Corp's alert system
Audience: Support engineers working with ACME
Confidentiality: Secret (requires special access)
```

### Understanding the Organization System

**Controlled Vocabularies (Use These Exact Terms):**

- **audience:** `external`, `internal`
- **visibility:** `public`, `private`
- **tenancy:** `cross-tenant`, `tenant-specific`
- **function:** `sales`, `marketing`, `support`, `success`, `docs`
- **artifact-nature:** `prompt-module`, `kb-article`, `playbook`, `runbook`, `howto`, `faq`
- **lifecycle:** `draft`, `review`, `approved`, `deprecated`
- **confidentiality:** `public`, `internal`, `restricted`, `secret`

## What Happens Behind the Scenes (Automatic Processing)

### The surveilr system organizes the prompts as follows:

1. **File Discovery** - Finds all `.prompt.md` and `.prompt-snippet.md` files
2. **Content Parsing** - Reads your information cards and prompt content
3. **Database Storage** - Stores everything in organized tables:
   - `uniform_resource` - Your original files and content
   - `ur_ingest_session` - When files were processed
   - `uniform_resource_transform` - Combined/merged prompts
4. **Quality Validation** - Checks that all required fields are present
5. **Search Indexing** - Makes everything searchable by any field

### Smart Combining Process:

When you want to create a comprehensive AI system, the system:

1. Finds all prompts with the same `merge-group` name
2. Sorts them by their `order` number
3. Combines them into one large prompt
4. Stores the result as a new "transform" record
5. Exports the final prompt to the appropriate `.build/` folder

**Example SQL Query (happens automatically):**
The system finds all prompts with `merge-group: "core-system"`, sorts by order, and combines them into one master prompt for your AI assistant.

## Benefits You'll See Right Away

### For Content Creators

- **Template reuse** - Build on existing Opsfolio prompt patterns
- **Smart organization** - Find any prompt by function, audience, or topic
- **Version tracking** - Never lose track of what changed when
- **Easy collaboration** - Share and improve prompts across teams

### For Team Leaders

- **Consistent brand voice** - All AI interactions follow Opsfolio standards
- **Access control** - Restrict sensitive prompts to authorized teams only
- **Performance tracking** - See which prompts work best for different scenarios
- **Easy onboarding** - New staff get proven, tested prompts immediately

### For Opsfolio Business

- **Professional AI interactions** - Consistent, high-quality customer experience
- **Compliance ready** - Track and audit all AI instructions
- **Scalable growth** - Easily add new prompts as business grows
- **Multi-tenant support** - Different instructions for different customer types

## Common Opsfolio Use Cases

### Customer Support Team

**Create prompts for:**

- SLA and service level communications
- Opsfolio feature troubleshooting
- Integration support (webhooks, APIs)
- Compliance and security questions
- Escalation procedures for critical issues

### Sales Team

**Create prompts for:**

- Opsfolio value proposition presentations
- SOC2 and compliance benefit explanations
- Technical objection handling
- Demo customization for different industries
- Pricing and packaging discussions

### Marketing Team

**Create prompts for:**

- Industry-specific positioning (healthcare, finance, etc.)
- Compliance-focused content generation
- Customer success story templates
- Technical blog post outlines
- Social media response templates

### Customer Success Team

**Create prompts for:**

- Onboarding new Opsfolio customers
- Feature adoption guidance
- Renewal conversation starters
- Upselling additional Opsfolio modules
- Health check and optimization recommendations

## Getting Started: Your First Week with Opsfolio Prompts

### Explore Existing Structure

- Review the `ai-context-engineering/` folder structure
- Look at existing prompt examples for your team
- Understand the naming conventions being used

### Create Your First Prompts

- Start with 2-3 prompts you use regularly in your role
- Use the proper Opsfolio information card format
- Choose appropriate `function`, `audience`, and `confidentiality` levels

### Test Integration

- See how your prompts appear in the system
- Try creating a simple `merge-group` with multiple prompts
- Test the export process to see your final AI instructions

## Real Workflow Example: Creating a Support Triage System

Let's walk through creating a complete AI system for triaging Opsfolio support tickets:

### Step 1: Create the Base System Prompt

**File:** `internal--private--cross-tenant--support--base-system.prompt.md`

```yaml
---
id: opsfolio-support-base-2025-08-21
title: "Support System Base Instructions"
merge-group: "support-triage"
order: 10
function: support
audience: internal
visibility: private
---

You are an Opsfolio support AI assistant. Your role is to help customers with professional, accurate, and helpful responses about our compliance and operations platform.

Always maintain a helpful, professional tone and prioritize customer success.
```

### Step 2: Add Triage Logic

**File:** `internal--private--cross-tenant--support--triage-process.prompt.md`

```yaml
---
id: opsfolio-triage-logic-2025-08-21  
title: "Ticket Classification and Prioritization"
merge-group: "support-triage"
order: 20
function: support
audience: internal
visibility: private
---

## Ticket Triage Process

Classify each support ticket by:
1. **Severity**: Critical, High, Medium, Low
2. **Category**: Technical Issue, Billing, Feature Request, Integration Help
3. **Product Area**: Alerts, Assets, Compliance Reports, API
4. **Customer Tier**: Enterprise, Professional, Starter

Critical tickets (system down, security issue) get immediate escalation.
```

### Step 3: Add Opsfolio-Specific Knowledge

**File:** `internal--private--cross-tenant--support--product-knowledge.prompt.md`

```yaml
---
id: opsfolio-product-knowledge-2025-08-21
title: "Opsfolio Product Knowledge Base"  
merge-group: "support-triage"
order: 30
function: support
audience: internal
visibility: private
---

## Opsfolio Key Features

**Alerts System**: Real-time monitoring and notification system
**Assets Management**: IT asset tracking and compliance
**Compliance Reports**: Automated SOC2, HIPAA, and other compliance reporting
**Integrations**: API connections to popular business tools

Common issues and their solutions...
```

### Step 4: System Combines Everything Automatically

The system finds all prompts with `merge-group: "support-triage"`, combines them in order (10, 20, 30), and creates one comprehensive support AI system ready for deployment.

## Best Practices for Opsfolio Success

### Writing Great Opsfolio Prompts

1. **Be specific about Opsfolio features** - Reference actual product capabilities
2. **Include compliance context** - Most customers care about SOC2, HIPAA, etc.
3. **Set professional tone** - Match Opsfolio's enterprise brand voice
4. **Define clear boundaries** - What should AI not promise or guarantee?
5. **Test with real scenarios** - Use actual customer questions and situations

### Organizing for Multiple Audiences

1. **Use audience tags properly** - `external` for customers, `internal` for team
2. **Respect confidentiality levels** - Mark sensitive content appropriately
3. **Consider tenant needs** - Some customers need specialized instructions
4. **Plan for growth** - Structure folders to scale with new products/features
5. **Document your decisions** - Use clear, descriptive file names and summaries

### Team Collaboration at Opsfolio

1. **Establish ownership** - Who maintains support vs. sales vs. marketing prompts?
2. **Review process** - How do prompt changes get approved before going live?
3. **Sharing guidelines** - When can prompts be reused across different functions?
4. **Access control** - Who can see restricted or customer-specific prompts?
5. **Regular maintenance** - Schedule reviews to keep prompts current with product updates

## Troubleshooting Common Issues

### "My prompt isn't being included in the merge"

- Check that the `merge-group` name matches exactly
- Verify the `order` number is unique within the group
- Ensure the file follows the naming convention with `.prompt.md`

### "I can't find my prompt in the system"

- Confirm the information card has all required fields
- Check that `surveilr ingest files` has been run recently
- Verify the file is saved in the `ai-context-engineering/` folder

### "The combined prompt doesn't make sense"

- Review the `order` sequence - prompts combine in numerical order
- Check that each individual prompt makes sense on its own
- Ensure consistent tone and style across all prompts in the group

### "My changes aren't showing up in the AI system"

- Run `surveilr ingest files` to pick up new changes
- Check that the export process has run to update `.build/` files
- Verify you're looking at the right environment (development vs. production)

## Advanced Features: Growing Your Opsfolio AI Library

### Month 1: Foundation

- Create core prompts for your primary Opsfolio use cases
- Establish team processes for prompt creation and approval
- Set up proper access controls for different content types

### Month 2-3: Specialization

- Add industry-specific prompts (healthcare, finance, manufacturing)
- Create customer tier-specific instructions (Enterprise vs. Professional)
- Build comprehensive merge groups for complex workflows

### Month 4+: Optimization

- Analyze which prompts perform best with real customers
- A/B test different approaches for common scenarios
- Scale successful patterns to new product areas and customer segments

### Multi-Tenant Considerations

As Opsfolio serves different types of customers, you can create:

- **Cross-tenant prompts** - Work for all Opsfolio customers
- **Tenant-specific prompts** - Customized for particular clients or industries
- **Tiered prompts** - Different experiences for different service levels

---

## Summary

AI Workforce™ transforms how Opsfolio teams create and manage AI instructions. Instead of scattered, inconsistent prompts, you get a professional library of reusable, trackable, and improvable AI components that reflect Opsfolio's enterprise-grade standards.

The system handles all the technical complexity of organizing, combining, and deploying your prompts while you focus on creating great content that helps Opsfolio customers succeed with their compliance and operations challenges.

Start with your most common customer interactions, use the proven Opsfolio templates and naming conventions, and watch as your AI systems become more powerful and reliable with each prompt you add to the library.
