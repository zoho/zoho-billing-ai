#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Zoho Billing AI Claude Code Installer
# Installs all available agents for Claude Code CLI
# Supports: payment-intelligence-agent, retention-agent, quote-acceleration-agent
# ============================================================

REPO_URL="https://github.com/zoho/zoho-billing-ai.git"
CLAUDE_DIR="${HOME}/.claude"
PLUGINS_DIR="${CLAUDE_DIR}/plugins"
SKILLS_DIR="${CLAUDE_DIR}/skills"
TEMP_DIR=$(mktemp -d)

# Detect if running via curl pipe (no interactive input available)
INTERACTIVE=true
if [ ! -t 0 ]; then
    INTERACTIVE=false
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Zoho Billing AI Claude Code Installer    ║${NC}"
    echo -e "${BLUE}║   Skills & Agents for Zoho Billing         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_info()    { echo -e "${BLUE}→ $1${NC}"; }

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

main() {
    print_header

    # ---- Check Prerequisites ----
    print_info "Checking prerequisites..."

    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        echo "  Install: https://git-scm.com/downloads"
        exit 1
    fi
    print_success "Git found: $(git --version)"

    if ! command -v claude &> /dev/null; then
        print_warning "Claude Code CLI not found in PATH."
        echo "  Install: npm install -g @anthropic-ai/claude-code"
        echo ""
        if [ "$INTERACTIVE" = true ]; then
            read -p "Continue installation anyway? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            print_info "Non-interactive mode — continuing anyway..."
        fi
    else
        print_success "Claude Code CLI found"
    fi

    # ---- Create Directories ----
    print_info "Creating plugin and skills directories..."
    mkdir -p "$PLUGINS_DIR"
    mkdir -p "$SKILLS_DIR"
    print_success "Directories created: ${PLUGINS_DIR}, ${SKILLS_DIR}"

    # ---- Resolve Source Directory ----
    print_info "Fetching Zoho Billing AI agents..."

    SCRIPT_DIR=""
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
    fi

    if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/plugins/agent-plugins" ]; then
        print_info "Installing from local directory..."
        SOURCE_DIR="$SCRIPT_DIR"
    else
        print_info "Cloning from GitHub repository..."
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" || {
            print_error "Failed to clone repository. Check your internet connection."
            echo "  Repository: $REPO_URL"
            exit 1
        }
        SOURCE_DIR="${TEMP_DIR}/repo"
    fi

    # ---- Discover and Install All Agents ----
    print_info "Installing agents from plugins/agent-plugins/..."
    AGENT_COUNT=0
    FAILED_AGENTS=()

    if [ -d "$SOURCE_DIR/plugins/agent-plugins" ]; then
        for agent_dir in "$SOURCE_DIR/plugins/agent-plugins"/*/; do
            if [ -d "$agent_dir" ]; then
                agent_name=$(basename "$agent_dir")
                target_dir="${PLUGINS_DIR}/${agent_name}"

                # Check if agent has valid structure (.claude-plugin/plugin.json or SKILL.md)
                if [ -f "$agent_dir/.claude-plugin/plugin.json" ] || [ -f "$agent_dir/SKILL.md" ]; then
                    # Remove any existing installation
                    rm -rf "$target_dir"
                    # Copy entire agent directory including hidden files
                    cp -r "$agent_dir" "$target_dir"

                    if [ -f "$target_dir/.claude-plugin/plugin.json" ] || [ -f "$target_dir/SKILL.md" ]; then
                        print_success "Installed: ${agent_name}"
                        AGENT_COUNT=$((AGENT_COUNT + 1))
                    else
                        print_warning "Partial install: ${agent_name} (some files may be missing)"
                        FAILED_AGENTS+=("$agent_name")
                    fi
                else
                    print_warning "Skipped: ${agent_name} (not a valid agent directory)"
                fi
            fi
        done
    else
        print_warning "No agents directory found at: $SOURCE_DIR/plugins/agent-plugins"
    fi

    if [ $AGENT_COUNT -eq 0 ]; then
        print_error "No valid agents were installed."
        exit 1
    fi

    # ---- Install Standalone Skills ----
    SKILL_COUNT=0
    if [ -d "$SOURCE_DIR/.claude/skills" ]; then
        print_info "Installing standalone skills from .claude/skills/..."
        for skill_dir in "$SOURCE_DIR/.claude/skills"/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                if [ -f "$skill_dir/SKILL.md" ]; then
                    rm -rf "${SKILLS_DIR}/${skill_name}"
                    cp -r "$skill_dir" "${SKILLS_DIR}/${skill_name}"
                    print_success "Installed skill: ${skill_name}"
                    SKILL_COUNT=$((SKILL_COUNT + 1))
                fi
            fi
        done
        print_success "Installed ${SKILL_COUNT} standalone skill(s)"
    else
        print_warning "No standalone skills directory found — skipping"
    fi

    # ---- Verify Installation ----
    echo ""
    print_info "Verifying installation..."

    VERIFY_OK=true
    agent_verify_count=0

    for plugin_dir in "$PLUGINS_DIR"/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            if [ -f "$plugin_dir/.claude-plugin/plugin.json" ] || [ -f "$plugin_dir/SKILL.md" ]; then
                print_success "Verified: ${plugin_name}"
                agent_verify_count=$((agent_verify_count + 1))
            else
                print_error "Invalid: ${plugin_name} (missing required files)"
                VERIFY_OK=false
            fi
        fi
    done

    if [ "$agent_verify_count" -eq 0 ]; then
        print_error "No valid agents found in ${PLUGINS_DIR}"
        VERIFY_OK=false
    fi

    # ---- Print Summary ----
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Installation Complete!              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Agents installed to: ${PLUGINS_DIR}"
    echo "  Skills installed to: ${SKILLS_DIR}"
    echo "  Total agents: ${AGENT_COUNT} plugin(s)"
    echo "  Total skills: ${SKILL_COUNT} skill(s)"
    echo ""

    if [ ${#FAILED_AGENTS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warnings:${NC}"
        for agent in "${FAILED_AGENTS[@]}"; do
            echo "  ⚠ ${agent} (partial install)"
        done
        echo ""
    fi

    echo -e "${BLUE}Available Agents:${NC}"
    for plugin_dir in "$PLUGINS_DIR"/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
                description=$(grep -o '"description":"[^"]*' "$plugin_dir/.claude-plugin/plugin.json" | cut -d'"' -f4 || echo "No description")
                echo "  • ${plugin_name}"
                echo "    → ${description:0:60}..."
            fi
        fi
    done
    echo ""

    echo -e "${BLUE}Quick Start:${NC}"
    echo "  1. Open Claude Code"
    echo "  2. Use standalone skills directly:"
    echo ""
    echo "    /mrr-growth"
    echo "    /collections-today"
    echo "    /customer-360 Acme Corp"
    echo "    /subscription-kpis"
    echo "    /dunning-status"
    echo "    /create-invoice"
    echo ""
    echo "  3. Or trigger agents with natural language:"
    echo "    - 'Check for cards expiring soon'"
    echo "    - 'Show me open quotes'"
    echo "    - 'Which subscriptions are at risk?'"
    echo ""

    echo -e "${BLUE}Configuration:${NC}"
    echo "  Each agent requires Zoho Organization ID and API Key:"
    echo "  • Find Organization ID: Zoho Billing → Settings → Organization"
    echo "  • Create API Key: Zoho Billing → Settings → API Connections"
    echo ""
    echo "  When prompted, provide these credentials to connect to Zoho Billing."
    echo ""

    echo -e "${BLUE}Documentation:${NC}"
    echo "  GitHub: ${REPO_URL}"
    echo "  Readme: Each agent folder contains detailed instructions"
    echo ""

    if [ "$VERIFY_OK" = false ]; then
        print_warning "Some agents may be incomplete. Please check manually."
        exit 1
    fi

    print_success "All agents installed successfully!"
    echo ""
}

main "$@"
