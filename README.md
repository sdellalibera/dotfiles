# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start (new machine)

```bash
# 1. Clone this repo
git clone <your-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles

# 2. Install all required software
chmod +x install-software.sh
./install-software.sh

# 3. Apply configurations (symlinks via stow)
chmod +x install-configs.sh
./install-configs.sh
```

## What's Included

| Package      | Contents                                          |
|--------------|---------------------------------------------------|
| `git`        | `.gitconfig`                                      |
| `zsh`        | `.zshrc` (Oh My Zsh + plugins)                    |
| `vscode`     | Settings, keybindings, extensions list             |
| `nuget`      | `NuGet.Config`                                    |
| `edge`       | Bookmarks                                         |
| `azure-vpn`  | VPN connection profiles                           |
| `intune`     | Device registration & flights config              |
| `pwa`        | PWA apps (Outlook, Teams, OneDrive) .desktop + icons |
| `dconf`      | GNOME/desktop settings (loaded directly, not stowed) |

## Keeping Configs in Sync

After making changes on your machine, pull them back into the repo:

```bash
./sync-from-home.sh
git add -A && git commit -m "Update configs"
git push
```

## How Stow Works

Each top-level folder is a "package". Stow creates symlinks from `$HOME` pointing
into this repo. For example:

```
dotfiles/git/.gitconfig  →  ~/.gitconfig (symlink)
dotfiles/vscode/.config/Code/User/settings.json  →  ~/.config/Code/User/settings.json (symlink)
```

This means edits in `$HOME` automatically update the repo files (they're the same file).

## Selective Installation

Install only specific packages:

```bash
cd ~/repos/dotfiles
stow git zsh vscode   # only these three
```
