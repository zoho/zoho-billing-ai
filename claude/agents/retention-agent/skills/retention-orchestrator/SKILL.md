---
name: retention-orchestrator
description: Run the full retention pipeline end-to-end — pull cohort, classify reasons, apply decision matrix, write proposal report. Use for any retention run request. Propose-only; no automated actions, no Cliq.
---

# Retention Orchestrator

Runs the full pipeline. **Propose-only** — writes a Markdown report for human review; never calls action endpoints (no coupon association, no pauses, no updates).

## Pipeline

1. Pull cohort → `churn-cohort-builder`
2. Classify reasons → `cancel-reason-classifier`
3. Apply matrix → `offer-recommender`
4. Write → `retention-runs/<DATE>/retention-proposals.md`

## Workflow

### Pre-flight — connector validation (run first, before anything else)

Check that every required Zoho Billing tool is available in the current session. The three tools this pipeline depends on are:

- `ZohoBilling_get_non_renewing_subscriptions_report`
- `ZohoBilling_get_churned_subscriptions_report`
- `ZohoBilling_list_organizations`

**How to check:** attempt to introspect or list available tools. If any of the three are absent, stop immediately and surface this message to the user:

> ⚠️ **Missing Zoho Billing tools**
>
> The retention agent needs these tools from your Zoho-MCP connector but they are not available:
> - `<list missing tools>`
>
> To fix this:
> 1. Go to **Settings → Connectors → Zoho Billing**
> 2. Enable the missing tools (or choose "All tools")
> 3. Re-run the retention agent
>
> Do not proceed past this point until all three tools are confirmed available.

- Get org ID via `list_organizations`; ask if multiple exist.
- Default scope: **both** pre-churn (next 30 days) + post-churn (last 7 days). Honor explicit user scope if given.
- If `retention-proposals.md` already exists for today → ask to overwrite or use `-rerun-<n>` suffix.
- State the plan in one sentence, then start.

### Step 1 — Pull cohorts
Follow `churn-cohort-builder`. Run both API calls in parallel (single turn, two tool uses). Use `per_page: 100`. Write:
```
retention-runs/<DATE>/cohort-pre_churn.json
retention-runs/<DATE>/cohort-post_churn.json
```
Skip empty cohorts — don't widen the window without asking.

### Step 2 — Classify
Follow `cancel-reason-classifier`. Run for each non-empty cohort:
```bash
python <skills-path>/cancel-reason-classifier/scripts/classify_reason.py \
    --cohort retention-runs/<DATE>/cohort-<TYPE>.json \
    --matrix config/retention-matrix.yaml \
    --output retention-runs/<DATE>/cohort-<TYPE>-classified.json
```
If unknown rate >10% → update YAML taxonomy and re-run before continuing.

### Step 3 — Apply matrix
Follow `offer-recommender`. Run for each classified cohort:
```bash
python <skills-path>/offer-recommender/scripts/apply_matrix.py \
    --cohort retention-runs/<DATE>/cohort-<TYPE>-classified.json \
    --matrix config/retention-matrix.yaml \
    --cohort-type <pre_churn|post_churn> \
    --output retention-runs/<DATE>/cohort-<TYPE>-recommendations.json
```
If any `rule_index: -1` rows appear → stop; matrix is missing a catch-all rule.

### Step 4 — Write proposal report

File: `retention-runs/<DATE>/retention-proposals.md`

```markdown
# Retention Proposals — <DATE>

## Summary
- Pre-churn: N subs · $X MRR at risk
- Post-churn: M subs · $Y MRR lost
- Action mix: discount A · pause B · downgrade C · human_triage D · standard_offer E · accept F

## Pre-churn recommendations

### Discount offers (N)
#### 1. <Customer Name> · sub_id <ID>
- Plan: <plan> · MRR: $<mrr> · LTV: $<ltv> (<ltv_tier>) · Tenure: <ltd>d (<ltd_tier>)
- Cancel reason: "<cancel_reason_raw>" → bucket: <bucket> (matched: `<keyword>`)
- Action: discount — <percent>% for <duration_months> months
- Rationale: <from matrix> | Rule: #<rule_index>
- Approve / modify / reject: ☐

### Pauses (N) / Downgrades (N) / Human triage (N) / Standard offers (N) / Accept (N)

## Post-churn recommendations
(same structure)

## Notes & flags
- ltv_unavailable rows, unknown-reason rate, catch-all hit rate, etc.
```

Section order: discount → pause → downgrade → human_triage → standard_offer → accept.

### Step 5 — Hand off
One message: `computer://` link to the proposals file, N pre-churn + M post-churn, action mix, one top observation. Stop — do not offer to execute any actions.

## Edge cases
- **Both cohorts empty** → write `retention-runs/<DATE>/empty-run.md`; skip proposal file.
- **All LTV = 0** → flag in Notes (LTV data likely not wired up; not a matrix bug).
- **YAML parse error** → surface error and stop pipeline.
