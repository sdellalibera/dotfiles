#!/usr/bin/env bash
# install-software.sh - Install all required software on a fresh Ubuntu machine
set -euo pipefail

echo "=== Installing developer tools and applications ==="

# Update system
sudo apt update && sudo apt upgrade -y

# GitHub CLI repo
if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
fi

# Essential tools
sudo apt update && sudo apt install -y \
    git \
    gh \
    curl \
    wget \
    stow \
    zsh \
    vim \
    build-essential \
    ca-certificates \
    apt-transport-https \
    gnupg \
    lsb-release \
    unzip \
    jq \
    htop

# ── GitHub CLI auth (needed for private repo clones) ───────────
if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
    echo "GitHub CLI not authenticated. Running gh auth login..."
    gh auth login
fi
# Configure git to use gh as credential helper (avoids PAT prompts)
if command -v gh &>/dev/null; then
    gh auth setup-git
fi

# ── Oh My Zsh ──────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh plugins (public repos, no auth needed)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ] || \
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

# ── .NET SDK ───────────────────────────────────────────────────
if ! command -v dotnet &>/dev/null; then
    echo "Installing .NET SDK..."
    wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh --channel LTS
    export PATH="$HOME/.dotnet:$PATH"
fi

# ── Aspire CLI ─────────────────────────────────────────────────
if ! command -v aspire &>/dev/null; then
    echo "Installing Aspire CLI..."
    curl -fsSL https://aka.ms/install-aspire-cli.sh | bash
fi

# ── Microsoft Edge ─────────────────────────────────────────────
if ! command -v microsoft-edge &>/dev/null; then
    echo "Installing Microsoft Edge..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
        sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    sudo apt update && sudo apt install -y microsoft-edge-stable
fi

# ── Visual Studio Code ─────────────────────────────────────────
if ! command -v code &>/dev/null; then
    echo "Installing VS Code..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" | \
        sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update && sudo apt install -y code
fi

# ── Azure VPN Client ──────────────────────────────────────────
if ! command -v microsoft-azurevpnclient &>/dev/null; then
    echo "Installing Azure VPN Client..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt update && sudo apt install -y microsoft-azurevpnclient
fi

# ── Microsoft Intune ───────────────────────────────────────────
if ! command -v microsoft-intune &>/dev/null; then
    echo "Installing Microsoft Intune (if available)..."
    sudo apt install -y intune-portal 2>/dev/null || echo "Intune package not available in current repos, skipping."
fi

# ── GNOME Extension Manager ────────────────────────────────────
if ! command -v extension-manager &>/dev/null; then
    echo "Installing GNOME Extension Manager..."
    sudo apt install -y gnome-shell-extension-manager
fi

# ── GNOME Extensions (via CLI) ─────────────────────────────────
SCRIPT_DIR_EARLY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR_EARLY/gnome-extensions/extensions.txt" ]; then
    echo "Installing GNOME Shell extensions..."
    # Install pipx and gnome-extensions-cli for easy installs
    sudo apt install -y pipx 2>/dev/null || true
    pipx ensurepath
    pipx install gnome-extensions-cli 2>/dev/null || pip install --user gnome-extensions-cli 2>/dev/null || true

    while IFS= read -r ext; do
        # Skip system/ubuntu extensions (they come preinstalled)
        case "$ext" in
            ding@*|snapd-*|ubuntu-*|web-search-provider@*) continue ;;
        esac
        echo "  Installing extension: $ext"
        gext install "$ext" 2>/dev/null || true
    done < "$SCRIPT_DIR_EARLY/gnome-extensions/extensions.txt"

    # Enable the enabled ones
    if [ -f "$SCRIPT_DIR_EARLY/gnome-extensions/extensions-enabled.txt" ]; then
        while IFS= read -r ext; do
            gnome-extensions enable "$ext" 2>/dev/null || true
        done < "$SCRIPT_DIR_EARLY/gnome-extensions/extensions-enabled.txt"
    fi
fi

# ── Fonts ──────────────────────────────────────────────────────
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    echo "Installing JetBrainsMono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -o /tmp/JetBrainsMono.tar.xz
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    fc-cache -fv
    rm /tmp/JetBrainsMono.tar.xz
fi

# ── VS Code Extensions ────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/vscode/extensions.txt" ]; then
    echo "Installing VS Code extensions..."
    while IFS= read -r ext; do
        code --install-extension "$ext" --force 2>/dev/null || true
    done < "$SCRIPT_DIR/vscode/extensions.txt"
fi

echo ""
echo "=== Software installation complete! ==="
echo "Run ./install-configs.sh to apply dotfile configurations."
echo "You may need to log out and back in for zsh to take effect."
