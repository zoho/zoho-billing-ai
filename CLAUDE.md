# zoho-billing-ai

Agent plugins and skills for Zoho Billing workflows — built for [Claude Cowork](https://claude.com/product/cowork) and the Claude Managed Agents API.

## Repository layout

```
claude/
  agents/                  # Installable plugins — one directory per agent
    retention-agent/       # Pre-churn & win-back retention workflow
      .claude-plugin/
        plugin.json        # Plugin manifest (name, MCPs, requiredEnv)
      skills/              # Skills bundled with this agent
      config/              # Tunable YAML config (e.g. decision matrix)
      tests/               # Fixtures and expected outputs
      .mcp.json            # MCP server declaration
      README.md
scripts/
  build-plugin.sh          # Zip any claude/agents/<slug>/ into a .plugin file
retention-runs/            # Runtime output — gitignored
```

## Installing a plugin

**Cowork** — Settings → Plugins → Add plugin → paste this repo URL, then pick the agent.

**Claude Code:**
```bash
claude plugin marketplace add zoho/zoho-billing-ai
claude plugin install retention-agent@zoho-billing-ai
```

## Adding a new agent

1. Copy an existing agent folder: `cp -r claude/agents/retention-agent claude/agents/my-new-agent`
2. Update `.claude-plugin/plugin.json` (name, description, MCPs, requiredEnv)
3. Replace or add skills under `skills/`
4. Run `./scripts/build-plugin.sh my-new-agent` to verify it zips cleanly

## Conventions

- All skills are `SKILL.md` files with a YAML front-matter block (`name`, `description`)
- Config lives in `config/*.yaml` — skills reference it but never hardcode thresholds
- `tests/fixtures/` contains sample API responses; `tests/output/` is gitignored
- Propose-only: no agent in this repo calls mutating API endpoints without a human approval step
