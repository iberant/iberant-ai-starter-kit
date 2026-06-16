#!/usr/bin/env bash
# Link CLAUDE.md -> AGENTS.md so Claude Code and other tools share one source of truth.
# macOS / Linux. Run from the repository root.
set -euo pipefail

if [ ! -f AGENTS.md ]; then
  echo "AGENTS.md not found. Run /init in Claude (it creates CLAUDE.md), then rename it:"
  echo "  mv CLAUDE.md AGENTS.md"
  exit 1
fi

ln -sf AGENTS.md CLAUDE.md
echo "Linked CLAUDE.md -> $(readlink CLAUDE.md)"
