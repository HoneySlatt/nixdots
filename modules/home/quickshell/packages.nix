{ pkgs, inputs, ... }:

let
  # nodePackages removed from nixpkgs unstable (2026-03-03), pin 24.11 for less
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.system; config = {}; overlays = []; };
in
{
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "steam-games";
      runtimeInputs = [ pkgs.jq ];
      text = ''
        steam_dir="$HOME/.local/share/Steam"
        grid_dir="$steam_dir/userdata/303776471/config/grid"
        cache_dir="$steam_dir/appcache/librarycache"
        lines=()

        # Collect all library paths from libraryfolders.vdf, deduplicated
        mapfile -t lib_paths < <(grep -oP '(?<="path"\t{1,8}")([^"]+)' "$steam_dir/config/libraryfolders.vdf" 2>/dev/null | sort -u)
        [[ ''${#lib_paths[@]} -eq 0 ]] && lib_paths=("$steam_dir")

        resolve_art() {
          local appid="$1"
          for ext in png jpg; do
            [[ -f "$grid_dir/''${appid}p.$ext" ]] && echo "$grid_dir/''${appid}p.$ext" && return
          done
          for ext in jpg png; do
            [[ -f "$cache_dir/''${appid}/library_600x900.$ext" ]] && echo "$cache_dir/''${appid}/library_600x900.$ext" && return
          done
          echo ""
        }

        for lib in "''${lib_paths[@]}"; do
        for acf in "$lib/steamapps"/appmanifest_*.acf; do
          [[ -f "$acf" ]] || continue

          appid=$(grep -m1 '"appid"' "$acf" | grep -oP '(?<=")\d+(?=")' || true)
          name=$(grep -m1 '"name"' "$acf" | sed 's/.*"name"[[:space:]]*"\([^"]*\)".*/\1/' || true)

          [[ -z "$appid" || -z "$name" ]] && continue

          case "$name" in
            Proton*|"Steam Linux Runtime"*|"Steamworks Common"*|"Steam VR"*)
              continue ;;
          esac

          art=$(resolve_art "$appid")
          lines+=("$(jq -n --arg a "$appid" --arg n "$name" --arg i "$art" '{appid:$a,name:$n,art:$i}')")
        done
        done

        if [[ ''${#lines[@]} -eq 0 ]]; then
          echo "[]"
        else
          printf '%s\n' "''${lines[@]}" | jq -s 'sort_by(.name | ascii_downcase)'
        fi
      '';
    })
    adw-gtk3
    glib
    gsettings-desktop-schemas
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    (writeShellApplication {
      name = "qs-compile-userstyle";
      runtimeInputs = [ pkgs.nodejs ];
      text = ''
        NODE_PATH="${pkgs-stable.nodePackages.less}/lib/node_modules" node "$HOME/.config/quickshell/scripts/compile-userstyle.js" "$@"
      '';
    })
  ];
}
