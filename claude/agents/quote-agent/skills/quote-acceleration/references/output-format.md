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

## Output Rules

1. **Show amounts in base currency** (USD, EUR, INR, etc.)
2. **Sort strictly by Expected Close Value descending** (highest revenue potential first)
3. **Keep reasoning concise** — max 2 sentences
4. **Use status flags**: ✅ Accepted, ⚠️ Stalled (0.7–0.9), ☠️ Dead (>0.9)
5. **Group actions** if user requests batch operations
