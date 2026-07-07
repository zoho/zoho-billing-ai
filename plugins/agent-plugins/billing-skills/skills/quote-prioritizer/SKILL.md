---
name: quote-prioritizer
description: >
  Rank all open quotes by staleness and expected close value, then recommend the
  next move per quote. Use when the user asks about open quotes, stalled deals,
  which quotes to follow up, or the sales pipeline status.
  Do NOT use for accepted/closed quotes or invoice creation.
when_to_use: >
  Trigger on: "open quotes", "quotes pipeline", "stalled deals", "quote follow-up",
  "which quotes to work", "quote status", "deals going cold", "sales pipeline",
  "quote priority list".
---

# Quotes Pipeline

Rank open quotes by revenue impact and surface which deals need attention.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Estimate_Details_Report` | All open quotes with details |
| 2 | `ZohoBilling_Get_Lost_Opportunities_Report` | Lost deal patterns (for staleness context) |
| 3 | `ZohoBilling_List_all_Quotes` | Live quote list with status |

## Staleness scoring (0.0 = fresh, 1.0 = dead)

```
base: 0.0
  + Days since last activity / 30          (capped at 0.5)
  + Days open / 90                         (capped at 0.3)
  + Expiry date passed                     → +0.3
  − Customer has active subscription       → −0.1 (warm account)
```

Expected close value = quote_amount × (1 − staleness_score)

## Output

```
Quotes Pipeline — [date]   (N open quotes · $XXX,XXX pipeline value)
────────────────────────────────────────────────────────────────────────────────
 #  Customer           Amount    Days open  Staleness  Exp. close  Action
────────────────────────────────────────────────────────────────────────────────
 1  Hot Deal Corp      $12,000   4d         0.12       $10,560     📧 Follow-up
 2  Warm Prospect Ltd  $ 4,500   18d        0.41       $ 2,655     📞 Call + discount?
 3  Stalled Co         $ 8,200   45d        0.72   ⚠   $ 2,296     🤝 Concession or close
 4  Dead Deal Inc      $ 3,100   87d        0.91   ☠   $   279     ☠ Mark lost
────────────────────────────────────────────────────────────────────────────────
⚠ Stalled (>0.7): N quotes  ·  ☠ Dead (>0.9): N quotes
```

**Recommended actions:**
- Staleness < 0.4: 📧 Follow-up email
- Staleness 0.4–0.7: 📞 Phone call, consider small concession
- Staleness 0.7–0.9: ⚠ Urgent intervention — discount or restructure
- Staleness > 0.9: ☠ Mark as lost and close

## Constraints

- "Open" quotes only — exclude accepted, declined, expired
- Sort by expected close value descending within staleness bands
- Propose-only: no quotes modified, no emails sent

## Edge cases

- Zero open quotes: "No open quotes in the pipeline"
- All quotes < 0.3 staleness: "Pipeline looks fresh — no urgent follow-ups needed 🟢"
