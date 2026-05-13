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
PACKAGES=(git zsh vscode nuget edge azure-vpn intune pwa)

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        # Find conflicts: real files that would block stow
        conflicts=$(stow --no --verbose "$pkg" --target="$HOME" 2>&1 | grep "existing target" | sed 's/.*: //' || true)
        if [ -n "$conflicts" ]; then
            echo "  Backing up conflicts for: $pkg"
            mkdir -p "$BACKUP_DIR"
            while IFS= read -r file; do
                target="$HOME/$file"
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    mkdir -p "$BACKUP_DIR/$(dirname "$file")"
                    mv "$target" "$BACKUP_DIR/$file"
                    echo "    Moved: $target → $BACKUP_DIR/$file"
                fi
            done <<< "$conflicts"
        fi
        echo "  Stowing: $pkg"
        stow --restow --target="$HOME" "$pkg"
    fi
done

if [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo "  ⚠ Conflicting files backed up to: $BACKUP_DIR"
fi

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
