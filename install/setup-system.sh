#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/backup.sh"
DOTFILES_DIR="$HOME/.local/share/dotfiles"

# Configure gnome-keyring PAM
log_info "Configuring gnome-keyring PAM integration..."

[ -f "/etc/pam.d/login" ] && backup_file "/etc/pam.d/login"
[ -f "/etc/pam.d/passwd" ] && backup_file "/etc/pam.d/passwd"

# Configure /etc/pam.d/login
if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/login; then
  sudo sed -i '/auth.*include.*system-local-login/a auth       optional     pam_gnome_keyring.so' /etc/pam.d/login
  sudo sed -i '/session.*include.*system-local-login/a session    optional     pam_gnome_keyring.so auto_start' /etc/pam.d/login
fi

# Configure /etc/pam.d/passwd
if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/passwd; then
  echo "password	optional	pam_gnome_keyring.so" | sudo tee -a /etc/pam.d/passwd >/dev/null
fi

log_success "gnome-keyring PAM configured"

# Configure pacman.conf
log_info "Configuring pacman.conf..."
PACMAN_CONF="/etc/pacman.conf"

[ -f "$PACMAN_CONF" ] && backup_file "$PACMAN_CONF"
sudo cp "$DOTFILES_DIR/default/pacman/pacman.conf" "$PACMAN_CONF"
log_success "pacman.conf configured"

# Configure UFW
if is_installed "ufw"; then
  log_info "Configuring UFW..."
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow 53317/udp comment 'LocalSend'
  sudo ufw allow 53317/tcp comment 'LocalSend'
  sudo ufw allow 22/tcp comment 'SSH'
  sudo ufw --force enable
  sudo systemctl enable ufw
  log_success "UFW configured and enabled"
else
  log_detail "UFW not installed, skipping firewall configuration"
fi

# Detect and configure NVIDIA if present
if has_nvidia_gpu; then
  log_info "NVIDIA GPU detected, configuring for Hyprland..."
  bash "$SCRIPT_DIR/setup-nvidia"
fi

# ly display manager configuration
if is_installed "ly"; then
  log_info "Configuring ly display manager..."
  sudo mkdir -p /etc/systemd/system/ly.service.d
  [ -f "/etc/systemd/system/ly.service.d/override.conf" ] && backup_file "/etc/systemd/system/ly.service.d/override.conf"
  sudo cp "$DOTFILES_DIR/default/ly/override.conf" /etc/systemd/system/ly.service.d/override.conf
  sudo systemctl daemon-reload

  [ -f "/etc/ly/config.ini" ] && backup_file "/etc/ly/config.ini"
  sudo rm -f /etc/ly/config.ini
  sudo cp "$DOTFILES_DIR/default/ly/config.ini" /etc/ly/config.ini

  log_success "ly display manager configured"
else
  log_detail "ly not installed, skipping"
fi

# Remove wait on network from system startup
log_info "Disabling systemd-networkd-wait-online.service..."
sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true

# Enable ssh agent
log_info "Enabling gcr-ssh-agent"
systemctl --user enable --now gcr-ssh-agent.socket

log_success "System configuration complete!"
