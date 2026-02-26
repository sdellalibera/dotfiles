# ============================================================
# Win 11 Setup - Automated Installation & Configuration Script
# ============================================================
# Run this script in an elevated (Administrator) PowerShell session.
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== Win 11 Setup ===" -ForegroundColor Cyan

# --------------------------------------------------
# 1. Ensure winget is available
# --------------------------------------------------
Write-Host "`n[1/5] Checking for winget..." -ForegroundColor Yellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Installing App Installer from the Microsoft Store..." -ForegroundColor Yellow
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        Write-Host "winget installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install winget. Please install it manually from https://aka.ms/getwinget"
        exit 1
    }
}
else {
    Write-Host "winget is already installed." -ForegroundColor Green
}

# --------------------------------------------------
# 2. Install Fastfetch
# --------------------------------------------------
Write-Host "`n[2/5] Installing Fastfetch..." -ForegroundColor Yellow
winget install --id Fastfetch-cli.Fastfetch --accept-source-agreements --accept-package-agreements -e
Write-Host "Fastfetch installed." -ForegroundColor Green

# --------------------------------------------------
# 3. Install JetBrainsMono Nerd Font
# --------------------------------------------------
Write-Host "`n[3/5] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow
winget install --id DEVCOM.JetBrainsMonoNerdFont --accept-source-agreements --accept-package-agreements -e
Write-Host "JetBrainsMono Nerd Font installed." -ForegroundColor Green

# --------------------------------------------------
# 4. Copy Powershell (Windows Terminal) settings
# --------------------------------------------------
Write-Host "`n[4/5] Configuring Windows Terminal..." -ForegroundColor Yellow
$wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$repoSettings  = Join-Path $RepoRoot "Powershell\settings.json"

if (Test-Path $wtSettingsDir) {
    $dest = Join-Path $wtSettingsDir "settings.json"

    # Back up existing settings before overwriting
    if (Test-Path $dest) {
        $backup = "$dest.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -Path $dest -Destination $backup -Force
        Write-Host "Existing settings backed up to $backup" -ForegroundColor DarkGray
    }

    # Read the repo customizations and merge them into the current settings
    $repoJson    = Get-Content -Raw $repoSettings | ConvertFrom-Json
    $currentJson = if (Test-Path $dest) { Get-Content -Raw $dest | ConvertFrom-Json } else { [PSCustomObject]@{} }

    # Merge profiles.defaults from repo into current settings
    if (-not $currentJson.profiles) {
        $currentJson | Add-Member -NotePropertyName profiles -NotePropertyValue ([PSCustomObject]@{})
    }
    $currentJson.profiles.defaults = $repoJson.profiles.defaults

    $currentJson | ConvertTo-Json -Depth 10 | Set-Content -Path $dest -Encoding UTF8
    Write-Host "Windows Terminal settings updated." -ForegroundColor Green
}
else {
    Write-Host "Windows Terminal settings directory not found. Skipping." -ForegroundColor DarkYellow
}

# --------------------------------------------------
# 5a. Copy Fastfetch config
# --------------------------------------------------
Write-Host "`n[5/5] Copying configuration files..." -ForegroundColor Yellow

$fastfetchDir = Join-Path $env:USERPROFILE ".config\fastfetch"
if (-not (Test-Path $fastfetchDir)) {
    New-Item -ItemType Directory -Path $fastfetchDir -Force | Out-Null
    Write-Host "Created $fastfetchDir" -ForegroundColor DarkGray
}

$srcFastfetch = Join-Path $RepoRoot "Fastfetch\config.jsonc"
Copy-Item -Path $srcFastfetch -Destination (Join-Path $fastfetchDir "config.jsonc") -Force
Write-Host "Fastfetch config copied to $fastfetchDir" -ForegroundColor Green

# --------------------------------------------------
# 5b. Copy VSCode settings
# --------------------------------------------------
$vscodeDir = "$env:APPDATA\Code\User"
if (-not (Test-Path $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    Write-Host "Created $vscodeDir" -ForegroundColor DarkGray
}

$srcVSCode = Join-Path $RepoRoot "VSCode\settings.json"
$destVSCode = Join-Path $vscodeDir "settings.json"

# Back up existing VSCode settings before overwriting
if (Test-Path $destVSCode) {
    $backup = "$destVSCode.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $destVSCode -Destination $backup -Force
    Write-Host "Existing VSCode settings backed up to $backup" -ForegroundColor DarkGray
}

Copy-Item -Path $srcVSCode -Destination $destVSCode -Force
Write-Host "VSCode settings copied to $vscodeDir" -ForegroundColor Green

# --------------------------------------------------
# Done
# --------------------------------------------------
Write-Host "`n=== Setup complete! ===" -ForegroundColor Cyan
Write-Host "Please restart your terminal to apply all changes." -ForegroundColor White
