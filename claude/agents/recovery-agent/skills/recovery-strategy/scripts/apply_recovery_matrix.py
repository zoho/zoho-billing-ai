#!/usr/bin/env python3
"""
apply_recovery_matrix.py
Applies the recovery-matrix.yaml decision rules to a normalized recovery cohort.

Usage:
    python apply_recovery_matrix.py \
        --cohort  path/to/cohort-raw.json \
        --matrix  path/to/recovery-matrix.yaml \
        --output  path/to/cohort-recommendations.json
"""

import argparse
import json
import sys
from pathlib import Path
from collections import Counter

try:
    import yaml
except ImportError:
    print("PyYAML not installed. Run: pip install pyyaml --break-system-packages", file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------------------
# Tier bucketing helpers
# ---------------------------------------------------------------------------

def bucket_value(lost_value, tiers: dict) -> str:
    """Return the value tier name for a given lost_value (float/int)."""
    val = float(lost_value or 0)
    for tier_name, bounds in tiers.items():
        low  = float(bounds.get("min", 0))
        high = bounds.get("max")
        if high is not None:
            if low <= val < float(high):
                return tier_name
        else:
            if val >= low:
                return tier_name
    return "low"  # fallback


def bucket_recency(days_since_event, tiers: dict) -> str:
    """Return the recency tier name for a given days_since_event (int)."""
    days = int(days_since_event) if days_since_event is not None else None
    if days is None:
        return "recent"  # conservative default

    for tier_name, bounds in tiers.items():
        low  = bounds.get("min_days")
        high = bounds.get("max_days")
        if low is not None and high is not None:
            if low <= days < high:
                return tier_name
        elif low is not None:
            if days >= low:
                return tier_name
        elif high is not None:
            if days <= high:
                return tier_name
    return "cold"  # fallback


# ---------------------------------------------------------------------------
# Rule matching
# ---------------------------------------------------------------------------

def matches_rule(record_tiers: dict, rule_match: dict) -> bool:
    """Check if a record satisfies all conditions in a rule's match block."""
    for field, expected in rule_match.items():
        if record_tiers.get(field) != expected:
            return False
    return True


def apply_matrix(record: dict, matrix: list, value_tiers: dict, recency_tiers: dict) -> dict:
    """Walk the matrix top-to-bottom and return the first matching rule's recommendation."""
    lost_value       = record.get("lost_value") or 0
    days_since_event = record.get("days_since_event")

    value_tier   = bucket_value(lost_value, value_tiers)
    recency_tier = bucket_recency(days_since_event, recency_tiers)

    tiers = {"value": value_tier, "recency": recency_tier}

    for idx, rule in enumerate(matrix):
        match_block = rule.get("match", {})
        if matches_rule(tiers, match_block):
            return {
                "action":       rule.get("action", "accept"),
                "params":       rule.get("params", {}),
                "rationale":    rule.get("rationale", ""),
                "rule_index":   idx,
                "value_tier":   value_tier,
                "recency_tier": recency_tier,
            }

    # No catch-all found
    return {
        "action":       "accept",
        "params":       {},
        "rationale":    "No rule matched — missing catch-all in matrix",
        "rule_index":   -1,
        "value_tier":   value_tier,
        "recency_tier": recency_tier,
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Apply recovery matrix to cohort.")
    parser.add_argument("--cohort",  required=True, help="Path to cohort-raw.json")
    parser.add_argument("--matrix",  required=True, help="Path to recovery-matrix.yaml")
    parser.add_argument("--output",  required=True, help="Path for cohort-recommendations.json")
    args = parser.parse_args()

    # Load inputs
    cohort_path = Path(args.cohort)
    matrix_path = Path(args.matrix)
    output_path = Path(args.output)

    if not cohort_path.exists():
        print(f"ERROR: cohort file not found: {cohort_path}", file=sys.stderr)
        sys.exit(1)

    if not matrix_path.exists():
        print(f"ERROR: matrix file not found: {matrix_path}", file=sys.stderr)
        sys.exit(1)

    with open(cohort_path) as f:
        cohort = json.load(f)

    with open(matrix_path) as f:
        matrix_cfg = yaml.safe_load(f)

    if not cohort:
        print("Cohort is empty — nothing to process.")
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text("[]")
        sys.exit(0)

    value_tiers   = matrix_cfg.get("value_tiers", {})
    recency_tiers = matrix_cfg.get("recency_tiers", {})
    lost_opp_matrix  = matrix_cfg.get("lost_opportunity_matrix", [])
    abandoned_matrix = matrix_cfg.get("abandoned_cart_matrix", [])

    results      = []
    action_counts = Counter()
    missing_catchall_sources = set()
    multi_currency = set()

    for record in cohort:
        source = record.get("source", "unknown")

        if source == "lost_opportunity":
            matrix = lost_opp_matrix
        elif source == "abandoned_cart":
            matrix = abandoned_matrix
        else:
            # Unknown source — apply lost opportunity matrix as fallback
            matrix = lost_opp_matrix

        rec = dict(record)
        recommendation = apply_matrix(rec, matrix, value_tiers, recency_tiers)
        rec["recommendation"] = recommendation

        if recommendation["rule_index"] == -1:
            missing_catchall_sources.add(source)

        action_counts[recommendation["action"]] += 1

        currency = record.get("currency")
        if currency:
            multi_currency.add(currency)

        results.append(rec)

    # Write output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2, default=str)

    # Print summary
    print(f"\nRecovery Strategy Applied")
    print(f"  Total records processed : {len(results)}")
    print(f"\nAction breakdown:")
    for action, count in sorted(action_counts.items(), key=lambda x: -x[1]):
        print(f"  {action:<25} {count}")

    if missing_catchall_sources:
        print(f"\n⚠️  WARNING: rule_index=-1 found for sources: {missing_catchall_sources}")
        print("   This means the matrix is missing a catch-all rule (match: {}).")
        print("   Add one at the bottom of each affected matrix section in recovery-matrix.yaml.")

    if len(multi_currency) > 1:
        print(f"\n⚠️  NOTE: Multiple currencies detected ({', '.join(multi_currency)}).")
        print("   Value tier bucketing uses raw numbers — review cross-currency records.")

    print(f"\nOutput written to: {output_path}")

    # Exit with error if catch-all is missing
    if missing_catchall_sources:
        sys.exit(2)


if __name__ == "__main__":
    main()
