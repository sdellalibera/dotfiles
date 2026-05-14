#!/usr/bin/env bash
# edge/install.sh - Install Microsoft Edge and symlink bookmarks
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Edge
if ! command -v microsoft-edge &>/dev/null; then
    echo "    Installing Microsoft Edge..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | \
        sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    sudo apt update && sudo apt install -y microsoft-edge-stable
fi

# Symlink bookmarks
EDGE_DIR="$HOME/.config/microsoft-edge/Default"
mkdir -p "$EDGE_DIR"
if [ -f "$TOPIC_DIR/Bookmarks" ]; then
    ln -sf "$TOPIC_DIR/Bookmarks" "$EDGE_DIR/Bookmarks"
fi
