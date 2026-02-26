# win-11-setup

Automated setup and customization for a fresh Windows 11 installation.

## Project Structure

```
├── Terminal/         # Windows Terminal settings
│   └── settings.json
├── Powershell/       # PowerShell profile script
│   └── Microsoft.PowerShell_profile.ps1
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
4. **Installs developer tools** (skips any that are already installed):
   - [AZD CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/) (Azure Developer CLI)
   - [Azure CLI](https://learn.microsoft.com/cli/azure/)
   - [.NET SDK](https://dotnet.microsoft.com/) (latest)
   - [Node.js LTS](https://nodejs.org/) (includes npm)
   - [Visual Studio Code](https://code.visualstudio.com/)
5. **Configures Windows Terminal** by merging the Terminal settings from this repo.
6. **Copies the PowerShell profile** to the current user's `$PROFILE` location, running Fastfetch on every new session.
7. **Copies Fastfetch config** to `~/.config/fastfetch/config.jsonc`, creating the directory if needed.
8. **Copies VSCode settings** to the VS Code user settings directory.

## Usage

Open an **elevated (Administrator) PowerShell** prompt, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Scripts\install.ps1
```