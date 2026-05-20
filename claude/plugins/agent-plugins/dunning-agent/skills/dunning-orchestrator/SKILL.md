---
name: dunning-orchestrator
description: >
  Top-level entry point for the dunning agent. Runs the full dunning analysis pipeline
  end-to-end: fetches and scores the dunning cohort (dunning-cohort-builder), applies
  error-code playbooks to produce prioritised actions (dunning-action-planner), then
  synthesises everything into a single Markdown report with an executive summary, error-
  code segment table, prioritised action list, and playbook reference. Propose-only —
  never calls mutating endpoints. Use for any request that asks to "analyse dunning",
  "show dunning report", "what subscriptions are at risk", "prioritise dunning actions",
  or "dunning pipeline overview".
---

# Dunning Orchestrator

Run the full dunning analysis pipeline and produce the complete action report.

---

## Step 0 — Setup

**Date scope**: Default to `RetryDate.ThisMonth`. Accept overrides from the user
(e.g. "this week", "last month", a custom date range).

Announce before starting:
> "Running dunning analysis for **this month**. I'll fetch and score all at-risk
> subscriptions, group them by gateway error, and produce a prioritised action report."

---

## Step 1 — Build the dunning cohort

Follow the **dunning-cohort-builder** skill exactly.

Pass the resulting JSON cohort (Step 5 output contract) to Step 2. Do not render
output yet — hold it for the final report.

If the cohort is empty:
> "No subscriptions currently in dunning for the selected period. All clear!"
> Stop here — do not proceed to Step 2.

---

## Step 2 — Apply playbooks and plan actions

Follow the **dunning-action-planner** skill exactly, using the cohort from Step 1.

Hold the action planner output (Step 5 output contract) for the final report.

---

## Step 3 — Render the Dunning Action Report

Assemble all sections into a single Markdown document.

---

### SECTION 1 — Executive Summary

```markdown
# Dunning Action Report
**Period:** <date_filter>   **Generated:** <today's date>

## Executive Summary

| Metric | Value |
|---|---|
| Subscriptions in dunning | <total_subscriptions> |
| Total revenue at risk | <total_bcy_at_risk> |
| 🔴 P0 Emergency | <p0_count> |
| 🟠 P1 High | <p1_count> |
| 🟡 P2 Medium | <p2_count> |
| ⚪ P3 Low | <p3_count> |
| ★ High-value customers at risk | <high_value_at_risk> |
| P0 × High-value overlap | <p0_high_value_overlap> |
| Needs escalation to support | <total_needs_escalation> |
| Auto-recoverable (retry eligible) | <total_auto_recoverable> |
| Estimated recoverable revenue | <estimated_recoverable_revenue> |
| Dominant error code | <dominant_error_code> (<dominant_error_pct>% of subscriptions) |
```

**Narrative** (2–4 sentences): Summarise the most important signal — e.g. "Card-expired
failures make up the majority of P0s this month, concentrated in high-LTV customers.
12 subscriptions need immediate escalation; 8 of those are high-value." Keep it direct
and actionable.

---

### SECTION 2 — Error-Code Segment Table

```markdown
## Error-Code Segments

| Error Code | # Subs | Total at Risk | P0 | Avg LTV | Avg LTD (days) | Owner | Primary Action | Auto-Recover? |
|---|---|---|---|---|---|---|---|---|
| card_expired | N | $X | N | $X | N | customer | send_card_update_request | ✗ |
| insufficient_funds | ... | ... |
...
| **TOTAL** | **N** | **$X** | **N** | | | | | |
```

> ★ marks rows where `high_value_count > 0`  
> ⚠ marks rows where `p0_count > 0`

---

### SECTION 3 — Prioritised Action List

```markdown
## Prioritised Action List

> Sorted by priority tier (P0 → P3), then by composite score (highest first).
> ★ = High-value customer   ⚠ = Escalation needed   ↻ = Auto-retry eligible

| Priority | Score | Subscription | Customer | Amount | LTV | LTD | Retry # | Error Code | Action | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 🔴 P0 | 87.4 | SUB-001234 | Acme Corp ★⚠ | $1,200 | $24,000 | 730d | 3 | card_expired | escalate_to_support | Escalation threshold reached |
| 🔴 P0 | 76.1 | SUB-002345 | Beta LLC ★ | $950 | $18,500 | 412d | 2 | do_not_honor | send_card_update_request | High-value: personal outreach |
...
```

Render all subscriptions (no truncation). If > 50 rows, add a note:
> "Showing all <n> subscriptions. Filter by error code or priority tier to narrow the view."

---

### SECTION 4 — Error-Code Playbook Cards

```markdown
## Playbook Reference

> These are the recommended remediation strategies for each error code present in your
> current dunning pipeline. Strategies are configured in `config/dunning-matrix.yaml`.
```

Emit one playbook card per distinct error code in the cohort (from action-planner Step 4).
Order by `total_bcy_amount` DESC.

---

### SECTION 5 — Recommended Next Steps

```markdown
## Recommended Next Steps

The following actions are proposed for human review. No changes have been made.

### Immediate (Today — P0 Emergency)
<list P0 subscriptions requiring escalation or customer contact, grouped by action>

### Within 48 Hours (P1 High)
<list P1 subscriptions>

### Within 5 Business Days (P2 Medium)
<list P2 subscriptions>

### Monitor (P3 Low)
<count of P3 subscriptions — individual listing only if ≤ 5>
```

For each action group, state: action name, how many subscriptions, total BCY at risk.

---

### SECTION 6 — Scoring Reference

```markdown
## Scoring Weights Used

| Component | Weight |
|---|---|
| Amount at risk | 35% |
| LTV | 30% |
| Lifetime duration | 20% |
| Retry count | 15% |

_Priority tiers, customer thresholds, and error-code playbooks are defined inline
in the `dunning-cohort-builder` and `dunning-action-planner` skill files._
```

---

## Propose-Only Guarantee

✓ This report identifies at-risk subscriptions, scores and ranks them, and recommends actions.

✗ This agent never:
  - Applies retries automatically
  - Cancels or modifies subscriptions
  - Sends emails or notifications
  - Applies discounts or coupons
  - Changes any customer or payment data

All findings are for human review. Every recommended action requires explicit human approval.

---

## Common Invocations

- *"Show me the dunning report"*
- *"Which subscriptions are at risk right now?"*
- *"Prioritise the dunning pipeline by LTV"*
- *"What are the most common gateway errors in dunning?"*
- *"Who are my P0 dunning customers this month?"*
- *"Which high-value customers are in dunning?"*
- *"Give me the full dunning action plan"*
