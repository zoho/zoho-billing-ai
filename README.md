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

Skills and agents in this repo are built on top of the **[Zoho Billing MCP server](https://github.com/zoho/zoho-billing-mcp)**, which provides the connection between any AI model and your Zoho Billing data. For MCP setup, authentication, and model connection details, refer to the [zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) repo.

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

**The Cash Collection Prioritization skill responds:**

```
Top 5 collection priorities — 13 May 2026
────────────────────────────────────────────
1. Acme Corp           $48,200   92 days overdue   ↓ payment cadence slipping
2. Northwind Traders   $31,500   45 days overdue   ↓ first miss in 14 months
3. Globex Industries   $22,750   67 days overdue   → consistent late payer
4. Initech LLC         $18,300   31 days overdue   ↑ partial payment received
5. Soylent Co.         $12,900   58 days overdue   ↓ no contact in 21 days

Total at-risk AR: $133,650 across 5 accounts
Suggested actions: dunning email (3), phone outreach (2)
```

No dashboards. No SQL. No exports. Just a question.

---

## What makes this different

Each skill is a **self-contained, ready-to-run workflow** defined entirely in a prompt file. Plug it into your AI assistant and start using it immediately — no SDK, no deployment, no custom code.

- **Prompt-driven.** Skills are plain-text files. Anyone who can paste text into an AI assistant can run them.
- **Action-oriented, not query-only.** Skills process, rank, analyse, and deliver structured outputs — not just raw data retrieval.
- **Finished workflows over building blocks.** Each skill covers one well-defined job end-to-end.
- **Model-agnostic.** Works identically with Claude, ChatGPT, or Gemini via the [Zoho Billing MCP](https://github.com/zoho/zoho-billing-mcp).

---

## Prerequisites

1. **A Zoho Billing account** with API access enabled
2. **Zoho Billing MCP** set up and connected — see [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) for setup instructions
3. An AI assistant that supports MCP tool use or function calling (Claude, ChatGPT, or Gemini)

---

## Quickstart

**1. Clone this repo**

```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
```

**2. Connect Zoho Billing MCP to your AI assistant**

Follow the setup in [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp). A typical Claude Desktop config looks like:

```json
{
  "mcpServers": {
    "zoho-billing": {
      "command": "npx",
      "args": ["-y", "@zoho/zoho-billing-mcp"],
      "env": {
        "ZOHO_BILLING_ORG_ID": "your-org-id",
        "ZOHO_BILLING_OAUTH_TOKEN": "your-oauth-token"
      }
    }
  }
}
```

**3. Load a skill and run it**

Pick a skill from the [catalog](#skills-catalog), paste the contents of its `SKILL.md` into your AI assistant's custom instructions (or system prompt), then ask in plain English:

> *"Show me my collections worklist for today."*

The skill takes over from there — MCP tool calls, ranking, formatting, and final answer.

---

## Skills Catalog

Each skill is a `SKILL.md` file containing the full workflow, MCP tool calls, edge cases, and expected output. Click through to the skill file for complete details.

| Skill | What it does | Key Zoho APIs used | Trigger phrases |
|---|---|---|---|
| [Cash Collection Prioritization](skills/cash-collection-prioritization/SKILL.md) | AR worklist ranked by balance + payment behaviour anomalies | `get_ar_aging`, `get_customer_balances` | *"show me collections"*, *"who should I chase today"* |
| [Country Performance Analysis](skills/country-performance-analysis/SKILL.md) | Compares subscription activations, cancellations, net growth by country | `get_countrywise_activations_report`, `get_countrywise_cancellations_report` | *"compare countries"*, *"how is each region doing"* |

---

## Architecture

```
┌──────────────────────────────────────────┐
│            Your AI Assistant             │
│   (Claude / ChatGPT / Gemini)            │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  Skill or Agent Prompt             │  │
│  │  (any SKILL.md / agent README)     │  │
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

## Repository Structure

```
zoho-billing-ai/
│
├── README.md
├── LICENSE
│
├── skills/                            ← One SKILL.md per use case
│   ├── cash-collection-prioritization/SKILL.md
│   └── country-performance-analysis/SKILL.md
│
└── agents/                            ← One README.md per agent
    ├── subscription-insights/README.md
    └── retention/README.md
```

---

## Roadmap

**Skills in progress**
- [ ] **Salesperson Performance** — analyse subscription activations, revenue contribution, and conversion rates by salesperson over a selected period
- [ ] **Quote Follow-up Prioritization** — rank open quotes by value, age, and customer engagement signals to surface which ones need follow-up first

**Agents in progress**
- [ ] **Subscription Insights Agent** — monthly summary of activations, MRR, active subscriptions, and churn rate
- [ ] **Retention Agent** — sends retention emails to customers based on LTV, LTD, and the company's retention policy

---

## FAQ

**Do I need to write any code to use these skills?**
No. Skills are plain prompt files. Paste one into your AI assistant's system prompt and start asking questions.

**Why MCP and not a custom integration per AI vendor?**
MCP (Model Context Protocol) is an open standard. One MCP server works across Claude, ChatGPT, Gemini, and any future model that supports it — so the same skill runs unchanged on any of them.

**Is my Zoho Billing data sent to the AI vendor?**
Only the data the AI explicitly fetches through MCP tool calls (e.g., the specific invoices or customer rows it needs to answer your question). The MCP server brokers every call — nothing leaves Zoho without an explicit tool invocation.

**Can I write my own skills?**
Yes — that's the point. Copy any `SKILL.md` as a template, adjust the workflow, and open a PR. See [Contributing](#contributing) below.

---

## Contributing

Contributions are welcome. The easiest way to add value:

1. Open an issue describing the workflow you want to automate
2. Fork the repo and add a new `skills/<your-skill>/SKILL.md`
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
