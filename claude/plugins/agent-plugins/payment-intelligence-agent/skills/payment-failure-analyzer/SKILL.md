---
name: payment-failure-analyzer
description: Analyzes payment failures from a date range, categorizes by error type and gateway, identifies systemic issues. Propose-only analysis for human review.
---

# Payment Failure Analyzer

Understand why payments are failing and identify patterns and systemic issues.

## What It Does

Analyzes payment failures from your Zoho Billing data and categorizes them:

- **By Error Type** — card_expired, insufficient_funds, gateway_declined, processing_error, etc.
- **By Payment Gateway** — Stripe, PayPal, Razorpay, etc.
- **By Failure Frequency** — which error types occur most often
- **By Impact** — total revenue at risk from each error category

## The Output

A failure analysis report showing:
- **Error Type** — canonical error category
- **Failure Count** — number of times this error occurred
- **Affected Customers** — number of unique customers impacted
- **Total Amount at Risk** — revenue from failed transactions
- **Gateway** — which payment processor returned the error
- **Common Reasons** — detailed error messages from gateway
- **Trend** — increasing, stable, or decreasing over time

### Segmented by Severity

- Systemic issues first (affecting many customers or high revenue)
- Then individual failure types
- Then by gateway (to identify integration problems)

## Decision Matrix Integration

Failure analysis findings inform **Recovery Recommender** decision matrix strategies:
- High volume "card_expired" errors → suggest proactive expiry notifications
- Rising "insufficient_funds" errors → suggest pause subscription option
- Gateway-specific issues → escalate to "manual_triage"

## Propose-Only Approach

✓ **This skill analyzes and categorizes failures**
✗ **This skill never:**
  - Retries payments automatically
  - Applies refunds or credits
  - Suspends subscriptions
  - Notifies customers

All findings are presented as analysis data for human decision-making.

## Common Invocations

- *"Analyze recent payment failures"*
- *"What's causing the most payment failures?"*
- *"Show me payment failures from the last 30 days"*
- *"Which payment gateway has the highest failure rate?"*
- *"Are we seeing more payment failures this week?"*
