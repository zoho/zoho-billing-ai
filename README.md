# Zoho Billing AI

> **AI-powered skills and agents for Zoho Billing** — query data, automate workflows, and surface insights using Claude, ChatGPT, or Gemini.

[![MCP Compatible](https://img.shields.io/badge/Zoho_Billing_MCP-Connected-blue?style=flat-square)](https://github.com/zoho/zoho-billing-mcp)
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

## Getting Started

**Step 1 — Set up Zoho Billing MCP**

Follow the instructions in [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) to connect your AI model to Zoho Billing.

**Step 2 — Load a skill**

Pick a skill from the [catalog](#️-skills-catalog) and paste its system prompt into your AI assistant's custom instructions, or reference the skill file directly if your assistant supports file-based context.

**Step 3 — Run it**

Talk to your AI in plain language. The skill handles the rest — MCP tool calls, data processing, and structured output.

---

## Skills Catalog

Each skill is a `SKILL.md` file containing the full workflow, MCP tool calls, edge cases, and expected output. Click through to the skill file for complete details.

| Skill | What it does | Key Zoho APIs used | Trigger phrases |
|---|---|---|---|
| [Cash Collection Prioritization](skills/cash-collection-prioritization/SKILL.md) | AR worklist ranked by balance + payment behaviour anomalies | `get_ar_aging`, `get_customer_balances` | *"show me collections"*, *"who should I chase today"* |
| [Country Performance Analysis](skills/country-performance-analysis/SKILL.md) | Compares subscription activations, cancellations, net growth by country | `get_countrywise_activations_report`, `get_countrywise_cancellations_report` | *"compare countries"*, *"how is each region doing"* |

---

## Agents Catalog [In Progress]

Agents combine multiple skills into a single orchestrated workflow. Each agent has its own `README.md` with full details on what it does, which skills it composes, and how to run it.

| Agent | What it does |
|---|---|
| Subscription Insights Agent | Monthly summary of activations, MRR, active subscriptions, and churn rate |
| Retention Agent | Sends retention emails to customers based on LTV, LTD, and the companies retention policy |

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

---

## 📚 Resources

| Resource | Description |
|---|---|
| [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) | MCP server for Zoho Billing — setup, authentication, and model connection |
| [Zoho Billing API Docs](https://www.zoho.com/billing/api/) | Full Zoho Billing API reference |
| [Model Context Protocol](https://modelcontextprotocol.io) | The open standard behind model-agnostic tool use |

---

<p align="center">
  Powered by <strong><a href="https://github.com/zoho/zoho-billing-mcp">Zoho Billing MCP</a></strong> · Works with <strong>Claude</strong>, <strong>ChatGPT</strong>, and <strong>Gemini</strong>
</p>
