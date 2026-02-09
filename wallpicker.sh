#!/bin/sh
theme_file="$HOME/.config/fwall/current_theme"
wall_file="$HOME/.config/fwall/current_wall"
themes_dir="$HOME/.config/hyde/themes"

if [ ! -f "$theme_file" ]; then
    first_theme=$(find "$themes_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | head -n 1)

    if [ -z "$first_theme" ]; then
        notify-send "error" "No themes found in $themes_dir"
        exit 1
    fi

    printf "%s\n" "$first_theme" > "$theme_file"
    notify-send "theme" "current_theme generated: $first_theme"
fi

current_theme=$(cat "$theme_file")
wall_dir="$themes_dir/$current_theme/wallpapers"
theme_item="🖼️ change theme"

if [ ! -d "$wall_dir" ]; then
    notify-send "error" "wallpapers not found for theme: $current_theme"
    exit 1
fi

current_wall=""
[ -f "$wall_file" ] && current_wall=$(cat "$wall_file")

wallpapers=$(ls "$wall_dir" | grep -E "\.(jpg|png|jpeg)$" | while read -r wp; do
    if [ "$wp" = "$current_wall" ]; then
        printf "▶ %s\n" "$wp"
    else
        printf "  %s\n" "$wp"
    fi
done)

menu_items=$(printf "%s\n\n%s" "$wallpapers" "$theme_item")

count=$(printf "%s\n" "$menu_items" | wc -l)

printf "%s\n" "$menu_items" | \
fuzzel --dmenu --auto-select --hide-prompt --lines="$count" | \
while read -r choice; do
    [ -z "$choice" ] && exit 0

    if [ "$choice" = "$theme_item" ]; then
        "$HOME/.config/fwall/themepicker.sh"
    else
        selected_wall=$(printf "%s\n" "$choice" | sed 's/^● //; s/^  //')

        printf "%s\n" "$selected_wall" > "$wall_file"

        swww img "$wall_dir/$selected_wall" \
            --transition-type=grow \
            --transition-fps=60 \
            --transition-duration=0.5
    fi
done