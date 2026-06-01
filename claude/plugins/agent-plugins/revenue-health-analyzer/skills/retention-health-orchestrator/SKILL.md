---
name: retention-health-orchestrator
description: >
  Run the full Revenue Health Analyzer pipeline end-to-end — NRR
  calculation, cohort retention heatmap, revenue waterfall, and
  renewal-exposure scoring — then synthesise all four into a single
  Red / Yellow / Green retention call with a propose-only short-list
  of at-risk renewals. Use for any request to run a "retention health
  check", "revenue retention review", "monthly retention read", "is
  our revenue staying with us", "are recent cohorts retaining like
  older ones", or any prompt that spans more than one of the four
  diagnostics. Propose-only; writes a Markdown report and renders a
  live dashboard; never calls mutating endpoints.
---

# Retention Health Orchestrator

Runs the four diagnostic skills in parallel and produces two outputs:
1. A **Markdown report file** for archiving and sharing
2. A **visual dashboard** rendered inline via `mcp__visualize__show_widget`

**Propose-only**: no write, update, or delete API calls. Ever.

---

## Pipeline overview

```
Step 1  Pre-flight  (org ID, window, output path, load config)
Step 2  Run four diagnostics in parallel
          ├── nrr-calculator
          ├── cohort-retention-analyzer
          ├── revenue-waterfall-builder
          └── renewal-exposure-tracker
Step 3  Synthesise the R / Y / G retention call
Step 4  Write Markdown report file
Step 5  Render visual dashboard  ← show_widget
Step 6  Post one-paragraph chat summary
```

---

## Step 1 — Pre-flight

**Org ID**: Call `list_organizations`. If multiple exist, ask which one.

**Windows** — compute and confirm with the user in one message before
any tool calls:

```
today        = current date
nrr_window   = trailing 12 months ending last month-end
cohort_window = last 12 acquisition months ending current month
waterfall_window = start of current year → last month-end
renewal_windows  = [30, 60, 90] days forward from today
```

Say in chat:

> "I'll run a retention health check for the trailing 12 months,
> with cohorts since <month>, waterfall YTD, and renewal exposure
> for the next 30/60/90 days. Use different windows?"

If the user provides a custom anchor (e.g. "for FY24"), shift all four
windows consistently around that anchor.

**Output path**: Check
`retention-runs/<YYYY-MM-DD>/revenue-health-report.md`. If it exists,
ask before overwriting; offer `-v2`. Never overwrite silently.

**Config**: Load `config/retention-bands.yaml` once. Pass the relevant
sections to each downstream skill so thresholds are consistent.

---

## Step 2 — Run four diagnostics in parallel

Issue all four skill instructions in a **single turn**. Pass to each:
- `org_id`
- The window relevant to that skill
- Instruction: "Don't re-prompt for inputs — use the values passed here"
- The relevant slice of `config/retention-bands.yaml`

Collect from each:
- The structured object documented in its SKILL.md
- The Markdown section text

If any diagnostic errors, continue the other three and mark the failed
section as `⚠️ Error — <message>` in the report. Never suppress.

---

## Step 3 — Synthesise the R / Y / G retention call

Apply the `health_call` rules from `config/retention-bands.yaml`
top-to-bottom; first match wins. Inputs:

```
nrr_band         from nrr-calculator
weak_cohorts     count from cohort-retention-analyzer.weak_cohorts
exposure_30d_pct from renewal-exposure-tracker.exposure_30d_pct_of_current_mrr
```

The catch-all rule guarantees every run gets a call.

In addition, surface **cross-signal observations** — patterns visible
only when the four streams are combined. Surface at most 3; fabricating
is worse than finding none.

| Pattern | Signal sources | What to look for |
|---|---|---|
| Waterfall-NRR mismatch | Waterfall + NRR | NRR ≥ 110% but expansion is a single-customer concentration → fragile |
| Cohort drag preceding NRR slip | Cohorts + NRR | NRR healthy but newest cohorts retain below peer median → forward drag |
| Renewal cliff on a leaking book | Renewal + NRR | NRR < 100% AND > 25% of MRR up for renewal in 30d → escalate |
| Expansion masking churn | Waterfall + NRR | Expansion >> churn but logo retention falling → losing accounts, expanding survivors |
| Cohort weakness explains contraction | Cohorts + Waterfall | A specific weak cohort accounts for the majority of contraction MRR |

---

## Step 4 — Write the Markdown report

File: `retention-runs/<YYYY-MM-DD>/revenue-health-report.md`

Structure:

```markdown
# Revenue Health Report — <YYYY-MM-DD>
_NRR window: <nrr_window> · Cohorts: <cohort_window> · Waterfall: <waterfall_window>_
_Organisation: <org_name>_

---

## Retention Call: <RED | YELLOW | GREEN>

_<one-sentence rationale from the matched health_call rule>_

**Headline numbers**
- NRR: <pct>% (band: <band>)
- Weak cohorts: <count>
- 30-day renewal exposure: $<m> (<pct>% of current MRR)
- Waterfall: $<start> → $<end> (<±n>%)

---

## Cross-Signal Observations

_(1–3 observations, or omit section if none found.)_

**<Pattern name>** — <2–3 sentences with specific numbers>

---

<NRR_SECTION>

---

<COHORTS_SECTION>

---

<WATERFALL_SECTION>

---

<RENEWAL_EXPOSURE_SECTION>

---

## At-Risk Renewals — Propose-Only Shortlist

_(From renewal-exposure-tracker. For human review. No outreach has been sent.)_

| Customer | MRR | Renews in | Trigger | Why |
|---|---|---|---|---|
| <name> | $<m> | <n>d | <trigger> | <rationale> |

---

_Generated: <timestamp> · Org: <org_name>_
_Propose-only. No subscription changes were written back to Zoho Billing._
```

