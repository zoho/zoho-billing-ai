---
name: revenue-recognition-health
description: >
  ASC 606 / IFRS 15 health check: deferred vs recognized revenue, waterfall
  variance, and anomaly flags for the controller or finance team. Use when the
  user asks about revenue recognition, deferred revenue, rev-rec health, or
  month-end close compliance. Do NOT use for MRR, ARR, or cash collection questions.
when_to_use: >
  Trigger on: "revenue recognition", "rev-rec health", "deferred revenue",
  "recognized revenue", "asc 606", "ifrs 15", "month-end rev-rec",
  "deferred vs recognized", "revenue waterfall variance", "revenue compliance".
argument-hint: "[period — e.g. 'last month' for month-end close]"
---

# Revenue Recognition Health

ASC 606 / IFRS 15 health monitor for finance and controllers. Notify-only.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: last month (typical use is month-end close).

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Recognized_Revenue_Report` | Total recognized revenue |
| 2 | `ZohoBilling_Get_Recognized_Revenue_Details_Report` | Per-item recognized detail |
| 3 | `ZohoBilling_Get_Recognized_Revenue_by_Customer_Report` | Customer-level outliers |
| 4 | `ZohoBilling_Get_Deferred_Revenue_Report` | Total deferred revenue |
| 5 | `ZohoBilling_Get_Deferred_Revenue_Details_Report` | Per-item deferred detail |
| 6 | `ZohoBilling_Get_Deferred_Revenue_by_Customer_Report` | Customer-level deferred |
| 7 | `ZohoBilling_Get_Revenue_Waterfall_Report` | Starting → earned → ending |
| 8 | `ZohoBilling_Get_Revenue_Waterfall_Details_Report` | Line-item waterfall |

## Output

```
Revenue Recognition Health — [Period]
────────────────────────────────────────────────────────────────────────
Recognized this period:  $XXX,XXX
Deferred (balance):      $XXX,XXX
Deferred-to-recognized:  X.X× ratio  [🟢 Healthy | 🟡 Watch | 🔴 Review]

REVENUE WATERFALL
  Opening deferred:    $XXX,XXX
  + New bookings:      +$XX,XXX
  − Earned (recognized): −$XX,XXX
  Closing deferred:    $XXX,XXX  (Δ +/-$X,XXX vs last period)

ANOMALY FLAGS
  ⚠ [Customer X]: $XX,XXX deferred — unusually large single-customer concentration
  ⚠ Recognized revenue variance: actual $X vs expected $Y — investigate timing

MONTH-END CLOSE CHECKLIST
  ☐ Deferred balance reconciles to contract values
  ☐ No items recognized before delivery (early recognition risk)
  ☐ Large deferred balances > $10,000 reviewed individually
  ☐ Waterfall closing balance matches prior-period opening
────────────────────────────────────────────────────────────────────────
```

**Deferred-to-recognized ratio bands:**
| Ratio | Call |
|---|---|
| < 1.5× | 🟢 Healthy — earning out at a good pace |
| 1.5–3× | 🟡 Watch — large deferred balance building |
| > 3× | 🔴 Review — potential recognition timing issue |

## Constraints

- Month-end checklist is static — always include it regardless of anomalies
- Customer concentration = single customer > 20% of total deferred
- Propose-only: no journal entries, no revenue schedule changes

## Edge cases

- No deferred revenue: "No deferred revenue balance — all revenue recognised immediately (check if deferred tracking is enabled)"
- Waterfall doesn't reconcile (closing ≠ opening + new − earned): flag as "⚠ Waterfall does not reconcile — manual review required"
