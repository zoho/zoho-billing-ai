---
name: nrr-check
description: >
  Compute Net Revenue Retention and classify it against SaaS industry benchmarks.
  Use when the user asks about NRR, net revenue retention, whether existing revenue
  is growing or shrinking, or how well the business retains and expands customer revenue.
  Do NOT use for MRR growth waterfall, churn rate, or new customer acquisition questions.
when_to_use: >
  Trigger on: "nrr", "net revenue retention", "revenue retention", "are we retaining revenue",
  "how sticky is our revenue", "expansion vs churn", "nrr benchmark", "nrr health".
argument-hint: "[period — e.g. 'last 12 months' or 'this year']"
---

# NRR Check

Report Net Revenue Retention rate, classify it against industry benchmarks,
and surface the cohort with the weakest retention.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: last 12 months (`SubscriptionDate.LastTwelveMonths`).

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Net_Revenue_Retention_Rate_Report` | NRR % for the period |
| 2 | `ZohoBilling_Get_Revenue_Retention_Cohort_Report` | Cohort-level retention heatmap |
| 3 | `ZohoBilling_Get_Subscription_Retention_Rate_Report` | Subscriber count retention |
| 4 | `ZohoBilling_Get_Revenue_Waterfall_Report` | Starting → expansion → contraction → churn → ending MRR |

## Output

**NRR Summary**
```
Net Revenue Retention: XX%
Band: 🟢 Best-in-class (>110%) | 🟡 Healthy (100–110%) | 🔴 Leaking (<100%)
```

**Benchmark context**
| Band | NRR | What it means |
|---|---|---|
| 🟢 Best-in-class | > 110% | Expansion more than covers all churn |
| 🟡 Healthy | 100–110% | Retaining revenue, limited expansion |
| 🔴 Leaking | < 100% | Losing more than gaining from existing customers |

**Revenue waterfall** — Starting MRR → +Expansion → −Contraction → −Churn → Ending MRR with Δ%.

**Weakest cohort** — Name the acquisition month with the lowest retention percentage from the cohort report. One sentence on what changed at acquisition time if visible.

**Subscriber retention** — Count-based retention rate alongside revenue retention (gap between them signals plan downgrades or ARPU compression).

## Constraints

- NRR formula: (Starting MRR + Expansion − Contraction − Churn) / Starting MRR × 100
- Do not conflate NRR with gross retention (gross excludes expansion)
- Propose-only: no subscription changes

## Edge cases

- NRR > 150%: verify the calculation — check for data anomalies before reporting
- Less than 3 months of data: label as "insufficient history for NRR — showing available period"
- Cohort data empty: skip weakest-cohort section with a note
