---
name: churn-cohort-builder
description: Build the retention cohort — at-risk (non-renewing) or recently churned subscriptions normalized with cancel reason, LTV, LTD, plan, and MRR. Use for any request to pull cohort data before a retention run.
---

# Churn Cohort Builder

Assembles the retention cohort from Zoho Billing reports. Two types:
- **Pre-churn** — non-renewing subscriptions (still active, scheduled to cancel at cycle end).
- **Post-churn** — recently cancelled subscriptions (last 7 days, win-back candidates).

## Output schema

| Field | Source |
|---|---|
| `subscription_id`, `customer_id`, `customer_name` | report row |
| `plan_code`, `plan_name` | report row |
| `mrr` | `recurring_amount` normalized to monthly (annual ÷ 12, quarterly ÷ 3) |
| `currency`, `country` | report row; `"Unknown"` if absent |
| `cancel_reason_raw` | free-text from report — classifier buckets it later |
| `cancellation_date` | scheduled end date (pre-churn) or actual cancel date (post-churn) |
| `ltv` | report field; default `0` + flag `ltv_unavailable: true` if missing |
| `ltd` | report field (days); compute from `activated_at` if absent; `0` + `ltd_unavailable: true` if both absent |
| `cohort` | `"pre_churn"` or `"post_churn"` |

## Workflow

**0. Verify tools** — before any API calls, confirm these tools are available in the session:
- `ZohoBilling_get_non_renewing_subscriptions_report`
- `ZohoBilling_get_churned_subscriptions_report`
- `ZohoBilling_list_organizations`

If any are missing, stop and tell the user: "The Zoho Billing connector is connected but the tool `<name>` is not enabled. Go to Settings → Connectors → Zoho Billing → enable that tool, then retry."

**1. Get org ID** — call `list_organizations` if unknown; ask if multiple exist (never guess).

**2. Pull reports** — run in parallel if both cohorts needed:
- Pre-churn: `ZohoBilling_get_non_renewing_subscriptions_report`
  `from_date: today`, `to_date: today+30`, `per_page: 100`, `page: 1` — paginate while `has_more_page: true`.
- Post-churn: `ZohoBilling_get_churned_subscriptions_report`
  `from_date: today-7`, `to_date: today`, `per_page: 100`, `page: 1` — paginate same way.

  Always use `per_page: 100` — the API default of 25 multiplies round-trips 4×.

**3. Normalize rows** to the output schema. Pass missing cancel reasons through as empty string.

**4. Write output:**
```
<workspace>/retention-runs/<YYYY-MM-DD>/cohort-<pre_churn|post_churn>.json
```
Print a one-line headline (N subs, total MRR at risk) and a 10-row preview table. Note any `ltv_unavailable` / `ltd_unavailable` rows.

## Edge cases
- **Empty cohort** → state it explicitly; don't widen the window without asking.
- **Same sub in both cohorts** → deduplicate by `subscription_id`, keep post-churn.
- **Non-monthly billing** → normalize or flag the row.
- **Missing cancel reason** → pass through as `""` — classifier will bucket as `unknown`.
