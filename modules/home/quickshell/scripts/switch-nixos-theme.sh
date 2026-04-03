#!/usr/bin/env bash
# Switch NixOS config theme (themes.nix, kitty.nix, btop.nix) + live reload
set -euo pipefail

THEME="${1:-pastelglow}"
NIXCFG="$HOME/NixOS/config"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A C
source "$SCRIPT_DIR/themes.conf"

if load_common_palette "$THEME"; then
  :
else
  case "$THEME" in
    aura)
      C[name]="Aura Dark"
      C[base]="#15141b" C[mantle]="#110f18" C[crust]="#110f18"
      C[surface0]="#1c1b22" C[surface1]="#21202e" C[surface2]="#3d375e"
      C[overlay0]="#6d6d6d" C[overlay1]="#6d6d6d"
      C[text]="#edecee" C[subtext1]="#edecee" C[subtext0]="#6d6d6d"
      C[red]="#ff6767" C[maroon]="#ff6767" C[rosewater]="#edecee" C[flamingo]="#edecee"
      C[pink]="#f694ff" C[mauve]="#a277ff" C[lavender]="#a277ff"
      C[blue]="#82e2ff" C[sapphire]="#82e2ff" C[sky]="#82e2ff"
      C[teal]="#61ffca" C[green]="#61ffca" C[yellow]="#ffca85"
      C[peach]="#ffca85" C[orange]="#ffca85"
      C[accent]="#a277ff"
      C[overlay2]="#6d6d6d"
      ;;
    carbonfox)
      C[name]="Carbonfox"
      C[base]="#161616" C[mantle]="#121212" C[crust]="#121212"
      C[surface0]="#222222" C[surface1]="#2a2a2a" C[surface2]="#525253"
      C[overlay0]="#6e7074" C[overlay1]="#9a9ca0"
      C[text]="#f2f4f8" C[subtext1]="#dfdfe0" C[subtext0]="#b2b4b8"
      C[red]="#ee5396" C[maroon]="#ee5396" C[rosewater]="#dfdfe0" C[flamingo]="#dfdfe0"
      C[pink]="#ff7eb6" C[mauve]="#be95ff" C[lavender]="#78a9ff"
      C[blue]="#78a9ff" C[sapphire]="#33b1ff" C[sky]="#33b1ff"
      C[teal]="#08bdba" C[green]="#25be6a" C[yellow]="#3ddbd9"
      C[peach]="#3ddbd9" C[orange]="#3ddbd9"
      C[accent]="#be95ff"
      C[overlay2]="#b2b4b8"
      ;;
    *)
      echo "Unknown theme: $THEME" >&2
      exit 1
      ;;
  esac
fi

# Script-specific keys per theme
case "$THEME" in
  everforest)
    C[nvim_colorscheme]="everforest"
    C[nvim_flavour]='' C[nvim_extra]='' C[lualine_theme]="auto"
    ;;
  pastelglow)
    C[nvim_colorscheme]="pastelglow"
    C[nvim_flavour]='' C[nvim_extra]='' C[lualine_theme]="auto"
    ;;
  rosepine)
    C[nvim_colorscheme]="rose-pine"
    C[nvim_flavour]='' C[nvim_extra]='' C[lualine_theme]="auto"
    ;;
  gruvbox)
    C[nvim_colorscheme]="gruvbox"
    C[nvim_flavour]='' C[nvim_extra]='settings.background = "dark";'
    C[lualine_theme]="gruvbox"
    ;;
  aura)
    C[nvim_colorscheme]="aura"
    C[nvim_flavour]='' C[nvim_extra]='' C[lualine_theme]="auto"
    ;;
  carbonfox)
    C[nvim_colorscheme]="nightfox"
    C[nvim_flavour]='' C[nvim_extra]='' C[lualine_theme]="auto"
    ;;
  gruvbox-light)
    C[nvim_colorscheme]="gruvbox"
    C[nvim_flavour]='' C[nvim_extra]='settings.background = "light";'
    C[lualine_theme]="gruvbox_light"
    ;;
esac

