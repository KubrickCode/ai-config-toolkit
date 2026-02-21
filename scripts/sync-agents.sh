#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$ROOT_DIR/AGENTS.md"

{
  echo "<!-- AUTO-GENERATED from CLAUDE.md + .claude/rules/ -->"
  echo "<!-- Do not edit directly. Run: just sync-agents -->"
  echo ""

  # Emit CLAUDE.md content if it exists
  NEED_SEPARATOR=false
  if [[ -s "$ROOT_DIR/CLAUDE.md" ]]; then
    cat "$ROOT_DIR/CLAUDE.md"
    NEED_SEPARATOR=true
  fi

  # Append each rule file under .claude/rules/ in sorted order
  find "$ROOT_DIR/.claude/rules" -name '*.md' -type f 2>/dev/null | sort | while read -r file; do
    echo ""
    echo "---"
    echo ""

    # Strip YAML frontmatter and leading blank lines
    if head -1 "$file" | grep -q '^---$'; then
      awk 'BEGIN{fm=0; skip=1} /^---$/{fm++; next} fm<2{next} skip && /^[[:space:]]*$/{next} {skip=0; print}' "$file"
    else
      cat "$file"
    fi
  done
} > "$OUTPUT"

echo "Generated $OUTPUT"
