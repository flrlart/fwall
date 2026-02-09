#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "script executed from root, aborting."
    exit 1
fi

FWALL_DIR="$HOME/.config/fwall"
USERPREFS="$HOME/.config/hypr/userprefs.conf"

mkdir -p "$FWALL_DIR"

WALLPICKER_URL="https://raw.githubusercontent.com/flrlart/fwall/main/wallpicker.sh"
THEMEPICKER_URL="https://raw.githubusercontent.com/flrlart/fwall/main/themepicker.sh"

echo "downloading wallpicker.sh..."
curl -sL "$WALLPICKER_URL" -o "$FWALL_DIR/wallpicker.sh"
echo "downloading themepicker.sh..."
curl -sL "$THEMEPICKER_URL" -o "$FWALL_DIR/themepicker.sh"

chmod +x "$FWALL_DIR/wallpicker.sh" "$FWALL_DIR/themepicker.sh"

if [[ ! -f "$USERPREFS" ]]; then
    echo "hyprland userprefs.conf not found, aborting."
    exit 1
fi

if grep -q "wallpicker.sh" "$USERPREFS"; then
    echo "bind already exists, skip"
else
    echo "adding bind SUPER+N -> wallpicker.sh into $HOME/.config/hypr/userprefs.conf"
    echo "bind = \$mainMod, N, exec, \$HOME/.config/fwall/wallpicker.sh" >> "$USERPREFS"
fi

for pkg in fuzzel swww; do
    if ! command -v "$pkg" &> /dev/null; then
        if ! command -v yay &> /dev/null; then
            echo "yay not found, aborting"
            exit 1
        fi
        echo "installing $pkg"
        yay -S --noconfirm "$pkg"
    else
        echo "$pkg already installed"
    fi
done

echo "install completed, run 'hyprctl reload'"
