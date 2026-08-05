---
name: subscription-insights
title: Subscription Insights
description: >
  Weekly/monthly KPI digest covering MRR, ARR, Active Subscriptions, Activations, Churn rate,
  NRR with anomaly callouts and natural-language recommendations on what's driving each movement.
action_type: Analysis + Reporting
tools:
  - get_mrr_report
  - get_arr_report
  - get_active_customers_report
  - get_activations_report
  - get_user_churn_report
  - get_revenue_churn_report
  - get_net_revenue_retention_rate_report
  - get_mrr_insights_report
---

# Subscription Insights

## Overview

**Action Type:** Analysis + Reporting

Weekly/monthly KPI digest covering MRR, ARR, Active Subscriptions, Activations, Churn rate, NRR with anomaly callouts and natural-language recommendations on what's driving each movement.

This is a **read-only, notify-only** skill — no write actions are performed.

---

## Trigger Phrases

- "subscription insights"
- "how are subscriptions doing"
- "weekly KPI report"
- "monthly metrics digest"
- "MRR update"
- "what's happening with churn"
- "give me the numbers"
- "subscription health check"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_mrr_report` | Fetches Monthly Recurring Revenue trend data |
| `get_arr_report` | Fetches Annual Recurring Revenue trend data |
| `get_active_customers_report` | Retrieves active customer/subscription counts over time |
| `get_activations_report` | Pulls new subscription activation data |
| `get_user_churn_report` | Gets customer/logo churn rate and details |
| `get_revenue_churn_report` | Gets revenue churn (MRR lost to cancellations and downgrades) |
| `get_net_revenue_retention_rate_report` | Retrieves NRR — measures expansion vs. contraction revenue |
| `get_mrr_insights_report` | Breaks down MRR movements: new, expansion, contraction, churn, reactivation |

### Write Tools

None — this is a reporting-only skill.

---

## Workflow

### Step 1 — Gather Revenue Metrics

1. Call `get_mrr_report` to fetch MRR data for the current and previous period (week-over-week or month-over-month).
2. Call `get_arr_report` to fetch ARR data for the same periods.
3. Call `get_mrr_insights_report` to get the MRR movement breakdown (new, expansion, contraction, churn, reactivation).

### Step 2 — Gather Customer Metrics

4. Call `get_active_customers_report` to get active subscription/customer counts over time.
5. Call `get_activations_report` to pull new activations for the period.

### Step 3 — Gather Churn & Retention Metrics

6. Call `get_user_churn_report` to get logo/customer churn rate.
7. Call `get_revenue_churn_report` to get revenue churn rate (gross MRR churn).
8. Call `get_net_revenue_retention_rate_report` to get NRR.

### Step 4 — Calculate Period-over-Period Changes

For each KPI, compute:

| KPI | Calculation |
|---|---|
| MRR | Current period MRR vs. previous period. Absolute change + % change. |
| ARR | Current period ARR vs. previous period. Absolute change + % change. |
| Active Subscriptions | Current count vs. previous period. Net change. |
| New Activations | Count for current period vs. previous period. |
| Customer Churn Rate | Current period rate vs. previous period rate. |
| Revenue Churn Rate | Current period rate vs. previous period rate. |
| Net Revenue Retention (NRR) | Current NRR vs. previous period. |
| MRR Movements | New + Expansion − Contraction − Churn + Reactivation = Net MRR change. |

### Step 5 — Detect Anomalies

Flag any KPI where the period-over-period change exceeds normal thresholds:

| Anomaly Type | Threshold | Flag |
|---|---|---|
| MRR drop | > 5% decline | 🔴 **MRR Alert** |
| MRR spike | > 15% increase | 🟢 **MRR Surge** |
| Churn rate spike | > 2× previous period | 🔴 **Churn Alert** |
| Activations drop | > 30% decline | 🟡 **Activation Slowdown** |
| NRR below 100% | NRR < 100% | 🔴 **Net Contraction** |
| NRR above 120% | NRR > 120% | 🟢 **Strong Expansion** |
| Contraction MRR spike | > 2× previous period | 🟡 **Downgrade Wave** |

### Step 6 — Generate Recommendations

For each anomaly or notable movement, generate a natural-language recommendation:

| Signal | Recommendation Pattern |
|---|---|
| MRR drop driven by churn | *"Churn contributed [amount] to MRR decline. Review the Retention skill to identify save opportunities."* |
| MRR drop driven by contraction | *"Downgrades accounted for [amount]. Investigate whether a recent pricing change or feature gap is driving plan switches."* |
| Activation slowdown | *"New activations fell [X]% — check marketing pipeline and trial conversion rates."* |
| NRR below 100% | *"Revenue contraction is outpacing expansion. Focus on upsell motions and reducing voluntary churn."* |
| Strong expansion revenue | *"Expansion MRR grew [amount] — identify which upsell or add-on is driving this and double down."* |
| Churn rate spike | *"Logo churn jumped to [X]%. Cross-reference with the Retention skill to catch at-risk customers."* |
| Healthy across the board | *"All KPIs trending positively. Maintain current trajectory."* |

### Step 7 — Present the Digest

9. Output the KPI digest (see Output Format below).
10. Default to **monthly** cadence. If the user asks for weekly, adjust the comparison period accordingly.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| Insufficient historical data (new org) | Show available data, note "Limited history — comparisons unavailable" for missing periods. |
| A report returns empty data | Skip that KPI, note it as "Data unavailable" in the digest, proceed with remaining metrics. |
| All KPIs flat (no movement) | Report "No significant changes — business is steady" with the current snapshot. |
| User asks for a custom date range | Adjust all report calls to the requested range and compare against the equivalent prior period. |
| API returns an error for any tool | Proceed with available data, note the missing metric, and adjust the digest accordingly. |
| MRR insights don't sum to net change | Flag the discrepancy and present both the breakdown and the reported net change. |

---

## Output Format

### KPI Dashboard

```
📈 Subscription Insights — [Period] ([Start Date] → [End Date])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Revenue
  MRR            : [amount]   [▲/▼ amount] ([+/-X%])  [flag if anomaly]
  ARR            : [amount]   [▲/▼ amount] ([+/-X%])
  NRR            : [X%]       [▲/▼ X pp]              [flag if anomaly]

