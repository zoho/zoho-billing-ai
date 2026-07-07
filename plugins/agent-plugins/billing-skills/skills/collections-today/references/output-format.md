# Collections Today — Output Format

## Worklist table

```
Collections Today — Jun 29, 2026
Total overdue: $312,450  ·  Top 20 shown  ·  Est. recoverable: $187,200
─────────────────────────────────────────────────────────────────────────────
 #   Customer              Invoice     Amount    Days   Score   Action
─────────────────────────────────────────────────────────────────────────────
 1   Acme Corp             INV-10045   $48,200    31d   0.82   📧 Email invoice
 2   Northwind Traders     INV-10089   $31,500    45d   0.71   📞 Phone call
 3   Globex Industries     INV-10102   $22,750    22d   0.68   📧 Email invoice
 4   Initech LLC           INV-10071   $18,300    67d   0.51   🔗 Payment link
 5   Soylent Co.           INV-10033   $12,900    92d   0.28   💳 Apply credits / Escalate
...
─────────────────────────────────────────────────────────────────────────────
```

## Action legend

| Icon | Action | When to use |
|---|---|---|
| 📧 Email invoice | Resend invoice with payment link | Score > 0.7, < 30 days overdue |
| 📞 Phone call | Direct call to AP contact | Score 0.4–0.7, 30–60 days |
| 🔗 Payment link | Send standalone payment URL | Score 0.4–0.7, 60+ days |
| 💳 Apply credits | Apply available credits first | Credits on account |
| ⚠ Escalate | Flag for senior review | Score < 0.3, 90+ days |
