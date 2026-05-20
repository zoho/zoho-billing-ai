---
name: dunning-risk-assessor
description: Identifies subscriptions currently in dunning status or at risk of entering dunning soon, segments by risk level for targeted recovery. Output feeds into decision matrix for recovery strategy recommendations.
---

# Dunning Risk Assessor

Identify and segment at-risk subscriptions by dunning status and predicted churn risk.

## What It Does

Scans your Zoho Billing data and classifies subscriptions into risk tiers:

- **Critical** — Will likely churn within 7 days (3+ failed payment attempts)
- **High** — Will likely churn within 14 days (2 failed payment attempts)
- **Medium** — Will likely churn within 30 days (1 failed payment attempt + expired card)
- **Low** — Minor payment friction but recoverable (single soft decline or expiring card)

## The Output

A risk segmentation table showing:
- **Subscription Number** — Zoho ID
- **Customer Name** — Customer identifier
- **Risk Tier** — critical | high | medium | low
- **Days Until Churn** — estimated time to involuntary cancellation
- **LTV** (Lifetime Value) — total revenue from customer
- **LTD** (Lifetime Duration) — days as active customer
- **Latest Failure** — most recent payment failure reason
- **Retry Count** — number of automated retry attempts so far

### Results Grouped by Risk Tier

- Critical subscriptions first (highest priority)
- Then high, medium, low (escalating priority)

## Used By Recovery Recommender

Output from this skill feeds directly into the **Recovery Recommender**, which applies your company's decision matrix to recommend specific recovery actions per subscription.

## Propose-Only Approach

✓ **This skill identifies and classifies subscriptions only**
✗ **This skill never:**
  - Modifies subscription status
  - Applies retries automatically
  - Cancels subscriptions
  - Changes customer data

All findings are presented as classification data for downstream decision-making.

## Common Invocations

- *"Which subscriptions are in dunning status right now?"*
- *"Show me all critical-risk subscriptions"*
- *"How many subscriptions are at risk this week?"*
- *"Give me the high-risk customers that need outreach"*
