---
name: renewal-exposure-tracker
description: >
  Quantify the upcoming renewal cliff in dollars across the next 30,
  60, and 90 days, and produce a propose-only short-list of at-risk
  renewals worth attention. Pulls renewal summary, upcoming renewal
  details, and non-renewing subscriptions from Zoho Billing, then
  applies the risk thresholds in config/retention-bands.yaml to rank
  the riskiest renewals. Use when the user asks about "renewal cliff",
  "renewal exposure", "what's up for renewal next month", "which
  renewals are at risk", or "how much MRR is up for renewal in 60
  days". Propose-only; never sends emails or extends subscriptions.
---

# Renewal Exposure Tracker

Sizes the upcoming renewal cliff and ranks the at-risk renewals worth
proactive attention.

**Propose-only**: no write, update, or delete API calls. Ever.
This skill never sends communications or extends subscriptions — it
only produces a short-list for a human reviewer.

---

## Step 0 — Pre-flight

**Org ID**: From `list_organizations` if not already known.

**Today / windows**: Use today's date. Compute three forward windows:

```
window_30 = [today,  today + 30 days]
window_60 = [today,  today + 60 days]
window_90 = [today,  today + 90 days]
```

Read `renewal_exposure` from `config/retention-bands.yaml` for
threshold values. State plainly:

> "Looking at renewals due in the next 30, 60, and 90 days from today."

---

## Step 1 — Fetch data (3 calls in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_get_renewal_summary_report` | Aggregate renewal counts and MRR by upcoming window |
| 2 | `ZohoBilling_get_upcoming_renewal_details_report` | Per-subscription renewal detail for next 90 days |
| 3 | `ZohoBilling_get_non_renewing_subscriptions_report` | Subscriptions flagged non-renewing |

For (2), filter `next_billing_date` to within `today + 90 days`.

---

## Step 2 — Size the cliff

Bucket upcoming renewals into the three windows by `next_billing_date`.
For each window emit:

```
window  | count | total_mrr | unique_customers
30d     | <c>   | $<m>      | <u>
60d     | <c>   | $<m>      | <u>      # cumulative through 60d
90d     | <c>   | $<m>      | <u>      # cumulative through 90d
```

Compute `exposure_30d_pct_of_current_mrr` — total MRR up for renewal
in the next 30 days divided by current MRR (use waterfall ending MRR
if available, otherwise the renewal summary's current-book figure).

---

## Step 3 — Build the at-risk short-list

A renewal lands on the short-list when ANY condition is true:

1. The subscription is on the non-renewing list (Step 1 #3).
2. The customer has ≥ `recent_payment_failures` payment failures in
   the past `failure_lookback_days` days.
3. `current_mrr ≥ high_value_mrr_usd` AND the customer has had no
   payment, login, or activity event in the past `last_activity_days`
   days. (Use whatever activity signal the upcoming-renewal-details
   payload exposes; if none is available, fall back to "no payment in
   last_activity_days".)

Rank the short-list by **MRR at risk × proximity score**, where
proximity is `1.0` for 30d, `0.7` for 60d, `0.5` for 90d. Cap the
list at `shortlist_size` from config.

Each row should include: customer name, subscription id, plan,
current MRR, next billing date, days until renewal, which condition
fired, and a one-line "why this is at risk" rationale.

---

## Step 4 — Emit output

```yaml
renewal_exposure:
  as_of: <iso date>
  current_mrr: <number>
  windows:
    "30d": { count, total_mrr, unique_customers }
    "60d": { count, total_mrr, unique_customers }
    "90d": { count, total_mrr, unique_customers }
  exposure_30d_pct_of_current_mrr: <number>
  at_risk_shortlist:
    - customer: <name>
      subscription_id: <id>
      plan: <name>
      current_mrr: <number>
      next_billing_date: <iso>
      days_to_renewal: <int>
      trigger: non_renewing | recent_failures | high_value_inactive
      rationale: <string>
markdown: |
  ### Renewal Exposure — as of <date>
  Next 30 days: <c> renewals · $<m> MRR  (<pct>% of current MRR)
  Next 60 days: <c> · $<m>
  Next 90 days: <c> · $<m>

  **At-risk shortlist (<k> renewals worth attention):**
  | Customer | MRR | Renews in | Why |
  |---|---|---|---|
  | <name> | $<m> | <n>d | <trigger>: <rationale> |
```

---

## Edge cases

- **No upcoming renewals**: emit zeroed windows and an empty short-list
  with note "No renewals scheduled in the next 90 days."
- **Activity signal not available in API payload**: fall back to
  payment activity only and note the substitution in the output.
- **Auto-renew off but customer still listed in upcoming renewals**:
  treat as non-renewing for the short-list trigger.
- **Subscriptions with mid-window pause or trial**: exclude trials
  from MRR cliff totals; include paused subs only if they resume
  within the window.
- **Multi-currency**: report each window's total in base currency,
  flagging conversion in the output.
