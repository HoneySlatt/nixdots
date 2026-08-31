nvim_reload() {
  local cs bg
  case "$THEME" in
    tokyonight)       cs="tokyonight-night" bg="dark" ;;
    kanagawa)         cs="kanagawa-wave" bg="dark" ;;
    kanagawa-lotus)   cs="kanagawa-lotus" bg="light" ;;
    sakura)           cs="sakura" bg="dark" ;;
    onedark)          cs="onedark" bg="dark" ;;
    miasma)           cs="miasma" bg="dark" ;;
    catppuccin-mocha) cs="catppuccin-mocha" bg="dark" ;;
    pastelglow)    cs="pastelglow" bg="light" ;;
    rosepine)      cs="rose-pine"  bg="dark"  ;;
    gruvbox)       cs="gruvbox"    bg="dark"  ;;
    gruvbox-light) cs="gruvbox"    bg="light" ;;
    carbonfox)     cs="carbonfox"  bg="dark"  ;;
    everforest) cs="everforest" bg="dark" ;;
  esac
  local uid
  uid=$(id -u)
  for sock in $(find /run/user/"$uid" -maxdepth 3 -name "nvim.*" -type s 2>/dev/null); do
    nvim --server "$sock" \
      --remote-send ":set background=$bg | colorscheme $cs<CR>" \
      2>/dev/null || true
  done
}
