# zoho-billing-ai — Codex Plugin Guide

Agent plugins and skills for Zoho Billing workflows — built for [Codex](https://developers.openai.com/codex/plugins).

## Available agents

| Plugin | Description |
|--------|-------------|
| `analyst-agent` | Full-spectrum business analyst — sales, collections, subscription growth scorecard |
| `dunning-agent` | Analyse dunning subscriptions, score by revenue at risk, produce prioritised remediation report |
| `payment-intelligence-agent` | Predict and prevent involuntary churn via payment failure analysis and recovery recommendations |
| `quote-agent` | Rank open quotes by staleness and close value, recommend next moves |
| `recovery-agent` | Signup recovery — lost opportunities and abandoned carts ranked by lost value |
| `retention-agent` | Pre-churn and win-back — detect at-risk subscriptions, classify cancel reasons, recommend offers |

---

## Install from this repo marketplace

### Codex app
1. Open **Plugins** in the Codex app
2. Add this repo as a marketplace source — paste the repo URL when prompted
3. Browse **zoho-billing-ai** and click **Add to Codex** next to the agent you want

### Codex CLI
```bash
codex plugin marketplace add zoho/zoho-billing-ai
/plugins    # open plugin browser, select and install
```

