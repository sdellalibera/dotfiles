#!/usr/bin/env bash
# nuget/install.sh - Symlink NuGet.Config
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.nuget/NuGet"
if [ -f "$TOPIC_DIR/NuGet.Config" ]; then
    ln -sf "$TOPIC_DIR/NuGet.Config" "$HOME/.nuget/NuGet/NuGet.Config"
fi
