#!/usr/bin/env bash
# install-configs.sh - Use GNU Stow to symlink dotfiles into $HOME
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "=== Applying dotfile configurations with GNU Stow ==="

# Ensure stow is installed
if ! command -v stow &>/dev/null; then
    echo "ERROR: GNU Stow is not installed. Run ./install-software.sh first."
    exit 1
fi

# ── Stow packages (symlink configs into $HOME) ─────────────────
PACKAGES=(zsh vscode nuget edge azure-vpn intune pwa)

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing: $pkg"
        # --adopt: if a target file already exists, move it INTO the repo
        # then restow to create the symlink. This handles existing files.
        stow --adopt --target="$HOME" "$pkg" 2>/dev/null || true
        # Restow to ensure correct symlinks
        stow --restow --target="$HOME" "$pkg"
    fi
done

echo "  ⚠ If stow adopted files, run 'git checkout .' in the dotfiles repo"
echo "    to restore repo versions over any adopted ones."

# ── dconf (GNOME settings) ────────────────────────────────────
# dconf can't be stowed (it's a binary database), so we load it directly
if [ -f "$DOTFILES_DIR/dconf/dconf-dump.ini" ]; then
    echo "  Loading dconf settings..."
    dconf load / < "$DOTFILES_DIR/dconf/dconf-dump.ini"
fi

# ── VS Code extensions ────────────────────────────────────────
if [ -f "$DOTFILES_DIR/vscode/extensions.txt" ] && command -v code &>/dev/null; then
    echo "  Installing VS Code extensions..."
    while IFS= read -r ext; do
        code --install-extension "$ext" --force 2>/dev/null || true
    done < "$DOTFILES_DIR/vscode/extensions.txt"
fi

echo ""
echo "=== Configuration applied! ==="
echo ""
echo "Notes:"
echo "  - Edge bookmarks will appear after restarting Edge"
echo "  - PWA apps (Outlook, Teams, OneDrive) are restored via .desktop files"
echo "  - Azure VPN profiles are ready in the VPN client"
echo "  - dconf/GNOME settings are loaded (may need logout for some)"
echo "  - VS Code settings and extensions are synced"
echo ""
echo "To update configs from this machine back to the repo:"
echo "  cd $DOTFILES_DIR && ./sync-from-home.sh"
