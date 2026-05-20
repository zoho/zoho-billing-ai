---
name: quote-acceleration
description: Analyzes all open quotes, ranks by expected close value, identifies stalled/dead deals using staleness scoring. Recommends next moves (follow-up, discount, convert, mark lost) for human review and execution.
---

# Quote Acceleration

Rank your open quotes by revenue impact and identify which deals need attention this week.

## What It Does

Analyzes all open quotes to:
- Calculate **staleness score** (0.0 = fresh, 1.0 = dead) from activity, age, follow-ups, customer history, and lost patterns
- Rank by **expected close value** = quote amount × probability of close
- Recommend **next action**: follow-up email, discount, convert to invoice, or mark lost
- Flag **stalled deals** (staleness > 0.7) and **dead deals** (staleness > 0.9) for intervention

## The Output

Markdown worklist ranked by revenue impact showing customer name, quote amount, days open, staleness score, expected close value, and recommended action.

Status flags: ✅ Accepted (convert now), ⚠️ Stalled (needs push), ☠️ Dead (mark lost)

## Common Invocations

- "Show me open quotes"
- "Which deals are stalling?"
- "Prioritize quotes for today"
- "Quote follow-up list"
- "What should sales work on today?"
- "Any quotes going cold?"

## Propose-Only Approach

✓ This skill analyzes and recommends
✗ This skill never modifies quotes, sends emails, or applies changes

All outputs are Markdown proposals for your team to review and execute in Zoho Billing.

See `references/output-format.md` and `references/workflow-details.md` for detailed examples and staleness algorithm.
