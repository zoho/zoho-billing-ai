# Skills

> Ready-to-run AI workflows for Zoho Billing — paste into any AI assistant and go.

---

## What is a Skill?

A skill is a **self-contained workflow** defined in a single `SKILL.md` file. Each skill tells your AI assistant exactly how to query Zoho Billing, process the results, and deliver a structured, actionable output.

- **No code required.** Copy the skill prompt into your AI assistant's instructions.
- **One job, done well.** Each skill solves one specific billing problem end-to-end.
- **Model-agnostic.** Works with Claude, ChatGPT, or Gemini via [Zoho Billing MCP](https://github.com/zoho/zoho-billing-mcp).

---

## Skills Catalog

| Skill | Description | Key APIs | Trigger Phrases |
|---|---|---|---|
| [Cash Collection Prioritization](cash-collection-prioritization/SKILL.md) | AR worklist ranked by balance + payment behaviour anomalies | `get_ar_aging`, `get_customer_balances` | *"show me collections"*, *"who should I chase today"* |
| [Country Performance Analysis](country-performance-analysis/SKILL.md) | Compares subscription activations, cancellations, and net growth by country | `get_countrywise_activations_report`, `get_countrywise_cancellations_report` | *"compare countries"*, *"how is each region doing"* |

---

## How to Use a Skill

### Step 1 — Prerequisites

Make sure [Zoho Billing MCP](https://github.com/zoho/zoho-billing-mcp) is set up and your AI assistant is connected to your Zoho Billing account.

### Step 2 — Load the skill

Open the `SKILL.md` file for the skill you want. Copy its full content and paste it into your AI assistant's **system prompt** or **custom instructions**.

### Step 3 — Run it

Use one of the skill's trigger phrases — or describe what you need in your own words. The skill handles MCP tool calls, data processing, and output formatting automatically.

---

## Skill File Structure

Each skill lives in its own folder under `skills/`:

```
skills/
├── README.md                              ← You are here
├── cash-collection-prioritization/
│   └── SKILL.md
└── country-performance-analysis/
    └── SKILL.md
```

Every `SKILL.md` follows a consistent structure:

| Section | Purpose |
|---|---|
| **Overview** | What the skill does and when to use it |
| **Trigger Phrases** | Example prompts that activate the skill |
| **MCP Tools Used** | Which Zoho Billing MCP tools the skill calls |
| **Workflow** | Step-by-step logic the AI follows |
| **Edge Cases** | How the skill handles missing data, errors, or ambiguity |
| **Output Format** | The structured output the user receives |

---

## Planned Skills

| Skill | Description | Status |
|---|---|---|
| Salesperson Performance | Analyse subscription activations, revenue contribution, and conversion rates by salesperson | Planned |
| Quote Follow-up Prioritization | Rank open quotes by value, age, and customer engagement signals | Planned |

---

## Contributing a Skill

To add a new skill:

1. Create a new folder under `skills/` with a descriptive kebab-case name
2. Add a `SKILL.md` file following the structure above
3. Update this README's catalog table
4. Update the root [README.md](../README.md) skills catalog

---

<p align="center">
  Part of <strong><a href="../README.md">Zoho Billing AI</a></strong> · Powered by <strong><a href="https://github.com/zoho/zoho-billing-mcp">Zoho Billing MCP</a></strong>
</p>
