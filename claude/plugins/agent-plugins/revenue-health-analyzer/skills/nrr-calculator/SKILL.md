---
name: nrr-calculator
description: >
  Compute Net Revenue Retention (NRR) for a chosen window and band the
  result against industry norms — best-in-class (≥110%), healthy
  (100–110%), or leaking (<100%). Pulls the NRR rate report and the
  subscription retention rate report from Zoho Billing. Use when the
  user asks "what is my NRR", "is revenue retention healthy", "are we
  expanding net of churn", or any question about Net Revenue Retention
  for a date range. Propose-only; never calls mutating endpoints.
---

# NRR Calculator

Compute Net Revenue Retention for a window and produce a banded call
against industry norms loaded from `config/retention-bands.yaml`.

**Propose-only**: no write, update, or delete API calls. Ever.

---

## Step 0 — Pre-flight

**Org ID**: Call `list_organizations`. If multiple, ask which one to use.

**Window**: Default is the **trailing 12 months ending last month-end**.
State it in one line:

> "Computing NRR for **<start> – <end>** (trailing 12 months). Use a
> different window?"

If the user supplies a custom window, use it as-is. Warn if shorter than
3 months — NRR is noisy on short windows.

**Bands config**: Load `config/retention-bands.yaml` → `nrr_bands` so
the thresholds reflect the org's tuning, not hardcoded defaults.

---

## Step 1 — Fetch data (2 calls in parallel)

Run both in a single turn:

| # | Tool | Purpose | Key params |
|---|------|---------|------------|
| 1 | `ZohoBilling_get_net_revenue_retention_rate_report` | NRR rate over window | `from_date`, `to_date` |
| 2 | `ZohoBilling_get_subscription_retention_rate_report` | Logo retention as cross-check | `from_date`, `to_date` |

If the NRR endpoint returns a pre-computed rate, use it directly. If it
returns the decomposed inputs (starting_mrr, expansion, contraction,
churn), compute NRR yourself:

```
nrr_pct = (starting_mrr + expansion - contraction - churned_mrr)
          / starting_mrr * 100
```

---

## Step 2 — Band the result

Load `nrr_bands` from config and pick the first matching band:

| Band | Condition | Industry meaning |
|---|---|---|
| `best_in_class` | nrr ≥ `best_in_class.min_pct` | Compounding revenue — top quartile SaaS |
| `healthy` | `healthy.min_pct` ≤ nrr < `healthy.max_pct` | Revenue at least flat after churn |
| `leaking` | nrr < `leaking.max_pct` | Book is contracting net of expansion |

---

## Step 3 — Cross-check with logo retention

Logo retention (subscription count) and NRR ($) can diverge:

| Pattern | What it means |
|---|---|
| NRR high, logo retention low | Losing small accounts, expanding large ones — concentration risk grows |
| NRR low, logo retention high | Customers stay but downgrade — pricing or value gap |
| Both low | Active retention erosion — escalate |
| Both high | Healthy book on both dimensions |

Add a one-line note in the output covering which pattern (if any) applies.

---

## Step 4 — Emit output

Return a JSON-shaped object the orchestrator can pick up:

```yaml
nrr:
  window: { from: <iso>, to: <iso> }
  nrr_pct: <number>           # one decimal
  starting_mrr: <number>
  expansion: <number>
  contraction: <number>
  churned_mrr: <number>
  ending_mrr: <number>
  band: best_in_class | healthy | leaking
  logo_retention_pct: <number>
  cross_check_note: <string>  # divergence pattern, or "aligned"
markdown: |
  ### Net Revenue Retention — <window>
  **<nrr_pct>%**  ·  Band: **<band>**
  Starting MRR $<x> → Ending MRR $<y>
  Expansion $<+e>  ·  Contraction −$<c>  ·  Churn −$<ch>
  Logo retention <l>%. <cross_check_note>
```

---

## Edge cases

- **Starting MRR is zero**: NRR is undefined; return `null` and a flag
  "Insufficient starting MRR for NRR calculation."
- **Negative expansion or contraction values from the API**: respect
  the sign as returned; do not invert.
- **Multi-currency org**: NRR is reported in the org's base currency.
  Note the currency code in the output.
- **Endpoint returns rate only (no components)**: emit the rate and
  band; leave decomposition fields `null` and note "decomposition
  unavailable" in markdown.
