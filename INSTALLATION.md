# Installation Guide — Zoho Billing AI Agents

This guide shows how to install Zoho Billing AI agents for **Claude Code CLI**.

## Quick Start (One Command)

### All Platforms (Mac, Linux, Windows)

```bash
curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh | bash
```

**For Windows users:** Use Git Bash (included with [Git for Windows](https://git-scm.com/download/win)) to run the `.sh` scripts.

---

## Installation Methods

### Method 1: Automatic Installation (Recommended)

The `install.sh` script automatically:
- ✅ Checks prerequisites (Git, Claude Code CLI)
- ✅ Clones the repo or uses local files
- ✅ Discovers all agents in `claude/agents/`
- ✅ Copies them to `~/.claude/plugins/`
- ✅ Verifies installation

**Prerequisites:**
- Git
- Claude Code CLI
- Bash shell (built into Mac/Linux; use Git Bash on Windows)
- Internet connection (for first-time setup)

**Run from terminal/Git Bash:**
```bash
# Clone repo (or use your existing clone)
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai

# Run installer
bash install.sh
```

**Or one-liner from anywhere:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zoho/zoho-billing-ai/main/install.sh)
```

> **Windows users:** Download [Git for Windows](https://git-scm.com/download/win) which includes Git Bash. Right-click in any folder and select "Git Bash Here" to use the same commands above.

### Method 2: Manual Installation

**Step 1:** Clone the repository
```bash
git clone https://github.com/zoho/zoho-billing-ai.git
cd zoho-billing-ai
```

**Step 2:** Create the plugins directory
```bash
mkdir -p ~/.claude/plugins
```

**Step 3:** Copy agents
```bash
cp -r claude/agents/* ~/.claude/plugins/
```

**Step 4:** Verify
```bash
ls ~/.claude/plugins/
# Should show: payment-intelligence-agent, quote-agent, retention-agent
```

> **Windows users:** Use Git Bash (from [Git for Windows](https://git-scm.com/download/win)) to run these same commands.

### Method 3: For Claude Code Users (Cowork)

If you're using **Claude Cowork** instead of Claude Code CLI:

1. Download the `.plugin` file for each agent
2. Open Claude Cowork
3. Upload the plugin folder
4. Agents are immediately available

For details, see each agent's README:
- `claude/agents/payment-intelligence-agent/README.md`
- `claude/agents/retention-agent/README.md`
- `claude/agents/zoho-billing-quote-agent/README.md`

---

## Configuration

Each agent requires Zoho Billing credentials to function.

### Get Your Credentials

1. **Organization ID:**
   - Log in to Zoho Billing
   - Settings → Organization
   - Copy the Organization ID

2. **API Key:**
   - Zoho Billing → Settings → API Connections
   - Create a new API Key
   - Copy and store securely

### Configure Agents

When you first run an agent command, Claude Code CLI will prompt for:
- **Organization ID**
- **API Key**

Enter these when prompted. They're stored securely in your Claude Code configuration.

---

## Verifying Installation

### Check Plugins Directory

```bash
# List installed plugins
ls -la ~/.claude/plugins/

# Should show:
# payment-intelligence-agent/
# quote-agent/
# retention-agent/
```

### Verify with Claude Code CLI

```bash
# Check if Claude Code CLI can see the plugins
claude status
```

### Test in Claude Code

1. Open Claude Code
2. Try a trigger phrase from any agent:
   - "Check for cards expiring soon"
   - "Show me open quotes"
   - "Which subscriptions are at risk?"

If the agent responds, installation is successful! ✅

---

## Available Agents

### 1. Payment Intelligence Agent
**Folder:** `claude/agents/payment-intelligence-agent/`

**Skills:**
- **Card Expiry Detector** — Flag cards expiring within 30 days
- **Payment Failure Analyzer** — Analyze recent payment failures
- **Dunning Risk Assessor** — Identify at-risk subscriptions
- **Recovery Recommender** — Get recovery strategies

**Trigger Phrases:**
- "Check for cards expiring soon"
- "Analyze recent payment failures"
- "Which subscriptions are at risk?"
- "What should I do about at-risk subscriptions?"

**Documentation:** See `claude/agents/payment-intelligence-agent/README.md`

---

### 2. Retention Agent
**Folder:** `claude/agents/retention-agent/`

**Skills:**
- Churn analysis and prevention strategies
- Customer retention recommendations

**Documentation:** See `claude/agents/retention-agent/README.md`

---

### 3. Quote Acceleration Agent
**Folder:** `claude/agents/zoho-billing-quote-agent/`

**Skills:**
- **Quote Acceleration** — Analyze open quotes, rank by close value, recommend next moves

**Trigger Phrases:**
- "Show me open quotes"
- "Which deals are stalling?"
- "Prioritize quotes for today"
- "What should sales work on today?"
- "Quote follow-up list"
- "Any quotes going cold?"

**Documentation:** See `claude/agents/zoho-billing-quote-agent/README.md`

---

## Troubleshooting

### "Claude Code CLI not found"

Install it globally:
```bash
npm install -g @anthropic-ai/claude-code
```

### "Permission denied" on install.sh

Make it executable:
```bash
chmod +x install.sh
bash install.sh
```

### Agents not showing in Claude Code

1. **Verify installation:**
   ```bash
   ls ~/.claude/plugins/
   ```

2. **Reload Claude Code** — Close and reopen it

3. **Check plugin.json files** are valid:
   ```bash
   cat ~/.claude/plugins/payment-intelligence-agent/.claude-plugin/plugin.json
   ```

### "Organization ID or API Key not working"

1. Verify credentials are correct in Zoho Billing
2. Ensure API key has necessary permissions
3. Try creating a new API key

### Installation fails on clone

Check your internet connection and GitHub access:
```bash
git clone https://github.com/zoho/zoho-billing-ai.git
```

### Agents work in Cowork but not in Claude Code CLI

- Claude Code CLI requires separate installation (via `install.sh`)
- Cowork uses plugin upload (`.plugin` files)
- Both are supported, but configurations are separate

---

## Uninstalling

Use the provided `uninstall.sh` script:

```bash
# Interactive mode (shows menu)
bash uninstall.sh

# Remove specific agent
bash uninstall.sh -a payment-intelligence-agent

# Remove all agents
bash uninstall.sh --all
```

Or manually remove:
```bash
rm -rf ~/.claude/plugins/payment-intelligence-agent
rm -rf ~/.claude/plugins/retention-agent
rm -rf ~/.claude/plugins/quote-agent
```

Then restart Claude Code.

> **Windows users:** Use Git Bash (from [Git for Windows](https://git-scm.com/download/win)) to run these commands.

---

## Updating Agents

To get the latest agent versions:

```bash
# Option 1: Re-run installer (overwrites old versions)
bash install.sh

# Option 2: Manual update
cd zoho-billing-ai
git pull origin main
cp -r claude/agents/* ~/.claude/plugins/
```

---

## Support & Documentation

- **GitHub:** https://github.com/zoho/zoho-billing-ai
- **Zoho Billing Help:** https://www.zoho.com/billing/help/
- **Claude Code Docs:** https://docs.anthropic.com/

For issues with specific agents, see their individual README files in `claude/agents/`.

---

## Advanced Configuration

### Using a Proxy or VPN

If you're behind a corporate proxy, set the `https_proxy` environment variable:

```bash
export https_proxy=http://proxy.example.com:8080
bash install.sh
```

### Custom Installation Directory

By default, agents install to `~/.claude/plugins/`. To use a custom location, edit `install.sh`:

```bash
PLUGINS_DIR="${HOME}/.claude/plugins"  # Change this line
```

Then run:
```bash
bash install.sh
```

### Offline Installation

If you don't have internet access:

1. Clone repo on a machine with internet:
   ```bash
   git clone https://github.com/zoho/zoho-billing-ai.git
   ```

2. Transfer the folder to your offline machine

3. Run installer locally:
   ```bash
   cd zoho-billing-ai
   bash install.sh
   ```

The installer detects the local clone and skips GitHub access.

---

**Ready to go!** 🚀 Open Claude Code and start using your Zoho Billing agents.
