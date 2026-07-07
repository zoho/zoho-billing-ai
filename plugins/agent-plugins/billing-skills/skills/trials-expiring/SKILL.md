---
name: trials-expiring
description: >
  List all active trials sorted by expiry date, showing days remaining and plan.
  Use when the user asks which trials are expiring, wants to see active trials,
  or needs to know which trial customers to engage before they expire.
  Do NOT use for trial conversion rates or historical trial analysis.
when_to_use: >
  Trigger on: "trials expiring", "active trials", "which trials are ending",
  "trial expiry", "trial watch", "trials about to expire", "upcoming trial ends".
argument-hint: "[days — e.g. '14' to show trials expiring within 14 days]"
---

# Trial Watch

List all active trials sorted by days remaining (soonest expiring first).

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default view: all active trials. If `$ARGUMENTS` is a number N, filter to trials
expiring within N days.

## Fetch

`ZohoBilling_List_all_Subscriptions` with `filter_by: SubscriptionStatus.TRIAL`, `per_page: 200`.
Paginate while `has_more_page: true`.

## Output

```
Active Trials — [date]   (N total)
──────────────────────────────────────────────────────
 #  Customer              Plan          Days left  Expires
──────────────────────────────────────────────────────
 1  Beta Corp             Pro           2 days     Jul 1
 2  Startup XYZ           Starter       5 days     Jul 4
 3  Acme Inc              Enterprise    11 days    Jul 10
...
──────────────────────────────────────────────────────
Expiring ≤7 days:   N trials  ← needs attention
Expiring 8–14 days: N trials
Expiring 15–30 days: N trials
```

For each trial show: customer name · plan · days remaining · expiry date.
Mark trials expiring in ≤ 3 days with ⚠.

## Constraints

- Sort ascending by trial end date (soonest first)
- Days remaining = trial_end_date − today
- If $ARGUMENTS is a number, only show trials where days_remaining ≤ N
- Propose-only: no subscription changes

## Edge cases

- Zero active trials: "No active trials at this time"
- Trial end date in the past (expired but not converted): label as "Expired [X] days ago" and include in output
