---
name: collections-today
description: >
  Daily AR worklist: top 20 overdue invoices ranked by recovery probability
  (outstanding amount × payment-behaviour score). Use when the user asks who
  to chase for payments today, wants a collections prioritisation, or needs a
  daily AR action list. Do NOT use for aggregate overdue totals or bad-debt analysis.
when_to_use: >
  Trigger on: "who should I chase today", "collections worklist", "collections today",
  "payment chase list", "who to call for collections", "AR priority list",
  "top collections priorities", "daily collections".
---

# Collections Today

Rank overdue invoices by recovery probability and surface the top 20 to work today.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_AR_Aging_Details_Report` | All overdue invoices with aging buckets |
| 2 | `ZohoBilling_Get_Time_to_Pay_Report` | Historical days-to-pay per customer |
| 3 | `ZohoBilling_Get_Customer_Payments_Report` | Recent payment activity |
| 4 | `ZohoBilling_Get_Customer_Balance_Summary_Report` | Total balance per customer |

## Scoring

For each overdue invoice compute a **recovery score**:

```
recovery_score = outstanding_amount × pay_probability

pay_probability derived from:
  + Customer has paid before within terms historically  → +0.3
  + Last payment within 60 days                        → +0.2
  + Invoice < 30 days overdue                          → +0.2
  − Invoice 61–90 days overdue                         → −0.2
  − Invoice 90+ days overdue                           → −0.4
  − Multiple previous missed payments                  → −0.2
  Base: 0.5
  Clamp: 0.1 – 0.9
```

Sort descending by recovery_score. Show top 20.

## Output

See [references/output-format.md](references/output-format.md) for the full worklist format.

Summary line at top:
```
Collections Today — [date]
Total overdue: $XXX,XXX  ·  Top 20 shown  ·  Est. recoverable today: $XX,XXX
```

Per row: rank · customer · invoice · amount · days overdue · recommended action.

**Recommended actions:**
- High score (>0.7) + < 30 days: **Email invoice** — likely to pay with a nudge
- Medium score (0.4–0.7) + 30–60 days: **Phone call** — needs direct contact
- Low score (<0.4) + 60–90 days: **Payment link** — remove friction
- Very low score + 90+ days: **Apply credits if available** or escalate

## Constraints

- Use API totals for balance sums — do not manually aggregate paginated rows
- If time-to-pay data is unavailable for a customer, use base probability 0.5
- Top 20 only — users should use `/overdue-invoices` for the full list
- Propose-only: no emails sent, no payments applied

## Edge cases

- Zero overdue invoices: "No overdue invoices — AR is clean 🟢"
- Customer with credits available: flag "Credits available — apply before chasing"