# ── Generate themes.nix ────────────────────────────────────────────────────
gen_themes_nix() {
  local let_block catppuccin_block gtk_block dconf_block kvantum_block

  case "$THEME" in
    everforest)
      let_block=''
      catppuccin_block=''
      gtk_block=$(cat << GTKEOF
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
  };
GTKEOF
)
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=quickshell-theme
  '"''"';'
      ;;
    pastelglow)
      let_block=''
      catppuccin_block=''
      gtk_block=$(cat << GTKEOF
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk3.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
  };
GTKEOF
)
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-light";
    gtk-theme = "adw-gtk3";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=quickshell-theme
  '"''"';'
      ;;
    rosepine)
      let_block=''
      catppuccin_block=''
      gtk_block='  gtk = {
    enable = true;
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };'
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "rose-pine";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=quickshell-theme
  '"''"';'
      ;;
    gruvbox)
      let_block=''
      catppuccin_block=''
      gtk_block='  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };'
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Gruvbox-Dark";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=Gruvbox-Dark-Brown
  '"''"';

  xdg.configFile."Kvantum/Gruvbox-Dark-Brown".source =
    "${pkgs.gruvbox-kvantum}/share/Kvantum/Gruvbox-Dark-Brown";'
      ;;
    aura)
      let_block=''
      catppuccin_block=''
      gtk_block='  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };'
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };'
      ;;
    carbonfox)
      let_block=''
      catppuccin_block=''
      gtk_block=$(cat << GTKEOF
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk3.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${C[accent]};
      @define-color accent_bg_color ${C[accent]};
      @define-color accent_fg_color ${C[base]};
      @define-color destructive_color ${C[red]};
      @define-color destructive_bg_color ${C[red]};
      @define-color destructive_fg_color ${C[base]};
      @define-color success_color ${C[green]};
      @define-color success_bg_color ${C[green]};
      @define-color success_fg_color ${C[base]};
      @define-color warning_color ${C[yellow]};
      @define-color warning_bg_color ${C[yellow]};
      @define-color warning_fg_color ${C[base]};
      @define-color error_color ${C[red]};
      @define-color error_bg_color ${C[red]};
      @define-color error_fg_color ${C[base]};
      @define-color window_bg_color ${C[base]};
      @define-color window_fg_color ${C[text]};
      @define-color view_bg_color ${C[mantle]};
      @define-color view_fg_color ${C[text]};
      @define-color headerbar_bg_color ${C[crust]};
      @define-color headerbar_fg_color ${C[text]};
      @define-color headerbar_border_color ${C[surface0]};
      @define-color headerbar_backdrop_color ${C[mantle]};
      @define-color headerbar_shade_color ${C[crust]};
      @define-color card_bg_color ${C[surface0]};
      @define-color card_fg_color ${C[text]};
      @define-color card_shade_color ${C[crust]};
      @define-color dialog_bg_color ${C[base]};
      @define-color dialog_fg_color ${C[text]};
      @define-color popover_bg_color ${C[surface0]};
      @define-color popover_fg_color ${C[text]};
      @define-color sidebar_bg_color ${C[mantle]};
      @define-color sidebar_fg_color ${C[text]};
    '';
  };
GTKEOF
)
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=quickshell-theme
  '"''"';'
      ;;
    gruvbox-light)
      let_block=''
      catppuccin_block=''
      gtk_block='  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Light";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 0;
  };'
      dconf_block='  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-light";
    gtk-theme = "Gruvbox-Light";
  };'
      kvantum_block='  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = '"''"'
    [General]
    theme=Gruvbox-Dark-Brown
  '"''"';

  xdg.configFile."Kvantum/Gruvbox-Dark-Brown".source =
    "${pkgs.gruvbox-kvantum}/share/Kvantum/Gruvbox-Dark-Brown";'
      ;;
  esac

  cat > "$NIXCFG/themes.nix" << NIXEOF
{ pkgs, ... }:

