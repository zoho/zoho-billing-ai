---
name: sales-performance-analysis
description: >
  Analyse sales performance by comparing two equal-length date windows — this
  month day 1 to today, vs the same day range in the prior month (e.g., May 1–19
  vs April 1–19). Pulls Zoho Billing invoice details, credit notes, sales by item,
  and sales by plan. Surfaces revenue trends, top-performing items/plans, credit-note
  pressure, and MoM delta. Use when the user asks about sales performance, revenue
  breakdown, invoice trends, best-selling plans or items, or credit note analysis.
---

# Sales Performance Analysis

Produces a **same-period MoM sales comparison** across four data streams: gross
invoicing, credit notes, sales by item, and sales by plan. Both windows span the
same number of days so the comparison is like-for-like.

---

## Step 0 — Setup

**Org ID**: Retrieve via `list_organizations` if not already known. Ask if multiple
orgs exist — never guess.

**Date windows** — compute as follows, then confirm with the user before proceeding:

```
today         = current date
cm_start      = first day of the current calendar month
cm_end        = today

lm_start      = first day of the prior calendar month
lm_end        = prior month's day number matching today's day
              → if today is May 19, lm_end = April 19
              → if today is May 31 but April has only 30 days, lm_end = April 30

period_label_cm = "<Month> 1–<today_day>" (e.g. "May 1–19")
period_label_lm = "<Prior Month> 1–<today_day>" (e.g. "April 1–19")
```

State the windows in one line and offer to use custom dates:
> "Comparing **May 1–19** vs **April 1–19**. Want to use different dates instead?"

If the user provides custom dates, use those for both windows. Ensure both windows
span the same number of days for a fair comparison; warn if they differ.

---

## Step 1 — Fetch all data (8 calls in parallel)

Run all 8 calls in a single turn — they are fully independent.

| # | Tool | Purpose | Key params |
|---|------|---------|------------|
| 1 | `ZohoBilling_get_invoice_details_report` | Invoice detail — current period | `filter_by: InvoiceDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: invoice_date`, `sort_order: D`, `per_page: 100`, `page: 1` |
| 2 | `ZohoBilling_get_invoice_details_report` | Invoice detail — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 3 | `ZohoBilling_get_credit_note_details_report` | Credit notes — current period | `filter_by: CreditNoteDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `per_page: 100`, `page: 1` |
| 4 | `ZohoBilling_get_credit_note_details_report` | Credit notes — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 5 | `ZohoBilling_get_sales_by_item_report` | Sales by item — current period | `filter_by: InvoiceDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100`, `page: 1` |
| 6 | `ZohoBilling_get_sales_by_item_report` | Sales by item — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 7 | `ZohoBilling_get_sales_by_plan_report` | Sales by plan — current period | `filter_by: InvoiceDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100`, `page: 1` |
| 8 | `ZohoBilling_get_sales_by_plan_report` | Sales by plan — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |

Paginate while `has_more_page: true`. Cap invoice details at 5 pages (500 invoices)
per period; note if cap is hit. Use API-level `total` fields for period sums — do not
sum rows (undercounts when pagination truncates).

---

## Step 2 — Compute revenue metrics

### 2a. Gross invoicing & credit notes

| Metric | Formula |
|---|---|
| Gross invoiced (CP) | API total from call #1 |
| Gross invoiced (PP) | API total from call #2 |
| MoM gross Δ | CP − PP (absolute) |
| MoM gross % | (CP − PP) / PP × 100 |
| Total credit notes (CP) | API total from call #3 |
| Total credit notes (PP) | API total from call #4 |
| Credit note ratio (CP) | credit_notes_CP / gross_CP × 100 |
| Credit note ratio (PP) | credit_notes_PP / gross_PP × 100 |
| Net revenue (CP) | gross_CP − credit_notes_CP |
| Net revenue (PP) | gross_PP − credit_notes_PP |
| MoM net revenue % | (net_CP − net_PP) / net_PP × 100 |

_CP = current period, PP = prior period_

### 2b. Invoice count and average deal size

- Invoice count CP and PP
- Average invoice value CP = gross_CP / invoice_count_CP
- Average invoice value PP = gross_PP / invoice_count_PP
- MoM average deal size Δ (absolute and %)

### 2c. Top items

From calls #5 and #6, rank items by `total` descending. Take **top 10 by CP revenue**.

For each item: item name, quantity sold, total revenue, % of CP gross invoiced.

Build a side-by-side comparison: for each top-10 CP item, look it up in PP data.
Call out items that:
- Are new in CP (no PP revenue) — emerging products
- Dropped out of top 10 from PP — declining products
- Had the biggest absolute revenue swing (up or down)

Also compute: top-item concentration = (item_1_total / gross_CP) × 100.
A single item driving > 60% of revenue is a diversification risk worth naming.

### 2d. Top plans

Same analysis as 2c but using calls #7/#8. Top 10 plans by CP revenue.
For each plan: plan name, total revenue CP and PP, MoM delta.

---

## Step 3 — Credit note breakdown

From calls #3/#4:
- Total credit note count CP vs. PP
- Average credit note value
- If reason/description is available → top 3 reasons by count
- Any single customer accounting for > 20% of CP credit notes (concentration risk)

---

## Step 4 — Invoice health (current period only)

From call #1, flag if present:
- **Overdue invoices**: `status: overdue` — count and total value
- **Draft invoices**: not yet sent — count
- Flag if overdue value > 10% of gross_CP (worth surfacing, not a failure)

---

## Step 5 — Produce the analysis output

Write a clean Markdown section (no green/amber/red scoring — let the numbers speak):

```markdown
## Sales Performance — <period_label_cm> vs <period_label_lm>

