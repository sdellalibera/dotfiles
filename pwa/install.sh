#!/usr/bin/env bash
# pwa/install.sh - Restore PWA .desktop files and icons
set -e

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Desktop files
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
for f in "$TOPIC_DIR/applications/"*.desktop; do
    [ -f "$f" ] || continue
    ln -sf "$f" "$APP_DIR/$(basename "$f")"
done

# Icons
for size in 128x128 256x256 32x32 48x48 512x512; do
    ICON_SRC="$TOPIC_DIR/icons/hicolor/${size}/apps"
    ICON_DST="$HOME/.local/share/icons/hicolor/${size}/apps"
    if [ -d "$ICON_SRC" ]; then
        mkdir -p "$ICON_DST"
        for f in "$ICON_SRC"/*.png; do
            [ -f "$f" ] || continue
            ln -sf "$f" "$ICON_DST/$(basename "$f")"
        done
    fi
done
