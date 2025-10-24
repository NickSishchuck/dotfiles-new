#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/lib/helpers.sh"
DOTFILES_DIR="$HOME/.local/share/dotfiles"

# Set initial theme
log_info "Setting up Everforest theme..."
mkdir -p "$DOTFILES_DIR/current"
ln -snf "$DOTFILES_DIR/themes/everforest" "$DOTFILES_DIR/current/theme"

# Find first wallpaper in backgrounds folder
first_wallpaper=$(find "$DOTFILES_DIR/themes/everforest/backgrounds" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) 2>/dev/null | sort | head -n1)

if [ -n "$first_wallpaper" ]; then
  ln -snf "$first_wallpaper" "$DOTFILES_DIR/current/background"
  log_detail "Using wallpaper: $(basename "$first_wallpaper")"
else
  log_detail "No wallpapers found in backgrounds folder"
  log_detail "Add wallpapers to: $DOTFILES_DIR/themes/everforest/backgrounds/"
fi

# Create config symlinks
mkdir -p "$HOME/.config/btop/themes"
mkdir -p "$HOME/.config/mako"

ln -snf "$DOTFILES_DIR/current/theme/btop.theme" "$HOME/.config/btop/themes/current.theme"
ln -snf "$DOTFILES_DIR/current/theme/mako.ini" "$HOME/.config/mako/config"

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme "Yaru-sage"
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font Mono 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 11'

log_success "Everforest theme configured"