${let_block}
{
${catppuccin_block}

${gtk_block}

${dconf_block}

${kvantum_block}

  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
    glib
  ];

  fonts.fontconfig.enable = true;

  xdg.configFile."swaync/style.css".text = ''
    /* ${C[name]} theme — auto-generated by switch-nixos-theme.sh */
    * {
      all: unset;
      font-size: 14px;
      font-family: "JetBrainsMono Nerd Font";
      transition: 200ms;
    }

    trough highlight { background: ${C[text]}; }

    scale { margin: 0 7px; }

    scale trough {
      margin: 0rem 1rem;
      min-height: 8px;
      min-width: 70px;
      border-radius: 12.6px;
    }

    trough slider {
      margin: -10px;
      border-radius: 12.6px;
      box-shadow: 0 0 2px rgba(0,0,0,0.8);
      transition: all 0.2s ease;
      background-color: ${C[blue]};
    }

    trough slider:hover {
      box-shadow: 0 0 2px rgba(0,0,0,0.8), 0 0 8px ${C[blue]};
    }

    trough { background-color: ${C[surface0]}; }

    .notification-background {
      box-shadow: 0 0 8px 0 rgba(0,0,0,0.8), inset 0 0 0 1px ${C[surface1]};
      border-radius: 12.6px;
      margin: 18px;
      background: ${C[mantle]};
      color: ${C[text]};
      padding: 0;
    }

    .notification-background .notification {
      padding: 7px;
      border-radius: 12.6px;
    }

    .notification-background .notification.critical {
      box-shadow: inset 0 0 7px 0 ${C[red]};
    }

    .notification .notification-content { margin: 7px; }

    .notification .notification-content overlay { margin: 4px; }

    .notification-content .summary { color: ${C[text]}; }
    .notification-content .time   { color: ${C[subtext0]}; }
    .notification-content .body   { color: ${C[subtext1]}; }

    .notification > *:last-child > * { min-height: 3.4em; }

    .notification-background .close-button {
      margin: 7px;
      padding: 2px;
      border-radius: 6.3px;
      color: ${C[base]};
      background-color: ${C[red]};
    }

    .notification-background .close-button:hover  { background-color: ${C[maroon]}; }
    .notification-background .close-button:active { background-color: ${C[pink]}; }

    .notification .notification-action {
      border-radius: 7px;
      color: ${C[text]};
      box-shadow: inset 0 0 0 1px ${C[surface1]};
      margin: 4px;
      padding: 8px;
      font-size: 0.2rem;
      background-color: ${C[surface0]};
    }

    .notification .notification-action:hover  { background-color: ${C[surface1]}; }
    .notification .notification-action:active { background-color: ${C[surface2]}; }

    .notification.critical progress { background-color: ${C[red]}; }
    .notification.low progress,
    .notification.normal progress   { background-color: ${C[blue]}; }

    .notification progress,
    .notification trough,
    .notification progressbar {
      border-radius: 12.6px;
      padding: 3px 0;
    }

    .control-center {
      box-shadow: 0 0 8px 0 rgba(0,0,0,0.8), inset 0 0 0 1px ${C[surface0]};
      border-radius: 12.6px;
      background-color: ${C[base]};
      color: ${C[text]};
      padding: 14px;
    }

    .control-center .notification-background {
      border-radius: 7px;
      box-shadow: inset 0 0 0 1px ${C[surface1]};
      margin: 4px 10px;
    }

    .control-center .notification-background .notification {
      border-radius: 7px;
    }

    .control-center .notification-background .notification.low { opacity: 0.8; }

    .control-center .widget-title > label {
      color: ${C[text]};
      font-size: 1.3em;
    }

    .control-center .widget-title button {
      border-radius: 7px;
      color: ${C[text]};
      background-color: ${C[surface0]};
      box-shadow: inset 0 0 0 1px ${C[surface1]};
      padding: 8px;
    }

    .control-center .widget-title button:hover  { background-color: ${C[surface1]}; }
    .control-center .widget-title button:active { background-color: ${C[surface2]}; }

    .control-center .notification-group { margin-top: 10px; }

    .control-center .notification-group:focus .notification-background {
      background-color: ${C[surface0]};
    }

    scrollbar slider { margin: -3px; opacity: 0.8; }
    scrollbar trough { margin: 2px 0; }

    .widget-dnd {
      margin-top: 5px;
      border-radius: 8px;
      font-size: 1.1rem;
    }

    .widget-dnd > switch {
      font-size: initial;
      border-radius: 8px;
      background: ${C[surface0]};
      box-shadow: none;
    }

    .widget-dnd > switch:checked { background: ${C[blue]}; }

    .widget-dnd > switch slider {
      background: ${C[surface1]};
      border-radius: 8px;
    }

    .widget-mpris-player {
      background: ${C[surface0]};
      border-radius: 12.6px;
      color: ${C[text]};
    }

    .mpris-overlay {
      background-color: ${C[surface0]};
      opacity: 0.9;
      padding: 15px 10px;
    }

    .widget-mpris-album-art {
      -gtk-icon-size: 100px;
      border-radius: 12.6px;
      margin: 0 10px;
    }

    .widget-mpris-title   { font-size: 1.2rem; color: ${C[text]}; }
    .widget-mpris-subtitle { font-size: 1rem;  color: ${C[subtext1]}; }

    .widget-mpris button {
      border-radius: 12.6px;
      color: ${C[text]};
      margin: 0 5px;
      padding: 2px;
    }

    .widget-mpris button image { -gtk-icon-size: 1.8rem; }
    .widget-mpris button:hover  { background-color: ${C[surface0]}; }
    .widget-mpris button:active { background-color: ${C[surface1]}; }
    .widget-mpris button:disabled { opacity: 0.5; }

    .widget-menubar > box > .menu-button-bar > button > label {
      font-size: 3rem;
      padding: 0.5rem 2rem;
    }

    .widget-menubar > box > .menu-button-bar > :last-child { color: ${C[red]}; }

    .power-buttons button:hover,
    .powermode-buttons button:hover,
    .screenshot-buttons button:hover { background: ${C[surface0]}; }

    .control-center .widget-label > label {
      color: ${C[text]};
      font-size: 2rem;
    }

    .widget-buttons-grid { padding-top: 1rem; }

    .widget-buttons-grid > flowbox > flowboxchild > button label { font-size: 2.5rem; }

    .widget-volume {
      padding: 1rem 0;
    }

    .widget-volume label {
      color: ${C[sapphire]};
      padding: 0 1rem;
    }

    .widget-volume trough highlight  { background: ${C[sapphire]}; }
    .widget-backlight trough highlight { background: ${C[yellow]}; }

    .widget-backlight label {
      font-size: 1.5rem;
      color: ${C[yellow]};
    }

    .widget-backlight .KB { padding-bottom: 1rem; }

    .image { padding-right: 0.5rem; }
  '';
}
NIXEOF
}

