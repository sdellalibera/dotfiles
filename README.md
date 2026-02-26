# win-11-setup

Automated setup and customization for a fresh Windows 11 installation.

## Project Structure

```
├── Powershell/       # Windows Terminal profile settings
│   └── settings.json
├── Fastfetch/        # Fastfetch configuration
│   └── config.jsonc
├── VSCode/           # Visual Studio Code text & visual settings
│   └── settings.json
├── FileExplorer/     # File Explorer customizations
└── Scripts/          # Installation & setup scripts
    └── install.ps1
```

## What the Install Script Does

1. **Installs winget** if it is not already available (fresh Win 11 install).
2. **Installs Fastfetch** via winget.
3. **Installs JetBrainsMono Nerd Font** via winget.
4. **Configures Windows Terminal** by merging the PowerShell settings from this repo.
5. **Copies Fastfetch config** to `~/.config/fastfetch/config.jsonc`, creating the directory if needed.
6. **Copies VSCode settings** to the VS Code user settings directory.

## Usage

Open an **elevated (Administrator) PowerShell** prompt, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Scripts\install.ps1
```