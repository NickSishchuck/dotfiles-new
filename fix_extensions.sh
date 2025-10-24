#!/bin/bash

# Script to fix file extensions in dotfiles
# This will rename files that shouldn't have .sh extensions

set -e

echo "Fixing file extensions in dotfiles..."
echo

# Change to dotfiles directory
cd ~/Projects/Misc/dotfiles-new || {
  echo "Error: Dotfiles directory not found"
  exit 1
}

# Function to rename file and report
rename_file() {
  local old_path="$1"
  local new_path="$2"

  if [ -f "$old_path" ]; then
    mv "$old_path" "$new_path"
    echo "✓ Renamed: $old_path → $new_path"
  else
    echo "⚠ File not found: $old_path"
  fi
}

echo "Fixing bin/ scripts..."
rename_file "bin/hyprsunset-toggle.sh" "bin/hyprsunset-toggle"
rename_file "bin/launch-walker.sh" "bin/launch-walker"
rename_file "bin/menu-keybindings.sh" "bin/menu-keybindings"
rename_file "bin/restart-app.sh" "bin/restart-app"

echo
echo "Fixing install/ scripts..."
rename_file "install/install.sh" "install/install"
rename_file "install/setup-applications.sh" "install/setup-applications"
rename_file "install/setup-by-hardware.sh" "install/setup-by-hardware"
rename_file "install/setup-config.sh" "install/setup-config"
rename_file "install/setup-nvidia.sh" "install/setup-nvidia"
rename_file "install/setup-system.sh" "install/setup-system"
rename_file "install/setup-theme.sh" "install/setup-theme"

echo
echo "Making bin/ scripts executable..."
chmod +x bin/* 2>/dev/null || true

echo
echo "Making install scripts executable..."
chmod +x install/install 2>/dev/null || true
chmod +x install/setup-* 2>/dev/null || true
chmod +x install/lib/*.sh 2>/dev/null || true

echo
echo "Done! All file extensions have been corrected."
echo
echo "Summary:"
echo "- Removed .sh from 11 files"
echo "- Made scripts executable"
echo
echo "Your dotfiles are now using standard Unix naming conventions."
