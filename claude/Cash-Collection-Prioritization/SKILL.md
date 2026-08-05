---
name: cash-collection-prioritization
title: Cash Collection Prioritization
description: >
  Daily ranks all overdue invoices by expected recovery value (outstanding amount × probability
  of paying based on customer's historical time-to-pay, dunning incidents, and balance trend).
  Surfaces the top 20 invoices finance should work today with reasoning per row and recommended
  next move (call, email, payment-link, or apply available credits).
action_type: Analysis + Prioritization + Follow-up
tools:
  - get_ar_aging_details_report
  - get_ar_aging_summary_report
  - get_time_to_pay_report
  - get_customer_payments_report
  - get_customer_balance_summary_report
  - apply_credits_to_invoice
  - create_paymentlink
  - email_invoice
  - update_invoice
---

# Cash Collection Prioritization

## Overview

**Action Type:** Analysis + Prioritization + Follow-up

Daily ranks all overdue invoices by expected recovery value (outstanding amount × probability of paying based on customer's historical time-to-pay, dunning incidents, and balance trend). Surfaces the top 20 invoices finance should work today with reasoning per row and recommended next move (call, email, payment-link, or apply available credits).

---

## Trigger Phrases

- "show me collections"
- "who should I chase today"
- "prioritize AR"
- "rank overdue invoices"
- "daily collections worklist"
- "which invoices should we follow up on"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_ar_aging_details_report` | Fetches line-level overdue invoice data with aging buckets |
| `get_ar_aging_summary_report` | Provides aggregated aging overview by customer |
| `get_time_to_pay_report` | Retrieves historical time-to-pay patterns per customer |
| `get_customer_payments_report` | Pulls payment history to assess payment reliability |
| `get_customer_balance_summary_report` | Gets current outstanding balances and credit availability |

### Write Tools

| Tool | Purpose |
|---|---|
| `apply_credits_to_invoice` | Apply available credits to an overdue invoice |
| `create_paymentlink` | Create and share a payment link for an invoice |
| `email_invoice` | Send an invoice reminder email to the customer |
| `update_invoice` | Update invoice details or add a note to the invoice |

---

## Workflow

### Step 1 — Gather Overdue Data

1. Call `get_ar_aging_details_report` to fetch all overdue invoices with aging bucket breakdown (Current, 1–30, 31–60, 61–90, 90+ days).
2. Call `get_ar_aging_summary_report` to get the customer-level aging summary for context.

### Step 2 — Assess Payment Behaviour

3. Call `get_time_to_pay_report` to retrieve each customer's historical average time-to-pay.
4. Call `get_customer_payments_report` to pull recent payment history — look for patterns: declining frequency, partial payments, missed due dates, or dunning escalations.

### Step 3 — Check Balances and Credits

5. Call `get_customer_balance_summary_report` to get current outstanding balances and any available credits or unapplied payments per customer.

### Step 4 — Calculate Expected Recovery Value

For each overdue invoice, compute:

```
Expected Recovery Value = Outstanding Amount × P(pay)
```

Where **P(pay)** is the probability of payment, derived from:

| Signal | Weight | Logic |
|---|---|---|
| Historical time-to-pay vs. terms | 30% | Customers who consistently pay within terms get higher P(pay). Chronic late payers get lower. |
| Recent payment frequency trend | 25% | Declining payment frequency in last 90 days reduces P(pay). |
| Dunning incidents | 20% | More dunning reminders sent without resolution = lower P(pay). |
| Balance trend (growing vs. shrinking) | 15% | Growing outstanding balance = lower P(pay). Shrinking = higher. |
| Aging bucket | 10% | Older buckets (61–90, 90+) get progressively lower P(pay). |

Assign a **P(pay) score between 0.0 and 1.0** for each invoice.

### Step 5 — Rank and Select Top 20

6. Sort all overdue invoices by Expected Recovery Value (descending).
7. Select the top 20 invoices.

### Step 6 — Determine Recommended Action

For each of the top 20 invoices, assign the **recommended next move** based on:

| Condition | Recommended Action |
|---|---|
| Customer has available credits ≥ invoice amount | **Apply credits** |
| Customer has available credits < invoice amount but > 0 | **Apply credits** (partial) + **Email invoice** for remainder |
| Invoice is 1–30 days overdue, customer has good payment history | **Email invoice** with payment link |
| Invoice is 31–60 days overdue, or customer has declining payment trend | **Generate payment link** + direct outreach |
| Invoice is 61+ days overdue, or multiple dunning incidents | **Call** — escalate to phone follow-up |
| Any invoice where customer has no recent activity | **Add note** for account review + **Email invoice** |

### Step 7 — Present the Worklist

7. Output the ranked worklist table (see Output Format below).
8. Include a brief executive summary at the top with total overdue amount, number of overdue invoices, and estimated recoverable value.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No overdue invoices found | Report "No overdue invoices — AR is clean" with a summary of total current receivables. |
| Customer has no payment history | Assign a neutral P(pay) of 0.5 and flag as "New customer — limited data" in reasoning. |
| Time-to-pay data unavailable | Skip that signal and reweight remaining signals proportionally. |
| Credits exceed total outstanding | Recommend "Apply credits" and note the surplus. |
| Fewer than 20 overdue invoices | Show all overdue invoices in the worklist. |
| API returns an error for any tool | Proceed with available data, note the missing data source, and adjust confidence accordingly. |

---

## Output Format

### Executive Summary

```
📊 Daily Collections Worklist — [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total overdue invoices : [count]
Total overdue amount   : [currency amount]
Estimated recoverable  : [currency amount] (based on P(pay) scores)
Top 20 recovery value  : [currency amount]
```

### Ranked Worklist

| # | Customer | Invoice # | Amount | Days Overdue | P(pay) | Expected Recovery | Reasoning | Recommended Action |
|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [INV-XXX] | [Amount] | [Days] | [0.X] | [Amount] | [Brief explanation of signals] | [Action] |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"Avg TTP 12 days (within terms), but last 2 payments were 25+ days late. Balance trending up. 1 dunning reminder sent."*

### One-Click Actions

For each row, present the available actions:

- **📧 Email invoice** — Send invoice reminder to customer
- **🔗 Generate payment link** — Create and share a payment link
- **💳 Apply credits** — Apply available credits to this invoice
- **📝 Add note** — Add an internal note to the customer record

---

## Output Rules

1. Always show amounts in the organization's base currency.
2. Sort strictly by Expected Recovery Value descending.
3. Keep reasoning concise — max 2 sentences per row.
4. If P(pay) < 0.2, flag the row with ⚠️ to indicate high risk of non-payment.
5. Group actions by type at the bottom for bulk execution if the user requests it.