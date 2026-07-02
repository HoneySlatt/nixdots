switch_wallpaper() {
  local wp_dir="$HOME/Pictures/Wallpapers/${C[wallpaper_dir]}"
  [ -d "$wp_dir" ] || return
  local wp
  local nsfw_file="$HOME/.config/quickshell/.nsfw-enabled"
  local nsfw_enabled
  nsfw_enabled=$(cat "$nsfw_file" 2>/dev/null | tr -d '[:space:]')
  if [ "$nsfw_enabled" = "true" ]; then
    wp=$(find "$wp_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | grep '\[NSFW\]' | shuf -n 1)
  else
    wp=$(find "$wp_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | grep -v '\[NSFW\]' | shuf -n 1)
  fi
  [ -n "$wp" ] && awww img "$wp" --transition-type wave --transition-duration 2 2>/dev/null || true
}
