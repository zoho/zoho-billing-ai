---
name: cancel-reason-classifier
description: Classify free-text cancel reasons into canonical buckets (price, feature_gap, temporary, quality, business_end, duplicate_account, unknown) using the YAML taxonomy. Run after cohort is built, before the strategy engine.
---

# Cancel Reason Classifier

Turns `cancel_reason_raw` into a canonical `cancel_reason_bucket` via keyword matching against `config/retention-matrix.yaml` (`reason_taxonomy` key). Deterministic, zero LLM tokens, re-runnable.

## Output fields added per row

| Field | Description |
|---|---|
| `cancel_reason_bucket` | Canonical bucket from YAML taxonomy |
| `cancel_reason_match` | Keyword that triggered the match; `null` for unknown |

Writes `cohort-<type>-classified.json` next to the input file.

## Workflow

**1. Run the classifier script:**
```bash
python <skill-path>/scripts/classify_reason.py \
    --cohort <workspace>/retention-runs/<DATE>/cohort-<type>.json \
    --matrix <workspace>/config/retention-matrix.yaml \
    --output <workspace>/retention-runs/<DATE>/cohort-<type>-classified.json
```
Script logic: lowercases `cancel_reason_raw`, walks YAML buckets top-to-bottom, first keyword match wins. Prints per-bucket counts + up to 10 unknown examples to stdout.

**2. Handle unknowns:**
- ≤5% unknown → acceptable; leave as `unknown` (strategy engine has fallback rules).
- >10% unknown → prefer **Option A**: add keywords to the YAML taxonomy and re-run (every future run benefits). Use **Option B** (inline LLM classification) only if reasons are too varied for keywords — set `cancel_reason_match: "llm_fallback"` for audit.

**3. Report** per-bucket counts to user and confirm output path.

## Edge cases
- **Missing `cancel_reason_raw`** → treat as `unknown`.
- **Non-English reasons** → keyword match will fail; recommend adding localized keywords to YAML.
- **Empty cohort** → exit cleanly with a one-line note.
