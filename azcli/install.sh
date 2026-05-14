#!/usr/bin/env bash
# azcli/install.sh - Install Azure CLI
set -e

if ! command -v az &>/dev/null; then
    echo "    Installing Azure CLI..."
    curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
fi
