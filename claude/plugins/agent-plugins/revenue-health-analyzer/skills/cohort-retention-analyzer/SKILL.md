---
name: cohort-retention-analyzer
description: >
  Build the cohort retention heatmap by acquisition month — both
  revenue retention (dollars retained from each cohort's starting MRR)
  and subscription retention (logos retained). Compares each cohort's
  month-N retention against the median of its peer cohorts and flags
  cohorts that lag by more than the threshold in
  config/retention-bands.yaml. Use when the user asks about "cohort
  retention", "how is the March cohort doing", "are newer cohorts
  retaining better than older ones", or wants a retention heatmap.
  Propose-only; never calls mutating endpoints.
---

# Cohort Retention Analyzer

Pulls revenue and subscription cohort retention reports, builds the
heatmap, and surfaces cohorts retaining below their peers.

**Propose-only**: no write, update, or delete API calls. Ever.

---

## Step 0 — Pre-flight

**Org ID**: From `list_organizations` if not already known.

**Cohort window**: Default — the last 12 acquisition cohorts (months)
plus the current month. State and offer override:

> "Building cohort heatmap for the last 12 acquisition months ending
> <month>. Use a different range?"

**Config**: Load `cohort_variance` from `config/retention-bands.yaml` —
`peer_window_months`, `flag_pct_below_peer_median`, `min_cohort_size`.

---

## Step 1 — Fetch data (2 calls in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_get_revenue_retention_cohort_report` | Revenue retained per cohort, month-by-month |
| 2 | `ZohoBilling_get_subscription_retention_cohort_report` | Logo count retained per cohort, month-by-month |

Pass the chosen cohort window dates to both.

---

## Step 2 — Normalise into a matrix

For each cohort, construct two rows:

```
cohort_month  size  m0%  m1%  m2%  m3%  m4%  ...  mN%
2025-06       142  100   97   94   91   90  ...   85
2025-07       138  100   95   90   87   85  ...   —
...
```

- `m0%` is always 100 (anchor month).
- Cells with no observation yet (cohort younger than month-N) → `—`.
- Compute both an MRR-retention matrix and a logos-retention matrix.

---

## Step 3 — Score each cohort vs peers

For every (cohort, month-N) cell where there are at least
`peer_window_months` older cohorts that have also reached month-N:

1. Compute the **peer median** retention at month-N across those older
   cohorts (skip cohorts with size < `min_cohort_size`).
2. Compute the **gap**: `peer_median_pct − cohort_pct`.
3. Flag the cell if `gap ≥ flag_pct_below_peer_median`.

A cohort is **weak overall** if it has ≥ 1 flagged month-N cell where
N ≥ 3 (don't flag based on month-1 or 2 alone — too noisy).

Pick the **single weakest cohort**: largest cumulative gap summed
across months 3+, with cohort size ≥ `min_cohort_size`.

---

## Step 4 — Emit output

```yaml
cohorts:
  window: { from: <iso>, to: <iso> }
  cohort_count: <int>
  matrix_mrr:  [...]          # rows of { cohort, size, m0..mN }
  matrix_logo: [...]          # same shape, logo retention
  weak_cohorts: [<cohort_month>, ...]
  weakest_cohort:
    cohort_month: <YYYY-MM>
    size: <int>
    biggest_gap_month: <int>      # which month-N has the largest lag
    gap_pct: <number>             # peer median − cohort, in pp
    peer_median_pct: <number>
    cohort_pct: <number>
markdown: |
  ### Cohort Retention — <window>
  <N> cohorts analysed. <K> retaining below peer median.
  **Weakest cohort: <month>** — at month-<N>, retained <c>% vs
  peer median <p>% (gap <g>pp). Worth investigating what changed
  in acquisition, onboarding, or pricing during <month>.
```

---

## Edge cases

- **Fewer than `peer_window_months` cohorts available**: skip the
  scoring step; still emit the matrix and note "Peer-comparison
  requires at least N cohorts; analysed descriptively only."
- **A cohort has size below `min_cohort_size`**: include in the matrix
  but exclude from peer-median and weakest-cohort calculations.
- **API returns absolute MRR instead of percentages**: normalise to
  percentage of starting cohort MRR before banding.
- **Pricing change suspected**: if the user said "we changed pricing
  in <month>", explicitly split the report into pre/post and highlight
  whether post-change cohorts retain differently.
