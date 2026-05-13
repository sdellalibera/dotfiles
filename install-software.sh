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

# ── .NET 10 SDK ────────────────────────────────────────────────
# Reference: https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?tabs=dotnet10&pivots=os-linux-ubuntu-2604
if ! dotnet --list-sdks 2>/dev/null | grep -q "^10\."; then
    echo "Installing .NET 10.0 SDK via apt..."
    sudo apt-get update && sudo apt-get install -y dotnet-sdk-10.0
    echo ".NET SDK installed: $(dotnet --version)"
fi

# ── Aspire CLI ─────────────────────────────────────────────────
if ! command -v aspire &>/dev/null; then
    echo "Installing Aspire CLI..."
    # Ensure dotnet is in PATH (just installed above)
    export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"
    curl -sSL https://aspire.dev/install.sh | bash || echo "Aspire CLI install failed — install manually later with: curl -sSL https://aspire.dev/install.sh | bash"
fi

# ── GitHub Copilot CLI ─────────────────────────────────────────
if ! command -v github-copilot-cli &>/dev/null; then
    echo "Installing GitHub Copilot CLI..."
    gh extension install github/gh-copilot 2>/dev/null || true
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

# ── Microsoft packages repo (needed for Azure VPN, Intune, Identity Broker) ──
# Reference: https://learn.microsoft.com/en-us/entra/identity/devices/sso-linux
MSFT_UBUNTU_VER="$(lsb_release -rs)"
MSFT_UBUNTU_CODENAME="$(lsb_release -cs)"

# Import the legacy microsoft.asc key (used by Edge repo and older Ubuntu releases)
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/
rm -f /tmp/microsoft.gpg

# Ubuntu 26.04+ PMC repos are signed with a newer key
if dpkg --compare-versions "$MSFT_UBUNTU_VER" ge "26.04"; then
    MS_GPG_KEYRING="/usr/share/keyrings/microsoft-2025.gpg"
    curl -fsSL https://packages.microsoft.com/keys/microsoft-2025.asc | gpg --dearmor > /tmp/microsoft-2025.gpg
    sudo install -o root -g root -m 644 /tmp/microsoft-2025.gpg /usr/share/keyrings/
    rm -f /tmp/microsoft-2025.gpg
else
    MS_GPG_KEYRING="/usr/share/keyrings/microsoft.gpg"
fi

# Add the Microsoft prod repo for the current Ubuntu version
MSFT_REPO_LINE="deb [arch=amd64 signed-by=${MS_GPG_KEYRING}] https://packages.microsoft.com/ubuntu/${MSFT_UBUNTU_VER}/prod ${MSFT_UBUNTU_CODENAME} main"
if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ] || ! grep -qF "${MSFT_UBUNTU_VER}/prod ${MSFT_UBUNTU_CODENAME}" /etc/apt/sources.list.d/microsoft-prod.list; then
    echo "Configuring Microsoft packages repository (Ubuntu ${MSFT_UBUNTU_VER})..."
    echo "$MSFT_REPO_LINE" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt update
fi

# ── Azure VPN Client ──────────────────────────────────────────
# Reference: https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-entra-vpn-client-linux
# Azure VPN Client only supports Ubuntu 20.04 and 22.04; use 22.04 repo as fallback.
if ! command -v microsoft-azurevpnclient &>/dev/null; then
    echo "Installing Azure VPN Client..."
    AZURE_VPN_REPO="deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main"
    if ! grep -qsF "ubuntu/22.04/prod jammy" /etc/apt/sources.list.d/microsoft-azurevpn.list 2>/dev/null; then
        echo "$AZURE_VPN_REPO" | sudo tee /etc/apt/sources.list.d/microsoft-azurevpn.list
        sudo apt update
    fi
    sudo apt install -y microsoft-azurevpnclient || echo "Azure VPN Client install failed — see https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-entra-vpn-client-linux"
fi

# ── Microsoft Identity Broker (prerequisite for Intune) ───────
# Reference: https://learn.microsoft.com/en-us/entra/identity/devices/sso-linux
if ! dpkg-query -W -f='${Status}' microsoft-identity-broker 2>/dev/null | grep -q "install ok installed"; then
    echo "Installing Microsoft Identity Broker..."
    sudo apt install -y microsoft-identity-broker || echo "Identity Broker install failed — see https://learn.microsoft.com/en-us/entra/identity/devices/sso-linux"
fi

# ── Smart Card / YubiKey support (needed for Identity Broker PRMFA) ──
# Reference: https://learn.microsoft.com/en-us/entra/identity/devices/sso-linux
echo "Ensuring Smart Card and YubiKey packages are installed..."
sudo apt install -y pcscd opensc yubikey-manager libnss3-tools

# Configure NSS database for the current user (required for Edge/broker to see smart card certs)
if [ ! -d "$HOME/.pki/nssdb" ] || ! modutil -dbdir sql:"$HOME/.pki/nssdb" -list 2>/dev/null | grep -q "SC Module"; then
    echo "Configuring NSS database for smart card..."
    mkdir -p "$HOME/.pki/nssdb"
    chmod 700 "$HOME/.pki"
    chmod 700 "$HOME/.pki/nssdb"
    modutil -force -create -dbdir sql:"$HOME/.pki/nssdb"
    modutil -force -dbdir sql:"$HOME/.pki/nssdb" -add 'SC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
fi

# ── Microsoft Intune ───────────────────────────────────────────
# Reference: https://learn.microsoft.com/en-us/intune/user-help/company-portal/intune-app-linux
if ! dpkg-query -W -f='${Status}' intune-portal 2>/dev/null | grep -q "install ok installed"; then
    echo "Installing Microsoft Intune..."
    sudo apt install -y intune-portal || echo "Intune install failed — see https://learn.microsoft.com/en-us/intune/user-help/company-portal/intune-app-linux"
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