# ── Generate kitty.nix ─────────────────────────────────────────────────────
gen_kitty_nix() {
  cat > "$NIXCFG/kitty.nix" << NIXEOF
{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # Font settings
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    # Required packages
    extraConfig = ''
      bold_font        JetBrainsMono NF Bold
      italic_font      JetBrainsMono NF Italic
      bold_italic_font JetBrainsMono NF Medium Italic
      modify_font cell_height 118%
    '';

    settings = {
      # Background
      background_opacity = "0.9";

      # Shell and editor
      shell  = "zsh";
      editor = "nvim";

      # Remote control
      allow_remote_control = "yes";
      listen_on            = "unix:@mykitty";

      # Features
      allow_hyperlinks   = "yes";
      shell_integration  = "enabled";
      confirm_os_window_close = 0;

      # Cursor trail
      cursor_trail                 = 0;
      cursor_trail_decay           = "0.1 0.2";
      cursor_trail_start_threshold = 1;

      # Keybindings modifier
      kitty_mod = "ctrl";

      # ${C[name]} colors
      foreground           = "${C[text]}";
      background           = "${C[base]}";
      selection_foreground = "${C[base]}";
      selection_background = "${C[rosewater]}";

      cursor            = "${C[rosewater]}";
      cursor_text_color = "${C[base]}";

      url_color = "${C[rosewater]}";

      active_border_color   = "${C[lavender]}";
      inactive_border_color = "${C[overlay0]}";
      bell_border_color     = "${C[yellow]}";

      wayland_titlebar_color = "system";

      active_tab_foreground   = "${C[crust]}";
      active_tab_background   = "${C[mauve]}";
      inactive_tab_foreground = "${C[text]}";
      inactive_tab_background = "${C[mantle]}";
      tab_bar_background      = "${C[crust]}";

      mark1_foreground = "${C[base]}";
      mark1_background = "${C[lavender]}";
      mark2_foreground = "${C[base]}";
      mark2_background = "${C[mauve]}";
      mark3_foreground = "${C[base]}";
      mark3_background = "${C[sapphire]}";

      # Black
      color0 = "${C[surface1]}";
      color8 = "${C[surface2]}";

      # Red
      color1 = "${C[red]}";
      color9 = "${C[red]}";

      # Green
      color2  = "${C[green]}";
      color10 = "${C[green]}";

      # Yellow
      color3  = "${C[yellow]}";
      color11 = "${C[yellow]}";

      # Blue
      color4  = "${C[blue]}";
      color12 = "${C[blue]}";

      # Magenta
      color5  = "${C[pink]}";
      color13 = "${C[pink]}";

      # Cyan
      color6  = "${C[teal]}";
      color14 = "${C[teal]}";

      # White
      color7  = "${C[subtext1]}";
      color15 = "${C[subtext0]}";
    };
  };
}
NIXEOF
}

