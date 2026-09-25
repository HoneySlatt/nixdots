switch_vibe() {
  local config_file="$HOME/.config/vibe/config.toml"
  local vibe_theme

  # Map quickshell themes to Textual built-in themes
  case "$THEME" in
    pastelglow)    vibe_theme="catppuccin-latte" ;;
    rosepine)      vibe_theme="rose-pine" ;;
    gruvbox)       vibe_theme="gruvbox" ;;
    everforest)    vibe_theme="ansi-dark" ;;
    carbonfox)     vibe_theme="ansi-dark" ;;
    gruvbox-light) vibe_theme="ansi-light" ;;
    *) 
      echo "Unknown theme for vibe: $THEME" >&2
      return 1
      ;;
  esac

  # Update vibe config
  mkdir -p "$HOME/.config/vibe"

  if [ -f "$config_file" ]; then
    if grep -q '^theme =' "$config_file"; then
      sed -i "s/^theme = .*/theme = \"$vibe_theme\"/" "$config_file"
    else
      echo "theme = \"$vibe_theme\"" >> "$config_file"
    fi
  else
    cat > "$config_file" << EOF
active_model = "mistral-medium-3.5"
vim_keybindings = false
theme = "$vibe_theme"
disable_welcome_banner_animation = false
autocopy_to_clipboard = true
EOF
  fi

  echo "Switched vibe theme to: $vibe_theme"
}
