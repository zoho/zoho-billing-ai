---
name: subscription-lookup
description: >
  Full lifecycle view of one subscription: plan, billing history, renewal status,
  payment track record, and current health. Use when the user asks about a specific
  subscription, wants to know renewal date, billing amount, or full sub history.
  Do NOT use for a customer overview (use /customer-360) or subscription lists.
when_to_use: >
  Trigger on: "tell me about subscription [SUB-XXX]", "subscription details",
  "when does [customer] renew", "subscription status for [customer]",
  "billing history for subscription", "what plan is [customer] on",
  "subscription health", "full subscription info".
argument-hint: "[subscription ID or customer name]"
---

# Subscription Deep Dive

Complete subscription lifecycle: current state, billing history, and health signals.

## Step 1 — Resolve the subscription

If `$ARGUMENTS` looks like a subscription ID (starts with SUB):
- `ZohoBilling_Get_a_Subscription` directly

If `$ARGUMENTS` is a customer name:
- `ZohoBilling_Search_Customers` with `search_text: $ARGUMENTS` → customer_id
- `ZohoBilling_List_all_Subscriptions` with customer_id → if multiple, ask which one

## Step 2 — Fetch (run in parallel after subscription_id known)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_a_Subscription` | Full subscription details |
| 2 | `ZohoBilling_List_all_Invoices` | All invoices, filter to this sub |
| 3 | `ZohoBilling_List_all_Payments` | All payments, filter to this customer |

## Output

```
Subscription Deep Dive — [Customer] · [SUB-XXXXX]
────────────────────────────────────────────────────────────────
Plan:           [Plan name]  ·  $XX/[frequency]
Status:         ACTIVE | TRIAL | PAST_DUE | NON_RENEWING | CANCELLED
Started:        [date]   ·  Tenure: X months
Next renewal:   [date]   ·  Auto-collect: Yes | No
Billing mode:   Online | Offline

BILLING HISTORY (last 6 invoices)
  [INV-XXXXX]  [date]  $X,XXX  ✅ Paid | ❌ Overdue | ⚠ Partial
  ...

HEALTH SIGNALS
  🟢 No issues  |  ⚠ [specific flags]

Common flags:
  • PAST_DUE — last renewal failed, N retries remaining
  • NON_RENEWING — scheduled to cancel on [date]
  • Partial payment on [INV] — $X outstanding
  • Last paid [X] days ago — [normal | late]
────────────────────────────────────────────────────────────────
```

## Constraints

- Show last 6 invoices for this subscription only
- NON_RENEWING subscriptions: always show the scheduled cancellation date prominently
- Propose-only: no subscription modifications

## Edge cases

- Cancelled subscription: show full history with cancellation date and reason if available
- Subscription ID not found: "Subscription [ID] not found — check the ID and try again"
- Customer has multiple active subscriptions: list them all and ask which one to deep-dive
