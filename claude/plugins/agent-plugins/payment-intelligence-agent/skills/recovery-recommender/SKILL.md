---
name: recovery-recommender
description: Recommends targeted recovery actions for at-risk subscriptions based on failure reason and risk level. Uses decision matrix configuration to tune strategies. Produces propose-only Markdown report for human review.
---

# Recovery Recommender

Analyze at-risk subscriptions and recommend recovery actions using your company's decision matrix.

## How It Works

1. **Pulls at-risk data** from dunning-risk-assessor output
2. **Applies decision matrix** (config/decision-matrix.yaml) to map:
   - Risk tier (critical, high, medium, low)
   - Payment failure type (card_expired, insufficient_funds, gateway_declined, etc.)
   - → Recommended action + incentive + success probability
3. **Produces propose-only Markdown report** for human review and approval

## What You Get

A recovery strategy table with columns:
- **Subscription Number** — Zoho subscription ID
- **Customer Name** — Customer identifier
- **Risk Tier** — critical | high | medium | low
- **Recommended Action** — e.g., "Update Payment Method", "Offer Pause Option", "Manual Triage"
- **Failure Type** — e.g., "card_expired", "insufficient_funds"
- **Incentive** — if applicable (e.g., 5% discount, 1 free month)
- **Success Probability** — based on risk tier (critical: 30%, high: 45%, medium: 60%, low: 75%)
- **Urgency Level** — immediate | critical | high | medium | low

### Grouped by Action Type

Results are organized by recommended action for easy batch implementation:
- All "Update Payment Method" customers first
- Then "Retry Payment" customers
- Then "Manual Triage" escalations
- Etc.

## Tuning Strategies

Edit `config/decision-matrix.yaml` to adjust:
- **Success probabilities** for each risk tier
- **Recovery actions** for each failure type
- **Incentive amounts** (discounts, free months, etc.)
- **Thresholds** for LTV/LTD segmentation

The recommender reads your decision matrix at each run — no code changes needed.

## Propose-Only Approach

✓ **This skill produces recommendations only** — all outputs are Markdown proposals for human review
✗ **This skill never:**
  - Sends emails to customers
  - Applies discounts or credits directly
  - Pauses or downgrades subscriptions
  - Modifies any data in Zoho Billing

All suggested actions require explicit human approval before implementation.

## Common Invocations

- *"What recovery actions should we take for at-risk customers?"*
- *"Generate a recovery strategy for next week"*
- *"What's the success probability for each at-risk subscription?"*
- *"Which customers need manual triage?"*
