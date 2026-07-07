# MRR Growth — Output Format

## Waterfall table

```
MRR Waterfall — May 2026 vs Apr 2026
──────────────────────────────────────────────────────────────
Component          May 2026      Apr 2026          Δ        Δ%
──────────────────────────────────────────────────────────────
Previous MRR      $142,300      $138,100       +$4,200    +3.0%
  + New            +$18,500      +$16,200       +$2,300   +14.2%
  + Expansion       +$6,200       +$5,100       +$1,100   +21.6%
  + Reactivation    +$1,400          +$800         +$600  +75.0%
  − Contraction     −$4,100       −$3,600         −$500   +13.9%
  − Churn           −$9,800      −$14,200       +$4,400   −31.0%
──────────────────────────────────────────────────────────────
Net MRR           $154,500      $142,300      +$12,200    +8.6%
──────────────────────────────────────────────────────────────

Health: 🟢 Green — Net positive. New MRR ($18.5k) > Churn MRR ($9.8k).
Biggest driver: New MRR +$18.5k · Biggest drag: Churn −$9.8k
MoM change: +$12,200 (+8.6%)
```

## Health classification

| Condition | Call |
|---|---|
| Net MRR positive AND New MRR ≥ Churn MRR | 🟢 Green |
| Net MRR positive BUT Churn MRR > New MRR (expansion carrying the growth) | 🟡 Yellow |
| Net MRR negative OR Churn MRR > New + Expansion combined | 🔴 Red |

## Discount-leakage flag (add when triggered)

```
⚠ Discount leakage: Gross MRR ($X) exceeds Net MRR ($Y) by Z%.
  Run /discount-mrr-cleanup for a list of stale coupons to review.
```

Trigger threshold: gross MRR > net MRR by more than 20%.
