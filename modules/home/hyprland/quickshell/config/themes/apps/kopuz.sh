switch_kopuz() {
  command -v switch-kopuz-theme >/dev/null 2>&1 || return 0

  switch-kopuz-theme \
    "Quickshell ${C[name]}" \
    "${C[base]}" \
    "${C[surface0]}" \
    "${C[surface1]}" \
    "${C[text]}" \
    "${C[subtext0]}" \
    "${C[accent]}" \
    "${C[sapphire]}" \
    "${C[blue]}" \
    "${C[crust]}" \
    "${C[mauve]}" \
    "${C[pink]}" \
    "${C[green]}" \
    "${C[red]}"
}