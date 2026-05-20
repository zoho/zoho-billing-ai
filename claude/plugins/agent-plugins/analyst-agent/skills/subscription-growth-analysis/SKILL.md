---
name: subscription-growth-analysis
description: >
  Analyse subscription growth by comparing two equal-length date windows — this
  month day 1 to today, vs the same day range in the prior month (e.g., May 1–19
  vs April 1–19). Pulls Zoho Billing active subscriptions, MRR, activations, and
  product/country breakdowns. Surfaces MRR trajectory, churn rate, net subscriber
  growth, and geographic/product mix. Use when the user asks about subscriber
  growth, MRR trends, churn, activations by product or market, geographic expansion,
  or any subscription-level performance question.
---

# Subscription Growth Analysis

Produces a **same-period MoM subscription health report** covering MRR, churn,
net growth, and product/country mix — both windows spanning the same number of
days for a like-for-like comparison.

---

## Step 0 — Setup

**Org ID**: Retrieve via `list_organizations` if not already known. Ask if multiple exist.

**Date windows** — use the same logic as the other pillar skills:

```
today     = current date
cm_start  = first day of current month  →  cm_end = today
lm_start  = first day of prior month    →  lm_end = prior month day matching today
            (cap lm_end at last day of prior month if today's day > prior month's length)
```

State windows and offer custom dates:
> "Comparing **May 1–19** vs **April 1–19**. Want to use different dates instead?"

If called by the orchestrator, accept windows directly — don't re-prompt.

---

## Step 1 — Fetch all data

### Batch A — 10 calls in parallel

| # | Tool | Purpose | Key params |
|---|------|---------|------------|
| 1 | `ZohoBilling_get_subscriptions_summary_report` | Subscription status counts — CP | `filter_by: ActivatedDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>` |
| 2 | `ZohoBilling_get_subscriptions_summary_report` | Subscription status counts — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 3 | `ZohoBilling_get_mrr_report` | MRR — CP | `filter_by: ActivatedDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>` |
| 4 | `ZohoBilling_get_mrr_report` | MRR — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>` |
| 5 | `ZohoBilling_get_activations_report` | Activation totals — CP | `filter_by: SubscriptionDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `per_page: 100` |
| 6 | `ZohoBilling_get_activations_report` | Activation totals — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>`, `per_page: 100` |
| 7 | `ZohoBilling_get_productwise_activations_report` | Activations by product — CP | `filter_by: SubscriptionDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100` |
| 8 | `ZohoBilling_get_productwise_activations_report` | Activations by product — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>`, `per_page: 100` |
| 9 | `ZohoBilling_get_productwise_cancellations_report` | Cancellations by product — CP | `filter_by: CancellationDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100` |
| 10 | `ZohoBilling_get_productwise_cancellations_report` | Cancellations by product — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>`, `per_page: 100` |

### Batch B — 4 more calls in parallel (after Batch A)

| # | Tool | Purpose | Key params |
|---|------|---------|------------|
| 11 | `ZohoBilling_get_countrywise_activations_report` | Activations by country — CP | `filter_by: SubscriptionDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100` |
| 12 | `ZohoBilling_get_countrywise_activations_report` | Activations by country — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>`, `per_page: 100` |
| 13 | `ZohoBilling_get_countrywise_cancellations_report` | Cancellations by country — CP | `filter_by: CancellationDate.CustomDate`, `from_date: <cm_start>`, `to_date: <cm_end>`, `sort_column: total`, `sort_order: D`, `per_page: 100` |
| 14 | `ZohoBilling_get_countrywise_cancellations_report` | Cancellations by country — PP | same, `from_date: <lm_start>`, `to_date: <lm_end>`, `per_page: 100` |

Paginate while `has_more_page: true`. Use API `total` fields for period-level
sums (activations, cancellations) — do not aggregate rows when pagination may
truncate.

---

## Step 2 — Compute subscription metrics

### 2a. Active subscribers and MRR

| Metric | Formula |
|---|---|
| Active subs end-of-CP | `live` count from call #1 |
| Active subs end-of-PP | `live` count from call #2 |
| MoM active subs Δ | CP − PP (absolute and %) |
| MRR (CP) | from call #3 |
| MRR (PP) | from call #4 |
| MoM MRR Δ | MRR_CP − MRR_PP (absolute and %) |
| ARPU (CP) | MRR_CP / active_subs_CP |
| ARPU (PP) | MRR_PP / active_subs_PP |
| ARPU Δ | (ARPU_CP − ARPU_PP) / ARPU_PP × 100 |

### 2b. Activations and cancellations

| Metric | Formula |
|---|---|
| Activations CP / PP | API totals from calls #5 / #6 |
| Cancellations CP / PP | API totals from productwise calls #9 / #10 summed |
| Net growth CP | activations_CP − cancellations_CP |
| Net growth PP | activations_PP − cancellations_PP |
| MoM activation % | (act_CP − act_PP) / act_PP × 100 |
| MoM cancellation % | (can_CP − can_PP) / can_PP × 100 |
| MoM net growth Δ | net_CP − net_PP |