# ── Generate btop.nix ──────────────────────────────────────────────────────
gen_btop_nix() {
  cat > "$NIXCFG/btop.nix" << NIXEOF
{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    btop
  ];

  # Deploy the ${C[name]} theme file
  xdg.configFile."btop/themes/current.theme".text = ''
    theme[main_bg]="${C[base]}"
    theme[main_fg]="${C[text]}"
    theme[title]="${C[text]}"
    theme[hi_fg]="${C[accent]}"
    theme[selected_bg]="${C[surface1]}"
    theme[selected_fg]="${C[accent]}"
    theme[inactive_fg]="${C[overlay1]}"
    theme[graph_text]="${C[accent]}"
    theme[meter_bg]="${C[surface1]}"
    theme[proc_misc]="${C[rosewater]}"
    theme[cpu_box]="${C[accent]}"
    theme[mem_box]="${C[accent]}"
    theme[net_box]="${C[accent]}"
    theme[proc_box]="${C[accent]}"
    theme[div_line]="${C[overlay0]}"
    theme[temp_start]="${C[green]}"
    theme[temp_mid]="${C[yellow]}"
    theme[temp_end]="${C[red]}"
    theme[cpu_start]="${C[teal]}"
    theme[cpu_mid]="${C[sapphire]}"
    theme[cpu_end]="${C[accent]}"
    theme[free_start]="${C[mauve]}"
    theme[free_mid]="${C[lavender]}"
    theme[free_end]="${C[blue]}"
    theme[cached_start]="${C[sapphire]}"
    theme[cached_mid]="${C[blue]}"
    theme[cached_end]="${C[accent]}"
    theme[available_start]="${C[peach]}"
    theme[available_mid]="${C[maroon]}"
    theme[available_end]="${C[red]}"
    theme[used_start]="${C[green]}"
    theme[used_mid]="${C[teal]}"
    theme[used_end]="${C[sky]}"
    theme[download_start]="${C[peach]}"
    theme[download_mid]="${C[maroon]}"
    theme[download_end]="${C[red]}"
    theme[upload_start]="${C[green]}"
    theme[upload_mid]="${C[teal]}"
    theme[upload_end]="${C[sky]}"
    theme[process_start]="${C[accent]}"
    theme[process_mid]="${C[sky]}"
    theme[process_end]="${C[mauve]}"
  '';

  # btop config
  xdg.configFile."btop/btop.conf".text = ''
    color_theme = "/home/honey/.config/btop/themes/current.theme"
    theme_background = True
    truecolor = True
    force_tty = False
    presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty"
    vim_keys = False
    rounded_corners = True
    terminal_sync = True
    graph_symbol = "braille"
    graph_symbol_cpu = "default"
    graph_symbol_gpu = "default"
    graph_symbol_mem = "default"
    graph_symbol_net = "default"
    graph_symbol_proc = "default"
    shown_boxes = "cpu mem net proc"
    update_ms = 2000
    proc_sorting = "cpu lazy"
    proc_reversed = False
    proc_tree = False
    proc_colors = True
    proc_gradient = True
    proc_per_core = False
    proc_mem_bytes = True
    proc_cpu_graphs = True
    proc_info_smaps = False
    proc_left = False
    proc_filter_kernel = False
    proc_aggregate = False
    keep_dead_proc_usage = False
    cpu_graph_upper = "Auto"
    cpu_graph_lower = "Auto"
    show_gpu_info = "Auto"
    cpu_invert_lower = True
    cpu_single_graph = False
    cpu_bottom = False
    show_uptime = True
    show_cpu_watts = True
    check_temp = True
    cpu_sensor = "Auto"
    show_coretemp = True
    cpu_core_map = ""
    temp_scale = "celsius"
    base_10_sizes = False
    show_cpu_freq = True
    freq_mode = "first"
    clock_format = "%X"
    background_update = True
    custom_cpu_name = ""
    disks_filter = ""
    mem_graphs = True
    mem_below_net = False
    zfs_arc_cached = True
    show_swap = True
    swap_disk = True
    show_disks = True
    only_physical = True
    use_fstab = True
    zfs_hide_datasets = False
    disk_free_priv = False
    show_io_stat = True
    io_mode = False
    io_graph_combined = False
    io_graph_speeds = ""
    net_download = 100
    net_upload = 100
    net_auto = True
    net_sync = True
    net_iface = ""
    base_10_bitrate = "Auto"
    show_battery = True
    selected_battery = "Auto"
    show_battery_watts = True
    log_level = "WARNING"
    save_config_on_exit = True
    nvml_measure_pcie_speeds = True
    rsmi_measure_pcie_speeds = True
    gpu_mirror_graph = True
    shown_gpus = "nvidia amd intel"
    custom_gpu_name0 = ""
    custom_gpu_name1 = ""
    custom_gpu_name2 = ""
    custom_gpu_name3 = ""
    custom_gpu_name4 = ""
    custom_gpu_name5 = ""
  '';
}
NIXEOF
}

