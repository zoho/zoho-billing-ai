---
name: card-expiry-detector
description: Flags subscriptions with payment cards expiring within 30 days to enable proactive payment method updates. Propose-only output for human review.
---

# Card Expiry Detector

Proactively identify customers whose payment cards are expiring soon.

## What It Does

Scans card expiration dates in your Zoho Billing data and flags subscriptions at risk:

- **Expiring This Month** — card expires within the next 30 days
- **Expired Last Month** — card already expired (high failure risk on next renewal)
- **Expiring Next Month** — card expires in 30-60 days (advance notice)

## The Output

A flagged customer table showing:
- **Subscription Number** — Zoho ID
- **Customer Name** — Customer identifier
- **Card Type** — Visa, Mastercard, etc.
- **Last Four Digits** — for customer identification
- **Expiry Date** — when the card expires
- **Days Until Expiry** — countdown to expiration
- **Plan Renewal Date** — next scheduled billing date
- **Risk Level** — high (renewal date < expiry date) or medium (time to update)

### Segmented by Urgency

- Expired cards first (immediate action needed)
- Then expiring this month
- Then expiring next month

## Decision Matrix Integration

The flagged customers from this detector feed into **Recovery Recommender**, which applies your decision matrix to recommend proactive outreach (e.g., "notify_payment_update_required" or "remind_card_expiry").

## Propose-Only Approach

✓ **This skill identifies expiring cards and flags them**
✗ **This skill never:**
  - Sends emails to customers
  - Suspends subscriptions automatically
  - Deletes payment methods
  - Modifies subscription status

All flagged customers are presented as data for human review and action planning.

## Common Invocations

- *"Check for cards expiring soon"*
- *"Show me which customers need payment method updates"*
- *"Flag cards expiring in the next 30 days"*
- *"Which subscriptions are at risk due to card expiry?"*
