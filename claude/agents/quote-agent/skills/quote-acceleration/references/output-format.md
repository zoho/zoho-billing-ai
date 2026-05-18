# Output Format Reference

## Executive Summary

```
📊 Quote Acceleration Worklist — May 18, 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total open quotes        : 47
Total pipeline value     : $1,250,000
Estimated closeable      : $892,500 (71% at current staleness)
Stalled deals (>0.7)     : 12 ($185,000)
Dead deals (>0.9)        : 5 ($42,000)
Avg days open            : 18 days
```

## Ranked Worklist Table

| # | Customer | Quote # | Amount | Days Open | Last Activity | Staleness | Expected Close Value | Reasoning | Action |
|---|---|---|---|---|---|---|---|---|---|
| 1 | ✅ Acme Corp | QT-5823 | $150,000 | 8 | Accepted 2 days ago | 0.0 | $150,000 | Customer accepted quote. Ready to convert. | **Convert to invoice** |
| 2 | TechStart Inc | QT-5901 | $87,500 | 5 | Sent 5 days ago | 0.15 | $74,375 | Fresh quote, in conversation with prospect. Allow more time. | No action (yet) |
| 3 | Global Services | QT-5847 | $125,000 | 12 | Follow-up opened 2 days ago | 0.35 | $81,250 | Sent 12 days ago, customer opened follow-up email. Engaged. | Send follow-up email |
| 4 | ⚠️ DataFlow Systems | QT-5789 | $95,000 | 22 | Quote viewed 8 days ago | 0.62 | $36,100 | 22 days old, 1 follow-up, customer has 50% conversion rate. Stalled. | **Apply 7% discount** |
| 5 | MidMarket Solutions | QT-5756 | $64,000 | 18 | Emailed follow-up 9 days ago | 0.58 | $26,880 | 18 days old, customer converts 4 of 7 quotes. Needs push. | Send follow-up email |
| 6 | ☠️ Old Industries | QT-5401 | $42,000 | 45 | Quote created 45 days ago | 0.95 | $2,100 | 45 days with zero activity. Customer never engaged. Dead deal. | **Mark as lost** |

## Reasoning Cell Examples

Each row's "Reasoning" column briefly explains the staleness score:

- *"Sent 14 days ago, no response to 2 follow-ups. Customer converted 3 of 5 past quotes. High value — worth a concession."*
- *"Created 35 days ago, one follow-up 20 days ago, customer converts 1 of 4 quotes. Low engagement, declining probability."*
- *"Just sent yesterday, customer is actively evaluating. Still in evaluation window."*
- *"Sent 8 days ago but matches pattern of a customer segment that churned 90% of the time. High-risk profile."*
- *"Sent to new customer (first interaction). No historical data to assess conversion probability. Assume average."*

## Output Rules

1. **Always show amounts in base currency** (e.g., USD, EUR, INR)
2. **Sort strictly by Expected Close Value descending** (highest revenue potential first)
3. **Keep reasoning concise** — max 2 sentences per row
4. **Use status flags**:
   - ✅ **Accepted quotes** appear at the top with green checkmark
   - ⚠️ **Stalled quotes** (staleness 0.7–0.9) flagged with warning
   - ☠️ **Dead quotes** (staleness > 0.9) flagged with skull
5. **Group actions at bottom** if user requests batch operations (e.g., "Email all stalled quotes", "Mark all dead deals as lost")

## Example Recommendations Section

### High-Priority Actions

These quotes need attention this week:

1. **Convert Acme Corp (QT-5823)** — $150,000, accepted quote ready to close
2. **Apply discount to DataFlow Systems (QT-5789)** — $95,000, stalled 22 days, send 7% concession
3. **Follow up with MidMarket Solutions (QT-5756)** — $64,000, 18 days old, customer is warm

### Clean-Up Actions

These quotes should be marked lost:

1. **Old Industries (QT-5401)** — $42,000, 45 days no activity, zero engagement
2. **Discontinued LLC (QT-5102)** — $18,500, 52 days, customer never opened quote

### Consolidation Opportunities

These customers have multiple open quotes — review for upsell:

1. **TechStart Inc** — 3 open quotes totaling $250,000 (separate products, but same buyer)
