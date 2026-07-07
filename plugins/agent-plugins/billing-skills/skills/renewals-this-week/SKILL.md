---
name: renewals-this-week
description: >
  Upcoming renewal worklist: every subscription renewing in the next 14 days with
  a recommended motion per renewal (hold price, increase, pitch annual, or save-call).
  Use when the user asks about upcoming renewals, what's renewing soon, or renewal
  action planning. Do NOT use for past renewals or renewal failure recovery.
when_to_use: >
  Trigger on: "upcoming renewals", "what's renewing soon", "renewals this week",
  "renewals next 14 days", "renewal list", "what renews", "renewal action plan",
  "renewal motion", "renewal worklist".
argument-hint: "[days — e.g. '30' for 30-day window, default is 14]"
---

# Renewals This Week

Upcoming renewals ranked by MRR with recommended motion per renewal.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
Default window: next 14 days. If `$ARGUMENTS` is a number, use that many days.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Upcoming_Renewal_Details_Report` | All upcoming renewals |
| 2 | `ZohoBilling_Get_Renewal_Summary_Report` | Aggregate renewal stats |
| 3 | `ZohoBilling_Get_LTV_Report` | LTV per customer for motion scoring |

## Motion logic

For each renewing subscription, assign one motion:

| Condition | Motion |
|---|---|
| Monthly sub · tenure > 6 months · no payment failures | **Pitch annual** — convert to annual with discount |
| Usage near plan limit or repeated addon purchases | **Pitch upgrade** — propose next tier |
| LTV > 90th percentile · no payment issues | **Hold price** — don't risk it |
| PAST_DUE or dunning incident in last 90 days | **Save-call** — human outreach before renewal |
| All clear · LTV median range | **Hold price** — standard renewal |

## Output

```
Renewals — Next [N] Days    [date]
Total renewal MRR: $XXX,XXX  ·  N subscriptions
──────────────────────────────────────────────────────────────────────
 #  Customer              Plan          MRR      Renews    Motion
──────────────────────────────────────────────────────────────────────
 1  Acme Corp             Enterprise    $4,200   Jul 1     📅 Hold price
 2  Beta Inc              Pro (monthly) $  490   Jul 2     📆 Pitch annual
 3  Startup XYZ           Starter       $   79   Jul 3     ⬆ Pitch upgrade
 4  At-Risk Co            Professional  $1,200   Jul 4     📞 Save-call
──────────────────────────────────────────────────────────────────────
By motion: Hold N · Pitch annual N · Pitch upgrade N · Save-call N
```

**Save-call** entries always include: last payment date · failure reason if available.

## Constraints

- Filter to renewals within the specified day window
- LTV percentiles computed from the LTV report data — do not estimate
- Propose-only: no subscription changes, no quotes created automatically

## Edge cases

- Zero renewals in window: "No renewals in the next [N] days"
- LTV data unavailable: default to Hold Price motion and note "LTV data unavailable — using conservative motion"
