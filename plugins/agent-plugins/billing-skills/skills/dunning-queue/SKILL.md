---
name: dunning-queue
description: >
  List all subscriptions currently in PAST_DUE or UNPAID status, ranked by
  MRR at risk. Use when the user wants to see which subscriptions are in trouble,
  past-due subs, or subscriptions with failed renewals.
  Do NOT use for invoice-level overdue (use /overdue-invoices) or dunning analysis.
when_to_use: >
  Trigger on: "past due subscriptions", "which subs are past due", "subscriptions in trouble",
  "failed renewal subs", "unpaid subscriptions", "subscription payment issues".
---

# Past Due Subscriptions

List all PAST_DUE and UNPAID subscriptions ranked by MRR at risk.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_List_all_Subscriptions` | `filter_by: SubscriptionStatus.PAST_DUE`, `per_page: 200` |
| 2 | `ZohoBilling_List_all_Subscriptions` | `filter_by: SubscriptionStatus.UNPAID`, `per_page: 200` |

Paginate while `has_more_page: true`.

## Output

```
Past Due & Unpaid Subscriptions — [date]
Total MRR at risk: $XXX,XXX across N subscriptions
──────────────────────────────────────────────────────────
 #  Customer              Plan          MRR      Status
──────────────────────────────────────────────────────────
 1  Acme Corp             Pro Annual    $4,200   PAST_DUE
 2  Northwind Traders     Starter       $  490   UNPAID
...
──────────────────────────────────────────────────────────

PAST_DUE:  N subs  $X MRR
UNPAID:    N subs  $X MRR
```

For each subscription show: customer name · plan name · MRR · status · subscription ID.
Sort by MRR descending within each status group.

## Constraints

- PAST_DUE and UNPAID are distinct — show them in separate groups
- MRR = plan amount / billing frequency months (approximate if not available)
- Propose-only: no subscription changes

## Edge cases

- Zero results: "No past-due or unpaid subscriptions 🟢"
- Same customer appears multiple times: group their subs together, show subtotal
