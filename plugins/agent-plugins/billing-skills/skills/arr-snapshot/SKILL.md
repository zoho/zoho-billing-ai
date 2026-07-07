---
name: arr-snapshot
description: >
  Show Annual Recurring Revenue with QoQ and YoY trend and a growth trajectory.
  Use when the user asks about ARR, annual recurring revenue, annual run rate,
  or year-over-year revenue growth. Do NOT use for MRR, NRR, or monthly breakdowns.
when_to_use: >
  Trigger on: "arr", "annual recurring revenue", "annual run rate", "yearly revenue",
  "arr growth", "arr trend", "yoy revenue", "year over year arr".
argument-hint: "[period — e.g. 'this year' or 'last 12 months']"
---

# ARR Snapshot

Report ARR with gross vs net comparison and QoQ / YoY growth trend.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: this year (`SubscriptionDate.ThisYear`).

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_ARR_Report` | Net ARR for current period |
| 2 | `ZohoBilling_Get_ARR_Report` | Net ARR for prior year (for YoY) |
| 3 | `ZohoBilling_Get_Gross_ARR_Report` | Gross ARR current period |

## Output

```
ARR Snapshot — [Period]
─────────────────────────────────────
Net ARR (current):   $X,XXX,XXX
Net ARR (prior yr):  $X,XXX,XXX
YoY growth:          +XX%

Gross ARR:           $X,XXX,XXX
Discount gap:        $XX,XXX (X% of gross)
─────────────────────────────────────
Trajectory: 🟢 Accelerating | 🟡 Steady | 🔴 Decelerating
```

**Trajectory classification:**
- 🟢 Accelerating: YoY growth > 20% or growth rate improving QoQ
- 🟡 Steady: YoY growth 5–20%
- 🔴 Decelerating: YoY growth < 5% or negative

## Constraints

- ARR = Net MRR × 12 (confirm this matches API definition)
- Report gross and net separately — do not mix them
- If discount gap > 15% of gross ARR, add ⚠ flag
- Propose-only: no write actions

## Edge cases

- Less than 12 months of data: show annualised run-rate with note "< 12 months history"
- ARR and MRR × 12 disagree by > 5%: surface the discrepancy and ask before reporting