# ── Generate nvim colorscheme.nix ───────────────────────────────────────────
gen_nvim_colorscheme_nix() {
  local cs="${C[nvim_colorscheme]}"

  if [ "$cs" = "everforest" ]; then
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << 'NIXEOF'
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.everforest ];
    colorscheme = "everforest";
    opts.background = "dark";
  };
}
NIXEOF
  elif [ "$cs" = "pastelglow" ]; then
    # TODO: run `nix-prefetch-github ankushbhagats pastel.nvim` to get the real hash
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << 'NIXEOF'
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "pastel-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "ankushbhagats";
          repo = "pastel.nvim";
          rev = "67e5aa4a6f70a38a4cc2e814221c9b2f8f354749";
          sha256 = "sha256-+6/HgHjNdiXGA8Zn2MS6gRdSCyV9v5I/bgoCf/wvnmQ=";
        };
      })
    ];
    colorscheme = "pastelglow";
    opts.background = "light";
  };
}
NIXEOF
  elif [ "$cs" = "rose-pine" ]; then
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << 'NIXEOF'
{
  programs.nixvim.colorschemes.rose-pine = {
    enable = true;
    settings = {
      variant = "main";
    };
  };
}
NIXEOF
  elif [ "$cs" = "aura" ]; then
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << 'NIXEOF'
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "aura-theme-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "daltonmenezes";
          repo = "aura-theme";
          rev = "20924aa0a43975420edd0e0b2f919e07a3eff9c9";
          sha256 = "08cagqdks57qcbjnzd54z6g00s6nsdd2mv10i2m3jwij85k6nklr";
        };
        sourceRoot = "source/packages/neovim";
      })
    ];
    colorscheme = "aura-dark";
  };
}
NIXEOF
  elif [ "$cs" = "nightfox" ]; then
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << 'NIXEOF'
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.nightfox-nvim ];
    colorscheme = "carbonfox";
  };
}
NIXEOF
  elif [ "$cs" = "gruvbox" ]; then
    local bg="dark"
    [ "$THEME" = "gruvbox-light" ] && bg="light"
    cat > "$NIXCFG/nvim/plugins/colorscheme.nix" << NIXEOF
{
  programs.nixvim.colorschemes.gruvbox = {
    enable = true;
    settings = {
      contrast = "hard";
      transparent_mode = true;
    };
  };

  programs.nixvim.opts.background = "${bg}";
}
NIXEOF
  fi
}

