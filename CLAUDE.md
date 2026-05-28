# zoho-billing-ai

Agent plugins and skills for Zoho Billing workflows — built for [Claude Cowork](https://claude.com/product/cowork) and the Claude Managed Agents API.

## Repository layout

```
.claude-plugin/
  marketplace.json         # Claude marketplace entry point — lists all agents
.agents/
  plugins/
    marketplace.json       # Codex marketplace entry point — lists all agents
plugins/
  agent-plugins/           # Installable plugins — one directory per agent (platform-neutral)
    retention-agent/       # Pre-churn & win-back retention workflow
      .claude-plugin/
        plugin.json        # Claude plugin manifest
      .codex-plugin/
        plugin.json        # Codex plugin manifest (mirrors .claude-plugin)
      skills/              # Skills bundled with this agent
      config/              # Tunable YAML config (e.g. decision matrix)
      README.md
scripts/
  build-plugin.sh          # Zip any plugins/agent-plugins/<slug>/ into a .plugin file
```

## Installing a plugin

**Cowork** — Settings → Plugins → Add plugin → paste this repo URL, then pick the agent.

**Claude Code:**
```bash
claude plugin marketplace add zoho/zoho-billing-ai
claude plugin install retention-agent@zoho-billing-ai
```

## Adding a new agent

1. Copy an existing agent folder: `cp -r plugins/agent-plugins/retention-agent plugins/agent-plugins/my-new-agent`
2. Update both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` (name, description, MCPs, requiredEnv)
3. Add the new agent entry to both root `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`
4. Replace or add skills under `skills/`
5. Run `./scripts/build-plugin.sh my-new-agent` to verify it zips cleanly

## Conventions

- All skills are `SKILL.md` files with a YAML front-matter block (`name`, `description`)
- Config lives in `config/*.yaml` — skills reference it but never hardcode thresholds
- Propose-only: no agent in this repo calls mutating API endpoints without a human approval step
- Each agent carries both `.claude-plugin/plugin.json` (for Claude) and `.codex-plugin/plugin.json` (for Codex) — keep them in sync
