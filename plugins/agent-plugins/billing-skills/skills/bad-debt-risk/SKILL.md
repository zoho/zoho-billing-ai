---
name: bad-debt-risk
description: >
  Identify overdue invoices most likely heading toward write-off, while a save is
  still possible. Use when the user asks about bad debt, write-off risk, invoices
  unlikely to be recovered, or wants to see which AR is at risk of becoming bad debt.
  Do NOT use for general overdue lists or collections prioritisation.
when_to_use: >
  Trigger on: "bad debt risk", "write-off risk", "which invoices won't get paid",
  "at-risk receivables", "invoices heading to write-off", "bad debt prevention",
  "which AR is unrecoverable".
---

# Bad Debt Risk

Surface invoices at high risk of write-off while a save is still possible.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Bad_Debt_Report` | Already written-off amounts |
| 2 | `ZohoBilling_Get_AR_Aging_Details_Report` | All overdue invoices with age |
| 3 | `ZohoBilling_Get_Payment_Failures_Report` | Payment failure history |
| 4 | `ZohoBilling_Get_Subscriptions_Dunning_Report` | Active dunning state |

## Risk scoring

For each overdue invoice compute a **write-off risk score** (higher = more at risk):

```
  + 90+ days overdue                              → +40
  + 61–90 days overdue                            → +20
  + 2+ previous payment failures for this customer → +20
  + Currently in dunning and retries exhausted    → +20
  + No payment in last 120 days                   → +15
  − Partial payment received recently             → −15
  − Customer has other active paid subscriptions  → −10
```

Surface invoices with risk score ≥ 40 as **at-risk**.

## Output

```
Bad Debt Risk — [date]
Already written off (YTD): $XX,XXX
At-risk receivables: $XXX,XXX across N invoices
────────────────────────────────────────────────────────────────────
 #  Customer              Invoice     Amount    Days   Risk    Save window
────────────────────────────────────────────────────────────────────────
 1  Dead Deal Corp        INV-10011   $18,200   97d    🔴 High   Closing
 2  Struggling Inc        INV-10034   $9,400    78d    🟠 Med    2–3 weeks
 3  Late Payer Ltd        INV-10067   $4,100    65d    🟠 Med    4–5 weeks
────────────────────────────────────────────────────────────────────────

RECOMMENDED SAVE ACTIONS (propose-only):
  🔴 High risk: partial credit-note settlement or payment plan offer
  🟠 Medium risk: payment plan or restructure invoice due date
```

## Constraints

- Only surface invoices with risk score ≥ 40
- "Save window" is an estimate: (90 − days_overdue) days remaining before typical write-off
- Propose-only: no credit notes created, no write-offs applied

## Edge cases

- Zero at-risk invoices: "No invoices at high write-off risk 🟢"
- Bad debt report shows prior write-offs: always include YTD bad debt figure as context
