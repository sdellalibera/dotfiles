#!/usr/bin/env bash
# dconf/install.sh - Load GNOME/dconf settings
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$TOPIC_DIR/dconf-dump.ini" ] && command -v dconf &>/dev/null; then
    echo "    Loading dconf settings..."
    dconf load / < "$TOPIC_DIR/dconf-dump.ini"
fi
