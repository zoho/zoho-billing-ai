# Installation Guide — Zoho Billing AI

This guide covers installing Zoho Billing AI agents and skills for **Claude Code CLI**, **Claude Cowork**, and **OpenAI Codex**.

## Quick Start (One Command)

### Mac / Linux / Git Bash

```bash
curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh" `
  -OutFile "install.sh" ; bash install.sh
```

### OpenAI Codex — two clicks

Plugins sidebar → **Built by OpenAI** → **Add More** → paste URL → **Add Marketplace**
```
https://github.com/zoho/zoho-billing-ai
```
Then click **Install** next to each agent.

---

## Method 1: Automatic Installation (Recommended)

The `install.sh` script automatically:
- Checks prerequisites (Git, Claude Code CLI)
- Clones the repo or uses local files
- Copies all agent plugins to `~/.claude/plugins/`
- Copies all standalone skills to `~/.claude/skills/`
- Verifies installation

**Prerequisites:**
- Git
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- Internet connection (for first-time setup)

```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
bash install.sh
```

**Or one-liner from anywhere:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh)
```

---

## Method 2: Manual Installation

**Step 1:** Clone the repository
```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
```

**Step 2:** Create directories
```bash
mkdir -p ~/.claude/plugins
mkdir -p ~/.claude/skills
```

**Step 3:** Copy agents and skills
```bash
cp -r plugins/agent-plugins/* ~/.claude/plugins/
cp -r .claude/skills/* ~/.claude/skills/
```

**Step 4:** Verify
```bash
ls ~/.claude/plugins/
# analyst-agent  dunning-agent  payment-intelligence-agent  quote-agent  recovery-agent  retention-agent

ls ~/.claude/skills/
# mrr-growth  customer-360  collections-today  ... (32 skills)
```

---

## Method 3: Claude Cowork

1. Download the `.plugin` file for each agent from [Releases](https://github.com/zoho/zoho-billing-ai/releases)
2. Open Claude Cowork → Settings → Plugins → Add Plugin
3. Upload the `.plugin` file

For all agents:
- `analyst-agent.plugin`
- `dunning-agent.plugin`
- `payment-intelligence-agent.plugin`
- `quote-agent.plugin`
- `recovery-agent.plugin`
- `retention-agent.plugin`

---

## Method 4: OpenAI Codex (Desktop App)

**Step 1 — Add the marketplace**

Open Plugins → **Built by OpenAI** → **Add More** → paste the source URL → **Add Marketplace**

```
https://github.com/zoho/zoho-billing-ai
```

**Step 2 — Install agents**

Under **Built by OpenAI → Zoho Billing AI**, click **Install** next to each agent.

---

## Configuration

Each agent requires Zoho Billing credentials.

### Get Your Credentials

1. **Organization ID:** Zoho Billing → Settings → Organization → copy Organization ID
2. **OAuth Token / API Key:** Zoho Billing → Settings → API Connections → create key

### MCP Server Setup

Zoho Billing AI uses the [Zoho Billing MCP server](https://github.com/zoho/zoho-billing-mcp). Add it to your Claude Desktop or Claude Code MCP config:

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

---

## Verifying Installation

### Check directories

```bash
ls -la ~/.claude/plugins/
ls -la ~/.claude/skills/
```

### Test in Claude Code

Try these trigger phrases:

```
/mrr-growth
/collections-today
/customer-360 Acme Corp
/subscription-kpis
```

If the skill responds with data from Zoho Billing, installation is successful.

---

## Available Agents

### analyst-agent
Full-spectrum business analyst — sales performance, collections dashboard, subscription growth scorecard, and country-by-country breakdown.

### dunning-agent
Analyses subscriptions currently in dunning retry. Scores by MRR at risk, shows retry count and next retry date, and produces a prioritised remediation report.

### payment-intelligence-agent
Predict and prevent involuntary churn. Skills: card expiry detector, payment failure analyser, dunning risk assessor, recovery recommender.

**Trigger phrases:**
- "Check for cards expiring soon"
- "Analyse recent payment failures"
- "Which subscriptions are at risk?"

### quote-agent
Rank open quotes by staleness and expected close value. Recommends next move per quote (follow-up, call, concession, mark lost).

**Trigger phrases:**
- "Show me open quotes"
- "Which deals are stalling?"
- "Prioritise quotes for today"

### recovery-agent
Signup recovery — surfaces lost opportunities and abandoned carts ranked by lost revenue. Recommends re-engagement actions.

### retention-agent
Pre-churn and win-back. Detects at-risk subscriptions, classifies cancel reasons, and recommends retention offers.

---

## Troubleshooting

### "Claude Code CLI not found"
```bash
npm install -g @anthropic-ai/claude-code
```

### "Permission denied" on install.sh
```bash
chmod +x install.sh
bash install.sh
```

### Skills not responding in Claude Code

1. Verify skills are installed: `ls ~/.claude/skills/`
2. Reload Claude Code (close and reopen)
3. Confirm the MCP server is connected and authenticated

### "Organization ID or API Key not working"

1. Verify credentials are correct in Zoho Billing → Settings
2. Ensure the API key has the necessary scopes (subscriptions, invoices, reports)
3. Try generating a fresh OAuth token

### Installation fails on clone

Check internet connection and GitHub access:
```bash
git clone https://github.com/zoho/zoho-billing-ai.git
```

---

## Uninstalling

Remove agents:
```bash
rm -rf ~/.claude/plugins/analyst-agent
rm -rf ~/.claude/plugins/dunning-agent
rm -rf ~/.claude/plugins/payment-intelligence-agent
rm -rf ~/.claude/plugins/quote-agent
rm -rf ~/.claude/plugins/recovery-agent
rm -rf ~/.claude/plugins/retention-agent
```

Remove all standalone skills:
```bash
rm -rf ~/.claude/skills/
```

Or remove everything:
```bash
rm -rf ~/.claude/plugins/ ~/.claude/skills/
```

Then restart Claude Code.

---

## Updating

```bash
# Re-run installer (overwrites old versions)
bash install.sh

# Or manual update
cd zoho-billing-ai
git pull origin main
cp -r plugins/agent-plugins/* ~/.claude/plugins/
cp -r .claude/skills/* ~/.claude/skills/
```

---

## Advanced Configuration

### Using a proxy

```bash
export https_proxy=http://proxy.example.com:8080
bash install.sh
```

### Offline installation

1. Clone repo on a machine with internet access
2. Transfer the folder to your offline machine
3. Run `bash install.sh` — the script detects the local clone and skips GitHub

---

## Support

- **GitHub:** https://github.com/zoho/zoho-billing-ai
- **Zoho Billing Help:** https://www.zoho.com/billing/help/
- **MCP server issues:** https://github.com/zoho/zoho-billing-mcp
