# Cash Collection Prioritization

> Prioritize your accounts receivable collections by ranking customers based on outstanding balance and payment behaviour anomalies.

---

## What it does

This skill generates an **AR worklist** that ranks customers by who you should chase first. It combines outstanding balance data with payment behaviour signals to surface the highest-priority collection targets — so your team spends time where it matters most.

---

## Key APIs Used

| API | Purpose |
|---|---|
| `get_ar_aging` | Fetches accounts receivable aging data |
| `get_customer_balances` | Retrieves outstanding customer balances |

---

## Trigger Phrases

- *"show me collections"*
- *"who should I chase today"*
- *"prioritize AR"*
- *"rank overdue customers"*

---

## Prerequisites

1. **Zoho Billing MCP** set up and connected — see [zoho/zoho-billing-mcp](https://github.com/zoho/zoho-billing-mcp)
2. An AI assistant that supports MCP tool use (Claude, ChatGPT, or Gemini)

---

## Download

[**cash-collection-prioritization.skill**](cash-collection-prioritization.skill) — Use this skill file for Claude AI agents.

---

## How to Use

1. Download the [skill file](cash-collection-prioritization.skill)
2. Load it into your AI assistant's custom instructions or reference it as file-based context
3. Use one of the trigger phrases above, or describe what you need in your own words

---

<p align="center">
  Part of <strong><a href="../../README.md">Zoho Billing AI</a></strong> · Powered by <strong><a href="https://github.com/zoho/zoho-billing-mcp">Zoho Billing MCP</a></strong>
</p>