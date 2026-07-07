# Zoho Billing AI

> **AI-powered skills and agents for Zoho Billing** — query data, automate workflows, and surface insights using Claude, ChatGPT, or Gemini.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square)](LICENSE)
[![Stars](https://img.shields.io/github/stars/zoho/zoho-billing-ai?style=flat-square)](https://github.com/zoho/zoho-billing-ai/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/zoho/zoho-billing-ai?style=flat-square)](https://github.com/zoho/zoho-billing-ai/commits/main)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/zoho/zoho-billing-ai/pulls)
[![Works with Claude](https://img.shields.io/badge/AI-Claude-orange?style=flat-square)](https://claude.ai)
[![Works with ChatGPT](https://img.shields.io/badge/AI-ChatGPT-green?style=flat-square)](https://chat.openai.com)
[![Works with Gemini](https://img.shields.io/badge/AI-Gemini-purple?style=flat-square)](https://gemini.google.com)

---

## What is this?

**Zoho Billing AI** is a collection of **skills and agents** that bring AI into your Zoho Billing workflows. Instead of navigating dashboards, writing scripts, or exporting data — you describe what you need in plain language, and the AI does the rest.

Skills and agents in this repo are built on top of the **[Zoho Billing MCP server](https://github.com/zoho/zoho-billing-mcp)**, which provides the connection between any AI model and your Zoho Billing data.

```
You (natural language)
        │
        ▼
  AI Model (Claude / ChatGPT / Gemini)
        │
        ▼
  Zoho Billing MCP  ──→  github.com/zoho/zoho-billing-mcp
        │
        ▼
  Zoho Billing APIs
  (Subscriptions, Invoices, Customers, Reports…)
```

---

## See it in action

**You ask:**

> *"Who should I chase for payments today?"*

**The Collections skill responds:**

```
Collections Worklist — 29 Jun 2026
────────────────────────────────────────────
 #  Customer             Outstanding   Days     Score   Action
────────────────────────────────────────────
 1  Acme Corp            $48,200       92d      94      ⚠ Escalate
 2  Northwind Traders    $31,500       45d      78      📞 Phone call
 3  Globex Industries    $22,750       67d      71      📧 Email + link
 4  Initech LLC          $18,300       31d      52      📧 Email
 5  Soylent Co.          $12,900       58d      49      📧 Email

Total at-risk AR: $133,650 across 5 accounts
```

No dashboards. No SQL. No exports. Just a question.

---

## What makes this different

Each skill is a **self-contained, ready-to-run workflow** defined entirely in a prompt file. Plug it into your AI assistant and start using it — no SDK, no deployment, no custom code.

- **Prompt-driven.** Skills are plain-text files. Anyone who can paste text into an AI assistant can run them.
- **Action-oriented, not query-only.** Skills process, rank, analyse, and deliver structured outputs — not just raw data retrieval.
- **Finished workflows over building blocks.** Each skill covers one well-defined job end-to-end.
- **Model-agnostic.** Works identically with Claude, ChatGPT, or Gemini via the [Zoho Billing MCP](https://github.com/zoho/zoho-billing-mcp).

---

## Prerequisites

1. **A Zoho Billing account** with API access enabled
2. **Zoho Billing MCP** set up and connected — see [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) for setup
3. An AI assistant that supports MCP tool use (Claude, ChatGPT, or Gemini)

---

## Quickstart

### Claude Code CLI

Install all agents and skills with one command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh)
```

Or clone and run locally:

```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
bash install.sh
```

Then invoke a skill directly in Claude Code:

```
/mrr-growth
/collections-today
/customer-360 Acme Corp
```

See [INSTALLATION.md](INSTALLATION.md) for full setup, configuration, and troubleshooting.

### OpenAI Codex

Install directly from the Codex desktop app — no terminal needed:

1. Open the **Plugins** sidebar in Codex
2. Scroll to **Built by OpenAI** → click **Add More**
3. Enter source: `https://github.com/zoho/zoho-billing-ai` → click **Add Marketplace**
4. Browse the agent list and click **Install**

### Claude Cowork

Download `.plugin` files from [Releases](https://github.com/zoho/zoho-billing-ai/releases) and upload them directly to Claude Cowork.

### Direct Prompt Integration

1. Clone this repo
2. Connect [Zoho Billing MCP](https://github.com/zoho/zoho-billing-mcp) to your AI assistant
3. Paste the contents of any `SKILL.md` into your system prompt and ask in plain English

---

## Skills Catalog

Skills live under `.claude/skills/<name>/SKILL.md` and are invoked as `/skill-name` in Claude Code.

### Analytics & Revenue

| Skill | What it does | Invoke |
|---|---|---|
| [mrr-growth](.claude/skills/mrr-growth/SKILL.md) | MRR waterfall: new, expansion, reactivation, contraction, churn | `/mrr-growth` |
| [arr-snapshot](.claude/skills/arr-snapshot/SKILL.md) | ARR with gross vs net, QoQ/YoY trend, trajectory classification | `/arr-snapshot` |
| [nrr-check](.claude/skills/nrr-check/SKILL.md) | Net Revenue Retention vs SaaS benchmarks + cohort heatmap | `/nrr-check` |
| [mrr-quick-ratio](.claude/skills/mrr-quick-ratio/SKILL.md) | Growth quality: (new + expansion) / (contraction + churn) | `/mrr-quick-ratio` |
| [churn-breakdown](.claude/skills/churn-breakdown/SKILL.md) | Voluntary vs involuntary churn decomposition by product | `/churn-breakdown` |
| [subscription-kpis](.claude/skills/subscription-kpis/SKILL.md) | Weekly/monthly digest: MRR, ARR, activations, churn rate, NRR | `/subscription-kpis` |
| [refund-analysis](.claude/skills/refund-analysis/SKILL.md) | Refund anomalies: product spikes, country spikes, repeat-refunders | `/refund-analysis` |
| [revenue-recognition-health](.claude/skills/revenue-recognition-health/SKILL.md) | ASC 606 / IFRS 15 health: deferred vs recognized, month-end checklist | `/revenue-recognition-health` |
| [expansion-opportunities](.claude/skills/expansion-opportunities/SKILL.md) | Customers who've outgrown their plan — ranked by expansion MRR potential | `/expansion-opportunities` |
| [quote-prioritizer](.claude/skills/quote-prioritizer/SKILL.md) | Open quotes ranked by staleness score and expected close value | `/quote-prioritizer` |

### Operational Lookups

| Skill | What it does | Invoke |
|---|---|---|
| [invoice-aging](.claude/skills/invoice-aging/SKILL.md) | All overdue invoices in aging buckets (0-30, 31-60, 61-90, 90+) | `/invoice-aging` |
| [dunning-queue](.claude/skills/dunning-queue/SKILL.md) | PAST_DUE and UNPAID subscriptions ranked by MRR | `/dunning-queue` |
| [trials-expiring](.claude/skills/trials-expiring/SKILL.md) | Active trials sorted by expiry date, marks ≤3 days urgent | `/trials-expiring [days]` |
| [catalog-browser](.claude/skills/catalog-browser/SKILL.md) | All products, plans, addons, and items with pricing | `/catalog-browser` |
| [renewals-this-week](.claude/skills/renewals-this-week/SKILL.md) | Upcoming renewals with motion: pitch annual / upgrade / save-call | `/renewals-this-week [days]` |

### Investigation & Diagnosis

| Skill | What it does | Invoke |
|---|---|---|
| [invoice-investigator](.claude/skills/invoice-investigator/SKILL.md) | Full invoice timeline: charges, payments, gaps — answers "did they pay?" | `/invoice-investigator [INV-# or customer]` |
| [payment-failure-diagnosis](.claude/skills/payment-failure-diagnosis/SKILL.md) | Maps gateway error codes to plain English + fix playbook | `/payment-failure-diagnosis [customer]` |
| [subscription-lookup](.claude/skills/subscription-lookup/SKILL.md) | Full subscription lifecycle + last 6 invoices and payments | `/subscription-lookup [SUB-# or customer]` |
| [collections-today](.claude/skills/collections-today/SKILL.md) | AR worklist ranked by recovery score (balance × pay probability) | `/collections-today` |
| [card-expiry-risk](.claude/skills/card-expiry-risk/SKILL.md) | Cards expiring in 30/60 days ranked by MRR at risk | `/card-expiry-risk` |
| [trial-pulse](.claude/skills/trial-pulse/SKILL.md) | Conversion likelihood score per trial + nudge recommendation | `/trial-pulse` |
| [bad-debt-risk](.claude/skills/bad-debt-risk/SKILL.md) | Write-off risk scoring — surfaces AR still saveable | `/bad-debt-risk` |

---

## Agent Plugins

For more complex, multi-step workflows, use the installable agent plugins:

| Agent | Description | Platform |
|---|---|---|
| [analyst-agent](plugins/agent-plugins/analyst-agent/) | Full-spectrum business analyst — sales, collections, subscription scorecard | Claude + Codex |
| [dunning-agent](plugins/agent-plugins/dunning-agent/) | Analyse dunning subscriptions, score by MRR at risk, remediation report | Claude + Codex |
| [payment-intelligence-agent](plugins/agent-plugins/payment-intelligence-agent/) | Predict and prevent involuntary churn via payment failure analysis | Claude + Codex |
| [quote-agent](plugins/agent-plugins/quote-agent/) | Rank open quotes by staleness and close value, recommend next moves | Claude + Codex |
| [recovery-agent](plugins/agent-plugins/recovery-agent/) | Signup recovery — lost opportunities and abandoned carts | Claude + Codex |
| [retention-agent](plugins/agent-plugins/retention-agent/) | Pre-churn and win-back — detect at-risk subscriptions, recommend offers | Claude + Codex |

---

## Architecture

```
┌──────────────────────────────────────────┐
│            Your AI Assistant             │
│   (Claude / ChatGPT / Gemini)            │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  Skill or Agent Prompt             │  │
│  │  (SKILL.md / agent plugin)         │  │
│  └────────────────┬───────────────────┘  │
└───────────────────┼──────────────────────┘
                    │  Tool calls (MCP)
                    ▼
┌──────────────────────────────────────────┐
│  Zoho Billing MCP                        │
│  github.com/zoho/zoho-billing-mcp        │
└───────────────────┬──────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │     Zoho Billing      │
        │  Subscriptions        │
        │  Invoices             │
        │  Customers            │
        │  Reports & Analytics  │
        └───────────────────────┘
```

---

## FAQ

**Do I need to write any code to use these skills?**
No. Skills are plain prompt files. Install them and start asking questions in plain English.

**Why MCP and not a custom integration per AI vendor?**
MCP (Model Context Protocol) is an open standard. One MCP server works across Claude, ChatGPT, Gemini, and any future model that supports it.

**Is my Zoho Billing data sent to the AI vendor?**
Only the data the AI explicitly fetches through MCP tool calls. The MCP server brokers every call — nothing leaves Zoho without an explicit tool invocation.

**Can I write my own skills?**
Yes. Copy any `SKILL.md` as a template, adjust the workflow, and open a PR.

---

## Contributing

1. Open an issue describing the workflow you want to automate
2. Fork the repo and add a new `.claude/skills/<your-skill>/SKILL.md`
3. Submit a PR — include a sample prompt and sample output

---

## Resources

| Resource | Description |
|---|---|
| [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) | MCP server for Zoho Billing — setup, authentication, and model connection |
| [Zoho Billing API Docs](https://www.zoho.com/billing/api/) | Full Zoho Billing API reference |
| [Model Context Protocol](https://modelcontextprotocol.io) | The open standard behind model-agnostic tool use |

---

## License

Released under the [Apache License 2.0](LICENSE).

---

<p align="center">
  Powered by <strong><a href="https://github.com/zoho/zoho-billing-mcp">Zoho Billing MCP</a></strong> · Works with <strong>Claude</strong>, <strong>ChatGPT</strong>, and <strong>Gemini</strong>
</p>