### Revenue Summary
| Metric | <period_label_lm> | <period_label_cm> | Δ |
|---|---|---|---|
| Gross invoiced | $X | $Y | +$Z (+N%) |
| Credit notes | $X | $Y | +$Z |
| Net revenue | $X | $Y | +$Z (+N%) |
| Invoice count | N | N | +N |
| Avg deal size | $X | $Y | +$Z |
| Credit note ratio | N% | N% | +Npp |

**Net revenue: <direction and magnitude in plain English>**

### Top 10 Items
| Rank | Item | PP Revenue | CP Revenue | Δ | Δ% |
|---|---|---|---|---|---|
...
_Top-item concentration: N% of gross from "<item name>"_

### Top 10 Plans
| Rank | Plan | PP Revenue | CP Revenue | Δ | Δ% |
|---|---|---|---|---|---|
...

### Credit Notes
- CP: $X across N notes (N% of gross)
- PP: $Y across M notes (N% of gross)
<top reason or concentration note if data available>

### Invoice Health (Current Period)
- Overdue: N invoices · $X outstanding
- Draft: N invoices pending
```

---

## Output contract (for orchestrator)

Pass this JSON object back alongside the Markdown section:

```json
{
  "pillar": "revenue",
  "period_label_cm": "May 1–19",
  "period_label_lm": "April 1–19",
  "metrics": {
    "gross_invoiced_cp": <number>,
    "gross_invoiced_pp": <number>,
    "mom_gross_pct": <number>,
    "credit_notes_cp": <number>,
    "credit_note_ratio_cp_pct": <number>,
    "net_revenue_cp": <number>,
    "net_revenue_pp": <number>,
    "mom_net_revenue_pct": <number>,
    "invoice_count_cp": <number>,
    "avg_deal_size_cp": <number>,
    "top_item_concentration_pct": <number>
  },
  "top_items": [{"name": "...", "revenue_cp": ..., "revenue_pp": ..., "delta_pct": ...}],
  "top_plans": [{"name": "...", "revenue_cp": ..., "revenue_pp": ..., "delta_pct": ...}],
  "flags": ["<overdue > 10%>", "<credit note concentration>"]
}
```

---

## Edge cases

- **Day 1 of month**: CP has only today's data. Note "Day 1 — only <date> available."
  Use LM same-day (e.g. April 1 only) — both are single-day windows, still comparable.
- **Zero invoices in either period**: state explicitly; don't infer.
- **Multi-currency org**: use base-currency total field; note mixed-currency if relevant.
- **Pagination cap**: note "invoice totals from API summary field — accurate regardless
  of pagination cap."
- **No credit notes**: skip credit note section; set ratio = 0.
- **Prior month shorter than current** (e.g. Feb when today is March 29):
  lm_end = Feb 28/29. Note the truncation once.
