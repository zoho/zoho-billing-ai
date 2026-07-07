# zoho-billing-ai — Plugin & Skill Guide

Agent plugins and skills for Zoho Billing workflows — compatible with **Claude Code**, **Claude Cowork**, and **OpenAI Codex**.

## Available agent plugins

| Plugin | Description |
|--------|-------------|
| `analyst-agent` | Full-spectrum business analyst — sales, collections, subscription growth scorecard |
| `dunning-agent` | Analyse dunning subscriptions, score by MRR at risk, produce prioritised remediation report |
| `payment-intelligence-agent` | Predict and prevent involuntary churn via payment failure analysis and recovery recommendations |
| `quote-agent` | Rank open quotes by staleness and close value, recommend next moves |
| `recovery-agent` | Signup recovery — lost opportunities and abandoned carts ranked by lost value |
| `retention-agent` | Pre-churn and win-back — detect at-risk subscriptions, classify cancel reasons, recommend offers |

## Available standalone skills

Standalone skills are invoked directly as `/skill-name` — no agent installation needed.

| Skill | Category | Description |
|-------|----------|-------------|
| `mrr-growth` | Analytics | MRR waterfall: new, expansion, contraction, churn |
| `arr-snapshot` | Analytics | ARR with YoY trend and trajectory |
| `nrr-check` | Analytics | Net Revenue Retention vs industry benchmarks |
| `mrr-quick-ratio` | Analytics | Growth quality score |
| `churn-breakdown` | Analytics | Voluntary vs involuntary churn by product |
| `subscription-kpis` | Analytics | Weekly/monthly KPI digest |
| `refund-digest` | Analytics | Refund anomaly detection |
| `dso-check` | Analytics | Days Sales Outstanding trend |
| `revenue-recognition-health` | Analytics | ASC 606 / IFRS 15 health check |
| `upsell-candidates` | Analytics | Customers outgrowing their plan |
| `quotes-pipeline` | Analytics | Open quote pipeline ranked by staleness |
| `customer-360` | Lookup | Full customer profile |
| `overdue-invoices` | Lookup | Overdue invoices in aging buckets |
| `past-due-subscriptions` | Lookup | PAST_DUE and UNPAID subscriptions |
| `trial-watch` | Lookup | Active trials sorted by expiry |
| `catalog-browser` | Lookup | Products, plans, addons, items |
| `coupon-lookup` | Lookup | All coupons with usage and expiry |
| `renewals-this-week` | Lookup | Upcoming renewals with recommended motion |
| `invoice-investigator` | Investigation | Invoice timeline — "did they pay?" |
| `payment-failure-diagnosis` | Investigation | Gateway error → plain English + fix |
| `subscription-deep-dive` | Investigation | Full subscription lifecycle |
| `collections-today` | Investigation | AR worklist ranked by recovery score |
| `card-expiry-risk` | Investigation | Cards expiring soon ranked by MRR |
| `trial-pulse` | Investigation | Trial conversion likelihood scoring |
| `bad-debt-risk` | Investigation | Write-off risk scoring |
| `dunning-status` | Investigation | Active dunning queue with save actions |
| `create-invoice` | Creation | Guided invoice creation with confirm step |
| `create-quote` | Creation | Guided quote creation with confirm step |
| `create-coupon` | Creation | Guided coupon creation with confirm step |
| `new-plan-setup` | Creation | Guided plan creation with confirm step |

---

## Install agents for Claude Code CLI

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh)
```

Or from a local clone:

```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
bash install.sh
```

This copies all agent plugins to `~/.claude/plugins/` and all standalone skills to `~/.claude/skills/`.

## Install agents for Claude Cowork

1. Download the `.plugin` file for each agent from [Releases](https://github.com/zoho/zoho-billing-ai/releases)
2. Open Claude Cowork → Settings → Plugins → Add Plugin
3. Upload the `.plugin` file
4. The agent is immediately available in your workspace

Or install from this repo URL directly:
- Settings → Plugins → Add plugin → paste `https://github.com/zoho/zoho-billing-ai`

## Install agents for OpenAI Codex

### Codex desktop app

1. Open **Plugins** in the Codex app
2. Add this repo as a marketplace source — paste the repo URL when prompted
3. Browse **zoho-billing-ai** and click **Add to Codex** next to the agent you want

### Codex CLI

```bash
codex plugin marketplace add zoho/zoho-billing-ai
/plugins    # open plugin browser, select and install
```

---

## Plugin structure

Each agent plugin has a consistent layout:

```
plugins/agent-plugins/<agent-name>/
├── .claude-plugin/
│   └── plugin.json        ← Claude plugin manifest
├── .codex-plugin/
│   └── plugin.json        ← Codex plugin manifest (mirrors Claude)
├── skills/
│   └── <skill-name>/
│       └── SKILL.md       ← Skill prompt file
├── config/
│   └── *.yaml             ← Tunable thresholds and decision matrices
└── README.md
```

Both `plugin.json` files must be kept in sync when adding or changing skills.

## Skill structure

Standalone skills live at `.claude/skills/<skill-name>/SKILL.md`. Skill command = directory name.

```
.claude/skills/<skill-name>/
├── SKILL.md               ← Skill prompt (frontmatter + instructions)
└── references/            ← Optional supporting files (output formats, tables)
    └── output-format.md
```

Key frontmatter fields:

```yaml
---
name: Skill Display Name
description: >
  When to trigger this skill — used by Claude to auto-invoke.
when_to_use: >
  Trigger phrases list.
argument-hint: "[what to pass]"
disable-model-invocation: true   # set for creation skills
---
```

## Adding a new agent plugin

1. Copy an existing plugin: `cp -r plugins/agent-plugins/retention-agent plugins/agent-plugins/my-new-agent`
2. Update both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`
3. Add entry to `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`
4. Add skills under `skills/`
5. Run `./scripts/build-plugin.sh my-new-agent` to verify the zip

## Adding a new standalone skill

1. Create the directory: `mkdir -p .claude/skills/my-skill`
2. Write `SKILL.md` with correct frontmatter
3. Test by invoking `/my-skill` in Claude Code
