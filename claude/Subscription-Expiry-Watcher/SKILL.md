---
name: subscription-expiry-watcher
title: Subscription Expiry Watcher
description: >
  Catches non-auto-renewing subscriptions whose term is ending in the next 14/30/60 days.
  Recommends re-engagement motion per sub: extend term, switch to auto-renew, generate renewal
  quote, or pitch upgrade. Closes the gap left by the standard renewal flow which assumes
  auto-renewal.
action_type: Analysis + Re-engagement
tools:
  - get_subscription_expiry_report
  - get_non_renewing_subscriptions_report
  - get_subscriptions_report
  - get_ltv_report
  - update_subscription
  - create_quote
  - email_invoice
---

# Subscription Expiry Watcher

## Overview

**Action Type:** Analysis + Re-engagement

Catches non-auto-renewing subscriptions whose term is ending in the next 14/30/60 days. Recommends re-engagement motion per sub: extend term, switch to auto-renew, generate renewal quote, or pitch upgrade. Closes the gap left by the standard renewal flow which assumes auto-renewal.

---

## Trigger Phrases

- "expiring subscriptions"
- "what's up for renewal"
- "which subs are ending soon"
- "non-renewing subscriptions"
- "renewal worklist"
- "who needs a renewal quote"
- "subscriptions ending this month"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_subscription_expiry_report` | Fetches subscriptions expiring within configurable time windows (14/30/60 days) |
| `get_non_renewing_subscriptions_report` | Retrieves subscriptions explicitly set to not auto-renew |
| `get_subscriptions_report` | Gets full subscription details including plan, tenure, and billing configuration |
| `get_ltv_report` | Retrieves lifetime value data per customer for prioritization |

### Write Tools

| Tool | Purpose |
|---|---|
| `update_subscription` | Extend subscription term or switch to auto-renew |
| `create_quote` | Generate a renewal quote for the customer |
| `email_invoice` | Send a renewal reminder or invoice email to the customer |

---

## Workflow

### Step 1 — Identify Expiring Subscriptions

1. Call `get_subscription_expiry_report` to fetch all subscriptions expiring within the next 60 days.
2. Call `get_non_renewing_subscriptions_report` to fetch subscriptions explicitly marked as non-renewing.
3. Merge both lists, deduplicating by subscription ID.

### Step 2 — Enrich with Subscription Details

4. Call `get_subscriptions_report` to get full details for each expiring subscription: plan, plan_code, pricing, tenure, billing cycle, add-ons, and auto-renew status.

### Step 3 — Assess Customer Value

5. Call `get_ltv_report` to retrieve LTV for each customer with an expiring subscription.
6. Compute a **Renewal Priority Score** (0.0 to 1.0):

| Signal | Weight | Logic |
|---|---|---|
| Lifetime Value (LTV) | 35% | Higher LTV = higher priority to renew. Normalize against org's median LTV. |
| Subscription MRR | 25% | Higher MRR subscriptions are more valuable to retain. |
| Tenure | 20% | Longer-tenured customers are more likely to renew and worth more effort. |
| Urgency (days to expiry) | 20% | Fewer days remaining = more urgent. <14 days = critical, 14–30 = high, 30–60 = standard. |

### Step 4 — Classify Urgency Window

Assign each subscription to an urgency window:

| Window | Days to Expiry | Flag |
|---|---|---|
| 🔴 Critical | 0–14 days | Immediate action required |
| 🟡 High | 15–30 days | Action this week |
| 🟢 Standard | 31–60 days | Plan and queue |

### Step 5 — Determine Recommended Motion

For each expiring subscription, assign the **recommended re-engagement motion**:

| Condition | Recommended Motion |
|---|---|
| High-value customer, on lower-tier plan, tenure > 12 months | **Pitch upgrade** — create a renewal quote with an upgraded plan |
| High-value customer, satisfied (no support issues), non-auto-renew | **Switch to auto-renew** — update subscription to auto-renew (requires plan_code) |
| Mid-value customer, expiring in < 14 days | **Send renewal quote** — create and email a renewal quote immediately |
| Mid-value customer, expiring in 14–30 days | **Send renewal reminder** — email invoice as a reminder |
| Customer on annual plan, expiring in 30–60 days | **Extend term** — offer a term extension with loyalty discount |
| Customer previously declined renewal or downgraded | **Create quote with incentive** — renewal quote + coupon consideration |
| Low-value customer, expiring in any window | **Send renewal reminder** — standard email notification |
| Subscription has add-ons or multiple products | **Send renewal quote** — ensure the full bundle is quoted for renewal |

### Step 6 — Present the Worklist

7. Output the ranked worklist grouped by urgency window (see Output Format below).
8. Include an executive summary with expiry pipeline metrics.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No expiring subscriptions found | Report "No subscriptions expiring in the next 60 days" with total active subscription count. |
| Subscription already has auto-renew enabled | Exclude from the worklist — the standard renewal flow handles it. Note the count in the summary. |
| Customer has multiple expiring subscriptions | Group together as a single entry; combine MRR and flag "Multiple subs expiring" in reasoning. |
| LTV data unavailable | Use MRR × tenure as a proxy. Flag as "Estimated value" in reasoning. |
| Subscription expired today or yesterday | Move to "Overdue Renewal" section with 🔴 flag — immediate outreach needed. |
| Customer already contacted about renewal | Note "Previously contacted [X days ago]" in reasoning — escalate to next-level motion. |
| API returns an error for any tool | Proceed with available data, note the missing source, and adjust the worklist accordingly. |

---

## Output Format

### Executive Summary

```
⏰ Subscription Expiry Watcher — [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Expiring subscriptions (60d) : [count]
Total MRR at risk            : [currency amount]

By Urgency:
  🔴 Critical (0–14 days)    : [count] ([currency amount] MRR)
  🟡 High (15–30 days)       : [count] ([currency amount] MRR)
  🟢 Standard (31–60 days)   : [count] ([currency amount] MRR)

Auto-renew enabled (excluded): [count] (handled by standard flow)
```

### Ranked Worklist

#### 🔴 Critical — Expiring in 0–14 Days

| # | Customer | Subscription | Plan | MRR | Days Left | LTV | Priority Score | Recommended Motion | Reasoning |
|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Days] | [Amount] | [0.X] | [Motion] | [Brief explanation] |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 🟡 High — Expiring in 15–30 Days

| # | Customer | Subscription | Plan | MRR | Days Left | LTV | Priority Score | Recommended Motion | Reasoning |
|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Days] | [Amount] | [0.X] | [Motion] | [Brief explanation] |

#### 🟢 Standard — Expiring in 31–60 Days

| # | Customer | Subscription | Plan | MRR | Days Left | LTV | Priority Score | Recommended Motion | Reasoning |
|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [Days] | [Amount] | [0.X] | [Motion] | [Brief explanation] |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"LTV $8,200, 24-month tenure, on Basic plan. Non-auto-renew, no support issues. High value — pitch upgrade to Pro with renewal quote."*

### One-Click Actions

For each row, present the available actions:

- **📄 Send renewal quote** — Create and email a renewal quote to the customer
- **⏳ Extend term** — Update the subscription with an extended term
- **🔄 Switch to auto-renew** — Update the subscription to enable auto-renewal (uses plan_code from subscription details)

---

## Output Rules

1. Always show MRR and LTV amounts in the organization's base currency.
2. Sort within each urgency group by Renewal Priority Score descending.
3. Keep reasoning concise — max 2 sentences per row.
4. Always show the 🔴 Critical section first, regardless of score.
5. If a subscription expired within the last 48 hours, add it to the top of the Critical section with a ⚠️ **Overdue** flag.
6. Exclude auto-renewing subscriptions from the worklist — only show the excluded count in the summary.
7. Group actions by type at the bottom for bulk execution if the user requests it.