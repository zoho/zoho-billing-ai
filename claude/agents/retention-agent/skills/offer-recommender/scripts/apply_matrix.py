#!/usr/bin/env python3
"""
apply_matrix.py — apply the retention decision matrix to a classified cohort.

Reads:
  - A classified cohort JSON (output of cancel-reason-classifier).
  - The shared retention-matrix.yaml (LTV/LTD tiers + decision matrix).

For each row, buckets LTV and LTD into tier names, then walks the appropriate
matrix (`pre_churn_matrix` or `win_back_matrix`) top-to-bottom and returns the
first matching rule's action.

Writes a recommendations JSON: original row fields plus `recommendation`:
    {
      "action": "discount" | "pause" | "downgrade" | "human_triage" |
                "standard_offer" | "accept",
      "params": { ... },
      "rationale": "...",
      "rule_index": <int>,
      "ltv_tier": "high" | "medium" | "low",
      "ltd_tier": "veteran" | "established" | "new"
    }

Why this is pure logic with no API calls:
  - Determinism. Same inputs always produce same recommendation.
  - Auditability. Reviewers can trace exactly which rule fired.
  - Cheap to re-run if the matrix changes — no API tokens consumed.

Usage:
    python apply_matrix.py \\
        --cohort path/to/cohort-classified.json \\
        --matrix path/to/retention-matrix.yaml \\
        --cohort-type pre_churn \\
        --output path/to/recommendations.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "ERROR: PyYAML is not installed. Install it with:\n"
        "    pip install pyyaml --break-system-packages\n"
    )
    sys.exit(2)


def bucket_value(value: float, tiers: dict[str, dict[str, float]]) -> str:
    """
    Bucket a numeric value into a tier name based on min/max bounds in the YAML.
    Tier order in the YAML matters — first matching tier wins.
    A tier matches when:
      - value >= min  (if min defined)
      - value <  max  (if max defined; strict less-than)
    """
    for tier_name, bounds in tiers.items():
        lower = bounds.get("min")
        upper = bounds.get("max")
        if lower is not None and value < lower:
            continue
        if upper is not None and value >= upper:
            continue
        return tier_name
    # Fallback — shouldn't happen if YAML is well-formed
    return "unknown"


def bucket_ltd(days: float, ltd_tiers: dict[str, dict[str, float]]) -> str:
    """Same as bucket_value but uses min_days / max_days keys."""
    for tier_name, bounds in ltd_tiers.items():
        lower = bounds.get("min_days")
        upper = bounds.get("max_days")
        if lower is not None and days < lower:
            continue
        if upper is not None and days >= upper:
            continue
        return tier_name
    return "unknown"


def rule_matches(rule_match: dict[str, Any], row: dict[str, Any]) -> bool:
    """
    A rule's `match` clause is an AND of field equality checks.
    An empty match clause ({}) is the catch-all and always matches.
    """
    for field, expected in rule_match.items():
        if row.get(field) != expected:
            return False
    return True


def apply_matrix(
    row: dict[str, Any],
    matrix: list[dict[str, Any]],
    ltv_tier: str,
    ltd_tier: str,
    reason_bucket: str,
) -> dict[str, Any]:
    """
    Walk the matrix top-to-bottom. First rule whose `match` clause is
    satisfied wins. Returns the recommendation enriched with the rule index
    and the tier labels used in matching.
    """
    # Build the row representation the rules match against
    match_row = {
        "reason": reason_bucket,
        "ltv": ltv_tier,
        "ltd": ltd_tier,
    }
    for idx, rule in enumerate(matrix):
        if rule_matches(rule.get("match", {}), match_row):
            return {
                "action": rule.get("action"),
                "params": rule.get("params", {}),
                "rationale": rule.get("rationale", ""),
                "rule_index": idx,
                "ltv_tier": ltv_tier,
                "ltd_tier": ltd_tier,
            }
    # No rule matched and no catch-all — flag for human review
    return {
        "action": "human_triage",
        "params": {"route_to": "Retention Team", "priority": "normal"},
        "rationale": "No matrix rule matched — matrix is missing a catch-all rule. Flagged for review.",
        "rule_index": -1,
        "ltv_tier": ltv_tier,
        "ltd_tier": ltd_tier,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--cohort", required=True, type=Path)
    parser.add_argument("--matrix", required=True, type=Path)
    parser.add_argument(
        "--cohort-type",
        required=True,
        choices=["pre_churn", "post_churn"],
        help="Which matrix to use: pre_churn_matrix or win_back_matrix",
    )
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    if not args.cohort.exists():
        sys.stderr.write(f"ERROR: cohort file not found: {args.cohort}\n")
        return 2
    if not args.matrix.exists():
        sys.stderr.write(f"ERROR: matrix file not found: {args.matrix}\n")
        return 2

    with args.matrix.open("r", encoding="utf-8") as f:
        matrix_yaml = yaml.safe_load(f)

    ltv_tiers = matrix_yaml.get("ltv_tiers") or {}
    ltd_tiers = matrix_yaml.get("ltd_tiers") or {}

    if args.cohort_type == "pre_churn":
        matrix_rules = matrix_yaml.get("pre_churn_matrix") or []
    else:
        matrix_rules = matrix_yaml.get("win_back_matrix") or []

    if not matrix_rules:
        sys.stderr.write(
            f"ERROR: no matrix rules for cohort type '{args.cohort_type}' in {args.matrix}\n"
        )
        return 2

    with args.cohort.open("r", encoding="utf-8") as f:
        cohort = json.load(f)

    if not isinstance(cohort, list):
        sys.stderr.write("ERROR: cohort JSON must be a list of rows\n")
        return 2

    # Stats for the summary
    action_counts: dict[str, int] = {}

    for row in cohort:
        ltv = float(row.get("ltv") or 0)
        ltd = float(row.get("ltd") or 0)
        reason = row.get("cancel_reason_bucket") or "unknown"

        ltv_tier = bucket_value(ltv, ltv_tiers)
        ltd_tier = bucket_ltd(ltd, ltd_tiers)

        rec = apply_matrix(row, matrix_rules, ltv_tier, ltd_tier, reason)
        row["recommendation"] = rec
        action_counts[rec["action"]] = action_counts.get(rec["action"], 0) + 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8") as f:
        json.dump(cohort, f, indent=2, ensure_ascii=False)

    summary = {
        "total": len(cohort),
        "cohort_type": args.cohort_type,
        "by_action": action_counts,
        "output_path": str(args.output),
    }
    print(json.dumps(summary, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
