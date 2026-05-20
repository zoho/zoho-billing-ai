---
name: business-health-orchestrator
description: >
  Run the full analyst pipeline end-to-end — sales performance, collection
  performance, and subscription growth — then synthesise all three into a
  single business-health report with an executive narrative and a rich visual
  dashboard. Use for any request to analyse "overall business health",
  "monthly business review", "how is the business doing", "full analysis",
  or any request that spans more than one of the three pillars. Propose-only;
  writes a Markdown report and renders a live dashboard; never calls mutating
  endpoints.
---

# Business Health Orchestrator

Runs the full three-pillar analysis and delivers two outputs:
1. A **Markdown report file** for archiving and sharing
2. A **visual dashboard** rendered inline via `mcp__visualize__show_widget`

**Propose-only**: no write, update, or delete API calls. Ever.

---

## Pipeline overview

```
Step 1  Pre-flight  (org ID, date windows, output path check)
Step 2  Run three pillars in parallel
          ├── sales-performance-analysis
          ├── collection-performance-analysis
          └── subscription-growth-analysis
Step 3  Synthesise cross-pillar insights
Step 4  Write Markdown report file
Step 5  Render visual dashboard  ← show_widget
Step 6  Post one-paragraph chat summary
```

---

## Step 1 — Pre-flight

**Org ID**: Call `list_organizations`. If multiple exist, ask which one.

**Date windows** — compute and confirm with the user in one message before
any tool calls:

```
today         = current date
cm_start      = first day of current calendar month
cm_end        = today
lm_start      = first day of prior calendar month
lm_end        = same day number as today in prior month
              (cap at last day of prior month if today > prior month length)

period_label_cm = e.g. "May 1–19"
period_label_lm = e.g. "April 1–19"
```

Say in chat:
> "I'll compare **May 1–19** vs **April 1–19** (same-period MoM).
> Want to use different dates, or shall I proceed?"

If the user provides custom dates, validate that both windows span the same
number of days. Warn if they differ — the comparison will still run, but the
asymmetry should be noted in the report.

**Output path**: Check `analysis-runs/<YYYY-MM-DD>/business-health-report.md`.
If it exists, ask: "A report already exists for today — overwrite, or save
as `-v2`?" Never overwrite silently.

---

## Step 2 — Run three pillars in parallel

Issue all three skill instructions in a **single turn**. Pass to each:
- `org_id`
- `cm_start`, `cm_end`, `lm_start`, `lm_end`, `period_label_cm`, `period_label_lm`
- Instruction: "Don't re-prompt for dates — use the values passed here"

For collection-performance-analysis: also pass `gross_invoiced_cp` and
`gross_invoiced_pp` from sales-performance-analysis so it doesn't re-fetch
invoice summaries. If running truly in parallel (first turn), collection
efficiency will be computed in a second pass once sales data is available.

Collect from each pillar:
- `metrics` object
- `flags` array
- Markdown section text
- `top_items`, `top_plans`, `top_products`, `top_countries` arrays

---

## Step 3 — Synthesise cross-pillar insights

Look for patterns that only emerge when all three data streams are compared.
Surface at most **3 genuine cross-pillar patterns** — fabricating is worse than
finding none. Describe each with the specific numbers involved.

