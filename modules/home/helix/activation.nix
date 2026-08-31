{ lib, ... }:

{
  home.activation.helixThemeSync = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cfg="$HOME/.config/helix/config.toml"
    if [ -L "$cfg" ]; then
      cp "$cfg" "$cfg.tmp" && rm "$cfg" && mv "$cfg.tmp" "$cfg"
    fi
    theme_file="$HOME/.config/quickshell/.current-theme"
    if [ -f "$theme_file" ]; then
      qs_theme=$(tr -d '[:space:]' < "$theme_file")
      case "$qs_theme" in
        tokyonight)       hx_theme="tokyonight" ;;
        kanagawa)         hx_theme="kanagawa" ;;
        kanagawa-lotus)   hx_theme="kanagawa_lotus" ;;
        sakura)           hx_theme="sakura" ;;
        onedark)          hx_theme="onedark" ;;
        miasma)           hx_theme="miasma" ;;
        catppuccin-mocha) hx_theme="catppuccin_mocha" ;;
        pastelglow)    hx_theme="pastelglow" ;;
        rosepine)      hx_theme="rose_pine" ;;
        gruvbox)       hx_theme="gruvbox_dark" ;;
        gruvbox-light) hx_theme="gruvbox_dark" ;;
        carbonfox)     hx_theme="carbonfox" ;;
        everforest)    hx_theme="everforest_dark" ;;
        *)             hx_theme="gruvbox_dark" ;;
      esac
      sed -i "s/^theme = .*/theme = \"$hx_theme\"/" "$cfg" 2>/dev/null || true
    fi
  '';
}
