#!/usr/bin/env bash
# podman/install.sh - Install Podman and Podman Desktop
set -e

# Podman
if ! command -v podman &>/dev/null; then
    echo "    Installing Podman..."
    sudo apt install -y podman
fi

# Podman Desktop via Flatpak
if ! flatpak list --user 2>/dev/null | grep -q io.podman_desktop.PodmanDesktop; then
    echo "    Installing Podman Desktop via Flatpak..."
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install --user -y flathub io.podman_desktop.PodmanDesktop
fi
