switch_element() {
  local config_file="$HOME/.config/Element/config.json"
  local base_json="$SCRIPT_DIR/element/catppuccin-base.json"
  mkdir -p "$(dirname "$config_file")"

  [ -f "$base_json" ] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  command -v perl >/dev/null 2>&1 || return 0

  # Detect dark vs light: base lighter than text => light theme
  local base_hex="${C[base]#\#}"
  local text_hex="${C[text]#\#}"
  local base_sum=$(( 0x${base_hex:0:2} + 0x${base_hex:2:2} + 0x${base_hex:4:2} ))
  local text_sum=$(( 0x${text_hex:0:2} + 0x${text_hex:2:2} + 0x${text_hex:4:2} ))
  local is_dark=true
  [ "$base_sum" -gt "$text_sum" ] && is_dark=false

  # Select base flavor: mocha (dark) or latte (light)
  local flavor="mocha"
  local flavor_name="Catppuccin Mocha (Mauve)"
  [ "$is_dark" = false ] && flavor="latte" && flavor_name="Catppuccin Latte (Mauve)"

  # Catppuccin palette (mocha + latte) for 1:1 substitution by color name
  local ctp_table="rosewater f5e0dc dc8a78
flamingo f2cdcd dd7878
pink f5c2e7 ea76cb
mauve cba6f7 8839ef
red f38ba8 d20f39
maroon eba0ac e64553
peach fab387 fe640b
yellow f9e2af df8e1d
green a6e3a1 40a02b
teal 94e2d5 179299
sky 89dceb 04a5e5
sapphire 74c7ec 209fb5
blue 89b4fa 1e66f5
lavender b4befe 7287fd
text cdd6f4 4c4f69
subtext1 bac2de 5c5f77
subtext0 a6adc8 6c6f85
overlay2 9399b2 7c7f93
overlay1 7f849c 8c8fa1
overlay0 6c7086 9ca0b0
surface2 585b70 acb0be
surface1 45475a bcc0cc
surface0 313244 ccd0da
base 1e1e2e eff1f5
mantle 181825 e6e9ef
crust 11111b dce0e8"

  # Build hex substitution map (catppuccin hex -> user palette hex, no #)
  local map=""
  local name mhex lhex uhex
  while read -r name mhex lhex; do
    [ -n "$name" ] || continue
    uhex="${C[$name]#\#}"
    map+="${mhex}"$'\t'"${uhex}"$'\n'
    map+="${lhex}"$'\t'"${uhex}"$'\n'
  done <<< "$ctp_table"

  # Accent: mauve hex -> C[accent] for direct fields
  # Plus derived shades (hovered/pressed/selected) computed from C[accent]
  local accent_hex="${C[accent]#\#}"
  local mauve_cat mhovered_cat mpressed_cat mselected_cat
  if [ "$is_dark" = true ]; then
    mauve_cat="cba6f7"
    mhovered_cat="aa93d0"
    mpressed_cat="9c8bbf"
    mselected_cat="403752"
    local acc_hovered acc_pressed acc_selected
    acc_hovered="$(darken_hex "${C[accent]}" 85)"
    acc_pressed="$(darken_hex "${C[accent]}" 77)"
    acc_selected="$(darken_hex "${C[accent]}" 32)"
    map+="${mauve_cat}"$'\t'"${accent_hex}"$'\n'
    map+="${mhovered_cat}"$'\t'"${acc_hovered#\#}"$'\n'
    map+="${mpressed_cat}"$'\t'"${acc_pressed#\#}"$'\n'
    map+="${mselected_cat}"$'\t'"${acc_selected#\#}"$'\n'
  else
    mauve_cat="8839ef"
    mhovered_cat="8f5dd9"
    mpressed_cat="926dd0"
    mselected_cat="c7b6ea"
    local acc_hovered acc_pressed acc_selected
    acc_hovered="$(darken_hex "${C[accent]}" 90)"
    acc_pressed="$(darken_hex "${C[accent]}" 85)"
    acc_selected="$(lighten_hex "${C[accent]}" 30)"
    map+="${mauve_cat}"$'\t'"${accent_hex}"$'\n'
    map+="${mhovered_cat}"$'\t'"${acc_hovered#\#}"$'\n'
    map+="${mpressed_cat}"$'\t'"${acc_pressed#\#}"$'\n'
    map+="${mselected_cat}"$'\t'"${acc_selected#\#}"$'\n'
  fi

  # Extract the selected flavor's theme, rename it, set is_dark
  local theme_json
  theme_json="$(jq -r \
    --arg name "${C[name]}" \
    --argjson dark "$is_dark" \
    '.setting_defaults.custom_themes[] | select(.name == "'"$flavor_name"'")
     | .name = $name | .is_dark = $dark' \
    "$base_json")"

  # Perl substitute all hex tokens in the extracted theme JSON
  local substituted
  substituted="$(printf '%s' "$theme_json" | MAP="$map" perl -0777 -pe '
    my %map;
    for my $line (split /\n/, $ENV{MAP}) {
      my ($cat, $user) = split /\t/, $line, 2;
      next unless defined $user && length $user;
      $map{lc $cat} = $user;
    }
    s{#([0-9A-Fa-f]{6})(?![0-9A-Fa-f])}{
      exists $map{lc $1} ? "#$map{lc $1}" : "#$1"
    }ge;
  ')"

  # Build final config.json with the single substituted theme
  printf '%s' "$substituted" | jq -c '.' | jq '{setting_defaults: {custom_themes: [.]}, show_labs_settings: true}' > "$config_file"
}

darken_hex() {
  local h="${1#\#}"
  local factor="$2"
  local r=$(( 0x${h:0:2} * factor / 100 ))
  local g=$(( 0x${h:2:2} * factor / 100 ))
  local b=$(( 0x${h:4:2} * factor / 100 ))
  printf '#%02x%02x%02x' "$r" "$g" "$b"
}

lighten_hex() {
  local h="${1#\#}"
  local factor="$2"
  local r=$(( 0x${h:0:2} + (255 - 0x${h:0:2}) * factor / 100 ))
  local g=$(( 0x${h:2:2} + (255 - 0x${h:2:2}) * factor / 100 ))
  local b=$(( 0x${h:4:2} + (255 - 0x${h:4:2}) * factor / 100 ))
  printf '#%02x%02x%02x' "$r" "$g" "$b"
}
