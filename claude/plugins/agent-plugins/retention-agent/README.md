# Retention Agent

> **Pre-churn and win-back retention workflow for Zoho Billing.** Detects at-risk subscriptions, classifies cancel reasons, applies a tunable YAML decision matrix (LTV × LTD × reason), and produces a propose-only Markdown recommendation report for human review.

This is a Claude Code plugin. It bundles the Zoho Billing MCP declaration so you don't have to wire it up manually — but you still need to set two credentials before the first run.

---

## Skills in this plugin

| Skill | What it does |
|---|---|
| `retention-orchestrator` | End-to-end run — pulls the cohort, classifies reasons, applies the matrix, produces the report. The main entry point. |
| `churn-cohort-builder` | Builds the at-risk cohort (pre-churn non-renewing + post-churn win-back) from Zoho Billing reports. |
| `cancel-reason-classifier` | Buckets free-text cancel reasons into canonical categories (price, feature_gap, temporary, quality, business_end, duplicate_account, unknown). |
| `offer-recommender` | Applies the YAML decision matrix and recommends a per-subscription action (discount, pause, downgrade, human_triage, standard_offer, accept). |

The agent is **propose-only**: it never sends emails, applies discounts, or modifies subscriptions. Every output is a Markdown recommendation file for human approval.

---

## Installation

**1. Install the plugin**

From a marketplace:
```
/plugin install retention-agent@<marketplace-name>
```

Or directly from this repo:
```
/plugin install retention-agent@zoho/zoho-billing-ai
```

**2. Set your Zoho Billing credentials**

The plugin ships with `.mcp.json` declaring the Zoho Billing MCP server, but it pulls credentials from environment variables at runtime so secrets never live in the plugin files.

Set these in your shell before launching Claude Code (add them to `~/.zshrc`, `~/.bashrc`, or your IDE's env config so they persist):

```bash
export ZOHO_BILLING_ORG_ID="your-org-id"
export ZOHO_BILLING_OAUTH_TOKEN="your-oauth-token"
```

To get these values, follow the setup in [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) — the org ID is in your Zoho Billing settings, and the OAuth token comes from the Zoho API Console flow.

**3. Verify the MCP is connected**

Restart Claude Code (so the new env vars are picked up) and run:

```
/mcp
```

You should see `Zoho-MCP` listed with status `connected`. If it shows `failed`, double-check the two env vars are set in the shell where Claude Code launched.

---

## Quickstart

Once the MCP is connected, just ask:

> *"Run today's retention review."*

The orchestrator skill takes over: pulls the at-risk cohort, classifies reasons, applies the decision matrix, and writes a Markdown proposal file under `retention-runs/<date>/proposal.md` for you to review.

Other useful phrases:
- *"Pull the pre-churn cohort for the next 30 days."* → runs `churn-cohort-builder` standalone
- *"Classify yesterday's cancel reasons."* → runs `cancel-reason-classifier` standalone
- *"What should we offer each at-risk customer?"* → runs `offer-recommender` standalone

---

## Tuning the decision matrix

The decision matrix lives in `config/decision-matrix.yaml`. Edit thresholds, reason → action mappings, and offer parameters there — the strategy engine reads them at every run, no code changes needed.

---

## What the plugin doesn't do

- **No outbound communication.** The agent never emails customers, posts to Cliq, or modifies subscriptions in Zoho. Every output is a proposal file for human review.
- **No credential storage.** OAuth tokens stay in your environment; the plugin reads them via env-var substitution at MCP startup.
- **No cross-tenant data.** Each run uses whatever org the `ZOHO_BILLING_ORG_ID` env var points to.

---

## Troubleshooting

**`/mcp` shows Zoho-MCP as `failed`**
→ Env vars not set in the shell that launched Claude Code. `echo $ZOHO_BILLING_ORG_ID` should return your org ID. If it doesn't, add the `export` lines to your shell rc file and restart your terminal *and* Claude Code.

**Skill says "no subscriptions in cohort"**
→ Legitimate result — no one is non-renewing right now. Try the post-churn (win-back) cohort instead, or widen the date window.

**Conflict with an existing Zoho-MCP server**
→ If you already had a server named `Zoho-MCP` configured before installing this plugin, the plugin's declaration will silently override yours. Inspect your global `~/.claude/.mcp.json` if behaviour seems off.

---

## License

Apache 2.0 — see the [repo root](../LICENSE).
