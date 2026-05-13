---
name: quote-acceleration
title: Quote Acceleration
description: >
  Ranks every open quote/estimate by expected close value × staleness, identifies stalled deals,
  and recommends the next move per quote (follow-up email, small concession, auto-convert if
  accepted, or kill if dead). Keeps sales pipeline reflecting reality.
action_type: Analysis + Prioritization + Follow-up
tools:
  - get_estimate_details_report
  - get_progress_invoice_summary_report
  - get_lost_opportunities_report
---

# Quote Acceleration

## Overview

**Action Type:** Analysis + Prioritization + Follow-up

Ranks every open quote/estimate by expected close value × staleness, identifies stalled deals, and recommends the next move per quote (follow-up email, small concession, auto-convert if accepted, or kill if dead). Keeps sales pipeline reflecting reality.

---

## Trigger Phrases

- "show me open quotes"
- "which deals are stalling"
- "prioritize quotes"
- "quote follow-up list"
- "what should sales work on today"
- "any quotes going cold"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_estimate_details_report` | Fetches all open quotes/estimates with amounts, dates, and status |
| `get_progress_invoice_summary_report` | Retrieves progress invoicing data to assess quote-to-invoice conversion history |
| `get_lost_opportunities_report` | Pulls historically lost quotes to identify patterns and risk signals |

### Write Tools

| Tool | Purpose |
|---|---|
| Email a quote | Send a follow-up or reminder email for a quote |
| Update a Quote | Modify quote details (e.g., apply discount or adjust terms) |
| Mark a Quote as accepted | Mark a quote as accepted when customer confirms |
| Create an invoice from quote | Convert an accepted quote into an invoice |
| Create a subscription | Create a subscription from a converted quote |

---

## Workflow

### Step 1 — Gather Open Quotes

1. Call `get_estimate_details_report` to fetch all open/draft/sent quotes with their amounts, creation dates, last activity dates, and customer details.

### Step 2 — Assess Historical Context

2. Call `get_progress_invoice_summary_report` to understand conversion patterns — which quotes historically converted and how quickly.
3. Call `get_lost_opportunities_report` to pull lost quote data — identify common characteristics of deals that died (age, value range, customer type).

### Step 3 — Calculate Staleness Score

For each open quote, compute a **staleness score**:

| Signal | Weight | Logic |
|---|---|---|
| Days since last activity | 35% | More days without activity = higher staleness. Threshold: >14 days = stale, >30 days = critical. |
| Days since quote created | 25% | Older quotes have lower close probability. Benchmark against avg historical time-to-close. |
| Number of follow-ups sent | 15% | Multiple follow-ups without response = higher staleness. |
| Customer's historical conversion rate | 15% | Customers who rarely convert from quotes get higher staleness. |
| Similarity to lost opportunities | 10% | Quotes matching patterns of historically lost deals get higher staleness. |

Assign a **staleness score between 0.0 (fresh) and 1.0 (dead)**.

### Step 4 — Calculate Expected Close Value

For each open quote, compute:

```
Expected Close Value = Quote Amount × P(close)
```

Where **P(close) = 1.0 − staleness score**.

### Step 5 — Rank Quotes

4. Sort all open quotes by Expected Close Value (descending).
5. Flag quotes with staleness > 0.7 as **"Stalled"** and staleness > 0.9 as **"Dead"**.

### Step 6 — Determine Recommended Action

For each quote, assign the **recommended next move** based on:

| Condition | Recommended Action |
|---|---|
| Quote is marked as accepted by customer | **Convert to invoice** — auto-convert immediately |
| Staleness < 0.3, quote sent < 7 days ago | **No action** — still fresh, allow time |
| Staleness 0.3–0.5, no follow-up in last 7 days | **Send follow-up email** — gentle reminder with payment link |
| Staleness 0.5–0.7, high-value quote | **Apply discount** — offer a small concession (5–10%) to accelerate |
| Staleness 0.5–0.7, low-value quote | **Send follow-up email** — last-chance reminder |
| Staleness 0.7–0.9, customer has responded before | **Send follow-up email** — direct ask for decision with deadline |
| Staleness > 0.9, no customer activity in 30+ days | **Mark as lost** — kill the deal, clean the pipeline |
| Customer has multiple open quotes | Flag for consolidation — **Add note** to review account |

### Step 7 — Present the Worklist

6. Output the ranked worklist table (see Output Format below).
7. Include an executive summary with pipeline health metrics.

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No open quotes found | Report "No open quotes — pipeline is empty" with a note to review lead generation. |
| Quote has no activity history | Assign staleness based on creation date only; flag as "Limited data" in reasoning. |
| Customer has no prior quotes | Use organization-wide averages for conversion rate benchmarks. |
| Quote amount is zero or missing | Exclude from ranking; flag for data cleanup. |
| Multiple quotes for same customer | Group together, flag for consolidation, and rank by combined value. |
| API returns an error for any tool | Proceed with available data, note the missing data source, and adjust confidence accordingly. |
| Quote is in draft (never sent) | Flag separately — recommend "Send quote" as primary action. |

---

## Output Format

### Executive Summary

```
📊 Quote Acceleration Worklist — [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total open quotes        : [count]
Total pipeline value     : [currency amount]
Estimated closeable      : [currency amount] (based on P(close) scores)
Stalled deals (>0.7)     : [count] ([currency amount])
Dead deals (>0.9)        : [count] ([currency amount])
Avg days open            : [number]
```

### Ranked Worklist

| # | Customer | Quote # | Amount | Days Open | Last Activity | Staleness | Expected Close Value | Reasoning | Recommended Action |
|---|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [QT-XXX] | [Amount] | [Days] | [Date/Days ago] | [0.X] | [Amount] | [Brief explanation] | [Action] |
| 2 | ... | ... | ... | ... | ... | ... | ... | ... | ... |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"Sent 14 days ago, no response to 2 follow-ups. Customer converted 3 of 5 past quotes. High value — worth a concession."*

### One-Click Actions

For each row, present the available actions:

- **📧 Send follow-up email** — Send a reminder email with the quote attached
- **💰 Apply discount** — Update the quote with a concession to accelerate close
- **🔄 Convert to invoice** — Create an invoice from this accepted quote
- **❌ Mark as lost** — Mark the quote as lost and remove from active pipeline

---

## Output Rules

1. Always show amounts in the organization's base currency.
2. Sort strictly by Expected Close Value descending.
3. Keep reasoning concise — max 2 sentences per row.
4. If staleness > 0.9, flag the row with ☠️ to indicate a dead deal.
5. If staleness > 0.7, flag the row with ⚠️ to indicate a stalled deal.
6. Quotes marked as accepted should always appear at the top with a ✅ flag — they need immediate conversion.
7. Group write actions (bulk email, bulk mark-as-lost) at the bottom for batch execution if the user requests it.