#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Zoho Billing AI Claude Code Uninstaller
# Removes all installed agents from Claude Code CLI
# ============================================================

CLAUDE_DIR="${HOME}/.claude"
PLUGINS_DIR="${CLAUDE_DIR}/plugins"

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
    echo -e "${BLUE}║   Zoho Billing AI Claude Code Uninstaller  ║${NC}"
    echo -e "${BLUE}║   Remove all installed agents              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_info()    { echo -e "${BLUE}→ $1${NC}"; }

main() {
    print_header

    # ---- Check if plugins directory exists ----
    if [ ! -d "$PLUGINS_DIR" ]; then
        print_error "Plugins directory not found: ${PLUGINS_DIR}"
        echo "  No plugins are installed."
        exit 1
    fi

    # ---- List agents to be removed ----
    print_info "Scanning for installed agents..."

    AGENTS_TO_REMOVE=()
    AGENT_COUNT=0

    for plugin_dir in "$PLUGINS_DIR"/*/; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")

            # Check if it's a valid Zoho Billing agent
            if [ -f "$plugin_dir/.claude-plugin/plugin.json" ] || [ -f "$plugin_dir/SKILL.md" ]; then
                AGENTS_TO_REMOVE+=("$plugin_name")
                AGENT_COUNT=$((AGENT_COUNT + 1))
            fi
        fi
    done

    if [ $AGENT_COUNT -eq 0 ]; then
        print_warning "No Zoho Billing agents found in ${PLUGINS_DIR}"
        echo "  Plugins directory exists but is empty or contains no valid agents."
        exit 0
    fi

    # ---- Show agents to be removed ----
    echo ""
    echo -e "${YELLOW}Agents to be removed:${NC}"
    for agent in "${AGENTS_TO_REMOVE[@]}"; do
        echo "  • ${agent}"
    done
    echo ""

    # ---- Confirm removal ----
    if [ "$INTERACTIVE" = true ]; then
        read -p "Are you sure you want to remove these agents? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Uninstall cancelled."
            exit 0
        fi
    else
        print_warning "Non-interactive mode — proceeding with removal..."
    fi

    # ---- Remove agents ----
    print_info "Removing agents..."

    REMOVED_COUNT=0
    FAILED_AGENTS=()

    for agent in "${AGENTS_TO_REMOVE[@]}"; do
        agent_path="${PLUGINS_DIR}/${agent}"

        if rm -rf "$agent_path" 2>/dev/null; then
            print_success "Removed: ${agent}"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        else
            print_warning "Failed to remove: ${agent}"
            FAILED_AGENTS+=("$agent")
        fi
    done

    # ---- Verify removal ----
    echo ""
    print_info "Verifying removal..."

    VERIFY_OK=true
    for agent in "${AGENTS_TO_REMOVE[@]}"; do
        if [ ! -d "${PLUGINS_DIR}/${agent}" ]; then
            print_success "Verified removed: ${agent}"
        else
            print_error "Still exists: ${agent}"
            VERIFY_OK=false
        fi
    done

    # ---- Clean up empty plugins directory ----
    echo ""
    if [ -d "$PLUGINS_DIR" ] && [ ! "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
        print_info "Plugins directory is empty. Removing..."
        if rm -rf "$PLUGINS_DIR" 2>/dev/null; then
            print_success "Plugins directory removed"
        else
            print_warning "Could not remove empty plugins directory (may require manual cleanup)"
        fi
    fi

    # ---- Print Summary ----
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Uninstall Complete!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Agents removed: ${REMOVED_COUNT}/${AGENT_COUNT}"

    if [ ${#FAILED_AGENTS[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Failed to remove:${NC}"
        for agent in "${FAILED_AGENTS[@]}"; do
            echo "  ⚠ ${agent}"
        done
    fi

    echo ""
    if [ "$VERIFY_OK" = false ]; then
        print_warning "Some agents may not have been fully removed."
        echo "  Manual cleanup may be required:"
        echo "    rm -rf ${PLUGINS_DIR}"
        exit 1
    fi

    print_success "All agents successfully removed!"
    echo ""
    echo -e "${BLUE}What's next:${NC}"
    echo "  • Restart Claude Code for changes to take effect"
    echo "  • To reinstall: bash install.sh"
    echo "  • Questions? See INSTALLATION.md"
    echo ""
}

main "$@"
