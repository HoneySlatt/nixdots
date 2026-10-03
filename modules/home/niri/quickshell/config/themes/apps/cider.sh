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
      --qs-cider-text: ${C[text]};
      --qs-cider-subtext: ${C[subtext0]};
      --qs-cider-accent: ${accent};
    }

    :root:root,
    body.body--dark,
    body.body--light {
      --q-primary: var(--qs-cider-accent);
      --qDark: var(--qs-cider-mantle);
      --qDarkPage: var(--qs-cider-base);
      --lightBackgroundColor: var(--qs-cider-mantle);
      --glassFallbackColor: var(--qs-cider-mantle);
      --mats-darkBackgroundBase: var(--qs-cider-mantle);
      --mats-lightBackgroundBase: var(--qs-cider-mantle);
      --textDefault: var(--qs-cider-text);
      --systemPrimary: var(--qs-cider-text);
      --systemSecondary: var(--qs-cider-subtext);
    }

    body {
      background: var(--qs-cider-mantle) !important;
      color: var(--qs-cider-text) !important;
    }

    .new-shell-page-container {
      --pageContainerBg: var(--qs-cider-base) !important;
      background-color: var(--qs-cider-base) !important;
    }

    /* Keep a hint of the artwork behind the sidebar */
    .blurmap-container {
      opacity: 0.25;
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
