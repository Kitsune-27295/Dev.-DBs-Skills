#!/usr/bin/env bash
# PreToolUse hook: block dangerous git commands before the agent runs them.
# Reads the hook JSON on stdin; exit 2 blocks the call, exit 0 allows it.
# Best-effort guardrail, not a security boundary (see SKILL.md, "Limits").
set -euo pipefail

block() {
  # Never echo the command itself: it may contain tokens or credentials.
  printf 'BLOCKED: %s The user has prevented you from doing this.\n' "$1" >&2
  exit 2
}

# Fail closed: without jq the command cannot be inspected.
command -v jq >/dev/null 2>&1 || block "jq is not installed, so the git command cannot be checked."

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty') ||
  block "the hook input could not be parsed."

# Nothing to check (not a Bash call, or an empty command).
[[ -n "$COMMAND" ]] || exit 0

# Optional git global options between "git" and the subcommand, e.g. git -C dir push.
G='git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+'

# "label|extended regex" pairs. Edit this list to customize.
DANGEROUS_PATTERNS=(
  "git push|${G}push([[:space:]]|$)"
  "git reset --hard|${G}reset([[:space:]]+[^;&|]*)?[[:space:]]--hard"
  "git clean -f|${G}clean([[:space:]]+[^;&|]*)?[[:space:]]-[a-zA-Z]*f"
  "git branch -D|${G}branch([[:space:]]+[^;&|]*)?[[:space:]]-[a-zA-Z]*D"
  "git checkout .|${G}checkout[[:space:]]+(--[[:space:]]+)?\\.([[:space:]]|$)"
  "git restore .|${G}restore[[:space:]]+(--[a-z-]+[[:space:]]+)*(--[[:space:]]+)?\\.([[:space:]]|$)"
)

for entry in "${DANGEROUS_PATTERNS[@]}"; do
  label="${entry%%|*}"
  regex="${entry#*|}"
  if printf '%s' "$COMMAND" | grep -qE -- "$regex"; then
    block "this command matches the blocked pattern '${label}'."
  fi
done

exit 0
