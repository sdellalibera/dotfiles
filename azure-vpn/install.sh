#!/usr/bin/env bash
# azure-vpn/install.sh - Install Azure VPN Client and copy profiles
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Microsoft packages repo setup (shared prerequisite)
MSFT_UBUNTU_VER="$(lsb_release -rs)"
MSFT_UBUNTU_CODENAME="$(lsb_release -cs)"

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/
rm -f /tmp/microsoft.gpg

if dpkg --compare-versions "$MSFT_UBUNTU_VER" ge "26.04"; then
    MS_GPG_KEYRING="/usr/share/keyrings/microsoft-2025.gpg"
    curl -fsSL https://packages.microsoft.com/keys/microsoft-2025.asc | gpg --dearmor > /tmp/microsoft-2025.gpg
    sudo install -o root -g root -m 644 /tmp/microsoft-2025.gpg /usr/share/keyrings/
    rm -f /tmp/microsoft-2025.gpg
else
    MS_GPG_KEYRING="/usr/share/keyrings/microsoft.gpg"
fi

MSFT_REPO_LINE="deb [arch=amd64 signed-by=${MS_GPG_KEYRING}] https://packages.microsoft.com/ubuntu/${MSFT_UBUNTU_VER}/prod ${MSFT_UBUNTU_CODENAME} main"
if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ] || ! grep -qF "${MSFT_UBUNTU_VER}/prod ${MSFT_UBUNTU_CODENAME}" /etc/apt/sources.list.d/microsoft-prod.list; then
    echo "$MSFT_REPO_LINE" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt update
fi

# Azure VPN Client
if ! command -v microsoft-azurevpnclient &>/dev/null; then
    echo "    Installing Azure VPN Client..."
    AZURE_VPN_REPO="deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main"
    if ! grep -qsF "ubuntu/22.04/prod jammy" /etc/apt/sources.list.d/microsoft-azurevpn.list 2>/dev/null; then
        echo "$AZURE_VPN_REPO" | sudo tee /etc/apt/sources.list.d/microsoft-azurevpn.list
        sudo apt update
    fi
    sudo apt install -y microsoft-azurevpnclient || echo "    Azure VPN Client install failed"
fi

# Copy VPN profiles
VPN_DIR="$HOME/.config/microsoft-azurevpnclient/profiles"
mkdir -p "$VPN_DIR"
if [ -d "$TOPIC_DIR/profiles" ]; then
    cp -u "$TOPIC_DIR/profiles/"* "$VPN_DIR/" 2>/dev/null || true
fi
