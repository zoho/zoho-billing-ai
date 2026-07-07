---
name: payment-failure-diagnosis
description: >
  Diagnose why a payment failed for a customer or subscription: look up the
  gateway error code, translate it to plain English, and recommend the fix.
  Use when the user asks why a payment failed, what a dunning error means,
  or how to resolve a failed charge. Do NOT use for churn analysis or dunning reports.
when_to_use: >
  Trigger on: "why did payment fail", "payment failure for [customer]",
  "what does this error mean", "dunning error", "card declined reason",
  "how to fix failed payment", "gateway error", "payment declined diagnosis".
argument-hint: "[customer name, subscription ID, or error code]"
---

# Payment Failure Diagnosis

Look up the payment failure, decode the error, and recommend the fix.
Uses `ZohoBilling_Search_Error_Categories` — the most underutilised tool in the MCP.

## Step 1 — Resolve the subject

If `$ARGUMENTS` is a customer name:
- `ZohoBilling_Search_Customers` with `search_text: $ARGUMENTS` → get customer_id
- `ZohoBilling_List_all_Subscriptions` with customer_id, `filter_by: SubscriptionStatus.PAST_DUE`

If `$ARGUMENTS` looks like an error code or error name:
- `ZohoBilling_Search_Error_Categories` with `search_text: $ARGUMENTS` → get error details

If `$ARGUMENTS` is empty: ask "Which customer or subscription should I diagnose?"

## Step 2 — Get failure details (run in parallel after Step 1)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_Get_Payment_Failures_Report` | filter by customer or period |
| 2 | `ZohoBilling_Search_Error_Categories` | search_text from error code in failures |
| 3 | `ZohoBilling_Get_Subscriptions_Dunning_Report` | current dunning state |

## Output

```
Payment Failure Diagnosis — [Customer Name]
────────────────────────────────────────────────────────────────
Subscription:  [Plan] · $XX/month · Status: PAST_DUE
Last attempt:  [date]  ❌ Failed
Error code:    [code]
Error meaning: [plain-English translation from Search_Error_Categories]

ROOT CAUSE: [one sentence]

RECOMMENDED FIX:
  1. [specific action — e.g. "Ask customer to update payment card"]
  2. [fallback — e.g. "Switch to offline payment if card cannot be updated"]
  3. [escalation — e.g. "If unresolved after 2 attempts, flag for manual outreach"]

Dunning state: Retry N of M · Next retry: [date]
────────────────────────────────────────────────────────────────
```

**Error category playbooks** (apply based on Search_Error_Categories result):
- Card expired / Invalid card → ask customer to update card
- Insufficient funds → retry later / offer payment plan
- Do not honour → customer's bank blocked it — customer must call bank
- Card stolen/fraud flag → do not retry — contact customer via alternate channel
- Technical/gateway error → retry immediately — not customer's fault

## Constraints

- Always translate error codes to plain English using Search_Error_Categories
- Never tell the user to "check the gateway" without naming the specific action
- Propose-only: no payment retries or subscription changes

## Edge cases

- Error code not found in Search_Error_Categories: show raw code + "Unknown error — escalate to payment operations"
- Multiple failures for same customer: show the most recent 3 with dates
- No PAST_DUE subscriptions found: "No failed payments found for this customer"
