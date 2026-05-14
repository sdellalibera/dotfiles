#!/usr/bin/env bash
# vscode/install.sh - Install VS Code, extensions, and symlink settings
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install VS Code
if ! command -v code &>/dev/null; then
    echo "    Installing VS Code..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" | \
        sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update && sudo apt install -y code
fi

# Symlink settings
VSCODE_DIR="$HOME/.config/Code/User"
mkdir -p "$VSCODE_DIR"
if [ -f "$TOPIC_DIR/settings.json" ]; then
    ln -sf "$TOPIC_DIR/settings.json" "$VSCODE_DIR/settings.json"
fi
if [ -f "$TOPIC_DIR/keybindings.json" ]; then
    ln -sf "$TOPIC_DIR/keybindings.json" "$VSCODE_DIR/keybindings.json"
fi

# Install extensions
if [ -f "$TOPIC_DIR/extensions.txt" ] && command -v code &>/dev/null; then
    echo "    Installing VS Code extensions..."
    while IFS= read -r ext; do
        code --install-extension "$ext" --force 2>/dev/null || true
    done < "$TOPIC_DIR/extensions.txt"
fi
