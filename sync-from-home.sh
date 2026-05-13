#!/usr/bin/env bash
# sync-from-home.sh - Pull latest configs from $HOME back into the dotfiles repo
# Run this before committing to capture any changes you've made.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Syncing configs from \$HOME into dotfiles repo ==="

# Git
cp -u ~/.gitconfig "$DOTFILES_DIR/git/.gitconfig" 2>/dev/null && echo "  ✓ git"

# Zsh
cp -u ~/.zshrc "$DOTFILES_DIR/zsh/.zshrc" 2>/dev/null && echo "  ✓ zsh"

# VSCode
cp -u ~/.config/Code/User/settings.json "$DOTFILES_DIR/vscode/.config/Code/User/settings.json" 2>/dev/null && echo "  ✓ vscode settings"
cp -u ~/.config/Code/User/keybindings.json "$DOTFILES_DIR/vscode/.config/Code/User/keybindings.json" 2>/dev/null && echo "  ✓ vscode keybindings"
code --list-extensions > "$DOTFILES_DIR/vscode/extensions.txt" 2>/dev/null && echo "  ✓ vscode extensions"

# NuGet
cp -u ~/.nuget/NuGet/NuGet.Config "$DOTFILES_DIR/nuget/.nuget/NuGet/NuGet.Config" 2>/dev/null && echo "  ✓ nuget"

# Edge Bookmarks
cp -u ~/.config/microsoft-edge/Default/Bookmarks "$DOTFILES_DIR/edge/.config/microsoft-edge/Default/Bookmarks" 2>/dev/null && echo "  ✓ edge bookmarks"

# Azure VPN
cp -u ~/.config/microsoft-azurevpnclient/profiles/* "$DOTFILES_DIR/azure-vpn/.config/microsoft-azurevpnclient/profiles/" 2>/dev/null && echo "  ✓ azure vpn"

# Intune
cp -u ~/.config/intune/*.toml "$DOTFILES_DIR/intune/.config/intune/" 2>/dev/null && echo "  ✓ intune"

# PWA desktop files and icons
cp -u ~/.local/share/applications/msedge-*.desktop "$DOTFILES_DIR/pwa/.local/share/applications/" 2>/dev/null && echo "  ✓ pwa desktop files"
for size in 128x128 256x256 32x32 48x48; do
    cp -u ~/.local/share/icons/hicolor/${size}/apps/msedge-*.png \
        "$DOTFILES_DIR/pwa/.local/share/icons/hicolor/${size}/apps/" 2>/dev/null
done
echo "  ✓ pwa icons"

# dconf
dconf dump / > "$DOTFILES_DIR/dconf/dconf-dump.ini" 2>/dev/null && echo "  ✓ dconf"

echo ""
echo "=== Sync complete! Review changes with: git diff ==="
