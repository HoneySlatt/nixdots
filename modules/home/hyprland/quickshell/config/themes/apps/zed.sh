zed_reload() {
  local zf
  case "$THEME" in
    tokyonight)       zf="tokyonight" ;;
    kanagawa)         zf="kanagawa" ;;
    kanagawa-lotus)   zf="kanagawa-lotus" ;;
    sakura)           zf="sakura" ;;
    onedark)          zf="onedark" ;;
    miasma)           zf="miasma" ;;
    catppuccin-mocha) zf="catppuccin-mocha" ;;
    pastelglow)    zf="pastelglow" ;;
    rosepine)      zf="rosepine" ;;
    gruvbox)       zf="gruvbox" ;;
    gruvbox-light) zf="gruvbox" ;;
    carbonfox)     zf="carbonfox" ;;
    everforest)    zf="everforest" ;;
    *)             zf="gruvbox" ;;
  esac
  local pal="$HOME/.config/zed/theme-overrides/${zf}.json"
  [ -f "$pal" ] || return
  local cfg="$HOME/.config/zed/settings.json"
  if [ -L "$cfg" ]; then
    cp "$cfg" "$cfg.tmp" && rm "$cfg" && mv "$cfg.tmp" "$cfg"
  fi
  jq --slurpfile p "$pal" '.theme_overrides."One Dark" = $p[0]' \
    "$cfg" > /tmp/zed-settings.json \
    && mv /tmp/zed-settings.json "$cfg"
}
