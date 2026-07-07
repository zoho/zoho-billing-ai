---
name: expansion-opportunities
description: >
  Identify customers underpriced for their actual usage — hitting addon limits,
  sustained high utilisation, or buying repeated one-time charges — and propose
  plan upgrades with supporting evidence. Use when the user asks about upsell
  opportunities, upgrade candidates, or revenue expansion from existing customers.
  Do NOT use for new customer acquisition or cross-sell of unrelated products.
when_to_use: >
  Trigger on: "upsell opportunities", "upgrade candidates", "who should upgrade",
  "expansion revenue", "customers outgrowing their plan", "upsell candidates",
  "usage-based upgrades", "which customers to upsell".
---

# Upsell Candidates

Surface customers whose usage signals they've outgrown their current plan.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Usage_Record_Report` | Usage per subscription |
| 2 | `ZohoBilling_Get_Usage_Record_Details_Report` | Detailed usage breakdown |
| 3 | `ZohoBilling_Get_Sales_Details_by_Addon_Report` | Repeated addon purchases per customer |
| 4 | `ZohoBilling_Get_Subscriptions_Report` | Current plan for each sub |
| 5 | `ZohoBilling_List_all_Plans` | All available plans (for upgrade targets) |

## Scoring signals

Flag a subscription as an upsell candidate if ANY of:
- Usage > 80% of plan limit for 2+ consecutive periods
- Same addon purchased 3+ times (indicates persistent need)
- Usage growth > 30% MoM for 2+ months
- Seat/user count within 2 of plan maximum

## Output

```
Upsell Candidates — [date]   (N candidates · $XX,XXX expansion MRR potential)
────────────────────────────────────────────────────────────────────────────────
 #  Customer           Current Plan     Signal                  Target Plan
────────────────────────────────────────────────────────────────────────────────
 1  Acme Corp          Starter ($79)    Usage 94% · 3 mo trend  Professional ($199)
 2  Beta Inc           Pro ($199)       Storage addon ×5        Enterprise ($499)
 3  Startup XYZ        Starter ($79)    Seats: 8/10             Pro ($199)
────────────────────────────────────────────────────────────────────────────────
Total expansion MRR if all convert: $XX,XXX/month
```

Per row: customer · current plan + price · signal · recommended target plan.
"Signal" should be specific and evidence-based — not generic.

## Constraints

- Only propose a plan that actually exists (from List_all_Plans results)
- Do not recommend downgrade — this skill is upsell only
- Expansion MRR estimate = target_plan_price − current_plan_price per candidate
- Propose-only: no quotes created, no plan changes

## Edge cases

- No usage data available: "Usage data not available — enable usage tracking in Zoho Billing to use this skill"
- No candidates found: "No clear upsell signals detected — all customers appear well-matched to their plans"
