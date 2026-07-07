---
name: mrr-quick-ratio
description: >
  Compute the MRR Quick Ratio (new + expansion + reactivation) / (contraction + churn)
  and classify business growth quality as efficient, leaky, or accelerating.
  Use when the user asks about growth quality, quick ratio, MRR efficiency,
  or whether growth is healthy. Do NOT use for raw MRR amounts or ARR questions.
when_to_use: >
  Trigger on: "quick ratio", "growth quality", "mrr efficiency", "is our growth healthy",
  "growth ratio", "expansion vs churn ratio", "growth quality score".
argument-hint: "[period — e.g. 'last 6 months']"
---

# MRR Quick Ratio

Compute MRR Quick Ratio and classify growth quality. A ratio > 4 is
best-in-class; < 1 means the business is shrinking.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: last 3 months.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_MRR_Quick_Ratio_Report` | Quick ratio for the period |
| 2 | `ZohoBilling_Get_MRR_Insights_Report` | Component breakdown narrative |
| 3 | `ZohoBilling_Get_Gross_MRR_Report` | Gross MRR for context |
| 4 | `ZohoBilling_Get_Net_Revenue_Retention_Rate_Report` | NRR as corroborating signal |

## Output

```
MRR Quick Ratio — [Period]
──────────────────────────────────────────
Quick Ratio:    X.X
Classification: 🟢 Efficient (>4) | 🟡 Growing (2–4) | 🟠 Leaky (1–2) | 🔴 Shrinking (<1)

Inputs:
  + New MRR:           $XX,XXX
  + Expansion MRR:     $XX,XXX
  + Reactivation MRR:  $XX,XXX
  − Contraction MRR:   $XX,XXX
  − Churn MRR:         $XX,XXX

NRR (corroborating):  XXX%
──────────────────────────────────────────
Insight: [one sentence on the biggest ratio driver]
```

**Classification bands:**
| Ratio | Label | What it means |
|---|---|---|
| > 4 | 🟢 Efficient | Best-in-class — expansion far exceeds losses |
| 2–4 | 🟡 Growing | Healthy growth with manageable churn |
| 1–2 | 🟠 Leaky | Growing but churn is absorbing much of the gain |
| < 1 | 🔴 Shrinking | Losses exceed new revenue |

## Constraints

- Formula: (New + Expansion + Reactivation) / (Contraction + Churn)
- If contraction + churn = 0, ratio is undefined — report as "N/A (no churn this period)"
- Propose-only: no write actions

## Edge cases

- Ratio > 10: verify inputs — likely a data or date-range issue
- Ratio drops sharply MoM: flag "⚠ Quick Ratio declined — investigate churn spike or expansion slowdown"
