---
name: retention
title: Retention
description: >
  Catches cancelled and non-renewing subscriptions, scores by LTV/LTD, applies the org's
  Retention Policy, and sends retention offers (discount coupon, plan downgrade suggestion,
  postpone renewal) to high-value at-risk customers.
action_type: Analysis + Save-action
tools:
  - get_churned_subscriptions_report
  - get_non_renewing_subscriptions_report
  - get_ltv_report
  - get_voluntary_churn_details_report
  - associate_coupon_to_subscription
  - postpone_subscription_renewal
  - reactivate_subscription
  - email_invoice
---

# Retention

## Overview

**Action Type:** Analysis + Save-action

Catches cancelled and non-renewing subscriptions, scores by LTV/LTD, applies the org's Retention Policy, and sends retention offers (discount coupon, plan downgrade suggestion, postpone renewal) to high-value at-risk customers.

---

## Trigger Phrases

- "show me at-risk subscriptions"
- "who's about to churn"
- "retention worklist"
- "which customers should we save"
- "non-renewing subscriptions"
- "run retention playbook"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_churned_subscriptions_report` | Fetches recently cancelled subscriptions with cancellation details |
| `get_non_renewing_subscriptions_report` | Retrieves subscriptions set to not renew at end of current term |
| `get_ltv_report` | Gets lifetime value (LTV) and lifetime deal (LTD) data per customer |
| `get_voluntary_churn_details_report` | Pulls voluntary churn data including cancellation reasons |

### Write Tools

| Tool | Purpose |
|---|---|
| `associate_coupon_to_subscription` | Apply a discount coupon to a subscription as a retention offer |
| `postpone_subscription_renewal` | Postpone the renewal date to give the customer breathing room |
| `reactivate_subscription` | Reactivate a cancelled subscription |
| `email_invoice` | Send a retention email or invoice to the customer |

---

## Workflow

### Step 1 — Identify At-Risk Subscriptions

1. Call `get_non_renewing_subscriptions_report` to fetch all subscriptions marked as non-renewing.
2. Call `get_churned_subscriptions_report` to fetch recently cancelled subscriptions (within the last 30 days — still saveable).

### Step 2 — Score by Customer Value

3. Call `get_ltv_report` to retrieve LTV and LTD for each at-risk customer.
4. Compute a **Customer Value Score** for each subscription:

| Signal | Weight | Logic |
|---|---|---|
| Lifetime Value (LTV) | 40% | Higher LTV = higher priority to retain. Normalize against org's median LTV. |
| Lifetime Deal value (LTD) | 25% | Total revenue collected to date — higher LTD = proven paying customer. |
| Subscription tenure | 20% | Longer-tenured customers are harder to replace. Tenure > 12 months = high value. |
| Plan tier | 15% | Higher-tier plans contribute more revenue — prioritize retaining them. |

Assign a **Customer Value Score between 0.0 and 1.0** for each subscription.

### Step 3 — Understand Churn Reason

5. Call `get_voluntary_churn_details_report` to pull cancellation reasons for churned subscriptions.
6. For non-renewing subscriptions without an explicit reason, infer likely cause from:
   - Recent downgrade activity → price sensitivity
   - Declining usage (if available) → value perception
   - Support ticket history → dissatisfaction
   - No recent activity → disengagement

### Step 4 — Apply Retention Policy

Match each at-risk subscription to the appropriate **retention offer** based on the org's Retention Policy:

| Customer Value | Churn Reason | Retention Offer |
|---|---|---|
| High (>0.7) | Price sensitivity | **Apply coupon** — offer 15–25% discount for next renewal |
| High (>0.7) | Feature mismatch / overkill | **Suggest plan downgrade** — retain at lower tier rather than lose |
| High (>0.7) | Timing / cash flow | **Postpone renewal** — extend by 30–60 days |
| High (>0.7) | Competitor / dissatisfaction | **Schedule call** — personal outreach from account manager |
| Medium (0.4–0.7) | Price sensitivity | **Apply coupon** — offer 10–15% discount |
| Medium (0.4–0.7) | Timing / cash flow | **Postpone renewal** — extend by 15–30 days |
| Medium (0.4–0.7) | Disengagement | **Send retention email** — highlight value, share tips |
| Low (<0.4) | Any reason | **Send retention email** — standard win-back template |
| Recently cancelled (<7 days) | Any, high value | **Reactivate subscription** — offer coupon + reactivation |
| Recently cancelled (7–30 days) | Any | **Send retention email** — win-back offer |

### Step 5 — Rank the Worklist

7. Sort at-risk subscriptions by Customer Value Score (descending).
8. Flag subscriptions cancelling within 7 days as **🔴 Urgent**.
9. Flag high-value customers (>0.7) as **⭐ High Priority**.

### Step 6 — Present the Worklist

10. Output the ranked worklist table (see Output Format below).
11. Include an executive summary with churn risk metrics.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No at-risk subscriptions found | Report "No at-risk subscriptions — retention is healthy" with current active subscription count. |
| Customer has no LTV data | Use subscription MRR × tenure months as a proxy. Flag as "Estimated LTV" in reasoning. |
| Churn reason not available | Classify as "Unknown" and default to a retention email as the safe first move. |
| Customer already received a retention offer | Flag as "Previously contacted" — escalate to next-level offer or schedule call. |
| Subscription already past cancellation date | Move to "Win-back" category — only email-based outreach, no coupon/postpone. |
| Customer has multiple subscriptions | Aggregate value across all subscriptions; treat as a single retention case. |
| API returns an error for any tool | Proceed with available data, note the missing data source, and adjust confidence accordingly. |

---

## Output Format

### Executive Summary

```
🛡️ Retention Worklist — [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
At-risk subscriptions    : [count]
Total MRR at risk        : [currency amount]
High-value at risk (⭐)  : [count] ([currency amount] MRR)
Urgent (cancelling <7d)  : [count]
Recently cancelled       : [count] (saveable within 30 days)
```

### Ranked Worklist

| # | Customer | Subscription | Plan | MRR | Value Score | Churn Reason | Days Until Cancel | Retention Offer | Reasoning |
|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [SUB-XXX] | [Plan] | [Amount] | [0.X] | [Reason] | [Days / Cancelled] | [Offer] | [Brief explanation] |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"LTV $12,400, 18-month tenure. Marked non-renewing citing price. Downgraded plan last quarter. High value — worth a 20% coupon."*

### One-Click Actions

For each row, present the available actions:

- **🎟️ Apply coupon** — Associate a discount coupon to the subscription
- **⏳ Postpone renewal** — Extend the renewal date to retain the customer
- **📧 Send retention email** — Send a personalized retention offer email
- **📞 Schedule call** — Flag for account manager phone outreach

---

## Output Rules

1. Always show MRR amounts in the organization's base currency.
2. Sort strictly by Customer Value Score descending.
3. Keep reasoning concise — max 2 sentences per row.
4. Mark rows with 🔴 if cancellation is within 7 days.
5. Mark rows with ⭐ if Customer Value Score > 0.7.
6. Recently cancelled subscriptions (still within reactivation window) should appear in a separate section at the bottom.
7. Group actions by type at the bottom for bulk execution if the user requests it.