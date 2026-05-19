# Recovery Agent

> **Signup and cart recovery workflow for Zoho Billing.** Fetches the last 7 days of lost opportunities and abandoned carts, ranks them by lost value, applies a tunable YAML decision matrix, and produces a propose-only Markdown recovery action report for human review.

The agent is **propose-only**: it never sends emails, applies discounts, or modifies records in Zoho. Every output is a Markdown proposal file for a human to act on.

---

## Skills in this plugin

| Skill | What it does |
|---|---|
| `recovery-orchestrator` | End-to-end run — fetches cohort, applies strategy, writes the proposal report. Main entry point. |
| `recovery-cohort-builder` | Fetches and normalizes the last 7 days of lost opportunities + abandoned carts, sorted by lost value. |
| `recovery-strategy` | Applies the YAML decision matrix and recommends a per-record action (human outreach, email with discount, email reminder, email sequence, or accept). |

---

## How it works

```
Lost Opportunities (7d)  ─┐
                           ├─→  Normalized cohort  ─→  Decision matrix  ─→  proposal.md
Abandoned Carts (7d)     ─┘      (sorted by $)         (recovery-matrix.yaml)
```

**Priority order in the report:**
1. Lost Opportunities — sorted by lost value DESC
2. Abandoned Carts — sorted by lost value DESC

Abandoned carts appear second in the report because they represent the highest purchase intent (the visitor chose a plan and started checkout). The Sales team should action `urgent` rows from both sections immediately; marketing queues the rest.

---

## Installation

**Cowork** — Settings → Plugins → Add plugin → paste this repo URL, then select `recovery-agent`.

**Claude Code:**
```bash
claude plugin install recovery-agent@zoho/zoho-billing-ai
```

---

## Quickstart

Once the Zoho Billing MCP is connected, ask:

> *"Run today's recovery review."*

or

> *"What leads and carts did we lose this week?"*

The orchestrator fetches the last 7 days, applies the recovery matrix, and saves a proposal to `recovery-runs/<date>/proposal.md`.

Other useful phrases:
- *"Build the recovery cohort for this week."* → runs `recovery-cohort-builder` standalone
- *"Apply the recovery strategy to the cohort."* → runs `recovery-strategy` standalone
- *"Show me what abandoned carts we have."* → triggers the cohort builder, filtered mentally to abandoned carts

---

## Tuning the decision matrix

Edit `config/recovery-matrix.yaml` to change:

- **`value_tiers`** — adjust the ACV thresholds for `high` / `medium` / `low`
- **`recency_tiers`** — adjust how many days counts as `fresh` vs `recent` vs `cold`
- **`lost_opportunity_matrix`** — change what action to take for each value × recency combination
- **`abandoned_cart_matrix`** — same for abandoned carts

No code changes needed — the strategy script reads the YAML on every run.

---

## Output files

Each run saves three files under `recovery-runs/<DATE>/`:

| File | Contents |
|------|----------|
| `cohort-raw.json` | Normalized cohort (lost opps + carts), sorted by lost value |
| `cohort-recommendations.json` | Cohort with per-record recommendation appended |
| `proposal.md` | Human-readable action proposal |

---

## What the plugin doesn't do

- **No outbound communication.** It never sends emails, posts Cliq messages, or modifies subscriptions.
- **No credential storage.** OAuth tokens stay in your environment variables.
- **No cross-tenant data.** Each run uses the org the `ZOHO_BILLING_ORG_ID` env var points to.

---

## License

Apache 2.0 — see the [repo root](../../LICENSE).
