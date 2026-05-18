---
description: Analyzes all open quotes, ranks by expected close value, identifies stalled/dead deals using staleness scoring. Recommends next moves (follow-up, discount, auto-convert, mark lost) with propose-only output for human review.
---

# Quote Acceleration

Keep your sales pipeline healthy by identifying which quotes need attention and what action to take next.

## What It Does

Analyzes your open quotes and estimates to:

- **Rank by Close Probability** — Scores each quote's staleness (0.0 = fresh, 1.0 = dead) based on days since activity, quote age, follow-up history, customer conversion rate, and match to lost deal patterns
- **Calculate Expected Close Value** — Multiplies quote amount by probability of close (1.0 − staleness) to prioritize by revenue impact
- **Flag Stalled Deals** — Highlights quotes with staleness > 0.7 (likely to be lost without intervention)
- **Flag Dead Deals** — Highlights quotes with staleness > 0.9 (should be marked lost to clean pipeline)
- **Recommend Actions** — Suggests specific next move for each quote: send follow-up email, apply a concession, auto-convert if accepted, or mark as lost

## The Output

A ranked worklist showing:

- **Quote Rank** — Ordered by expected close value (highest revenue potential first)
- **Customer Name** — Who the quote is for
- **Quote Amount** — Deal size
- **Days Open** — How long the quote has been in the system
- **Last Activity** — When customer or sales rep last touched it
- **Staleness Score** — 0.0 (fresh) to 1.0 (dead), based on multiple signals
- **Expected Close Value** — Quote amount × probability of close
- **Reasoning** — Brief explanation of why this score (e.g., "Sent 14 days ago, no response to 2 follow-ups, customer has 60% conversion rate")
- **Recommended Action** — What to do next (see below)

### Status Flags

- ✅ **Accepted** — Quote marked accepted by customer → Convert to invoice immediately
- ⚠️ **Stalled** — Staleness > 0.7 → High-risk, needs urgent intervention
- ☠️ **Dead** — Staleness > 0.9 → Likely lost, recommend marking as declined

### Recommended Actions

| Condition | Action | Why |
|-----------|--------|-----|
| Quote accepted | Convert to invoice | Customer has said yes |
| Staleness < 0.3, sent < 7 days | No action | Still fresh, give time |
| Staleness 0.3–0.5, no follow-up in 7 days | Send follow-up email | Gentle reminder with payment link |
| Staleness 0.5–0.7, high-value | Apply discount | Offer concession (5–10%) to accelerate |
| Staleness 0.5–0.7, low-value | Send follow-up email | Last-chance reminder |
| Staleness 0.7–0.9, customer responsive | Send follow-up email | Direct ask for decision with deadline |
| Staleness > 0.9, no activity 30+ days | Mark as lost | Clean pipeline, stop pursuing |
| Multiple quotes per customer | Flag for consolidation | Review account for upsell opportunity |

## The Workflow

1. **Fetch all open quotes** — Pull from Zoho Billing (Status: Draft, Sent, or Accepted)
2. **Assess conversion history** — Understand which customers convert from quotes and how quickly
3. **Analyze lost quotes** — Identify patterns in deals that died (age, value, customer type)
4. **Score staleness** for each quote based on:
   - Days since last activity (35% weight)
   - Days since created (25% weight)
   - Number of follow-ups without response (15% weight)
   - Customer's historical conversion rate (15% weight)
   - Similarity to lost opportunities (10% weight)
5. **Rank by expected close value** — Sort quotes by (Amount × (1.0 − staleness)) descending
6. **Generate recommendations** — Assign next action based on staleness tier and quote value
7. **Present worklist** — Show ranked table with executive summary and one-click actions

## Common Invocations

- *"Show me open quotes"*
- *"Which deals are stalling"*
- *"Prioritize quotes"*
- *"Quote follow-up list"*
- *"What should sales work on today?"*
- *"Any quotes going cold?"*

## Staleness Algorithm

Staleness is calculated on a scale of 0.0 (fresh) to 1.0 (dead). Each signal contributes a weighted score:

| Signal | Weight | Logic |
|--------|--------|-------|
| Days since last activity | 35% | >14 days = stale, >30 days = critical |
| Days since quote created | 25% | Older quotes have lower close probability |
| Follow-ups without response | 15% | More rejections = higher staleness |
| Customer's conversion rate | 15% | Customers who rarely convert = higher staleness |
| Similarity to lost deals | 10% | Matches patterns of failed quotes = higher staleness |

**Example:** A quote sent 25 days ago with no response, where the customer converts 1 of 5 quotes, and matches a lost deal pattern would score: 0.80–0.85 (stalled).

## Propose-Only Approach

✓ **This skill analyzes and ranks quotes**
✗ **This skill never:**
  - Sends emails to customers
  - Applies discounts or concessions
  - Converts quotes to invoices
  - Marks quotes as lost or accepted
  - Modifies any quote data

All recommendations are presented as a Markdown worklist for human review. Your sales team reviews the analysis, approves the recommendations, and executes actions in Zoho Billing.

### Why Propose-Only?

✓ **Full control** — Sales rep sees every recommendation before acting
✓ **Context awareness** — Rep can factor in customer relationships and ongoing conversations
✓ **Flexibility** — Discount amounts and follow-up messaging can be tailored per customer
✓ **Auditability** — Clear record of what was recommended vs. what was executed

## Edge Cases Handled

- **No open quotes** → Report "Pipeline is empty—review lead generation"
- **Quote with no activity history** → Assign staleness based on creation date only; flag as "Limited data"
- **Customer with no prior quotes** → Use organization-wide average conversion rate
- **Quote amount is zero** → Exclude from ranking; flag for data cleanup
- **Multiple quotes per customer** → Group together; flag for consolidation and upsell opportunity
- **Quote in draft (never sent)** → Recommend "Send quote" as primary action
- **API unavailable** → Proceed with available data, note missing sources, adjust confidence

## Output Format

See `references/output-format.md` for detailed examples of the executive summary and ranked worklist table.

See `references/workflow-details.md` for the complete 7-step workflow with examples.
