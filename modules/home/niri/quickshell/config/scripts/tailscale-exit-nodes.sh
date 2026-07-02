#!/usr/bin/env bash
set -euo pipefail

tailscale="/run/current-system/sw/bin/tailscale"
jq_bin="/etc/profiles/per-user/honey/bin/jq"

if [ ! -x "$jq_bin" ]; then
  jq_bin="jq"
fi

"$tailscale" status --json 2>/dev/null | "$jq_bin" '
  (.ExitNodeStatus.ID // "") as $exit
  | [
      .Peer[]
      | select((.Tags // []) | index("tag:mullvad-exit-node"))
      | select(.Online == true)
      | {
          id: .ID,
          host: ((.DNSName // (.HostName + ".mullvad.ts.net")) | sub("\\.$"; "")),
          ip: (.TailscaleIPs[0] // ""),
          country: (.Location.Country // "Unknown"),
          city: (.Location.City // "Unknown"),
          selected: (.ID == $exit)
        }
    ]
  | sort_by(.country, .city, .host)
'