# ── Generate nvim ui.nix (lualine theme) ───────────────────────────────────
gen_nvim_ui_nix() {
  cat > "$NIXCFG/nvim/plugins/ui.nix" << NIXEOF
{
  programs.nixvim.plugins = {
    web-devicons.enable = true;

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "${C[lualine_theme]}";
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
      };
    };

    neo-tree = {
      enable = true;
      settings = {
        filesystem = {
          follow_current_file = {
            enabled = true;
          };
          filtered_items = {
            visible = true;
          };
        };
      };
    };

    bufferline = {
      enable = true;
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          offsets = [
            {
              filetype = "neo-tree";
              text = "Explorer";
              text_align = "center";
            }
          ];
        };
      };
    };
  };
}
NIXEOF
}

# ── Generate yazi.nix (color replacement from catppuccin template) ─────────
gen_yazi_nix() {
  local tmpl="$HOME/.config/quickshell/templates/yazi.nix.tmpl"
  if [ ! -f "$tmpl" ]; then
    echo "Warning: yazi template not found at $tmpl, skipping" >&2
    return
  fi

  # Replace catppuccin mocha colors with target theme colors
  sed \
    -e "s/#1e1e2e/${C[base]}/g" \
    -e "s/#181825/${C[mantle]}/g" \
    -e "s/#11111b/${C[crust]}/g" \
    -e "s/#313244/${C[surface0]}/g" \
    -e "s/#45475a/${C[surface1]}/g" \
    -e "s/#585b70/${C[surface2]}/g" \
    -e "s/#6c7086/${C[overlay0]}/g" \
    -e "s/#7f849c/${C[overlay1]}/g" \
    -e "s/#9399b2/${C[overlay2]}/g" \
    -e "s/#cdd6f4/${C[text]}/g" \
    -e "s/#bac2de/${C[subtext1]}/g" \
    -e "s/#a6adc8/${C[subtext0]}/g" \
    -e "s/#f38ba8/${C[red]}/g" \
    -e "s/#eba0ac/${C[maroon]}/g" \
    -e "s/#f5e0dc/${C[rosewater]}/g" \
    -e "s/#f2cdcd/${C[flamingo]}/g" \
    -e "s/#f5c2e7/${C[pink]}/g" \
    -e "s/#cba6f7/${C[mauve]}/g" \
    -e "s/#b4befe/${C[lavender]}/g" \
    -e "s/#89b4fa/${C[blue]}/g" \
    -e "s/#74c7ec/${C[sapphire]}/g" \
    -e "s/#89dceb/${C[sky]}/g" \
    -e "s/#94e2d5/${C[teal]}/g" \
    -e "s/#a6e3a1/${C[green]}/g" \
    -e "s/#f9e2af/${C[yellow]}/g" \
    -e "s/#fab387/${C[peach]}/g" \
    "$tmpl" > "$NIXCFG/yazi.nix"
}

