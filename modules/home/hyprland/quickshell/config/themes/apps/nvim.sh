nvim_reload() {
  local cs bg
  case "$THEME" in
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