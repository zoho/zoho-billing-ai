---
name: collection-performance-analysis
description: >
  Analyse collection performance by comparing two equal-length date windows —
  this month day 1 to today, vs the same day range in the prior month (e.g.,
  May 1–19 vs April 1–19). Pulls Zoho Billing payments received, refund details,
  payment failures, and renewal failures. Surfaces collection efficiency, refund
  pressure, failure rates, and MoM trends. Use when the user asks about cash
  collected, payment trends, refund rates, dunning health, or collections vs.
  invoiced comparison.
---

# Collection Performance Analysis

Produces a **same-period MoM collections comparison** across four data streams:
payments received, refunds issued, payment failures, and renewal failures.
Both windows span the same number of days for a like-for-like comparison.

---

## Step 0 — Setup

**Org ID**: Retrieve via `list_organizations` if not already known. Ask if multiple
orgs exist — never guess.

**Date windows** — use the same logic as sales-performance-analysis (so all pillars
are always comparable). Compute and confirm once:

```
today         = current date
cm_start      = first day of the current calendar month
cm_end        = today
lm_start      = first day of the prior calendar month
lm_end        = prior month's day number matching today's day
              → May 19 run: cm = May 1–19, lm = April 1–19
              → if today is May 31 and prior month has 30 days: lm_end = April 30
```

State the windows and offer custom dates:
> "Comparing **May 1–19** vs **April 1–19**. Want to use different dates instead?"

If called by the orchestrator, accept the windows directly — don't re-prompt.

---

## Step 1 — Fetch all data (6 calls in parallel, then 1 more)

**Parallel batch:**

| # | Tool | Purpose | Key params |
|---|------|---------|------------|
| 1 | `ZohoBilling_get_customer_payments_report` | Payments received — current period | `filter_by: PaymentDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: payment_date`, `sort_order: D`, `per_page: 100`, `page: 1` |
| 2 | `ZohoBilling_get_customer_payments_report` | Payments received — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 3 | `ZohoBilling_get_refund_history_report` | Refunds — current period | `filter_by: RefundDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `per_page: 100`, `page: 1` |
| 4 | `ZohoBilling_get_refund_history_report` | Refunds — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 5 | `ZohoBilling_get_payment_failures_report` | Failed payments — current period | `filter_by: FailureDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `per_page: 100`, `page: 1` |
| 6 | `ZohoBilling_get_payment_failures_report` | Failed payments — prior period | same, `from_date: <lm_start>`, `to_date: <lm_end>` |

**After parallel batch** (current period only):

| # | Tool | Purpose |
|---|------|---------|
| 7 | `ZohoBilling_get_renewal_failure_report` | Renewal failures — current period (involuntary churn signal) |

Paginate all calls while `has_more_page: true`. Use API `total` fields for
period sums — do not aggregate rows when pagination is in play.

---

## Step 2 — Compute collections metrics

### 2a. Payments received

| Metric | Formula |
|---|---|
| Total collected (CP) | API total from call #1 |
| Total collected (PP) | API total from call #2 |
| MoM Δ | CP − PP |
| MoM % | (CP − PP) / PP × 100 |
| Payment count CP / PP | row counts from calls #1 and #2 |
| Avg payment value CP | total_CP / payment_count_CP |
| Avg payment value PP | total_PP / payment_count_PP |

### 2b. Collection efficiency

Collection efficiency = payments collected as a fraction of gross invoiced.

If called standalone (not via orchestrator), pull invoice totals:
- Call `ZohoBilling_get_invoice_details_report` with both date windows (summary
  totals only — `per_page: 1`, use the API `total` field).

If called via orchestrator, use `gross_invoiced_cp` and `gross_invoiced_pp`
from the sales-performance-analysis output directly.

```
efficiency_CP = total_collected_CP / gross_invoiced_CP × 100
efficiency_PP = total_collected_PP / gross_invoiced_PP × 100
```

Note: values can exceed 100% when prepayments or credit applications are counted
as payments — flag this rather than treating it as an error.

### 2c. Refunds

