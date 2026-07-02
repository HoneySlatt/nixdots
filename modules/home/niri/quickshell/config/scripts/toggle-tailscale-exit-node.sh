#!/usr/bin/env bash
set -euo pipefail

tailscale="/run/current-system/sw/bin/tailscale"
sudo="/run/wrappers/bin/sudo"
notify="/etc/profiles/per-user/honey/bin/notify-send"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
last_node_file="$cache_dir/tailscale-exit-node"
fallback_node="fr-par-wg-003.mullvad.ts.net"

notify_user() {
  if [ -x "$notify" ]; then
    "$notify" "$@"
  fi
}

selected_node() {
  while IFS= read -r line; do
    case "$line" in
      *" selected"*)
        set -- $line
        printf '%s\n' "${2:-}"
        return 0
        ;;
    esac
  done < <("$tailscale" exit-node list 2>/dev/null || true)

  return 0
}

suggested_node() {
  local suggestion

  suggestion="$("$tailscale" exit-node suggest 2>/dev/null || true)"
  if [[ "$suggestion" =~ ([[:alnum:]-]+\.mullvad\.ts\.net) ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  fi

  return 0
}

mkdir -p "$cache_dir"

set_node() {
  local node="$1"

  if "$sudo" -n "$tailscale" set --exit-node="$node" --exit-node-allow-lan-access=true; then
    printf '%s\n' "$node" > "$last_node_file"
    notify_user "VPN" "Mullvad exit node on: $node"
  else
    notify_user "VPN" "sudo permission required"
    exit 1
  fi
}

clear_node() {
  if "$sudo" -n "$tailscale" set --exit-node=; then
    notify_user "VPN" "Mullvad exit node off"
  else
    notify_user "VPN" "sudo permission required"
    exit 1
  fi
}

case "${1:-toggle}" in
  off)
    clear_node
    exit 0
    ;;
  toggle)
    ;;
  *.mullvad.ts.net)
    set_node "$1"
    exit 0
    ;;
  *)
    notify_user "VPN" "Invalid exit node"
    exit 1
    ;;
esac

current_node="$(selected_node)"
if [ -n "$current_node" ]; then
  printf '%s\n' "$current_node" > "$last_node_file"

  clear_node
  exit 0
fi

node=""
if [ -s "$last_node_file" ]; then
  node="$(tr -d '[:space:]' < "$last_node_file")"
fi

if [ -z "$node" ]; then
  node="$(suggested_node)"
fi

if [ -z "$node" ]; then
  node="$fallback_node"
fi

set_node "$node"
