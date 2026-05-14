#!/usr/bin/env bash
# dotnet/install.sh - Install .NET SDK and Aspire CLI, symlink global.json
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .NET 10 SDK
if ! dotnet --list-sdks 2>/dev/null | grep -q "^10\."; then
    echo "    Installing .NET 10.0 SDK..."
    sudo apt-get update && sudo apt-get install -y dotnet-sdk-10.0
fi

# Aspire CLI
if ! command -v aspire &>/dev/null; then
    echo "    Installing Aspire CLI..."
    export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"
    curl -sSL https://aspire.dev/install.sh | bash || echo "    Aspire CLI install failed — install manually later"
fi

# Symlink global.json to $HOME
if [ -f "$TOPIC_DIR/global.json" ]; then
    ln -sf "$TOPIC_DIR/global.json" "$HOME/global.json"
fi