# ── Generate hyprland border colors in settings.nix ────────────────────────
gen_hyprland_borders() {
  local active="${C[accent]}"
  local inactive="${C[surface0]}"
  # Strip # from hex colors for rgba format
  local active_hex="${active#\#}"
  local inactive_hex="${inactive#\#}"

  sed -i \
    -e "s/\"col.active_border\" = \"rgba(.*)\"/\"col.active_border\" = \"rgba(${active_hex}ff)\"/" \
    -e "s/\"col.inactive_border\" = \"rgba(.*)\"/\"col.inactive_border\" = \"rgba(${inactive_hex}ff)\"/" \
    "$HOME/NixOS/hyprland/settings.nix"
}

# ── Live reload ─────────────────────────────────────────────────────────────
live_reload() {
  # Apply hyprland border colors live
  if command -v hyprctl &>/dev/null; then
    local active="${C[accent]}"
    local inactive="${C[surface0]}"
    local active_hex="${active#\#}"
    local inactive_hex="${inactive#\#}"
    hyprctl keyword general:col.active_border "rgba(${active_hex}ff)" 2>/dev/null || true
    hyprctl keyword general:col.inactive_border "rgba(${inactive_hex}ff)" 2>/dev/null || true
  fi

  # Reload swaync style if running
  if command -v swaync-client &>/dev/null; then
    swaync-client -rs 2>/dev/null || true
  fi

  # Live-update kitty colors if kitty is running
  if command -v kitty &>/dev/null; then
    kitty @ --to unix:@mykitty set-colors \
      foreground="${C[text]}" \
      background="${C[base]}" \
      cursor="${C[rosewater]}" \
      cursor_text_color="${C[base]}" \
      selection_foreground="${C[base]}" \
      selection_background="${C[rosewater]}" \
      color0="${C[surface1]}" color8="${C[surface2]}" \
      color1="${C[red]}" color9="${C[red]}" \
      color2="${C[green]}" color10="${C[green]}" \
      color3="${C[yellow]}" color11="${C[yellow]}" \
      color4="${C[blue]}" color12="${C[blue]}" \
      color5="${C[pink]}" color13="${C[pink]}" \
      color6="${C[teal]}" color14="${C[teal]}" \
      color7="${C[subtext1]}" color15="${C[subtext0]}" \
      active_border_color="${C[lavender]}" \
      inactive_border_color="${C[overlay0]}" \
      active_tab_foreground="${C[crust]}" \
      active_tab_background="${C[mauve]}" \
      inactive_tab_foreground="${C[text]}" \
      inactive_tab_background="${C[mantle]}" \
      tab_bar_background="${C[crust]}" \
      2>/dev/null || true
  fi
}

# ── Update fastfetch config colors ─────────────────────────────────────────
gen_fastfetch_config() {
  local cfg="$HOME/.config/fastfetch/config.jsonc"
  [ -f "$cfg" ] || return

  sed -i \
    -e "s/\"keyColor\": \"#[0-9A-Fa-f]\{6\}\"/\"keyColor\": \"${C[accent]}\"/g" \
    -e "s/\"1\": \"#[0-9A-Fa-f]\{6\}\"/\"1\": \"${C[accent]}\"/g" \
    -e "s/\"2\": \"#[0-9A-Fa-f]\{6\}\"/\"2\": \"${C[accent]}\"/g" \
    -e "s/\"3\": \"#[0-9A-Fa-f]\{6\}\"/\"3\": \"${C[accent]}\"/g" \
    -e "s/\"4\": \"#[0-9A-Fa-f]\{6\}\"/\"4\": \"${C[accent]}\"/g" \
    -e "s/\"5\": \"#[0-9A-Fa-f]\{6\}\"/\"5\": \"${C[accent]}\"/g" \
    -e "s/\"6\": \"#[0-9A-Fa-f]\{6\}\"/\"6\": \"${C[accent]}\"/g" \
    "$cfg"
}

# ── Main ────────────────────────────────────────────────────────────────────
gen_themes_nix
gen_kitty_nix
gen_btop_nix
gen_nvim_colorscheme_nix
gen_nvim_ui_nix
gen_yazi_nix
gen_fastfetch_config
gen_hyprland_borders
live_reload

echo "Switched NixOS config to: ${C[name]}"
echo "Run 'sudo nixos-rebuild switch --flake ~/NixOS#' to fully apply."
