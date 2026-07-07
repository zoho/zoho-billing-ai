---
name: subscription-kpis
description: >
  Weekly or monthly KPI digest covering MRR, ARR, active subscriptions, activations,
  churn rate, and NRR with anomaly callouts. Use when the user wants a top-level
  business health summary, weekly metrics, monthly report, or KPI dashboard.
  Do NOT use for detailed breakdowns of any single metric.
when_to_use: >
  Trigger on: "weekly kpis", "monthly report", "subscription health", "business summary",
  "key metrics", "kpi digest", "health dashboard", "how is the business doing",
  "give me the numbers", "metrics overview".
argument-hint: "[period — e.g. 'this month' or 'last week']"
---

# Subscription KPIs

One-page KPI digest for leadership. Notify-only — no write actions.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: this month vs previous month.

## Fetch (run all in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_MRR_Report` | MRR current |
| 2 | `ZohoBilling_Get_MRR_Report` | MRR prior period |
| 3 | `ZohoBilling_Get_ARR_Report` | ARR current |
| 4 | `ZohoBilling_Get_Active_Customers_Report` | Active subscriber count |
| 5 | `ZohoBilling_Get_Activations_Report` | New activations |
| 6 | `ZohoBilling_Get_User_Churn_Report` | Churn rate |
| 7 | `ZohoBilling_Get_Revenue_Churn_Report` | Revenue churn |
| 8 | `ZohoBilling_Get_Net_Revenue_Retention_Rate_Report` | NRR |
| 9 | `ZohoBilling_Get_MRR_Insights_Report` | MRR movement narrative |

## Output

```
Subscription KPIs — [Period]  (vs [Prior Period])
─────────────────────────────────────────────────
MRR                 $XXX,XXX     [+/-X%]  [🟢/🟡/🔴]
ARR                 $X.XM        [+/-X%]
Active subscribers  X,XXX        [+/-X]
New activations     XXX          [+/-X%]
User churn rate     X.X%         [+/-Xpp]
Revenue churn rate  X.X%         [+/-Xpp]
NRR                 XXX%         [+/-Xpp]
─────────────────────────────────────────────────
Overall health: 🟢 Green | 🟡 Yellow | 🔴 Red
```

**Anomaly callouts** — flag any metric that moved more than 2× its typical weekly variance:
> ⚠ User churn rate jumped from 2.1% to 4.3% — investigate before next week

**One-line narrative** from MRR insights if available.

## Constraints

- Show Δ as both absolute and % — never just one
- Use pp (percentage points) for rate changes, % for count/revenue changes
- Overall health = Red if any single metric is Red; Yellow if 2+ are Yellow

## Edge cases

- If any report returns no data: show "—" for that row, note which reports were unavailable
- First month of operation: skip prior-period Δ columns, note "No prior period"
