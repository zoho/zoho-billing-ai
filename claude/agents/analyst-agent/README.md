# Analyst Agent

Full-spectrum business analyst for Zoho Billing. Runs three parallel analysis
tracks and synthesises them into a single business-health scorecard.

## What it does

| Skill | Data sources | Output |
|---|---|---|
| **Sales Performance** | Invoice details, credit notes, sales by item, sales by plan | Revenue trend, top items/plans, credit-note pressure, MoM delta |
| **Collection Performance** | Payments received, refund history, payment failures, renewal failures | Collection efficiency, refund rate, failure rate, cash-at-risk |
| **Subscription Growth** | Subscriptions summary, MRR, activations, product/country breakdown | MRR trajectory, churn rate, net growth, geo/product mix |
| **Business Health Orchestrator** | All three pillars combined | Overall scorecard, cross-pillar insights, executive narrative, recommended actions |

All skills are **read-only** — no mutating API calls, no automated actions.
Every output is a Markdown report for human review.

## Skills

```
skills/
  sales-performance-analysis/      # Invoice + credit note + item/plan analysis
  collection-performance-analysis/ # Payments + refunds + failure rates
  subscription-growth-analysis/    # MRR + churn + activations by product/country
  business-health-orchestrator/    # Full pipeline → Business Health Report
```

## Config

`config/analyst-thresholds.yaml` defines what "healthy", "watch", and "at risk"
mean for each metric. Edit this file to tune the agent to your business — no
code changes required.

Key threshold groups:
- `revenue` — MoM growth, credit note ratio, item concentration
- `collections` — efficiency %, refund rate, failure rate
- `subscriptions` — MRR growth, churn rate, net growth, concentration

## Report output

Reports are written to:
```
analysis-runs/<YYYY-MM-DD>/business-health-report.md
```

The orchestrator will not overwrite an existing report without asking.

## Usage

### Run the full analysis
> "Run a full business health analysis"
> "How is the business doing this month?"
> "Monthly business review"

### Run individual pillars
> "Analyse sales performance this month"
> "Show me collection performance vs last month"
> "Subscription growth analysis"

### Use specific skills standalone
Each skill can be invoked independently — useful for ad hoc questions about
a single pillar without triggering the full pipeline.

## Installation

**Cowork** — Settings → Plugins → Add plugin → paste this repo URL → select `analyst-agent`.

**Claude Code:**
```bash
claude plugin install analyst-agent@zoho-billing-ai
```

## Required environment variables

| Variable | Description |
|---|---|
| `ZOHO_BILLING_ORG_ID` | Your Zoho Billing Organisation ID |
| `ZOHO_BILLING_OAUTH_TOKEN` | OAuth token with `ZohoSubscriptions.reports.READ` scope |
| `ZOHO_DOMAIN` | Data-centre domain — `zoho.com` (default) or `zoho.in` |
