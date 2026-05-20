---
name: dunning-cohort-builder
description: >
  Fetches every subscription currently in dunning from Zoho Billing, enriches each
  record with a composite priority score (weighted by amount at risk, LTV, lifetime
  duration, and retry count), then groups the cohort by gateway error code and error
  message. Output feeds directly into dunning-action-planner. Use when the user asks
  which subscriptions are in dunning, wants to see the current at-risk pipeline, or
  needs a scored and grouped cohort for downstream action planning.
---

# Dunning Cohort Builder

Fetch, score, and group all subscriptions currently in dunning for downstream action planning.

---

## Priority Scoring Rules

### Weights (must sum to 1.0)

| Component | Weight | What it measures |
|---|---|---|
| `amount` | 0.35 | `bcy_amount` at risk — primary revenue signal |
| `ltv` | 0.30 | Customer lifetime value |
| `ltd` | 0.20 | Lifetime duration in days — customer loyalty |
| `retry` | 0.15 | Retry count — higher retries = fewer chances left = more urgent |

### Customer tier thresholds

**LTV tiers (billing currency)**

| Tier | Condition |
|---|---|
| `high` | LTV ≥ 5000 |
| `medium` | LTV ≥ 1000 |
| `low` | LTV < 1000 |

**LTD tiers (days active)**

| Tier | Condition |
|---|---|
| `long_term` | LTD ≥ 365 |
| `standard` | LTD ≥ 90 |
| `new` | LTD < 90 |

A subscription is **high-value** if `ltv_tier == "high"` OR `ltd_tier == "long_term"`.

### Priority tier floors

| Tier | Label | Composite score floor | Override rule |
|---|---|---|---|
| P0 | Emergency | ≥ 75 | Also P0 if `retry_number ≥ 3` AND `is_high_value == true` |
| P1 | High | ≥ 50 | — |
| P2 | Medium | ≥ 25 | — |
| P3 | Low | < 25 | — |

---

## Step 0 — Setup

**Date scope**: Default to `RetryDate.ThisMonth`. Accept overrides from the user.

Announce before fetching:
> "Fetching all dunning subscriptions for **this month**. Want a different time window?"

If called by the orchestrator, accept scope directly — don't re-prompt.

---

## Step 1 — Fetch the dunning cohort

Call `ZohoBilling_get_subscriptions_dunning_report` with:

```json
{
  "query_params": {
    "filter_by": "RetryDate.ThisMonth",
    "per_page": 200,
    "page": 1,
    "sort_column": "bcy_amount",
    "sort_order": "D",
    "select_columns": [
      {"field": "subscription_number",    "group": "subscriptions"},
      {"field": "customer_name",          "group": "subscriptions"},
      {"field": "email",                  "group": "subscriptions"},
      {"field": "plan_name",              "group": "subscriptions"},
      {"field": "product_name",           "group": "subscriptions"},
      {"field": "bcy_amount",             "group": "subscriptions"},
      {"field": "fcy_amount",             "group": "subscriptions"},
      {"field": "ltv",                    "group": "subscriptions"},
      {"field": "ltd",                    "group": "subscriptions"},
      {"field": "retry_number",           "group": "subscriptions"},
      {"field": "next_retry_at",          "group": "subscriptions"},
      {"field": "gateway_error_code",     "group": "subscriptions"},
      {"field": "gateway_error_message",  "group": "subscriptions"},
      {"field": "invoice_number",         "group": "subscriptions"},
      {"field": "last_sent_date",         "group": "subscriptions"}
    ]
  }
}
```

Paginate while `has_more_page: true`, incrementing `page` by 1 each call. Collect all
records into a single flat list before scoring.

> If the org has multiple organisations, retrieve org ID via `list_organizations` first
> and pass it in the `X-com-zoho-subscriptions-organizationid` header.

---

## Step 2 — Normalise records

For each subscription record:

1. **`gateway_error_code`**: lowercase and trim. If empty or null → `"unknown"`.
2. **`gateway_error_message`**: trim. If empty or null → `"No error message returned"`.
3. **Numeric fields** (`bcy_amount`, `ltv`, `ltd`, `retry_number`): parse to numbers; treat null/missing as `0`.
4. **`next_retry_at`**: parse to date; compute `hours_until_next_retry` from now (negative if overdue).

---

## Step 3 — Compute priority scores

### Component scores (each 0–100)

Normalise against cohort maximums so scores stay in range. If a cohort max is 0, set all scores for that component to 0.

```
max_amount = max(bcy_amount) across all records
max_ltv    = max(ltv)         across all records
max_ltd    = max(ltd)         across all records
max_retry  = max(retry_number) across all records

score_amount(r) = (r.bcy_amount   / max_amount) * 100
score_ltv(r)    = (r.ltv          / max_ltv)    * 100
score_ltd(r)    = (r.ltd          / max_ltd)    * 100
score_retry(r)  = (r.retry_number / max_retry)  * 100
```

### Composite score

```
composite_score(r) = (0.35 × score_amount) + (0.30 × score_ltv) + (0.20 × score_ltd) + (0.15 × score_retry)
# Round to 1 decimal place
```

### Customer tier

Apply LTV and LTD thresholds from the rules table above.

`is_high_value = true` if `ltv_tier == "high"` OR `ltd_tier == "long_term"`.

### Priority tier

Apply in order:
1. If `composite_score ≥ 75` → **P0**
2. If `retry_number ≥ 3` AND `is_high_value == true` → **P0** (override)
3. If `composite_score ≥ 50` → **P1**
4. If `composite_score ≥ 25` → **P2**
5. Otherwise → **P3**

---

## Step 4 — Group by gateway error code

### Error groups

Group by normalised `gateway_error_code`. For each group compute:

| Field | Value |
|---|---|
| `error_code` | normalised gateway_error_code |
| `error_messages` | distinct gateway_error_message values in the group |
| `subscription_count` | count |
| `total_bcy_amount` | sum of bcy_amount |
| `avg_ltv` | mean ltv |
| `avg_ltd` | mean ltd |
| `p0_count` | count where priority_tier == "P0" |
| `p1_count` | count where priority_tier == "P1" |
| `high_value_count` | count where is_high_value == true |
| `max_retry` | max retry_number |
| `subscriptions` | full list, sorted by composite_score DESC |

Sort groups by `total_bcy_amount` DESC.

### Cohort summary

```
total_subscriptions   count of all records
total_bcy_at_risk     sum of all bcy_amount
p0_count              …by priority_tier
p1_count
p2_count
p3_count
high_value_at_risk    count where is_high_value == true
dominant_error_code   error_code with highest subscription_count
dominant_error_pct    (dominant group count / total) × 100
```

---

## Step 5 — Emit cohort output

Print a brief diagnostic:

```
Dunning cohort built: <total_subscriptions> subscriptions | <total_bcy_at_risk> at risk
P0: <n> | P1: <n> | P2: <n> | P3: <n> | High-value at risk: <n>
Top error code: <dominant_error_code> (<dominant_error_pct>%)
```

Then pass the structured cohort JSON to the action planner.

---

## Edge Cases

- **Empty cohort**: print "No subscriptions currently in dunning for the selected period." and stop.
- **`ltv` = 0 for all records**: set all `score_ltv = 0`; note in diagnostic.
- **`retry_number` = 0 for all**: set all `score_retry = 0`; note in diagnostic.
- **Pagination > 10 pages**: warn "Large cohort — paginating through all records" and continue.
