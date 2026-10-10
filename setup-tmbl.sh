#!/bin/bash
# setup-tmbl.sh -- bootstrap a fresh openSUSE Tumbleweed machine.
#
# Only does what has to happen BEFORE chezmoi can run:
#   1. Packman repo        (codecs; zypper scripts later rely on it)
#   2. git, zsh, curl, chezmoi
#   3. oh-my-zsh           (chezmoi's .zshrc sources it)
#   4. zsh as login shell
#   5. chezmoi init --apply from THIS checkout
# Everything else (packages, configs, oh-my-posh, systemd units) comes from
# chezmoi: home/.chezmoidata/packages.yaml and the run_onchange_ scripts.
# Safe to re-run: every step checks before it acts.

set -euo pipefail

if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# The repo this script lives in -- used as chezmoi's source, so a local
# checkout (or the Docker build context) is applied, not whatever is on GitHub.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! grep -q "openSUSE Tumbleweed" /etc/os-release; then
    echo "ERROR: This script supports only openSUSE Tumbleweed." >&2
    exit 1
fi

ensure_sudo() {
    if [ -n "$SUDO" ] && ! sudo -v; then
        echo "ERROR: sudo access is required." >&2
        exit 1
    fi
}

add_packman_repo() {
    if zypper lr | grep -q packman; then
        echo "Packman repository already exists."
    else
        $SUDO rpm --import https://ftp.gwdg.de/pub/linux/misc/packman/gpg-pubkey-1abd1afb.asc
        $SUDO zypper -n ar -cfgp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
        $SUDO zypper -n ref
    fi
}

install_requirements() {
    # Separate words, not one quoted string: zypper needs one argument per package.
    $SUDO zypper -n in git zsh curl chezmoi
}

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh is already installed."
        return
    fi
    # .zshrc is chezmoi's job now: keep whatever is there, don't switch shells,
    # don't start zsh at the end (that would stop this script).
    CHSH=no RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

change_shell_to_zsh() {
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [ "$(getent passwd "$(whoami)" | cut -d: -f7)" = "$zsh_path" ]; then
        echo "Default shell is already zsh."
    elif command -v chsh >/dev/null; then
        $SUDO chsh --shell "$zsh_path" "$(whoami)"
    else
        echo "chsh not available (minimal image?) -- skipping login shell change."
    fi
}

run_chezmoi() {
    chezmoi init --apply --source "$REPO_DIR"
}

main() {
    ensure_sudo
    add_packman_repo
    install_requirements
    install_ohmyzsh
    change_shell_to_zsh
    run_chezmoi
}

main "$@"
