# FHIR R4 Questionnaires and LHC Form Data Collection Exercises `lforms` Pattern 

This SQL code is an early prototype for a `surveilr` pattern we want to grow in the `lforms` directory, focused on handling **FHIR R4 Questionnaires** and **LHC Form definitions**. It introduces two views: one (`uniform_resource_lform_item`) that recursively flattens nested form items from JSON into SQL rows, and another (`uniform_resource_lform_item_grouped`) that consolidates duplicates and surfaces a cleaner item-level summary. The starting point is solid—it allows both ecosystems’ item structures to be queried side by side—but it’s still incomplete. Key next steps include adding hierarchy tracking (parent/child, depth, order), supporting more FHIR/LHC fields (types, required/repeats, answer options, enableWhen logic), and splitting choices, codes, and extensions into normalized views. The long-term goal is to evolve this into a full-fledged `lforms` pattern that aligns with surveilr’s evidence-centric architecture, making questionnaires and forms queryable, auditable, and usable as structured evidence within the broader data middleware platform.

- [ ] TODO: turn this into a standard surveilr pattern with `package.sql.ts`.
  
What it is
- Two SQLite views that flatten form definitions (FHIR R4 Questionnaire and LHC-Forms/LHC-FormDef) from your uniform\_resource tables.
- uniform\_resource\_lform\_item: a recursive JSON walker that pulls every item (question/section) at any depth from either item (FHIR) or items (LHC), surfacing common fields into columns.
- uniform\_resource\_lform\_item\_grouped: a “dedup-ish” rollup keyed by item\_id that tries to pick a preferred row (using window rank) and then collapses the rest with aggregates.

What it does well
- Handles both ecosystems by supporting both item and items at every nesting level.
- Preserves provenance basics (uniform\_resource\_id, file\_path\_rel).
- Extracts multiple human-readable fields (text, label, question) plus identifiers (linkId / questionCode).
- Leaves room for response/AEI metadata hookup.

What’s incomplete or risky
- Ambiguous grouping: GROUP BY item\_id alone will collide across different forms; linkId is form-scoped in FHIR.
- “First non-null” via MAX isn’t deterministic for text; MAX returns lexicographically greatest, not first non-null.
- No hierarchy columns (level, parent, path, ordinal). You’ll need these for reconstruction, branching logic, and UX.
- Missing many high-value FHIR/LHC attributes (type, required, repeats, enableWhen, answerOption, answerValueSet, initial, constraints, extensions, codes, units).
- Unclear identity strategy for LHC vs FHIR items when both exist (questionCode vs linkId).
- No normalization for choices, codings, constraints, or extensions—everything is trapped in JSON.
- Performance: json\_each recursion over full documents without filters may be slow for large banks; no materialization strategy.
- Content source filtering: you’re not limiting to questionnaire-like natures; could parse non-forms accidentally.
- Casting ur.content to TEXT assumes valid JSON1 input but doesn’t guard non-JSON payloads.

## High-impact improvements

Data model and identity
- Keying: use a composite key (form\_identity, item\_id). Derive form\_identity as COALESCE(Questionnaire.url, Questionnaire.id, file\_path\_rel, uniform\_resource\_id).
- Add stable synthetic keys: item\_uid = hash(form\_identity || path || item\_id).
- Distinguish ecosystems: add columns ecosystem (‘FHIR’|‘LHC’) and schema\_version.

Traversal and hierarchy
- Switch to json\_tree for a single, cleaner recursive pass. It gives parent, path, and key/index.
- Add columns: depth, parent\_item\_id, json\_path, array\_index, is\_group (section/display).
- Extract ordinal with json\_each.key (array index) to preserve display order.

Richer column extraction (FHIR R4 Questionnaire)
- item.type, required, repeats, readOnly, maxLength.
- enableBehavior, enableWhen (operator, question, answer\[x])—flatten into a separate enable\_when view.
- answerOption\[].value\[x], answerValueSet (resolve later)—normalize to an item\_choice view.
- initial\[x], initialSelected.
- code\[] (Coding), subjectType, extension\[].url/value\[x], itemControl and other common extensions (e.g., itemControl from SDC).
- valueSet bindings (if present in contained or by canonical).

