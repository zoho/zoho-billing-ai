---
name: card-expiry-risk
description: >
  List subscriptions whose payment card expires in the next 30 or 60 days,
  ranked by MRR at risk. Use when the user asks about expiring cards, cards
  about to expire, or wants to prevent involuntary churn from payment method expiry.
  Do NOT use for current payment failures or dunning analysis.
when_to_use: >
  Trigger on: "cards expiring soon", "expiring payment methods", "card expiry",
  "cards about to expire", "prevent failed renewals", "expiring cards",
  "card expiry risk", "payment method expiry".
argument-hint: "[days — e.g. '60' for 60-day window, default is 30]"
---

# Card Expiry Risk

List subscriptions with cards expiring in the next 30 (or N) days, ranked by MRR at risk.
Proactive prevention — act before the renewal fails.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default window: 30 days. If `$ARGUMENTS` is a number, use that as the day window.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Card_Expiry_Report` | Cards expiring in coming period |
| 2 | `ZohoBilling_List_all_Subscriptions` | filter_by: ACTIVE (for MRR amounts) |

## Output

```
Card Expiry Risk — Next [N] Days    [date]
Total MRR at risk: $XXX,XXX  ·  N subscriptions
────────────────────────────────────────────────────────────────────
 #  Customer              Plan        MRR      Card expires   Days left
────────────────────────────────────────────────────────────────────
 1  Acme Corp             Enterprise  $4,200   Jul 15, 2026   16d  ⚠
 2  Northwind Traders     Pro         $  890   Jul 22, 2026   23d
 3  Globex Industries     Starter     $   79   Jul 28, 2026   29d
────────────────────────────────────────────────────────────────────
Expiring ≤ 15 days:  N subs  $X MRR  ← urgent
Expiring 16–30 days: N subs  $X MRR
```

Flag ⚠ on any card expiring within 15 days.
Recommended action per row: "Send card-update request" (all rows — this is the only action available without write tools).

## Constraints

- Rank by MRR descending within each expiry window
- Propose-only: no emails sent, no payment mode changes
- If subscription MRR is not directly in the card expiry report, join to subscription list by customer_id

## Edge cases

- Zero results: "No cards expiring in the next [N] days 🟢"
- Card already expired (expiry date in the past): include in list, label as "EXPIRED — renewal will fail"
