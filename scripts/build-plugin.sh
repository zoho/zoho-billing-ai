#!/usr/bin/env bash
# scripts/build-plugin.sh — rebuild a plugin from source
#
# Usage:
#   ./scripts/build-plugin.sh [agent-slug]
#
# Examples:
#   ./scripts/build-plugin.sh retention-agent
#   ./scripts/build-plugin.sh              # defaults to retention-agent
#
# Auto-build on every git commit:
#   ln -sf ../../scripts/build-plugin.sh .git/hooks/pre-commit

set -e

AGENT="${1:-retention-agent}"
PLUGIN_SRC="plugins/agent-plugins/${AGENT}"
PLUGIN_OUT="${AGENT}.plugin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$SCRIPT_DIR"

if [ ! -d "$PLUGIN_SRC" ]; then
  echo "❌  Source folder '$PLUGIN_SRC' not found. Run from the repo root."
  echo "    Available agents: $(ls plugins/agent-plugins/ 2>/dev/null | tr '\n' ' ')"
  exit 1
fi

python3 - <<PYEOF
import zipfile, pathlib

src = pathlib.Path("${PLUGIN_SRC}")
out = pathlib.Path("${PLUGIN_OUT}")

SKIP = {".DS_Store", "__pycache__", ".pyc", ".git"}

added = []
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
    for f in sorted(src.rglob("*")):
        rel = str(f.relative_to(src))
        if any(s in f.parts for s in SKIP): continue
        if f.is_file():
            zf.write(f, rel)
            added.append(rel)

print(f"✅  Built {out} — {len(added)} files ({out.stat().st_size // 1024}KB)")
PYEOF
