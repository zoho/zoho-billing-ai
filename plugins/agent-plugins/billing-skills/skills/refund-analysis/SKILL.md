---
name: refund-analysis
description: >
  Weekly refund anomaly digest: refund volume by product and country, spike detection,
  repeat-refund customers, and root-cause hypotheses. Use when the user asks about
  refunds, refund spikes, which products have high refund rates, or refund anomalies.
  Do NOT use for credit notes, payment failures, or churn analysis.
when_to_use: >
  Trigger on: "refund digest", "refund anomalies", "refund spike", "refund report",
  "which products have refunds", "refund analysis", "why are refunds up",
  "refund patterns", "unusual refunds".
argument-hint: "[period — e.g. 'last month' or 'this week']"
---

# Refund Digest

Surface refund anomalies, product/country spikes, and repeat-refund customers.
Notify-only — no write actions.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: last 30 days.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Refund_History_Report` | All refunds in period |
| 2 | `ZohoBilling_Get_Productwise_Refund_Report` | Refunds by product |
| 3 | `ZohoBilling_Get_Countrywise_Refund_Report` | Refunds by country |
| 4 | `ZohoBilling_Get_Refund_Policy_Details_Report` | Refund policy (to flag out-of-policy) |

## Anomaly detection

Flag as anomalous:
- Product refund rate > 10% of revenue for that product
- Country refund spike > 2× prior period for same country
- Customer with 3+ refunds in 90 days (repeat-refund pattern)
- Refund processed outside policy window (date > policy days after purchase)

## Output

```
Refund Digest — [Period]
Total refunds: $XX,XXX  ·  N transactions  ·  Refund rate: X.X% of revenue
────────────────────────────────────────────────────────────────────────────

BY PRODUCT (anomalies flagged ⚠)
  Product A       $X,XXX   N refunds   X.X% of revenue
  ⚠ Product B     $X,XXX   N refunds   14.2% of revenue  ← above 10% threshold

BY COUNTRY
  United States   $X,XXX   N refunds
  ⚠ Germany       $X,XXX   N refunds   2.8× prior period  ← spike

REPEAT-REFUND CUSTOMERS (3+ in 90 days)
  ⚠ Customer X    4 refunds · $X,XXX total · likely abuse pattern

OUT-OF-POLICY REFUNDS
  N refunds processed after policy window — flag for finance review

ROOT-CAUSE HYPOTHESES:
  • Product B spike: matches product launch on [date] — possible feature issue
  • Germany spike: investigate local payment / satisfaction issue
────────────────────────────────────────────────────────────────────────────
```

## Constraints

- Root-cause hypotheses are hypotheses — label them clearly as such
- Do not name specific amounts in hypotheses — focus on pattern description
- Propose-only: no refunds issued, no policy changes

## Edge cases

- Zero refunds in period: "No refunds in this period 🟢"
- Policy data unavailable: skip out-of-policy section with note
