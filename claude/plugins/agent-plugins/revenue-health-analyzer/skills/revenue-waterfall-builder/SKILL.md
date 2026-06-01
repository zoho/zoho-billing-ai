---
name: revenue-waterfall-builder
description: >
  Render a revenue waterfall bridging starting MRR through new,
  expansion, contraction, and churn to ending MRR for a chosen window.
  Pulls the revenue waterfall summary and waterfall details from Zoho
  Billing so the user can see both the headline movement and the
  customer-level contributions. Use when the user asks for a "revenue
  waterfall", "MRR bridge", "where did MRR go", "what drove the change
  from <start> to <end>", or wants to decompose a revenue swing.
  Propose-only; never calls mutating endpoints.
---

# Revenue Waterfall Builder

Builds the starting-MRR → ending-MRR bridge and identifies the
customers driving each leg of the waterfall.

**Propose-only**: no write, update, or delete API calls. Ever.

---

## Step 0 — Pre-flight

**Org ID**: From `list_organizations` if not already known.

**Window**: Default — start of the current calendar year to last
month-end. State and offer override:

> "Building MRR waterfall for **<start> – <end>** (year-to-date).
> Use a different window?"

---

## Step 1 — Fetch data (2 calls in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_get_revenue_waterfall_report` | Aggregate legs: new, expansion, contraction, churn |
| 2 | `ZohoBilling_get_revenue_waterfall_details_report` | Customer/subscription-level contributions per leg |

Pass `from_date` and `to_date` to both.

---

## Step 2 — Compose the bridge

Build a 6-bar bridge:

```
Starting MRR  +  New MRR  +  Expansion  −  Contraction  −  Churned MRR  =  Ending MRR
```

Validation: starting + new + expansion − contraction − churn should
equal ending MRR within rounding. If the equation fails by more than
the org's currency rounding unit, emit a warning and show both the
reported ending MRR and the computed one — do not silently reconcile.

Compute leg shares as % of starting MRR so they're comparable across
orgs of different sizes:

```
expansion_pct   = expansion   / starting_mrr * 100
contraction_pct = contraction / starting_mrr * 100
churn_pct       = churned_mrr / starting_mrr * 100
net_movement_pct = (ending_mrr − starting_mrr) / starting_mrr * 100
```

---

## Step 3 — Identify the top contributors per leg

From the details report:

- **Top 5 expansion customers** — largest positive MRR changes
- **Top 5 contraction customers** — largest negative non-churn MRR changes
- **Top 5 churned customers** — largest MRR lost to cancellation
- **Top 5 new customers** — largest MRR added by new acquisition

Each row: customer name, subscription id, plan, delta MRR.

Concentration check: if the **top customer in any leg** represents
> 20% of that leg's total, note "concentrated movement — one customer
drove a fifth or more of <leg>."

---

## Step 4 — Emit output

```yaml
waterfall:
  window: { from: <iso>, to: <iso> }
  starting_mrr: <number>
  new_mrr: <number>
  expansion: <number>
  contraction: <number>
  churned_mrr: <number>
  ending_mrr: <number>
  net_movement_pct: <number>     # one decimal
  expansion_pct: <number>
  contraction_pct: <number>
  churn_pct: <number>
  top_expansion:    [{customer, subscription_id, delta_mrr}, ...]
  top_contraction:  [...]
  top_churn:        [...]
  top_new:          [...]
  concentration_flags: [<string>, ...]
markdown: |
  ### Revenue Waterfall — <window>
  Start $<s> → End $<e>  ·  Net <±n>%
  + New $<nm>  + Expansion $<x>  − Contraction $<c>  − Churn $<ch>
  Largest expansion: <name> +$<m>
  Largest churn:     <name> −$<m>
  <concentration notes if any>
```

---

## Edge cases

- **Reconciliation gap**: if the bridge doesn't add up within currency
  rounding, emit both reported and computed ending MRR plus a warning.
- **Window crosses a fiscal year**: respect calendar months; do not
  silently realign to fiscal periods.
- **Details endpoint returns paginated data**: page through until
  exhausted or until top-5 per leg is stable; do not truncate before
  ranking.
- **Multi-currency org**: report waterfall in the org's base currency
  and call it out: "Waterfall in <CCY>. Foreign-currency subscriptions
  converted at the rate Zoho Billing applied at posting time."
