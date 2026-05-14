# Dotfiles

These are my personal dotfiles. They are highly configurable depending on your necessities — pick and choose what you need.

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone <your-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
./install-software.sh   # install all software
./install-configs.sh    # symlink configs into $HOME
```

## install-software.sh

Installs the following on a fresh Ubuntu machine:

- System update & upgrade
- Essential tools: git, gh, curl, wget, stow, zsh, vim, build-essential, unzip, jq, htop
- GitHub CLI authentication & git credential helper
- Oh My Zsh + plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - zsh-completions
- Zsh set as default shell
- .NET 10 SDK
- Aspire CLI
- Podman & Podman Desktop (via Flatpak)
- GitHub Copilot CLI (gh extension)
- Microsoft Edge
- Visual Studio Code
- Microsoft packages repository (PMC)
- Azure VPN Client
- Microsoft Identity Broker
- Smart Card / YubiKey support (pcscd, opensc, yubikey-manager)
- NSS database configuration for smart card certs
- Microsoft Intune
- GNOME Extension Manager + extensions from `gnome-extensions/extensions.txt`
- JetBrainsMono Nerd Font
- VS Code extensions from `vscode/extensions.txt`

## install-configs.sh

Symlinks configuration files into `$HOME` via GNU Stow and applies settings:

- Stows packages (symlinks into $HOME):
  - `zsh` — `.zshrc` (Oh My Zsh config, aliases, PATH, plugins)
  - `git` — `.gitconfig`
  - `vscode` — VS Code `settings.json`
  - `nuget` — `NuGet.Config`
  - `dotnet` — `global.json`
  - `edge` — Edge bookmarks
  - `azure-vpn` — VPN connection profiles
  - `intune` — Device registration & flights config
  - `pwa` — PWA apps (.desktop files + icons)
- Loads dconf/GNOME settings from `dconf/dconf-dump.ini`
- Installs VS Code extensions from `vscode/extensions.txt`

## How Stow Works

Each top-level folder is a "package". Stow creates symlinks from `$HOME` pointing into this repo:

```
dotfiles/zsh/.zshrc  →  ~/.zshrc
dotfiles/vscode/.config/Code/User/settings.json  →  ~/.config/Code/User/settings.json
```

Edits in `$HOME` automatically update the repo (they're the same file).

## Selective Installation

```bash
stow --no-folding --target="$HOME" git zsh vscode
```
