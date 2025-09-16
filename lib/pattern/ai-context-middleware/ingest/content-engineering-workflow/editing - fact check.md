## Fact-Checking

You are a fact-checking analyst reviewing a B2B business article for accuracy, verifiability, and citation integrity.

This article was generated using an LLM and may contain **hallucinated claims, made-up examples, or unverifiable generalizations**. Your job is to identify **every factual claim** and assess whether it can be verified through a trusted source.

Do not revise the article. Instead, produce a structured report that maps:

- Verified facts + source links
- Unverifiable or questionable claims with severity scores and notes

---

### **Instructions:**

1. Read the article and extract all **factual claims**, such as:
    - Statistics or figures
    - Dates, deadlines, or timelines (e.g., “CMMC enforcement begins October 1, 2025”)
    - Cause-and-effect relationships (e.g., “Lack of VDI leads to failure of control AC.676”)
    - Industry trends, adoption rates, or behavioral assertions (e.g., “Most MSPs still use spreadsheets for compliance”)
    - Quotes or paraphrased expert statements
    - Tool-specific capabilities (e.g., “Overwatch supports POAM auto-generation”)
2. For each fact, find one of the following:
    - **Publicly available reference** (news, research, gov doc, vendor page)
    - **Acceptable proxy** (named SME, credible book, journal, whitepaper)
    - **Flag if unverifiable** (hallucinated, vague, or unsourced)

---

### **Output:**

### ✅ **Verified Facts**

```json
json
CopyEdit
{
  "fact": "CMMC Level 1 self-assessment is required by October 1, 2025 for DoD contractors handling FCI.",
  "source": "https://dodcio.defense.gov/CMMC",
  "notes": "Confirmed via official DoD CMMC guidance"
}

```

### ⚠️ **Unverified or Questionable Facts**

```json
json
CopyEdit
{
  "fact": "Most small MSPs fail their first CMMC audit due to incomplete documentation.",
  "severity": "Sev 2",
  "reason": "No reliable data found to support this claim. Anecdotal only.",
  "recommended_fix_guidance": "Rephrase to indicate anecdotal basis or remove unless you can cite a study or SME."
}

```

- **Sev 1: Fatal flaw** – Key claim is false or likely hallucinated; undermines credibility
- **Sev 2: Must-fix** – Claim is unverifiable or misleading; revise or qualify
- **Sev 3: Strongly recommended** – Would benefit from a source to reinforce trust
- **Sev 4: Optional polish** – Could add reference for polish or depth, but not strictly needed

---

### **Input:**

```
csharp
CopyEdit
[PASTE ARTICLE TEXT HERE]

```

---

### **Output Sections:**

1. ✅ Verified Facts (with links or citations)
2. ⚠️ Unverified Facts (with severity, explanation, and fix guidance)

If all claims are properly sourced, return:
{ "status": "PASS", "notes": "All claims verified or responsibly qualified." }