Look for these (only flag what's actually present in the data):

| Pattern | Signal sources | What to look for |
|---|---|---|
| Revenue-Collections gap | Revenue + Collections | Gross invoiced grew but collection efficiency fell → billing outpaced cash recovery |
| MRR-Revenue mismatch | Revenue + Subscriptions | Net revenue down despite MRR up → credit note spike or plan downgrades |
| Activation-Cash lag | Subscriptions + Collections | Activation surge but no matching collections increase → new subs on trial/free |
| Churn-Refund correlation | Subscriptions + Collections | Both churn and refunds up → possible product/onboarding signal |
| Concentration double-risk | Revenue + Subscriptions | Top-item AND top-country concentration both high simultaneously |
| Renewal-failure leading indicator | Collections + Subscriptions | High renewal failure MRR at risk → next month's involuntary churn forecast |
| ARPU-Net Revenue alignment | Subscriptions + Revenue | ARPU up but net revenue flat → fewer customers paying more; growth is fragile |

For each pattern found, write 2–3 sentences naming the specific numbers and
what action they suggest (propose-only — not an automated action).

---

## Step 4 — Write the Markdown report

File: `analysis-runs/<YYYY-MM-DD>/business-health-report.md`

Structure:

```markdown
# Business Health Report — <YYYY-MM-DD>
_<period_label_cm> vs <period_label_lm> (same-period MoM)_
_Organisation: <org_name>_

---

## Executive Summary

_3–5 sentences. Lead with the most important number (usually MRR or net revenue
delta). Call out the single most important positive and the single most important
concern. End with one actionable recommendation. Write for a VP reading on mobile —
every sentence must contain a number or a direction._

---

## Cross-Pillar Insights

_(1–3 insights, or omit section if none found.)_

**<Pattern name>** — <2–3 sentences with specific numbers>

---

<!-- Pillar sections pasted here from each skill's Markdown output -->

<SALES_PERFORMANCE_SECTION>

---

<COLLECTION_PERFORMANCE_SECTION>

---

<SUBSCRIPTION_GROWTH_SECTION>

---

## Flags & Watch Items

_(Consolidated from all three pillars — red flags first, then amber.)_

- ⚠️ <flag with specific number>

---

## Recommended Actions

_(Propose-only. Max 5. Specific, measurable, assigned to a function.)_

1. **<Action>** — <who does what, by when, expected outcome>

---

_Generated: <timestamp> · Org: <org_name>_
_Same-period comparison: <cm_window> vs <lm_window>_
```

### Report writing rules
- Every number gets commas ≥ 1,000. Percentages to one decimal.
- No green/amber/red signal labels — the numbers are the signal.
- Executive Summary: no bullet points. Prose only. Max 5 sentences.
- If a pillar had no data → write "Insufficient data for <period>" in that section.
- Recommended actions: must be executable today. "Review the 7 customers with
  repeated payment failures and trigger a card-update email" is an action.
  "Monitor churn" is not.

---

## Step 5 — Render the visual dashboard

After writing the report file, call `mcp__visualize__read_me` (modules:
`["data_viz", "chart", "diagram"]`) to get rendering context, then call
`mcp__visualize__show_widget` with a rich self-contained HTML dashboard.

### Dashboard layout

The dashboard is a **single HTML page** with no external data fetches. All
data is embedded as inline JSON constants from the pillar output objects.

#### Header strip

```
Business Health — <period_label_cm> vs <period_label_lm>  |  Org: <org_name>  |  Run: <timestamp>
```

Three KPI cards in a row:
```
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  Net Revenue        │  │  MRR                │  │  Net Subs Growth    │
│  $X  ▲/▼ N%        │  │  $X  ▲/▼ N%        │  │  +N  ▲/▼ N         │
│  vs <PP label>      │  │  vs <PP label>      │  │  vs <PP label>      │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

Use colour: green for positive delta, red for negative, neutral grey for flat.
Avoid purple gradients — use a clean blue/teal + slate palette.

#### Section 1 — Revenue (bar charts)

Two side-by-side bar charts using Chart.js:
1. **Revenue bars**: grouped bars — Gross Invoiced vs Net Revenue for CP and PP.
   X-axis: periods. Y-axis: dollar amount. Hover tooltip shows both values.
2. **Top 10 Items**: horizontal bar chart — CP revenue per item, sorted
   descending. Each bar shows a small PP marker (dot or line) so the viewer
   can see MoM movement at a glance.

Below the charts: a compact table showing Top 10 Plans with CP revenue, PP revenue,
and Δ column. Positive deltas in green, negative in red.

#### Section 2 — Collections (metrics + chart)

A row of four metric tiles:
```
Total Collected   Collection Efficiency   Refund Rate   Failure Rate
$X  (▲/▼ N%)     N%  (▲/▼ Npp)          N%  (▲/▼ Npp)  N%  (▲/▼ Npp)
```

One horizontal grouped bar chart — Payments Received vs Refunds for CP and PP.

Below: a small table of renewal failures (top 5 by MRR at risk) if any exist.
Format: customer name | MRR at risk | renewal failure date.

#### Section 3 — Subscription Growth (line + donut charts)

Left: **MRR movement** — a waterfall-style chart (if decomposition data
exists) or a simple bar showing MRR_PP → MRR_CP with the delta labelled.
If MRR decomposition is available, use a stacked bar: New / Expansion /
Contraction / Churned / Net.

Right: two small donut charts side by side:
- **Activations by product** — top 5 products + "Others" slice
- **Activations by country** — top 5 countries + "Others" slice

Below the charts: two compact tables side by side — Product Performance and
Country Performance (top 10 each), showing Act CP, Can CP, Net CP, MoM Δ.
Net negative rows get a subtle red background.

#### Section 4 — Cross-Pillar Insights (callout cards)

For each cross-pillar insight found in Step 3, render a callout card:
```
┌──────────────────────────────────────────────────────────┐
│  ⚡  Revenue-Collections Gap                              │
│  Gross invoiced grew 8% but collection efficiency fell   │
│  from 91% to 84% — $32k of new invoicing is outstanding. │
│  Pillars: Revenue × Collections                          │
└──────────────────────────────────────────────────────────┘
```

If no cross-pillar insights were found, omit this section.

#### Section 5 — Flags & Recommended Actions

Two-column layout:
- Left: flags list (icons: ⚠️ for watch items, 🚨 for serious flags)
- Right: recommended actions list (numbered, compact)

#### Dashboard styling rules

- Font: system-ui or IBM Plex Sans (load from Google Fonts inline if available,
  fall back to system-ui)
- Monospaced numbers: use `font-variant-numeric: tabular-nums` so columns align
- Background: white or very light grey (#F8F9FA)
- Card borders: 1px #E2E8F0, border-radius 8px, subtle box-shadow
- Positive delta: #16A34A (green-700)
- Negative delta: #DC2626 (red-600)
- Neutral: #64748B (slate-500)
- Primary accent: #0EA5E9 (sky-500) — for chart bars, headings
- Charts: Chart.js from cdnjs.cloudflare.com (allowed CDN)
- No localStorage, no external API calls — all data embedded at render time
- Must render correctly at 1280px width and scale down to 900px

#### Loading messages for show_widget

```
["Crunching revenue numbers", "Mapping collections health", "Building subscription charts", "Assembling your dashboard"]
```

---

## Step 6 — Chat hand-off

One message only after the dashboard renders:

1. `computer://` link to the Markdown report file
2. A single paragraph (3–5 sentences) in second person:
   > "Your net revenue grew N% MoM reaching $X, driven by… The MRR picture is…
   > One concern: … The full report and interactive dashboard are above."

Stop. Do not re-explain every metric — they can see the dashboard.

---

## Edge cases

- **A pillar errors out**: complete the other two, mark the failed pillar as
  `⚠️ Error — <message>` in both report and dashboard. Never suppress errors silently.
- **No cross-pillar insights**: omit Section 4 from the dashboard entirely;
  don't invent observations.
- **MRR decomposition unavailable**: omit the waterfall; use a simple MRR
  comparison bar instead.
- **Overwrite conflict**: always ask before overwriting; never silently destroy
  an existing report.
- **Org < 30 days old**: PP data empty. Note it in the report header. Dashboard
  still renders with PP bars at zero.
- **Custom date window mismatch (different day counts)**: note once in the report
  header and in the dashboard subtitle — "⚠️ Unequal windows: CP is N days, PP
  is M days — percentages may not be directly comparable."

---

## What this orchestrator deliberately does NOT do

- Call any create, update, or delete endpoint
- Send Cliq messages or emails automatically
- Generate invoices, apply credits, or issue refunds
- Auto-execute any recommended action
- Re-run silently if a report already exists
- Render a dashboard that fetches live data at view time (all data is embedded)
