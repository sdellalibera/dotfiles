# Dotfiles

Personal dotfiles for Ubuntu. Topic-based organization with symlinks.

## Quick Start

```bash
git clone <your-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
./setup.sh
```

## How It Works

### Structure

Each top-level folder is a **topic** (git, zsh, vscode, dotnet, etc.):

- `*.symlink` files → symlinked to `$HOME` as dotfiles by `script/bootstrap`
- `install.sh` → per-topic installer run by `script/install`

### Entry Points

| Command | What it does |
|---------|-------------|
| `./setup.sh` | Full setup: system packages + symlinks + topic installers |
| `./setup.sh links` | Only create symlinks |
| `./setup.sh install` | Only run topic installers |

### Symlink Convention

Any file named `something.symlink` in a topic folder gets linked as `~/.something`:

```
dotfiles/zsh/zshrc.symlink      →  ~/.zshrc
dotfiles/git/gitconfig.symlink  →  ~/.gitconfig
```

For nested configs (VS Code, Edge, NuGet, etc.), each topic's `install.sh` creates the symlinks at the correct paths.

**Because these are symlinks, editing `~/.zshrc` directly edits `dotfiles/zsh/zshrc.symlink` — they are the same file.**

## Topics

| Topic | What's included |
|-------|----------------|
| `zsh/` | Oh My Zsh, plugins, `.zshrc` |
| `git/` | `.gitconfig` |
| `vscode/` | VS Code, settings, extensions |
| `dotnet/` | .NET 10 SDK, Aspire CLI, global.json |
| `nuget/` | NuGet.Config |
| `edge/` | Microsoft Edge, bookmarks |
| `azure-vpn/` | Azure VPN Client, connection profiles |
| `intune/` | Identity Broker, Smart Card, Intune |
| `podman/` | Podman, Podman Desktop |
| `pwa/` | PWA .desktop files and icons |
| `gnome-extensions/` | GNOME extensions |
| `dconf/` | GNOME/dconf settings |

## Adding a New Topic

1. Create a folder: `mkdir mytopic`
2. Add config files with `.symlink` suffix for home-level dotfiles
3. Add an `install.sh` for any software installation or nested symlinks
4. Run `./setup.sh links` and `./setup.sh install`
