gen_swaylock_config() {
  local color="${C[base]#\#}"
  local inside="${C[surface0]#\#}"
  local ring="${C[surface1]#\#}"
  local text="${C[text]#\#}"
  local red="${C[red]#\#}"
  local yellow="${C[yellow]#\#}"
  local accent="${C[accent]#\#}"

  mkdir -p "$HOME/.config/swaylock"

  cat > "$HOME/.config/swaylock/config" << EOF
color=${color}
image=$HOME/.config/background
scaling=fill
font=JetBrainsMono Nerd Font
font-size=18
indicator-radius=100
indicator-thickness=4
ring-color=${ring}
ring-ver-color=${ring}
ring-wrong-color=${red}
ring-clear-color=${yellow}
inside-color=${inside}
inside-ver-color=${inside}
inside-wrong-color=${inside}
inside-clear-color=${inside}
line-color=${ring}
line-ver-color=${ring}
line-wrong-color=${red}
line-clear-color=${yellow}
separator-color=${ring}
text-color=${text}
text-ver-color=${text}
text-wrong-color=${red}
text-clear-color=${yellow}
key-hl-color=${accent}
bs-hl-color=${red}
caps-lock-key-hl-color=${yellow}
caps-lock-bs-hl-color=${red}
show-failed-attempts=true
indicator-idle-visible=false
hide-keyboard-layout=true
EOF
}