### 2c. Churn rate

```
monthly_churn_CP = cancellations_CP / active_subs_PP × 100
monthly_churn_PP = cancellations_PP / (active_subs at start of PP — use PP live subs)
```

Standard SaaS convention: denominator is start-of-period active subs (use PP's
live count as the CP denominator).

Note for dashboard: if CP is a partial month, label as "period churn rate
(N-day window)" rather than "monthly" to avoid over-stating.

### 2d. MRR decomposition (if available)

Call `ZohoBilling_get_mrr_insights_report` for CP. If it returns data, extract:
- New MRR (new activations)
- Expansion MRR (upgrades / add-ons)
- Contraction MRR (downgrades)
- Churned MRR (cancellations)
- Net MRR movement

If the report returns empty or is unavailable, skip this section — don't estimate.

### 2e. Product breakdown

From calls #7–10, build a per-product table for **top 10 products by CP activations**.

For each product:
- Activations CP and PP
- Cancellations CP and PP
- Net growth CP = act_CP − can_CP
- Net growth PP = act_PP − can_PP
- MoM net growth Δ

Compute top-product activation concentration = (product_1_act / total_act_CP) × 100.

Flag products with:
- Net negative growth in CP (cancellations > activations)
- > 20% MoM drop in activations
- Zero PP history (new product launch in CP)

### 2f. Country breakdown

From calls #11–14, apply the same analysis as 2e for **top 10 countries by CP total
activity** (activations + cancellations).

For each country:
- Activations CP and PP
- Cancellations CP and PP
- Net growth CP and PP
- MoM net growth Δ

Compute top-country activation concentration = (country_1_act / total_act_CP) × 100.

Flag:
- Countries with net negative growth (shrinking markets)
- Countries new in CP (emerging markets — zero PP history)
- "Others" bucket if > 15% of activations (unattributed addresses)

---

## Step 3 — Produce the analysis output

```markdown
## Subscription Growth — <period_label_cm> vs <period_label_lm>

### Key Metrics
| Metric | <PP label> | <CP label> | Δ |
|---|---|---|---|
| Active subscribers | N | N | +N (+N%) |
| MRR | $X | $Y | +$Z (+N%) |
| ARPU | $X | $Y | +$Z |
| Activations | N | N | +N (+N%) |
| Cancellations | N | N | +N |
| Net growth | +N | +N | +N |
| Period churn rate | N% | N% | +Npp |

**MRR: <direction and magnitude>. Net growth: <direction and magnitude>.**

### MRR Decomposition (if available)
| Component | CP |
|---|---|
| New MRR | +$X |
| Expansion | +$X |
| Contraction | -$X |
| Churned | -$X |
| **Net MRR** | **+$X** |

### Product Performance (Top 10 by CP Activations)
| Product | Act PP | Act CP | Can CP | Net CP | MoM Net Δ |
|---|---|---|---|---|---|
...
_Top-product concentration: N% of activations from "<product name>"_

### Country Performance (Top 10 by CP Activity)
| Country | Act PP | Act CP | Can CP | Net CP | MoM Net Δ |
|---|---|---|---|---|---|
...
_Top-country concentration: N% of activations from "<country>"_
Growing: <list>   Shrinking: <list>
```

---

## Output contract (for orchestrator)

```json
{
  "pillar": "subscriptions",
  "metrics": {
    "active_subs_cp": <number>,
    "active_subs_pp": <number>,
    "mrr_cp": <number>,
    "mrr_pp": <number>,
    "mom_mrr_pct": <number>,
    "activations_cp": <number>,
    "activations_pp": <number>,
    "cancellations_cp": <number>,
    "net_growth_cp": <number>,
    "net_growth_pp": <number>,
    "period_churn_rate_cp_pct": <number>,
    "arpu_cp": <number>,
    "arpu_pp": <number>,
    "top_product_concentration_pct": <number>,
    "top_country_concentration_pct": <number>
  },
  "mrr_decomposition": {"new": ..., "expansion": ..., "contraction": ..., "churned": ..., "net": ...},
  "top_products": [{"name": "...", "activations_cp": ..., "net_cp": ..., "net_pp": ...}],
  "top_countries": [{"name": "...", "activations_cp": ..., "net_cp": ..., "net_pp": ...}],
  "flags": ["<shrinking markets>", "<product net negative>", "<concentration risk>"]
}
```

---

## Edge cases

- **New org (< 1 month old)**: PP will be empty. Analyse CP only; note it.
- **Products with zero PP data**: label as "new product" — don't compute Δ%.
- **Churn > 100%**: impossible; if it appears, warn and skip churn scoring — denominator likely wrong.
- **MRR = 0 for free plans**: exclude from ARPU; count them separately as "free subscribers."
- **"Others" country**: include if top 10, flag as unattributed.
- **MRR decomposition unavailable**: skip the section entirely.
