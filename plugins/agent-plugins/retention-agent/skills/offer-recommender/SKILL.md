---
name: offer-recommender
description: Apply the retention decision matrix to a classified cohort and produce per-subscription recommendations (discount, pause, downgrade, human_triage, standard_offer, accept). Run after cancel reasons are classified.
---

# Offer Recommender

Applies `config/retention-matrix.yaml` (`pre_churn_matrix` or `win_back_matrix`) to the classified cohort. No API calls — pure rule evaluation, deterministic, re-runnable when YAML changes.

## Output: `recommendation` object appended per row

```json
{
  "action": "discount",
  "params": { "percent": 25, "duration_months": 3 },
  "rationale": "High-LTV, price objection — aggressive discount preserves long-term value",
  "rule_index": 0,
  "ltv_tier": "high",
  "ltd_tier": "veteran"
}
```

Supported actions: `discount`, `pause`, `downgrade`, `human_triage`, `standard_offer`, `accept`.

## Workflow

**1. Run the matrix script:**
```bash
python <skill-path>/scripts/apply_matrix.py \
    --cohort <workspace>/retention-runs/<DATE>/cohort-<type>-classified.json \
    --matrix <workspace>/config/retention-matrix.yaml \
    --cohort-type <pre_churn|post_churn> \
    --output <workspace>/retention-runs/<DATE>/cohort-<type>-recommendations.json
```
Script logic: buckets `ltv` (USD) and `ltd` (days) into tiers from the YAML, walks matrix rules top-to-bottom, first matching rule wins. An empty `match: {}` is a catch-all — every matrix should end with one.

**2. Inspect summary output for:**
- Spike in `human_triage` → new reason bucket not covered by matrix rules.
- Any `rule_index: -1` rows → no catch-all; stop pipeline and tell the user.

**3. Show the user** action-count summary and a top-5 high-MRR preview table. Confirm output path.

## Edge cases
- **Missing LTV/LTD** → script defaults to `0`, buckets as `low`/`new`; catch-all handles it.
- **Unknown action name in YAML** → passed through unchanged; orchestrator surfaces it.
- **No catch-all rule** → script emits `rule_index: -1`; flag and stop.
