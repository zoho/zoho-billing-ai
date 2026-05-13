---
name: salesperson-performance
title: Salesperson Performance
description: >
  Per-salesperson scorecard with actionable insight (not just metrics): trial conversion rate,
  sales cycle length, stale-quote rate, customer churn attribution, expansion left on table.
  Flags coaching opportunities by name.
action_type: Analysis + Reporting
tools:
  - get_sales_by_salesperson_report
  - get_average_sales_cycle_length_report
  - get_average_sales_cycle_length_details_report
  - get_estimate_details_report
  - get_voluntary_churn_details_report
---

# Salesperson Performance

## Overview

**Action Type:** Analysis + Reporting

Per-salesperson scorecard with actionable insight (not just metrics): trial conversion rate, sales cycle length, stale-quote rate, customer churn attribution, expansion left on table. Flags coaching opportunities by name.

This is a **read-only, notify-only** skill — no write actions are performed.

---

## Trigger Phrases

- "salesperson performance"
- "how is the sales team doing"
- "rep scorecard"
- "who's closing deals"
- "sales team review"
- "show me rep metrics"
- "coaching opportunities"
- "which reps need help"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_sales_by_salesperson_report` | Fetches revenue, deal count, and subscription data per salesperson |
| `get_average_sales_cycle_length_report` | Retrieves org-wide and per-rep average sales cycle length |
| `get_average_sales_cycle_length_details_report` | Gets granular deal-level cycle length data per salesperson |
| `get_estimate_details_report` | Pulls all quotes/estimates with status, age, and assigned salesperson |
| `get_voluntary_churn_details_report` | Fetches voluntary churn data with customer-to-salesperson attribution |

### Write Tools

None — this is a reporting-only skill.

---

## Workflow

### Step 1 — Gather Sales Performance Data

1. Call `get_sales_by_salesperson_report` to fetch revenue, deal count, new subscriptions, and trial conversions per salesperson for the current period (week or month).
2. Call `get_average_sales_cycle_length_report` to get the org-wide average cycle length as a benchmark.
3. Call `get_average_sales_cycle_length_details_report` to get deal-level cycle data per rep.

### Step 2 — Gather Quote Pipeline Data

4. Call `get_estimate_details_report` to pull all quotes assigned to each salesperson — open, accepted, declined, and expired.

### Step 3 — Gather Churn Attribution Data

5. Call `get_voluntary_churn_details_report` to get churned customers attributed to each salesperson.

### Step 4 — Calculate Per-Rep Metrics

For each salesperson, compute the following scorecard metrics:

| Metric | Calculation |
|---|---|
| **Revenue Closed** | Total revenue from closed deals in the period. |
| **Deal Count** | Number of deals closed in the period. |
| **Avg Deal Size** | Revenue Closed ÷ Deal Count. |
| **Trial Conversion Rate** | (Trials converted to paid ÷ Total trials assigned) × 100. |
| **Avg Sales Cycle Length** | Mean days from quote creation to deal close for this rep. |
| **Stale Quote Rate** | (Open quotes older than 30 days ÷ Total open quotes) × 100. |
| **Quote Win Rate** | (Accepted quotes ÷ Total quotes sent) × 100. |
| **Churn Attribution** | Number of churned customers originally sold by this rep. |
| **Churn Revenue Lost** | MRR lost from customers attributed to this rep. |
| **Expansion Left on Table** | Customers with single-product subscriptions that could upsell — not yet quoted. |

### Step 5 — Benchmark Against Team

For each metric, compare the rep's performance against:
- **Team average** — how does this rep compare to peers?
- **Previous period** — is this rep improving or declining?

Assign a **performance indicator** per metric:

| Performance | Indicator | Criteria |
|---|---|---|
| Above average | 🟢 | > team average + 10% |
| On track | 🟡 | Within ±10% of team average |
| Below average | 🔴 | < team average − 10% |

### Step 6 — Identify Coaching Opportunities

Flag specific, named coaching opportunities when:

| Signal | Coaching Flag |
|---|---|
| Trial conversion rate < 50% | *"[Rep] is converting fewer than half of trials. Review onboarding follow-up cadence."* |
| Sales cycle > 1.5× team average | *"[Rep]'s average cycle is [X] days vs. team avg [Y]. Check for bottlenecks in proposal or negotiation stage."* |
| Stale quote rate > 40% | *"[Rep] has [N] quotes older than 30 days. Pipeline hygiene needed — close or kill stale quotes."* |
| Quote win rate < 30% | *"[Rep]'s win rate is [X]%. Review quote quality, pricing, and competitive positioning."* |
| Churn attribution > 2× team average | *"[Rep]'s customers churn at [X]× the team rate. Investigate whether expectations are being set correctly during the sale."* |
| No expansion quotes on eligible accounts | *"[Rep] has [N] single-product customers with no upsell activity. Expansion revenue opportunity."* |
| Revenue declining period-over-period | *"[Rep]'s revenue dropped [X]% vs. last period. Check pipeline health and activity levels."* |

### Step 7 — Present the Scorecard

6. For **weekly** output: individual rep scorecards with coaching flags.
7. For **monthly** output: team summary table + individual scorecards + trend analysis.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| New salesperson with < 30 days tenure | Show available data, mark as "Ramping — limited data" and exclude from team average calculations. |
| Salesperson has zero deals in period | Still show scorecard with zero values; flag pipeline and quote activity instead. |
| No quotes assigned to a salesperson | Skip stale-quote and win-rate metrics; note "No quoting activity" in scorecard. |
| Churn data doesn't attribute to salesperson | Note "Attribution unavailable" and exclude from churn metrics for that rep. |
| Only one salesperson in org | Skip benchmarking; show absolute metrics and period-over-period trends only. |
| API returns an error for any tool | Proceed with available data, note the missing metric, and adjust the scorecard accordingly. |

---

## Output Format

### Weekly Per-Salesperson Scorecard

```
👤 [Salesperson Name] — Week of [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Revenue & Deals
  Revenue Closed       : [amount]    [▲/▼ vs. last week]   [🟢/🟡/🔴]
  Deals Closed         : [count]     [▲/▼]                 [🟢/🟡/🔴]
  Avg Deal Size        : [amount]    [▲/▼]

Conversion
  Trial Conversion     : [X%]        [▲/▼ pp]              [🟢/🟡/🔴]
  Quote Win Rate       : [X%]        [▲/▼ pp]              [🟢/🟡/🔴]

Efficiency
  Avg Sales Cycle      : [X days]    vs. team avg [Y days]  [🟢/🟡/🔴]
  Stale Quote Rate     : [X%]        ([N] quotes > 30d)     [🟢/🟡/🔴]

Retention
  Churn Attribution    : [N] customers ([amount] MRR)       [🟢/🟡/🔴]

Growth
  Expansion Opportunity: [N] accounts with upsell potential  [🟢/🟡/🔴]
```

### Coaching Flags (per rep)

> 🏷️ **Coaching: [Rep Name]**
> - [Specific coaching insight with data]
> - [Specific coaching insight with data]

### Monthly Team Summary

| Salesperson | Revenue | Deals | Avg Deal | Trial Conv. | Win Rate | Cycle (days) | Stale Quotes | Churn Attr. | Overall |
|---|---|---|---|---|---|---|---|---|---|
| [Name] | [amount] | [count] | [amount] | [X%] | [X%] | [days] | [X%] | [count] | [🟢/🟡/🔴] |
| [Name] | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| **Team Avg** | **[amount]** | **[count]** | **[amount]** | **[X%]** | **[X%]** | **[days]** | **[X%]** | **[count]** | |

### Monthly Trend (per rep)

| Salesperson | Revenue Trend (3mo) | Conversion Trend | Cycle Trend | Direction |
|---|---|---|---|---|
| [Name] | [▲/▼ X%] | [▲/▼ X pp] | [▲/▼ X days] | Improving / Declining / Steady |

### Top Recommendations

A numbered list of the top 3–5 actionable coaching and team-level recommendations:

1. [Recommendation with rep name and specific action]
2. [Recommendation with rep name and specific action]
3. [Recommendation with rep name and specific action]

---

## Output Rules

1. Always show currency amounts in the organization's base currency.
2. Use ▲ for improvements and ▼ for declines (direction-aware — lower churn = ▲).
3. Name reps explicitly in coaching flags — avoid vague "some reps" language.
4. Default to **weekly** scorecard. Switch to monthly team summary if the user requests it.
5. Keep coaching insights specific and data-backed — no generic advice.
6. If a rep is excelling across the board, call it out positively: *"[Rep] is the top performer this period — replicate their quoting cadence across the team."*
7. Sort the team summary by Revenue Closed descending.