| Metric | Formula |
|---|---|
| Total refunds CP / PP | API totals from calls #3 and #4 |
| Refund count CP / PP | row counts |
| Refund rate CP | total_refunds_CP / total_collected_CP × 100 |
| Refund rate PP | total_refunds_PP / total_collected_PP × 100 |
| MoM refund rate Δ | refund_rate_CP − refund_rate_PP (pp) |

From refund detail rows: top 3 customers by refund amount. Most common reason
if the field is populated.

### 2d. Payment failures

| Metric | Formula |
|---|---|
| Failed count CP / PP | row counts from calls #5 and #6 |
| Failed amount CP / PP | API totals |
| Failure rate CP | failed_count_CP / (failed_count_CP + payment_count_CP) × 100 |
| Failure rate PP | failed_count_PP / (failed_count_PP + payment_count_PP) × 100 |
| MoM Δ | failure_rate_CP − failure_rate_PP (pp) |

From failure detail rows: top 3 failure reasons by count. Customers with > 1
failure in CP (card likely needs update — flag for outreach).

### 2e. Renewal failures (current period only)

From call #7:
- Count of renewal failures
- Total MRR at risk
- Top 5 customers by MRR at risk

These are forward-looking — they signal involuntary churn that will hit next
month's subscriber count if not resolved.

### 2f. Net collections position

```
net_collected_CP = total_collected_CP − total_refunds_CP
net_collected_PP = total_collected_PP − total_refunds_PP
mom_net_pct      = (net_CP − net_PP) / net_PP × 100
```

---

## Step 3 — Produce the analysis output

```markdown
## Collection Performance — <period_label_cm> vs <period_label_lm>

### Collections Summary
| Metric | <PP label> | <CP label> | Δ |
|---|---|---|---|
| Total collected | $X | $Y | +$Z (+N%) |
| Refunds issued | $X | $Y | +$Z |
| Net collected | $X | $Y | +$Z (+N%) |
| Collection efficiency | N% | N% | +Npp |
| Payment count | N | N | +N |
| Avg payment value | $X | $Y | +$Z |

**Collections MoM: <direction and magnitude in plain English>**

### Payment Failures
| Metric | <PP label> | <CP label> | Δ |
|---|---|---|---|
| Failed attempts | N | N | +N |
| Failure rate | N% | N% | +Npp |
| Failed amount | $X | $Y | +$Z |

Top failure reasons (CP): <reason 1> (N), <reason 2> (M)
Repeated failures: <N customers — flag for card update>

### Refund Breakdown
- CP: $X across N refunds (N% of collected)
- PP: $Y across M refunds (N% of collected)
- Top refunded: <customer> ($X), <customer> ($Y)

### Renewal Failures — Forward-Looking
- N renewal failures · $X MRR at risk in current period
- Top 5 at-risk: <customer> ($MRR), ...
```

---

## Output contract (for orchestrator)

```json
{
  "pillar": "collections",
  "metrics": {
    "total_collected_cp": <number>,
    "total_collected_pp": <number>,
    "mom_collections_pct": <number>,
    "collection_efficiency_cp_pct": <number>,
    "collection_efficiency_pp_pct": <number>,
    "refund_rate_cp_pct": <number>,
    "refund_rate_pp_pct": <number>,
    "payment_failure_rate_cp_pct": <number>,
    "payment_failure_rate_pp_pct": <number>,
    "net_collected_cp": <number>,
    "renewal_failures_mrr_at_risk": <number>
  },
  "repeated_failure_customers": [{"name": "...", "failures": <count>}],
  "renewal_failures": [{"customer": "...", "mrr": ...}],
  "flags": ["<repeated failure customers>", "<efficiency > 100%>"]
}
```

---

## Edge cases

- **Zero payments**: verify date window first; state explicitly if genuinely empty.
- **No refunds**: skip refund section; set rate = 0.
- **Renewal failure report unavailable**: skip that sub-section; note it.
- **Efficiency > 100%**: note "prepayments or credit applications included" — not an error.
- **Multi-currency**: use base-currency totals throughout.
- **Prior month shorter than today's day**: note truncation; comparison is still valid
  since we're comparing the same calendar range in each month.
