---
name: churn-breakdown
description: >
  Decompose churn into voluntary (customers who chose to leave) vs involuntary
  (failed payments) and identify which plans and products are driving losses.
  Use when the user asks why customers are churning, churn composition, voluntary
  vs involuntary split, or which products have the highest cancellation rate.
  Do NOT use for MRR, NRR, or retention rate questions.
when_to_use: >
  Trigger on: "churn breakdown", "why are we losing customers", "churn composition",
  "voluntary churn", "involuntary churn", "what's driving churn", "cancellation analysis",
  "which plans are churning", "churn by product".
argument-hint: "[period — e.g. 'last quarter' or 'this month']"
---

# Churn Breakdown

Decompose churn into voluntary vs involuntary, surface the top churning
plans/products, and route findings to the owning team.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default period: this month. Accept `$ARGUMENTS` overrides.

## Fetch (run all calls in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Churn_Breakdown_Report` | Total churn split by type |
| 2 | `ZohoBilling_Get_Voluntary_Churn_Report` | Voluntary churn trend |
| 3 | `ZohoBilling_Get_Voluntary_Churn_Details_Report` | Per-customer voluntary reasons |
| 4 | `ZohoBilling_Get_Involuntary_Churn_Report` | Involuntary churn trend |
| 5 | `ZohoBilling_Get_Involuntary_Churn_Details_Report` | Per-sub dunning failures |
| 6 | `ZohoBilling_Get_Churn_After_Retries_Report` | Churn that exhausted retry attempts |
| 7 | `ZohoBilling_Get_Productwise_Cancellations_Report` | Cancellations by product/plan |

## Output

**Section 1 — Churn composition**
Table: Total churned MRR · Voluntary $ and % share · Involuntary $ and % share · Churn-after-retries $ and % share.

**Section 2 — Top churning plans (top 5 by cancellations)**
Rank by cancellation volume. Show: plan name · cancellations · churned MRR.

**Section 3 — Team routing**
- Involuntary share > 30% of total → flag as **Payment Operations** problem, not Product
- Voluntary concentrated in 1–2 plans → flag as **Product** problem for those plans
- Churn-after-retries volume rising → flag **dunning rules need review**

**Section 4 — Health call**
🟢 Churn rate low and balanced · 🟡 Involuntary > 30% or single-plan concentration · 🔴 Net MRR negative or churn > new + expansion

## Constraints

- Compute involuntary share = involuntary_churn_mrr / total_churn_mrr × 100
- Never attribute payment failures to product problems — route them separately
- Propose-only: no subscription or dunning changes

## Edge cases

- If involuntary data returns empty, note "No involuntary churn data — payment mode may be offline-only"
- If all churn is concentrated in one plan (>70%), bold that plan name in output
