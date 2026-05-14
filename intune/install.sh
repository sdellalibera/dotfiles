#!/usr/bin/env bash
# intune/install.sh - Install Microsoft Identity Broker, Smart Card support, and Intune
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Microsoft Identity Broker
if ! dpkg-query -W -f='${Status}' microsoft-identity-broker 2>/dev/null | grep -q "install ok installed"; then
    echo "    Installing Microsoft Identity Broker..."
    sudo apt install -y microsoft-identity-broker || echo "    Identity Broker install failed"
fi

# Smart Card / YubiKey support
echo "    Ensuring Smart Card and YubiKey packages are installed..."
sudo apt install -y pcscd opensc yubikey-manager libnss3-tools

# NSS database for smart card certs
if [ ! -d "$HOME/.pki/nssdb" ] || ! modutil -dbdir sql:"$HOME/.pki/nssdb" -list 2>/dev/null | grep -q "SC Module"; then
    mkdir -p "$HOME/.pki/nssdb"
    chmod 700 "$HOME/.pki"
    chmod 700 "$HOME/.pki/nssdb"
    modutil -force -create -dbdir sql:"$HOME/.pki/nssdb"
    modutil -force -dbdir sql:"$HOME/.pki/nssdb" -add 'SC Module' -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
fi

# Microsoft Intune
if ! dpkg-query -W -f='${Status}' intune-portal 2>/dev/null | grep -q "install ok installed"; then
    echo "    Installing Microsoft Intune..."
    sudo apt install -y intune-portal || echo "    Intune install failed"
fi

# Symlink Intune config files
INTUNE_DIR="$HOME/.config/intune"
mkdir -p "$INTUNE_DIR"
for f in "$TOPIC_DIR"/*.toml; do
    [ -f "$f" ] || continue
    ln -sf "$f" "$INTUNE_DIR/$(basename "$f")"
done
