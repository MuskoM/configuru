#!/bin/bash
# setup-tmbl.sh
#
# Bootstraps a fresh openSUSE Tumbleweed system with my preferred repositories, packages, shell tools, and configuration.
# - Only supports and detects openSUSE Tumbleweed.
# - Adds Packman repository if missing.
# - Installs core utilities and modern unix tools.
# - Installs oh-my-zsh and updates default shell to zsh.
# - Overwrites $HOME/.zshrc (existing config backed up as $HOME/.zshrc.backup-YYYYMMDD-HHMMSS if present).
# - Assumes user has sudo/root access as needed.
# WARNING: Review before use; customizes your shell environment.

set -euo pipefail

if [ "$EUID" -eq 0 ];  then
    SUDO=""
else
    SUDO="sudo"
fi

# Check for openSUSE Tumbleweed
if ! grep -q "openSUSE Tumbleweed" /etc/os-release; then
  echo "ERROR: This script supports only openSUSE Tumbleweed." >&2
  exit 1
fi

ensure_sudo() {
    if [ "$EUID" -ne 0 ]; then
        if ! sudo -v; then
          echo "ERROR:  access is required." >&2
          exit 1
        fi
    fi
}

# Add packman repository if not present
add_packman_repo() {
  if zypper lr | grep -q packman; then
      echo "Packman repository already exists."
  else
    $SUDO rpm --import https://ftp.gwdg.de/pub/linux/misc/packman/gpg-pubkey-1abd1afb.asc
    $SUDO zypper -n ar -cfgp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
    $SUDO zypper -n ref
  fi
}

install_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if rpm -q "$pkg" >/dev/null 2>&1; then
            echo "Package '$pkg' is already installed."
        else
            to_install+=("$pkg")
        fi
    done
    if [ ${#to_install[@]} -gt 0 ]; then
        $SUDO zypper -n in -y "${to_install[@]}"
    else
        echo "All specified packages are already installed."
    fi
}

# Install prerequisites
install_base_packages() {
  # git: Version control system
  # gcc: GNU Compiler Collection (C/C++ compiler)
  # make: Build automation tool
  # curl: Tool for transferring data with URLs
  # wget: Network downloader
  # unzip: Decompression utility for .zip files
  # zsh: Z shell, an interactive shell
  # zoxide: Smart cd command replacement
  # neovim: Modern Vim-based text editor
  # ripgrep: Fast, recursive search tool
  install_packages \
    git \
    gcc \
    make \
    curl \
    wget \
    unzip \
    zsh \
    zoxide \
    neovim \
    ripgrep
}

# Modern tools for their older counterparts taken from: https://github.com/ibraheemdev/modern-unix
install_modern_unix_packages() {
  # bat: cat clone with syntax highlighting
  # eza: Modern, colorful ls replacement
  # delta: Syntax-highlighting pager for git diff
  # dust: du alternative for disk usage
  # duf: Modern df, disk usage/free utility
  # jq: Lightweight and flexible JSON processor
  # cheat: Create and view interactive cheatsheets
  # xh: Friendly and fast HTTP client, alternative to curl
  install_packages \
    bat \
    eza \
    git-delta \
    dust \
    duf \
    jq \
    cheat \
    xh
}

install_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh"]; then
      echo "oh-my-zsh is already installed."
  else
    if [ -f "$HOME/.zshrc" ]; then
      cp "$HOME/.zshrc" "$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    cp .zshrc "$HOME/.zshrc"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  fi
}

install_ohmyzsh() {
    SRC_ZSHRC=".zshrc"
    DEST_ZSHRC="$HOME/.zshrc"

    if [ ! -f "$DEST_ZSHRC" ]; then
        cp "$SRC_ZSHRC" "$DEST_ZSHRC"
        echo "Installed new .zshrc."
    elif ! diff -q "$SRC_ZSHRC" "$DEST_ZSHRC" >/dev/null; then
        cp "$DEST_ZSHRC" "$DEST_ZSHRC.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$SRC_ZSHRC" "$DEST_ZSHRC"
        echo "Updated .zshrc (backup created)."

    else
        echo ".zshrc already up to date. No changes made."
    fi

    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh is already installed."
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    fi
}


change_shell_to_zsh() {
  if [ "$SHELL" = "/usr/bin/zsh" ]; then
      echo "Default shell is already zsh."
  else
    $SUDO chsh --shell /usr/bin/zsh "$(whoami)"
  fi
}

main() {
  ensure_sudo
  add_packman_repo
  install_base_packages
  install_ohmyzsh
  change_shell_to_zsh
  install_modern_unix_packages
}

main