Customers
  Active Subs    : [count]    [▲/▼ count] ([+/-X%])
  New Activations: [count]    [▲/▼ count] ([+/-X%])   [flag if anomaly]

Churn
  Customer Churn : [X%]       [▲/▼ X pp]              [flag if anomaly]
  Revenue Churn  : [X%]       [▲/▼ X pp]              [flag if anomaly]
```

### MRR Movement Breakdown

| Component | Amount | % of Gross MRR | Trend vs. Prior |
|---|---|---|---|
| 🆕 New | [amount] | [X%] | [▲/▼] |
| 📈 Expansion | [amount] | [X%] | [▲/▼] |
| 📉 Contraction | [amount] | [X%] | [▲/▼] |
| ❌ Churn | [amount] | [X%] | [▲/▼] |
| 🔄 Reactivation | [amount] | [X%] | [▲/▼] |
| **Net MRR Change** | **[amount]** | | |

### Anomaly Callouts

List each detected anomaly with its flag, the data point, and the recommendation:

> 🔴 **MRR Alert** — MRR declined 7.2% ($3,400). Churn contributed $2,800. *Review the Retention skill to identify save opportunities.*

> 🟡 **Activation Slowdown** — New activations dropped 35% (12 → 8). *Check marketing pipeline and trial conversion rates.*

### Recommendations Summary

A concise numbered list of the top 3–5 actionable recommendations based on the data:

1. [Recommendation]
2. [Recommendation]
3. [Recommendation]

---

## Output Rules

1. Always show currency amounts in the organization's base currency.
2. Use ▲ for positive changes and ▼ for negative changes.
3. Show percentage point changes (pp) for rates, percentage changes (%) for absolute values.
4. Keep anomaly callouts to genuinely significant movements — don't flag noise.
5. Recommendations must be specific and actionable, not generic advice.
6. Default to monthly comparison. Switch to weekly only if the user explicitly requests it.
7. If no anomalies are detected, still present the full KPI dashboard — just note "No anomalies detected this period."