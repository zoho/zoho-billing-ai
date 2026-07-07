---
name: mrr-growth
description: >
  Break down MRR movement into new, expansion, reactivation, contraction, and
  churn components for any period. Use when the user asks about MRR growth,
  what drove MRR change, new vs expansion MRR, MRR waterfall, or why monthly
  recurring revenue went up or down.
  Do NOT use for ARR, NRR, total revenue, or churn rate questions.
when_to_use: >
  Trigger on: "mrr growth", "mrr breakdown", "what's driving mrr",
  "new mrr", "expansion mrr", "why did mrr change", "mrr waterfall",
  "mrr movement", "break down mrr", "show mrr", "how is mrr doing".
argument-hint: "[period — e.g. 'last month' or 'Q1 2026']"
---

# MRR Growth

Show the MRR waterfall — what drove this period's net MRR change broken into
new, expansion, reactivation, contraction, and churn components with MoM Δ.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`. If multiple orgs
exist, ask the user which one before fetching any data.

**Default period:** this month (`SubscriptionDate.ThisMonth`).
Accept natural-language overrides from `$ARGUMENTS` and map to the closest
allowed `filter_by` value, or use `SubscriptionDate.CustomDate` with explicit
`from_date` / `to_date` when the user names a specific range.

Allowed `filter_by` values:
`ThisMonth` · `ThisQuarter` · `ThisYear` ·
`PreviousMonth` · `PreviousQuarter` · `PreviousYear` ·
`LastThreeMonths` · `LastTwelveMonths` · `CustomDate`

## Fetch (run all calls in parallel)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_Get_MRR_Report` | current period · `group_by: [{field: month_start_time, group: report}]` |
| 2 | `ZohoBilling_Get_MRR_Report` | prior comparable period (one step back) |
| 3 | `ZohoBilling_Get_Gross_MRR_Report` | current period · same group_by |

Call 2 derives the prior period:
- ThisMonth → PreviousMonth
- ThisQuarter → PreviousQuarter
- ThisYear → PreviousYear
- LastThreeMonths → CustomDate 3 months earlier
- CustomDate → shift the same span one period back

## Output

Render a **MRR waterfall** table. See [references/output-format.md](references/output-format.md)
for the exact format and health-call rules.

Required rows (in order):
Previous MRR → + New → + Expansion → + Reactivation → − Contraction → − Churn → **Net MRR**

For each row show: current value · prior value · Δ absolute · Δ %.

End with:
- **Health call:** 🟢 Green / 🟡 Yellow / 🔴 Red (see output-format.md for rules)
- **Biggest driver:** one sentence naming the largest positive and negative component
- **Gross vs Net gap:** if gross MRR exceeds net MRR by > 20%, add ⚠ discount-leakage flag

## Constraints

- Use API `total` fields — never manually sum paginated rows
- Show $0 for any component that returns null or zero — do not omit rows
- If prior period is unavailable (new org), show current period only with a note
- Never estimate, interpolate, or extrapolate — report only what the API returns
- Propose-only: no write actions

## Edge cases

- **Partial month:** label the period "Jun 1–29 (partial)" not "June"
- **All zeros:** report $0 MRR with note "No subscription activity in this period"
- **filter_by unrecognised:** ask the user to clarify before calling any tool
