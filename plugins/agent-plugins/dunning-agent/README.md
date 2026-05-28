# dunning-agent

Proactively prevent involuntary churn by analysing your live dunning pipeline, scoring every at-risk subscription by revenue, customer value, and urgency, and producing a human-review-ready prioritised action report.

## What It Does

The dunning agent runs a three-step pipeline on demand:

1. **Cohort Builder** — Fetches every subscription currently in dunning from Zoho Billing (all pages), computes a composite priority score for each using configurable weights (amount at risk, LTV, lifetime duration, retry count), and groups subscriptions by gateway error code.

2. **Action Planner** — Applies error-code-specific playbooks from the decision matrix to assign a recommended action, communication template, retry delay, and optional incentive to every subscription. Flags subscriptions that need escalation and identifies high-value customers for personal outreach.

3. **Report** — Synthesises the scored and annotated cohort into a single Markdown report covering:
   - Executive summary (total revenue at risk, P0–P3 breakdown, dominant error codes)
   - Error-code segment table (revenue exposure and recommended strategy per error type)
   - Prioritised action list (P0 → P3, within tier by composite score)
   - Playbook reference cards per error code
   - Recommended next steps grouped by urgency window

## Priority Tiers

| Tier | Label | Action Window |
|---|---|---|
| 🔴 P0 | Emergency | Act within 24 hours |
| 🟠 P1 | High | Act within 48 hours |
| 🟡 P2 | Medium | Act within 5 business days |
| ⚪ P3 | Low | Monitor |

P0 is triggered by a composite score ≥ 75 **or** a retry-count override for high-LTV / long-tenure customers — ensuring your most valuable subscribers are never silently lost.

## Priority Score Formula

```
score = (weight_amount × score_amount) + (weight_ltv × score_ltv) + (weight_ltd × score_ltd) + (weight_retry × score_retry)
```

Default weights: Amount 35% · LTV 30% · LTD 20% · Retry count 15%.
All weights and thresholds are tunable in `config/dunning-matrix.yaml`.

## Skills

| Skill | Purpose |
|---|---|
| `dunning-orchestrator` | Full pipeline — invoke this for any dunning analysis request |
| `dunning-cohort-builder` | Fetch + score + group only (feeds action planner) |
| `dunning-action-planner` | Apply playbooks to a scored cohort (feeds orchestrator) |

## Configuration

Edit `config/dunning-matrix.yaml` to tune:
- **Priority scoring weights** — how much amount, LTV, LTD, and retry count each contribute
- **Customer tier thresholds** — LTV and LTD values that define high / medium / low tiers
- **Error-code playbooks** — per-error-code remediation strategy, retry delay, escalation threshold, communication template, and optional incentive
- **Incentive definitions** — discount amounts and durations

No code changes needed — the skills read from the YAML at each run.

## Propose-Only Guarantee

This agent **never** modifies subscriptions, sends emails, applies retries, or changes any customer data. All output is a Markdown report for human review. Every recommended action requires explicit human approval before execution.

## Setup

### Cowork
Settings → Plugins → Add plugin → paste this repo URL → select **dunning-agent**.

### Claude Code
```bash
claude plugin install dunning-agent@zoho-billing-ai
```

### Required Environment Variables

| Variable | Description |
|---|---|
| `ZOHO_BILLING_ORG_ID` | Your Zoho Billing Organisation ID |
| `ZOHO_BILLING_OAUTH_TOKEN` | OAuth token with `ZohoSubscriptions.reports.READ` scope |
| `ZOHO_DOMAIN` | Data-centre domain (`zoho.com` default, `zoho.in` for India DC) |

## Example Prompts

- *"Show me the dunning report"*
- *"Which subscriptions are at risk right now?"*
- *"Who are my P0 dunning customers this month?"*
- *"What's the dominant gateway error in dunning?"*
- *"Prioritise the dunning pipeline — focus on high-LTV customers"*
- *"Give me the full dunning action plan for this week"*