### Report writing rules
- Every number gets commas ≥ 1,000. Percentages to one decimal.
- The retention call is one of RED, YELLOW, GREEN — no other labels.
- Executive summary at the top is plain English; the headline numbers
  block is a compact bullet list.
- Cross-signal observations: prose only, no bullets inside the section.
- If a diagnostic had no data → write "Insufficient data for <window>"
  in that section.
- Renewals shortlist is a Markdown table, max `shortlist_size` rows.

---

## Step 5 — Render the visual dashboard

After writing the report file, call `mcp__visualize__read_me` with
modules `["data_viz", "chart"]` to get rendering context, then call
`mcp__visualize__show_widget` with a single self-contained HTML page.

### Dashboard layout

#### Header strip

```
Revenue Health — <nrr_window>  |  Org: <org_name>  |  Run: <timestamp>
```

A single large **retention-call badge** (RED / YELLOW / GREEN) with
the rationale on the right.

#### KPI row — four cards

```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  NRR         │ │  Weak cohorts │ │  30d cliff   │ │  YTD net MRR │
│  N% — Band   │ │  K of M       │ │  $X (Y%)     │ │  ▲/▼ N%      │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

Colour for the NRR card from the band: best_in_class green,
healthy neutral, leaking red.

#### Section 1 — Waterfall

A horizontal waterfall chart using Chart.js: starting MRR, +new,
+expansion, −contraction, −churn, ending MRR. Bars labelled with
both $ and % of starting MRR.

Below: a compact 2×2 grid — top expansion customer, top contraction,
top churn, top new — each with customer name and delta MRR.

#### Section 2 — Cohort heatmap

A heatmap grid: rows are cohort acquisition months (newest at top),
columns are months-since-acquisition (m0 leftmost). Cell colour scales
from green (high retention) to red (low). Tag the weakest cohort row
with a callout: "Weakest: <month> — <gap>pp below peer median at m<N>."

#### Section 3 — Renewal cliff

Three vertical bars: 30d, 60d, 90d, each labelled with count of
renewals and total MRR. Stack each bar with the at-risk MRR shaded.

Below: the at-risk renewals table — max 10 rows on the dashboard, with
"… and <k> more in the full report" if truncated.

#### Section 4 — Cross-signal observations

For each pattern from Step 3, render a callout card with the pattern
name, the numbers involved, and which two streams it spans. Omit the
section entirely if no patterns surfaced.

#### Dashboard styling rules
- Font: system-ui
- Monospaced numbers: `font-variant-numeric: tabular-nums`
- Background: white or very light grey (#F8F9FA)
- Card borders: 1px #E2E8F0, border-radius 8px
- Retention-call colours:
  - GREEN: #16A34A
  - YELLOW: #CA8A04
  - RED: #DC2626
- Primary accent: #0EA5E9 (sky-500)
- Charts: Chart.js from cdnjs.cloudflare.com
- No localStorage; all data embedded at render time
- Must render correctly at 1280px and degrade gracefully to 900px

#### Loading messages for show_widget

```
["Crunching NRR numbers", "Mapping cohort retention", "Drawing the revenue waterfall", "Sizing the renewal cliff"]
```

---

## Step 6 — Chat hand-off

One message only after the dashboard renders:

1. `computer://` link to the Markdown report file
2. A single paragraph (3–5 sentences) in second person:
   > "Your retention call is **<COLOUR>** — <one-sentence reason>.
   > NRR is <pct>%, <K> cohort(s) flagged below peer median, and
   > <pct>% of current MRR comes up for renewal in 30 days. The full
   > report and interactive dashboard are above."

Stop. Do not re-explain every metric — the dashboard speaks for itself.

---

## Edge cases

- **A diagnostic errors out**: complete the other three, mark the
  failed section, never silently suppress.
- **No cross-signal observations**: omit the Cross-Signal section
  entirely; don't invent observations.
- **Starting MRR is zero**: NRR card shows "—"; call defaults to the
  catch-all rule.
- **Org younger than 12 months**: use whatever history is available;
  call out the shortened window in the report header.
- **Overwrite conflict**: always ask before overwriting; never
  silently destroy an existing report.
- **Custom anchor (e.g. FY24)**: shift all four windows consistently;
  do not mix calendar and fiscal year framings in one report.

---

## What this orchestrator deliberately does NOT do

- Call any create, update, or delete endpoint
- Send Cliq messages or emails automatically
- Extend, pause, or cancel any subscription
- Apply discounts or issue credit notes
- Auto-execute any recommended action from the at-risk shortlist
- Re-run silently if a report already exists for the day
- Render a dashboard that fetches live data at view time
