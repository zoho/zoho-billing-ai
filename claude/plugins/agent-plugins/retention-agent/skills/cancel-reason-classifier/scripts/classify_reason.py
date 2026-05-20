#!/usr/bin/env python3
"""
classify_reason.py — deterministic, keyword-based bucketing of cancel reasons.

Reads the reason taxonomy from the shared retention-matrix.yaml file and
classifies each raw cancel reason into one of the canonical buckets defined
in `reason_taxonomy`. Returns `unknown` when no keyword matches.

Why keyword-first (rather than LLM-first):
  - Free-text reasons are short and repetitive; keywords cover ~80%+ in practice.
  - Deterministic output is auditable — a reviewer can always see why a row
    was bucketed a given way.
  - No tokens consumed. The LLM fallback (in the SKILL.md workflow) handles
    only the residue.

Usage:
    python classify_reason.py \\
        --cohort path/to/cohort.json \\
        --matrix path/to/retention-matrix.yaml \\
        --output path/to/cohort-classified.json

Input cohort JSON shape (list of rows):
    [
      {"subscription_id": "sub_1", "cancel_reason_raw": "too expensive", ...},
      ...
    ]

Output adds a `cancel_reason_bucket` field and a `cancel_reason_match` debug
field showing which keyword matched (or null for unknown).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "ERROR: PyYAML is not installed. Install it with:\n"
        "    pip install pyyaml --break-system-packages\n"
    )
    sys.exit(2)


def load_taxonomy(matrix_path: Path) -> dict[str, list[str]]:
    """Load the reason_taxonomy section from retention-matrix.yaml."""
    with matrix_path.open("r", encoding="utf-8") as f:
        matrix = yaml.safe_load(f)
    taxonomy = matrix.get("reason_taxonomy") or {}
    # Normalize: {bucket_name: [lowercased keywords]}
    return {
        bucket: [kw.lower() for kw in (cfg.get("keywords") or [])]
        for bucket, cfg in taxonomy.items()
    }


def classify(reason_raw: str, taxonomy: dict[str, list[str]]) -> tuple[str, str | None]:
    """
    Return (bucket_name, matched_keyword_or_None).
    First bucket with a keyword found as substring of the lower-cased reason wins.
    """
    if not reason_raw or not reason_raw.strip():
        return ("unknown", None)
    haystack = reason_raw.lower()
    for bucket, keywords in taxonomy.items():
        for kw in keywords:
            if kw and kw in haystack:
                return (bucket, kw)
    return ("unknown", None)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--cohort", required=True, type=Path, help="Path to cohort JSON file")
    parser.add_argument("--matrix", required=True, type=Path, help="Path to retention-matrix.yaml")
    parser.add_argument("--output", required=True, type=Path, help="Path to write classified cohort JSON")
    args = parser.parse_args()

    if not args.cohort.exists():
        sys.stderr.write(f"ERROR: cohort file not found: {args.cohort}\n")
        return 2
    if not args.matrix.exists():
        sys.stderr.write(f"ERROR: matrix file not found: {args.matrix}\n")
        return 2

    taxonomy = load_taxonomy(args.matrix)
    if not taxonomy:
        sys.stderr.write(f"ERROR: no reason_taxonomy section found in {args.matrix}\n")
        return 2

    with args.cohort.open("r", encoding="utf-8") as f:
        cohort = json.load(f)

    if not isinstance(cohort, list):
        sys.stderr.write("ERROR: cohort JSON must be a list of rows\n")
        return 2

    # Stats for the run summary
    bucket_counts: dict[str, int] = {}
    unmatched: list[dict] = []

    for row in cohort:
        bucket, matched_kw = classify(row.get("cancel_reason_raw", ""), taxonomy)
        row["cancel_reason_bucket"] = bucket
        row["cancel_reason_match"] = matched_kw
        bucket_counts[bucket] = bucket_counts.get(bucket, 0) + 1
        if bucket == "unknown":
            unmatched.append({
                "subscription_id": row.get("subscription_id"),
                "cancel_reason_raw": row.get("cancel_reason_raw", ""),
            })

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8") as f:
        json.dump(cohort, f, indent=2, ensure_ascii=False)

    # Print a short summary to stdout — the SKILL.md uses this to decide
    # whether to invoke the LLM fallback for the unknown rows.
    summary = {
        "total": len(cohort),
        "by_bucket": bucket_counts,
        "unknown_count": bucket_counts.get("unknown", 0),
        "unknown_examples": unmatched[:10],  # first 10 for inspection
        "output_path": str(args.output),
    }
    print(json.dumps(summary, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
