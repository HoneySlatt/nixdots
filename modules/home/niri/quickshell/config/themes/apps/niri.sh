switch_niri() {
  local config_file="$HOME/.config/niri/config.kdl"
  local theme_file="$HOME/.config/niri/theme.kdl"
  local active="${C[hypr_accent]:-${C[accent]}}"
  local inactive="${C[surface0]}"

  # Replace symlink with writable copy + include directive
  if [ -L "$config_file" ]; then
    local source_config
    source_config="$(readlink -f "$config_file")"
    rm "$config_file"
    cat "$source_config" > "$config_file"
    echo "" >> "$config_file"
    echo "include \"~/.config/niri/theme.kdl\"" >> "$config_file"
  elif ! grep -q 'include.*theme.kdl' "$config_file" 2>/dev/null; then
    echo "" >> "$config_file"
    echo "include \"~/.config/niri/theme.kdl\"" >> "$config_file"
  fi

  # Write theme.kdl with border and shadow colors
  cat > "$theme_file" << EOF
layout {
    border {
        on
        active-color "${active}"
        inactive-color "${inactive}"
    }
    shadow {
        color "${C[crust]}aa"
    }
}
EOF
}