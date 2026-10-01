switch_cider() {
  local config="$HOME/.config/sh.cider.genten/spa-config.yml"
  [ -f "$config" ] || return 0

  local appearance="dark"
  case "${C[gtk_scheme]:-prefer-dark}" in
    prefer-light) appearance="light" ;;
  esac

  # Fill color behind Cider's hardcoded white text
  local accent="${C[accent_ui]:-${C[accent]}}"

  local css
  css=$(cat << EOF
  customCSS: |
    :root {
      --qs-cider-base: ${C[base]};
      --qs-cider-mantle: ${C[mantle]};
      --qs-cider-surface: ${C[surface0]};
      --qs-cider-text: ${C[text]};
      --qs-cider-subtext: ${C[subtext0]};
      --qs-cider-accent: ${accent};
      --qs-cider-link: ${C[accent]};
      --accent: ${accent};
      --text: ${C[text]};
      --card-bg: ${C[surface0]};
    }

    body,
    .q-layout,
    .q-page {
      background: var(--qs-cider-base) !important;
      color: var(--qs-cider-text) !important;
    }

    .q-dark,
    body.body--dark {
      --q-dark: var(--qs-cider-mantle) !important;
      --q-dark-page: var(--qs-cider-base) !important;
      --q-primary: var(--qs-cider-accent) !important;
      --q-accent: var(--qs-cider-accent) !important;
    }

    .q-card,
    .q-menu,
    .q-dialog__inner > div,
    .cider-card {
      background: var(--qs-cider-surface) !important;
      color: var(--qs-cider-text) !important;
    }

    a,
    .text-primary,
    .q-btn.text-primary {
      color: var(--qs-cider-link) !important;
    }
EOF
)

  local tmp
  tmp="$(mktemp)" || return 0

  if APPEARANCE="$appearance" ACCENT="$accent" CSS_BLOCK="$css" perl -0pe '
    my $appearance = $ENV{APPEARANCE};
    my $accent = $ENV{ACCENT};
    my $css = $ENV{CSS_BLOCK};

    s/(^visual:\n.*?^  appearance: )[^\n]*/${1}$appearance/ms;
    s/^  customCSS:.*?(?=^  [A-Za-z0-9_]+:)/$css\n/ms;
    s/^    useSystemAccentColor: .*/    useSystemAccentColor: false/m;
    s/^    customAccentColor: .*/    customAccentColor: true/m;
    s/^    customAccentColorValue: .*/    customAccentColorValue: "$accent"/m;
  ' "$config" > "$tmp"; then
    mv "$tmp" "$config"
  else
    rm -f "$tmp"
  fi
}