LHC-Forms specifics
- Map dataType to FHIR item.type where possible (string, integer, date, coding).
- Extract questionCodeSystem, codeSystem, units, answer lists, skip logic equivalents.
- Normalize LHC lists/options into the same item\_choice view for cross-ecosystem querying.

Normalization layer (additional views/tables)
- uniform\_resource\_lform: one row per form with identity, title, url, version, date, publisher, jurisdiction, language.
- …\_item: one row per item (your current core, enhanced with hierarchy).
- …\_item\_choice: one row per answer option (value\[x], display, system, code).
- …\_item\_enable\_when: one row per enableWhen condition.
- …\_item\_extension: URL, value\[x] flattened.
- …\_item\_code: codeable concepts (system, code, display).
- …\_qa: diagnostics flags (duplicate linkIds, missing required fields, mixed types, invalid regex, etc.).

Deterministic grouping and selection
- Replace MAX() “first non-null” heuristics. Options:
– Join ranked to itself on rn=1 to select the single preferred row and project its columns.
– Or use JSON-first selection via COALESCE of ordered json\_group\_array values (less clean).
- Don’t GROUP BY item\_id alone. Use (form\_identity, item\_id).

Performance and materialization
- Provide a materialized table build step (surveilr job) to persist the normalized projections with indexes.
- Indexes on (form\_identity, item\_id), (form\_identity, parent\_item\_id), (ecosystem, depth), and on frequently filtered fields (type, required).
- Consider incremental rebuild keyed by uniform\_resource\_id on ingest.

Provenance and filtering
- Keep source\_path, uri, nature in the final views.
- Filter base to likely forms: WHERE nature IN ('fhir.questionnaire', 'lhc.form', 'questionnaire.json', 'lforms.json') or detect by JSON predicates (has \$.resourceType='Questionnaire' OR has \$.items OR \$.item).
- Validate JSON: add a guard where json\_valid(content\_json)=1.

Internationalization and presentation
- Capture language (root and per-item if available).
- Prefer item.text over label/question per ecosystem rules; keep all and add a preferred\_text column with deterministic selection order.

Constraints and scoring
- Extract constraints: regex, minLength/maxLength, minValue/maxValue, maxDecimalPlaces, unit constraints.
- If using SDC scoring, add a scoring view mapping expressions or extensions for computed scores.

AnswerValueSet resolution
- Add a late-binding mechanism: if answerValueSet references a contained ValueSet, expand choices into item\_choice. If canonical, store the canonical URL and provide a capturable executable to resolve/expand offline.

Quality checks and utilities
- QA views:
– duplicate\_linkids(form\_identity, item\_id count >1)
– missing\_required\_text(item.required=1 AND COALESCE(text,label,question) IS NULL)
– inconsistent\_types(form\_identity, item\_id has >1 distinct type)
- Add a “dry-run validator” view that flags non-conformant forms before publishing to downstream UX.

Joinability to responses
- Define a stable join contract to responses: responses\_item.linkId ↔ items.item\_id scoped by form\_identity, plus path when repeats=true.

Safer COALESCEs for form name
- For FHIR: prefer \$.title, then \$.name, then \$.id, then \$.code\[0].text, then \$.code\[0].code.
- For LHC: prefer \$.name, then \$.title, then \$.code. Keep ecosystems separate to avoid odd fallbacks.

Implementation nits in your current SQL
- Use additional selected columns from base in the final SELECT (you dropped source\_path, uri, nature in the last projection). Keep them.
- Add depth, path, index now—it will save many headaches later.
- Prefer a single recursion that COALESCEs item arrays: in JSON, you can do a CASE that chooses \$.item when object has item, else \$.items. json\_tree makes this trivial.

