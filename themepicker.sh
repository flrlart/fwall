#!/bin/sh

themes_dir="$HOME/.config/hyde/themes"
theme_file="$HOME/.config/fwall/current_theme"

[ ! -d "$themes_dir" ] && exit 1

current_theme=""
[ -f "$theme_file" ] && current_theme=$(cat "$theme_file")

themes=$(find "$themes_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | while read -r theme; do
    if [ "$theme" = "$current_theme" ]; then
        printf "%s %s\n" "▶" "$theme"
    else
        printf "  %s\n" "$theme"
    fi
done)

count=$(printf "%s\n" "$themes" | wc -l)

printf "%s\n" "$themes" | \
fuzzel --dmenu --auto-select --hide-prompt --lines="$count" | \
while read -r choice; do
    [ -z "$choice" ] && exit 0

    selected_theme=$(printf "%s\n" "$choice" | sed "s/^▶ //; s/^  //")

    notify-send "theme changed" "theme selected: $selected_theme"
    printf "%s\n" "$selected_theme" > "$theme_file"

    "$HOME/.config/fwall/wallpicker.sh"
done