---
name: recovery-strategy
description: Apply the recovery decision matrix to a normalized recovery cohort and produce per-record action recommendations (human_outreach, email_with_discount, email_reminder, email_sequence, accept). Run after the cohort is built. Pure rule evaluation — deterministic, zero LLM tokens, re-runnable whenever the YAML changes.
---

# Recovery Strategy

Applies `config/recovery-matrix.yaml` to the normalized cohort from `recovery-cohort-builder`. Evaluates the `lost_opportunity_matrix` for lost-opportunity records and the `abandoned_cart_matrix` for abandoned-cart records. No API calls — pure YAML rule evaluation.

## Output: `recommendation` object appended per row

```json
{
  "action": "email_with_discount",
  "params": { "discount_percent": 20, "coupon_duration_months": 3, "expiry_hours": 48 },
  "rationale": "High-value lead cooling off — 20% welcome-back discount with a 48-hour urgency window",
  "rule_index": 1,
  "value_tier": "high",
  "recency_tier": "recent"
}
```

Supported actions: `human_outreach`, `email_with_discount`, `email_reminder`, `email_sequence`, `accept`.

## Workflow

**1. Run the matrix script:**

```bash
python <skill-path>/scripts/apply_recovery_matrix.py \
    --cohort    <workspace>/recovery-runs/<DATE>/cohort-raw.json \
    --matrix    <workspace>/config/recovery-matrix.yaml \
    --output    <workspace>/recovery-runs/<DATE>/cohort-recommendations.json
```

Script logic: buckets `lost_value` into value tiers and `days_since_event` into recency tiers from the YAML, then walks the appropriate matrix (lost_opportunity or abandoned_cart) top-to-bottom — first matching rule wins. An empty `match: {}` is a catch-all; every matrix ends with one.

**2. Inspect the summary output for:**

- Spike in `human_outreach` with `priority: urgent` → correct and expected for fresh high-value records.
- Any `rule_index: -1` rows → no catch-all in the YAML; stop and alert the user to fix the matrix.
- Records where `value_tier` or `recency_tier` is `null` → upstream normalization issue; review the cohort.

**3. Show the user** an action-count summary and a top-10 preview table sorted by `lost_value` DESC:

| # | Source | Customer | Plan | Lost Value | Days Since | Action | Rationale |
|---|--------|----------|------|-----------|------------|--------|-----------|

Confirm the output path before proceeding to the report.

## Edge cases

- **Missing `lost_value`** → script defaults to `0`, buckets as `low`; catch-all handles it.
- **Missing `days_since_event`** → script defaults to `recency: recent` (conservative middle bucket).
- **Unknown action name in YAML** → passed through unchanged; orchestrator surfaces it.
- **No catch-all rule** → script emits `rule_index: -1`; flag and stop — matrix must be fixed.
- **Mixed currencies** → script ignores currency when bucketing; flag if multiple currencies detected.
