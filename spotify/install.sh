#!/usr/bin/env bash
# spotify/install.sh - Install Spotify via Flatpak and configure flags
set -e

if ! flatpak list 2>/dev/null | grep -q "com.spotify.Client"; then
    echo "    Installing Spotify via Flatpak..."
    flatpak install -y flathub com.spotify.Client
fi

# Create spotify-flags.conf for native Wayland/GTK support
CONF_DIR="$HOME/.var/app/com.spotify.Client/config"
mkdir -p "$CONF_DIR"
cat > "$CONF_DIR/spotify-flags.conf" <<EOF
--ozone-platform=x11
--enable-features=RunAsNativeGtk
EOF

flatpak override --user --nosocket=wayland com.spotify.Client
