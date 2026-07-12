#!/usr/bin/env bash
# Companion hook for the reflect skill.
#
# Stashes each session's transcript location and compaction count under
# ~/.claude/reflect/ so reflect can tell whether the in-context transcript
# it's about to review is still complete, or has already been lossily
# summarized. On PreCompact it also snapshots the transcript before
# compaction runs, so a later /reflect can rescan the full pre-compaction
# history from a fresh context instead of the compacted one.
#
# Registered for two events (see .claude/settings.json):
#   precompact  - fires right before compaction; bumps the counter, snapshots
#   sessionend  - fires when the session ends; refreshes the stashed paths
#
# Never blocks Claude Code: always exits 0.
set -u

event="${1:-unknown}"
stash_dir="$HOME/.claude/reflect"
mkdir -p "$stash_dir" 2>/dev/null || exit 0

input="$(cat)"

get_field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r --arg k "$1" '.[$k] // empty' 2>/dev/null
  else
    printf '%s' "$input" | sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" | head -1
  fi
}

session_id="$(get_field session_id)"
transcript_path="$(get_field transcript_path)"
cwd="$(get_field cwd)"

# Nothing to key the stash on without a session id.
[ -z "$session_id" ] && exit 0

record="$stash_dir/$session_id.json"
snapshot="$stash_dir/$session_id.snapshot.jsonl"

compactions=0
if [ -f "$record" ]; then
  if command -v jq >/dev/null 2>&1; then
    compactions="$(jq -r '.compactions // 0' "$record" 2>/dev/null)"
  else
    compactions="$(sed -n 's/.*"compactions":\([0-9]*\).*/\1/p' "$record" | head -1)"
  fi
  case "$compactions" in ''|*[!0-9]*) compactions=0 ;; esac
fi

if [ "$event" = "precompact" ]; then
  compactions=$((compactions + 1))
  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    cp "$transcript_path" "$snapshot" 2>/dev/null
  fi
fi

snapshot_path=""
[ -f "$snapshot" ] && snapshot_path="$snapshot"

cat > "$record" <<EOF
{"session_id":"$session_id","transcript_path":"$transcript_path","cwd":"$cwd","snapshot_path":"$snapshot_path","compactions":$compactions}
EOF

exit 0
