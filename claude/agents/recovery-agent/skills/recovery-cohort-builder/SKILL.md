---
name: recovery-cohort-builder
description: Build the recovery cohort by fetching the last 7 days of lost opportunities and abandoned carts from Zoho Billing. Normalizes both sources into a unified JSON array sorted by lost_value DESC — lost opportunities first (higher intent), then abandoned carts. Use this skill whenever you need to pull fresh data before a recovery run, or any time someone asks "what leads or carts did we lose this week?", "show me what we need to recover", or "build the recovery list".
---

# Recovery Cohort Builder

Fetches two Zoho Billing reports — **Lost Opportunities** and **Abandoned Carts** — for the last 7 days, normalizes them into a unified schema, and sorts by `lost_value` DESC. Lost opportunities are fetched first (earlier in the output) because they represent higher-funnel intent worth investigating separately; abandoned carts follow.

The output is a single JSON file ready for the `recovery-strategy` skill to process.

## Output schema (one object per lead/cart)

```json
{
  "source":             "lost_opportunity | abandoned_cart",
  "record_id":          "API-provided ID",
  "customer_name":      "string | null",
  "email":              "string | null",
  "plan_name":          "string | null",
  "lost_value":         123.45,
  "currency":           "USD",
  "days_since_event":   3,
  "event_date":         "YYYY-MM-DD",
  "stage":              "string | null",
  "raw":                { ...original API fields }
}
```

`lost_value` is the annual or monthly contract value of what was not recovered. Use whatever monetary field the API provides (`amount`, `total`, `plan_price`, etc.) — prefer annual value when both are present.

## Workflow

### Step 1 — Fetch reports in parallel

Call both tools with a 7-day date range. Use today's date for `to_date` and 7 days ago for `from_date` (format: `YYYY-MM-DD`).

```
ZohoBilling_get_lost_opportunities_report  — from_date, to_date
ZohoBilling_get_abandoned_carts_report     — from_date, to_date
```

If either call returns an empty result set, note it but continue — the cohort may still have data from the other source.

### Step 2 — Normalize

Map API response fields to the unified schema above. Common field mappings to try:

| Unified field    | Lost Opp candidates                    | Abandoned Cart candidates              |
|------------------|----------------------------------------|----------------------------------------|
| `record_id`      | `opportunity_id`, `id`                 | `cart_id`, `id`                        |
| `customer_name`  | `customer_name`, `contact_name`        | `customer_name`, `visitor_name`        |
| `email`          | `email`, `contact_email`               | `email`, `customer_email`              |
| `plan_name`      | `plan_name`, `product_name`            | `plan_name`, `product`                 |
| `lost_value`     | `amount`, `total`, `plan_price`        | `cart_total`, `amount`, `plan_price`   |
| `event_date`     | `lost_date`, `closed_date`, `date`     | `abandoned_date`, `created_time`       |
| `stage`          | `stage`, `lost_stage`                  | `checkout_step`, null                  |

If a field is missing or null in the API response, set it to `null` in the output — don't drop the row.

`days_since_event` = today's date − `event_date` in calendar days.

### Step 3 — Sort

Sort the full combined array:
1. **Source order**: all `lost_opportunity` records first, then `abandoned_cart` records.
2. **Within each source**: sort by `lost_value` DESC (highest value first).

This ordering ensures the proposal report always leads with the highest-priority recoveries.

### Step 4 — Write output

Save to:
```
<workspace>/recovery-runs/<DATE>/cohort-raw.json
```

Where `<DATE>` is today in `YYYY-MM-DD` format. Create the directory if it doesn't exist.

Print a summary to the user:

```
Recovery cohort built — <DATE>
  Lost Opportunities : N records   (total lost value: $X,XXX)
  Abandoned Carts    : N records   (total lost value: $X,XXX)
  Combined total     : N records   (total lost value: $X,XXX)
  Saved to: recovery-runs/<DATE>/cohort-raw.json
```

## Edge cases

- **API returns no data for a source** → include that source with 0 records in the summary; don't error.
- **`lost_value` is null or non-numeric** → default to `0` for sorting; do not drop the record.
- **Duplicate records** (same `record_id` appearing in both reports) → keep both, add a `duplicate_flag: true` field for downstream review.
- **Date parsing fails** → set `event_date` to `null` and `days_since_event` to `null`; flag the row.
