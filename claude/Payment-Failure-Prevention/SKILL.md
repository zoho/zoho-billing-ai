---
name: payment-failure-prevention
title: Payment Failure Prevention
description: >
  Proactive complement to Bad Debt Prevention. Identifies subscriptions whose payment card
  expires in the next 30/60 days, ranks by MRR-at-risk, and triggers card-update outreach
  before any failed renewal occurs. Prevents involuntary churn at the source rather than
  after the dunning damage is done.
action_type: Proactive Outreach
tools:
  - get_card_expiry_report
  - get_subscriptions_report
  - get_customer_payments_report
  - create_paymentlink
  - email_invoice
  - update_subscription
---

# Payment Failure Prevention

## Overview

**Action Type:** Proactive Outreach

Proactive complement to Bad Debt Prevention. Identifies subscriptions whose payment card expires in the next 30/60 days, ranks by MRR-at-risk, and triggers card-update outreach before any failed renewal occurs. Prevents involuntary churn at the source rather than after the dunning damage is done.

---

## Trigger Phrases

- "expiring cards"
- "which cards are expiring soon"
- "card expiry worklist"
- "prevent failed payments"
- "involuntary churn risk"
- "payment method check"
- "MRR at risk from card expiry"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_card_expiry_report` | Fetches subscriptions with payment cards expiring within 30/60 days |
| `get_subscriptions_report` | Gets full subscription details including plan, MRR, billing cycle, and renewal date |
| `get_customer_payments_report` | Pulls payment history to assess reliability and identify customers with multiple payment methods |

### Write Tools

| Tool | Purpose |
|---|---|
| `create_paymentlink` | Generate a card-update payment link for the customer |
| `email_invoice` | Send a card-update reminder email to the customer |
| `update_subscription` | Update subscription: switch payment mode (online/offline), add notes, or modify settings |

---

## Workflow

### Step 1 — Identify Expiring Cards

1. Call `get_card_expiry_report` to fetch all subscriptions whose payment card expires within the next 60 days.
2. Call `get_subscriptions_report` to enrich with subscription details: plan, MRR, billing cycle, next renewal date, and payment configuration.

### Step 2 — Assess Payment Context

3. Call `get_customer_payments_report` to pull payment history for each affected customer.
4. For each subscription, determine:

| Data Point | Purpose |
|---|---|
| Has backup payment method? | If yes, risk is lower — the backup may cover renewal. |
| Payment failure history | Customers with prior failed payments are higher risk. |
| Last successful payment date | Recent payers are more engaged and likely to update. |
| Next renewal date | How soon will the expiring card actually be charged? |

### Step 3 — Calculate MRR-at-Risk

For each subscription, compute:

```
MRR-at-Risk = Subscription MRR × P(fail)
```

Where **P(fail)** is the probability of payment failure:

| Signal | Weight | Logic |
|---|---|---|
| Days until card expiry | 30% | Card expiring before next renewal = P(fail) high. Card expiring after next renewal = safe, exclude. |
| Backup payment method | 25% | Has backup = lower P(fail). No backup = higher. |
| Payment failure history | 20% | Prior failures = higher P(fail). Clean history = lower. |
| Customer responsiveness | 15% | Historically responds to emails quickly = lower P(fail). Non-responsive = higher. |
| Billing cycle alignment | 10% | Annual billing with renewal soon = high risk. Monthly with time to spare = lower urgency. |

Assign a **P(fail) score between 0.0 and 1.0** for each subscription.

### Step 4 — Filter and Classify

5. **Exclude** subscriptions where the card expires *after* the next renewal date — they're not at immediate risk.
6. Classify remaining subscriptions into urgency windows:

| Window | Condition | Flag |
|---|---|---|
| 🔴 Critical | Card expires in 0–14 days AND renewal before expiry | Immediate outreach |
| 🟡 Urgent | Card expires in 15–30 days AND renewal before expiry | Action this week |
| 🟢 Upcoming | Card expires in 31–60 days AND renewal before expiry | Plan and queue |

### Step 5 — Determine Recommended Action

For each subscription, assign the **recommended outreach motion**:

| Condition | Recommended Action |
|---|---|
| No backup payment method, card expiring < 14 days | **Create payment link** + **Email invoice** — urgent card-update request |
| No backup payment method, card expiring 15–30 days | **Email invoice** — polite card-update reminder with payment link |
| No backup payment method, card expiring 31–60 days | **Email invoice** — early heads-up with self-service update link |
| Has backup payment method | **Update subscription** — add note for monitoring, no outreach needed |
| Customer non-responsive to prior emails | **Create payment link** + **Update subscription** — escalate to phone/manual outreach |
| High-value customer (top 20% MRR), any window | **Create payment link** + **Email invoice** — prioritize personal outreach |
| Customer with prior payment failures | **Create payment link** + **Email invoice** + **Update subscription** — high risk, track closely |
| Customer requests offline payment | **Update subscription** — switch payment mode to offline to avoid failed auto-charge |

### Step 6 — Present the Worklist

7. Output the ranked worklist grouped by urgency window (see Output Format below).
8. Include an executive summary with total MRR-at-risk metrics.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No expiring cards found | Report "No cards expiring in the next 60 days — payment methods are healthy" with total active subscription count. |
| Card already expired | Move to top of 🔴 Critical. Flag as ⚠️ **Already expired** — renewal will fail on next charge attempt. |
| Customer has multiple subscriptions on same card | Group together as a single entry; sum MRR across all subscriptions. Note "Multiple subs on same card" in reasoning. |
| Card expiry date is after next renewal | Exclude from worklist — card will work for the upcoming renewal. Note excluded count in summary. |
| Customer already updated their card | Exclude if card expiry data has been refreshed. If stale data, note "Verify card status" in reasoning. |
| No payment history available | Assign neutral P(fail) of 0.5. Flag as "Limited payment data" in reasoning. |
| API returns an error for any tool | Proceed with available data, note the missing source, and adjust the worklist accordingly. |

---

## Output Format

### Executive Summary

```
💳 Payment Failure Prevention — Week of [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Subscriptions with expiring cards : [count]
Total MRR-at-risk                 : [currency amount]

By Urgency:
  🔴 Critical (0–14 days)         : [count] ([currency amount] MRR)
  🟡 Urgent (15–30 days)          : [count] ([currency amount] MRR)
  🟢 Upcoming (31–60 days)        : [count] ([currency amount] MRR)

Already expired (overdue)          : [count] ([currency amount] MRR)
Excluded (expires after renewal)   : [count]
Has backup payment method          : [count] (monitoring only)
```

### Ranked Worklist

#### 🔴 Critical — Card Expires in 0–14 Days

| # | Customer | Subscription | Plan | MRR | Card Expires | Next Renewal | P(fail) | MRR-at-Risk | Backup? | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Date] | [Date] | [0.X] | [Amount] | Yes/No | [Action] | [Brief explanation] |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 🟡 Urgent — Card Expires in 15–30 Days

| # | Customer | Subscription | Plan | MRR | Card Expires | Next Renewal | P(fail) | MRR-at-Risk | Backup? | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Date] | [Date] | [0.X] | [Amount] | Yes/No | [Action] | [Brief explanation] |

#### 🟢 Upcoming — Card Expires in 31–60 Days

| # | Customer | Subscription | Plan | MRR | Card Expires | Next Renewal | P(fail) | MRR-at-Risk | Backup? | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Date] | [Date] | [0.X] | [Amount] | Yes/No | [Action] | [Brief explanation] |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"Visa ending 4821 expires Jun 2, next renewal May 28. No backup method. 2 prior payment failures. High risk — send card-update link immediately."*

### One-Click Actions

For each row, present the available actions:

- **🔗 Send card-update link** — Create and email a payment link for the customer to update their card
- **🔀 Switch to offline mode** — Update subscription to offline payment to avoid failed auto-charge
- **📝 Add note** — Update subscription with an internal note to track outreach status

---

## Output Rules

1. Always show MRR amounts in the organization's base currency.
2. Sort within each urgency group by MRR-at-Risk descending.
3. Keep reasoning concise — max 2 sentences per row.
4. If a card has already expired, flag the row with ⚠️ **Expired** and place at the top of Critical.
5. Always show the 🔴 Critical section first.
6. Subscriptions with backup payment methods should be listed separately at the bottom as "Monitoring Only."
7. Group actions by type at the bottom for bulk execution if the user requests it.
8. Include the last 4 digits of the card number in reasoning where available for easy identification.