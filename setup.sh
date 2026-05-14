#!/usr/bin/env bash
#
# setup.sh - Single entry point for dotfiles installation
#
# Usage:
#   ./setup.sh          # Full setup: system packages + symlinks + topic installers
#   ./setup.sh links    # Only create symlinks (script/bootstrap)
#   ./setup.sh install  # Only run topic installers (script/install)

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_system_packages () {
    echo "=== Installing base system packages ==="

    sudo apt update && sudo apt upgrade -y

    # GitHub CLI repo
    if ! command -v gh &>/dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    fi

    # Essential tools (no vim, no stow — we handle symlinks ourselves)
    sudo apt update && sudo apt install -y \
        git \
        gh \
        curl \
        wget \
        zsh \
        build-essential \
        ca-certificates \
        apt-transport-https \
        gnupg \
        lsb-release \
        unzip \
        jq \
        htop

    # GitHub CLI auth
    if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
        echo "GitHub CLI not authenticated. Running gh auth login..."
        gh auth login
    fi
    if command -v gh &>/dev/null; then
        gh auth setup-git
    fi

    # GitHub Copilot CLI
    if command -v gh &>/dev/null; then
        gh extension install github/gh-copilot 2>/dev/null || true
    fi

    # JetBrainsMono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        echo "Installing JetBrainsMono Nerd Font..."
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o /tmp/JetBrainsMono.tar.xz
        tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
        fc-cache -fv
        rm /tmp/JetBrainsMono.tar.xz
    fi

    echo "=== Base system packages installed ==="
}

case "${1:-}" in
    links)
        "$DOTFILES_ROOT/script/bootstrap"
        ;;
    install)
        "$DOTFILES_ROOT/script/install"
        ;;
    *)
        install_system_packages
        "$DOTFILES_ROOT/script/bootstrap"
        "$DOTFILES_ROOT/script/install"
        echo ''
        echo '=== All done! Log out and back in for zsh to take effect. ==='
        ;;
esac
