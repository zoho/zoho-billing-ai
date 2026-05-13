# Zoho Billing AI — Skills for Claude

> Ready-to-use AI skills for Claude agents that automate Zoho Billing workflows — from collections and retention to pipeline management and reporting.

---

## What is a Skill?

A skill is a **self-contained AI workflow** defined in a single `SKILL.md` file. It tells Claude exactly what to do: which Zoho Billing MCP tools to call, how to process the data, what logic to apply, and how to present the results.

Each skill covers one well-defined job end-to-end — no code, no deployment, no configuration beyond pasting the file.

```
SKILL.md file
    │
    ▼
Claude Agent (reads the skill instructions)
    │
    ▼
Zoho Billing MCP (executes API calls)
    │
    ▼
Structured output (worklists, scorecards, digests)
```

---

## Why Skills Matter

| Without Skills | With Skills |
|---|---|
| You ask Claude a vague question and get a generic answer | Claude follows a precise workflow with the right API calls in the right order |
| You have to know which APIs exist and how to combine them | The skill encodes the domain logic — you just trigger it |
| Output is inconsistent and unstructured | Every run produces a consistent, actionable format |
| No scoring, ranking, or prioritization | Built-in scoring models rank items by business impact |
| Read-only — you still have to act manually | Write actions (email, apply credits, update subscriptions) are one click away |

Skills turn Claude from a general-purpose assistant into a **domain-specific operator** that knows your billing workflows.

---

## Skills Catalog

| Skill | Description | Action Type |
|---|---|---|
| [Cash Collection Prioritization](Cash-Collection-Prioritization/SKILL.md) | AR worklist ranked by expected recovery value using payment behaviour signals | Analysis + Prioritization + Follow-up |
| [Quote Acceleration](Quote-Acceleration/SKILL.md) | Ranks open quotes by expected close value × staleness, identifies stalled deals | Analysis + Prioritization + Follow-up |
| [Retention](Retention/SKILL.md) | Catches churning/non-renewing subs, scores by LTV, applies retention policy | Analysis + Save-action |
| [Subscription Insights](Subscription-Insights/SKILL.md) | Weekly/monthly KPI digest: MRR, ARR, churn, NRR with anomaly callouts | Analysis + Reporting |
| [Salesperson Performance](Salesperson-Performance/SKILL.md) | Per-rep scorecard with coaching flags: conversion, cycle length, churn attribution | Analysis + Reporting |
| [Lost Opportunity Recovery](Lost-Opportunity-Recovery/SKILL.md) | Unified second-chance pipeline across abandoned carts, expired quotes, inactive trials | Re-engagement |
| [Subscription Expiry Watcher](Subscription-Expiry-Watcher/SKILL.md) | Catches non-auto-renewing subs expiring in 14/30/60 days with renewal motions | Analysis + Re-engagement |
| [Payment Failure Prevention](Payment-Failure-Prevention/SKILL.md) | Identifies expiring payment cards, ranks by MRR-at-risk, triggers card-update outreach | Proactive Outreach |

---

## How to Add a Skill to Claude Code

> Reference: [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

### Prerequisites

1. A **Zoho Billing account** with API access
2. **Zoho Billing MCP** set up and connected — see [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp)
3. **Claude Code** installed and running

### Step 1 — Create the Skill Directory

Each skill lives in its own directory with a `SKILL.md` file as the entrypoint. Choose where to install based on your needs:

| Scope | Path | Availability |
|---|---|---|
| **Personal** (all your projects) | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| **Project** (this project only) | `.claude/skills/<skill-name>/SKILL.md` | This project only |

For example, to install the Cash Collection Prioritization skill for personal use:

```bash
mkdir -p ~/.claude/skills/cash-collection-prioritization
```

Or for a specific project:

```bash
mkdir -p .claude/skills/cash-collection-prioritization
```

### Step 2 — Add the SKILL.md File

Copy the `SKILL.md` file from the skill you want into the directory you created:

```bash
cp Cash-Collection-Prioritization/SKILL.md ~/.claude/skills/cash-collection-prioritization/SKILL.md
```

Every `SKILL.md` must start with **YAML frontmatter** between `---` markers containing at minimum a `name` and `description`. All the skills in this repo already include the required frontmatter.

### Step 3 — Connect Zoho Billing MCP

Make sure the Zoho Billing MCP server is configured as a tool connection so the skill can call the Zoho Billing APIs. See [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) for setup instructions.

### Step 4 — Run It

Claude Code automatically detects skills. You can invoke a skill in two ways:

**Auto-invocation** — Ask something that matches the skill's description:
```
who should I chase today
```
Claude recognizes the intent and loads the skill automatically.

**Direct invocation** — Type `/` followed by the skill name:
```
/cash-collection-prioritization
```

### Step 5 — Verify

Check that your skill is available by asking Claude:
```
What skills are available?
```

> **Note:** Claude Code watches skill directories for file changes. Adding or editing a skill takes effect within the current session without restarting. Creating a new top-level skills directory requires restarting Claude Code.

---

## How to Add a Skill on claude.ai

### Prerequisites

1. A **Zoho Billing account** with API access
2. **Zoho Billing MCP** set up and connected — see [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp)
3. A [claude.ai](https://claude.ai) account

### Step 1 — Download the Skill File

Pick a skill from the [catalog](#skills-catalog) and download its `SKILL.md` file to your computer.

### Step 2 — Open Customize

1. Go to [claude.ai](https://claude.ai)
2. Click on your **profile icon** (bottom-left)
3. Select **Customize**

### Step 3 — Upload the Skill File

1. In the Customize panel, go to the **Custom Instructions** section
2. Click **Add content** or **Upload file**
3. Upload the `SKILL.md` file
4. Claude will use the skill instructions as context for your conversations

### Step 4 — Connect Zoho Billing MCP

Make sure the Zoho Billing MCP server is configured as an integration so the skill can call the Zoho Billing APIs. See [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp) for setup instructions.

### Step 5 — Run It

Start a new conversation and use one of the skill's **trigger phrases** or describe what you need in plain language:

```
You: "who should I chase today"
Claude: [runs Cash Collection Prioritization skill → outputs ranked AR worklist]
```

---

## Skill File Structure

Every `SKILL.md` follows a consistent structure:

| Section | Purpose |
|---|---|
| **YAML Frontmatter** | `name`, `title`, `description`, `action_type`, `tools` — required by Claude |
| **Overview** | What the skill does and when to use it |
| **Trigger Phrases** | Example prompts that activate the skill |
| **MCP Tools Used** | Which Zoho Billing MCP tools the skill calls (read + write) |
| **Workflow** | Step-by-step logic the AI follows |
| **Edge Cases** | How the skill handles missing data, errors, or ambiguity |
| **Output Format** | The structured output the user receives |
| **Output Rules** | Formatting and sorting rules for consistency |

---

<p align="center">
  Part of <strong><a href="../README.md">Zoho Billing AI</a></strong> · Powered by <strong><a href="https://github.com/zoho/zoho-billing-mcp">Zoho Billing MCP</a></strong>
</p>