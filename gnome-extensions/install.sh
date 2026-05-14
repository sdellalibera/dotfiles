#!/usr/bin/env bash
# gnome-extensions/install.sh - Install GNOME extensions and load settings
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# GNOME Extension Manager
if ! command -v extension-manager &>/dev/null; then
    echo "    Installing GNOME Extension Manager..."
    sudo apt install -y gnome-shell-extension-manager
fi

# Install extensions via gnome-extensions-cli
if [ -f "$TOPIC_DIR/extensions.txt" ]; then
    echo "    Installing GNOME Shell extensions..."
    sudo apt install -y pipx 2>/dev/null || true
    pipx ensurepath
    pipx install gnome-extensions-cli 2>/dev/null || pip install --user gnome-extensions-cli 2>/dev/null || true

    while IFS= read -r ext; do
        case "$ext" in
            ding@*|snapd-*|ubuntu-*|web-search-provider@*) continue ;;
        esac
        gext install "$ext" 2>/dev/null || true
    done < "$TOPIC_DIR/extensions.txt"
fi

# Enable extensions
if [ -f "$TOPIC_DIR/extensions-enabled.txt" ]; then
    while IFS= read -r ext; do
        gnome-extensions enable "$ext" 2>/dev/null || true
    done < "$TOPIC_DIR/extensions-enabled.txt"
fi
