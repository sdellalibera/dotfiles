# ============================================================
# Win 11 Setup - Automated Installation & Configuration Script
# ============================================================
# Run this script in an elevated (Administrator) PowerShell session.
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Tracking lists for the app-installation section
$failedInstalls    = [System.Collections.Generic.List[string]]::new()
$completedInstalls = [System.Collections.Generic.List[string]]::new()

# Helper: install one app via winget, record success / failure, never abort
function Install-AppTracked {
    param(
        [string]$DisplayName,
        [string]$WingetId,
        [string]$Source       = "",
        [string]$CheckCommand = ""
    )

    if ($CheckCommand -and (Get-Command $CheckCommand -ErrorAction SilentlyContinue)) {
        Write-Host "  [$DisplayName] Already installed – skipping." -ForegroundColor DarkGray
        $script:completedInstalls.Add($DisplayName)
        return
    }

    Write-Host "  [$DisplayName] Installing..." -ForegroundColor Yellow
    try {
        $wingetArgs = @(
            "install", "--id", $WingetId,
            "--accept-source-agreements", "--accept-package-agreements", "-e"
        )
        if ($Source) { $wingetArgs += "--source", $Source }

        & winget @wingetArgs

        # 0 = success; -1978335189 (0x8A150011) = already installed
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
            Write-Host "  [$DisplayName] Installed successfully." -ForegroundColor Green
            $script:completedInstalls.Add($DisplayName)
        }
        else {
            Write-Host "  [$DisplayName] Installation failed (winget exit code: $LASTEXITCODE)." -ForegroundColor Red
            $script:failedInstalls.Add($DisplayName)
        }
    }
    catch {
        Write-Host "  [$DisplayName] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedInstalls.Add($DisplayName)
    }
}

Write-Host "=== Win 11 Setup ===" -ForegroundColor Cyan

# --------------------------------------------------
# 1. Ensure winget is available
# --------------------------------------------------
Write-Host "`n[1/9] Checking for winget..." -ForegroundColor Yellow
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
Write-Host "`n[2/9] Installing Fastfetch..." -ForegroundColor Yellow
winget install --id Fastfetch-cli.Fastfetch --accept-source-agreements --accept-package-agreements -e
Write-Host "Fastfetch installed." -ForegroundColor Green

# --------------------------------------------------
# 3. Install JetBrainsMono Nerd Font
# --------------------------------------------------
Write-Host "`n[3/9] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow
winget install --id DEVCOM.JetBrainsMonoNerdFont --accept-source-agreements --accept-package-agreements -e
Write-Host "JetBrainsMono Nerd Font installed." -ForegroundColor Green

# --------------------------------------------------
# 4. Install developer tools
# --------------------------------------------------
Write-Host "`n[4/9] Installing developer tools..." -ForegroundColor Yellow

# AZD CLI (Azure Developer CLI)
if (Get-Command azd -ErrorAction SilentlyContinue) {
    Write-Host "AZD CLI is already installed. Skipping." -ForegroundColor DarkGray
}
else {
    Write-Host "Installing AZD CLI..." -ForegroundColor Yellow
    winget install --id Microsoft.Azd --accept-source-agreements --accept-package-agreements -e
    Write-Host "AZD CLI installed." -ForegroundColor Green
}

# Azure CLI
if (Get-Command az -ErrorAction SilentlyContinue) {
    Write-Host "Azure CLI is already installed. Skipping." -ForegroundColor DarkGray
}
else {
    Write-Host "Installing Azure CLI..." -ForegroundColor Yellow
    winget install --id Microsoft.AzureCLI --accept-source-agreements --accept-package-agreements -e
    Write-Host "Azure CLI installed." -ForegroundColor Green
}

# .NET SDK (latest)
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Host ".NET SDK is already installed. Skipping." -ForegroundColor DarkGray
}
else {
    Write-Host "Installing .NET SDK (latest)..." -ForegroundColor Yellow
    winget install --id Microsoft.DotNet.SDK.9 --accept-source-agreements --accept-package-agreements -e
    Write-Host ".NET SDK installed." -ForegroundColor Green
}

# Node.js / npm (LTS)
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "npm / Node.js is already installed. Skipping." -ForegroundColor DarkGray
}
else {
    Write-Host "Installing Node.js LTS (includes npm)..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements -e
    Write-Host "Node.js LTS installed." -ForegroundColor Green
}

# Visual Studio Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "VS Code is already installed. Skipping." -ForegroundColor DarkGray
}
else {
    Write-Host "Installing Visual Studio Code..." -ForegroundColor Yellow
    winget install --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements -e
    Write-Host "Visual Studio Code installed." -ForegroundColor Green
}

# --------------------------------------------------
# 5. Install Store apps and additional developer tools (tracked)
# --------------------------------------------------
Write-Host "`n[5/9] Installing Store apps and additional developer tools..." -ForegroundColor Yellow

# Samsung Galaxy Buds Manager (Microsoft Store)
Install-AppTracked -DisplayName "Samsung Galaxy Buds Manager" `
    -WingetId "9PPHJGB8S4NZ" -Source "msstore"

# Microsoft Teams
Install-AppTracked -DisplayName "Microsoft Teams" `
    -WingetId "Microsoft.Teams"

# Microsoft Outlook for Windows
Install-AppTracked -DisplayName "Microsoft Outlook for Windows" `
    -WingetId "Microsoft.OutlookForWindows"

# GitHub CLI
Install-AppTracked -DisplayName "GitHub CLI" `
    -WingetId "GitHub.cli" -CheckCommand "gh"

# Azure Functions Core Tools
Install-AppTracked -DisplayName "Azure Functions Core Tools" `
    -WingetId "Microsoft.Azure.FunctionsCoreTools" -CheckCommand "func"

# kubectl
Install-AppTracked -DisplayName "kubectl" `
    -WingetId "Kubernetes.kubectl" -CheckCommand "kubectl"

# Microsoft PowerToys
Install-AppTracked -DisplayName "Microsoft PowerToys" `
    -WingetId "Microsoft.PowerToys"

# Configure PowerToys: enable ZoomIt and Quick Accent only
Write-Host "  Configuring PowerToys settings..." -ForegroundColor Yellow
$powerToysDir = "$env:LOCALAPPDATA\Microsoft\PowerToys"
$powerToysModules = [ordered]@{
    "Always on Top"         = $false
    "Awake"                 = $false
    "Color Picker"          = $false
    "CropAndLock"           = $false
    "FancyZones"            = $false
    "File Locksmith"        = $false
    "Hosts File Editor"     = $false
    "Image Resizer"         = $false
    "Keyboard Manager"      = $false
    "Mouse Without Borders" = $false
    "Peek"                  = $false
    "PowerRename"           = $false
    "PowerToys Run"         = $false
    "Quick Accent"          = $true   # advanced letters for accents
    "Registry Preview"      = $false
    "Screen Ruler"          = $false
    "Shortcut Guide"        = $false
    "Text Extractor"        = $false
    "ZoomIt"                = $true   # zoom features
}
try {
    foreach ($entry in $powerToysModules.GetEnumerator()) {
        $moduleDir = Join-Path $powerToysDir $entry.Key
        if (-not (Test-Path $moduleDir)) {
            New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
        }
        $settingsObj = [PSCustomObject]@{
            version    = "1.0"
            name       = $entry.Key
            properties = [PSCustomObject]@{
                enabled = [PSCustomObject]@{ value = $entry.Value }
            }
        }
        $settingsObj | ConvertTo-Json -Depth 5 |
            Set-Content -Path (Join-Path $moduleDir "settings.json") -Encoding UTF8
    }
    Write-Host "  PowerToys configured: ZoomIt and Quick Accent enabled; all other modules disabled." -ForegroundColor Green
}
catch {
    Write-Host "  Could not write PowerToys settings: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# Telegram
Install-AppTracked -DisplayName "Telegram" `
    -WingetId "Telegram.TelegramDesktop"

# Python 3
Install-AppTracked -DisplayName "Python 3" `
    -WingetId "Python.Python.3" -CheckCommand "python"

# Docker Desktop
Install-AppTracked -DisplayName "Docker Desktop" `
    -WingetId "Docker.DockerDesktop" -CheckCommand "docker"

# ------ Installation summary ------
Write-Host "`n--- App Installation Summary ---" -ForegroundColor Cyan
if ($completedInstalls.Count -gt 0) {
    Write-Host "Completed ($($completedInstalls.Count)):" -ForegroundColor Green
    foreach ($item in $completedInstalls) {
        Write-Host "  [OK]     $item" -ForegroundColor Green
    }
}
if ($failedInstalls.Count -gt 0) {
    Write-Host "Failed ($($failedInstalls.Count)):" -ForegroundColor Red
    foreach ($item in $failedInstalls) {
        Write-Host "  [FAILED] $item" -ForegroundColor Red
    }
}

# --------------------------------------------------
# 6. Copy Windows Terminal settings
# --------------------------------------------------
Write-Host "`n[6/9] Configuring Windows Terminal..." -ForegroundColor Yellow
$wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$repoSettings  = Join-Path $RepoRoot "Terminal\settings.json"

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
# 7. Copy PowerShell profile
# --------------------------------------------------
Write-Host "`n[7/9] Configuring PowerShell profile..." -ForegroundColor Yellow
$psProfileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $psProfileDir)) {
    New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
    Write-Host "Created $psProfileDir" -ForegroundColor DarkGray
}

$srcProfile  = Join-Path $RepoRoot "Powershell\Microsoft.PowerShell_profile.ps1"
$destProfile = $PROFILE

# Back up existing profile before overwriting
if (Test-Path $destProfile) {
    $backup = "$destProfile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $destProfile -Destination $backup -Force
    Write-Host "Existing PowerShell profile backed up to $backup" -ForegroundColor DarkGray
}

Copy-Item -Path $srcProfile -Destination $destProfile -Force
Write-Host "PowerShell profile copied to $destProfile" -ForegroundColor Green

# --------------------------------------------------
# 8. Copy Fastfetch config
# --------------------------------------------------
Write-Host "`n[8/9] Copying configuration files..." -ForegroundColor Yellow

$fastfetchDir = Join-Path $env:USERPROFILE ".config\fastfetch"
if (-not (Test-Path $fastfetchDir)) {
    New-Item -ItemType Directory -Path $fastfetchDir -Force | Out-Null
    Write-Host "Created $fastfetchDir" -ForegroundColor DarkGray
}

$srcFastfetch = Join-Path $RepoRoot "Fastfetch\config.jsonc"
Copy-Item -Path $srcFastfetch -Destination (Join-Path $fastfetchDir "config.jsonc") -Force
Write-Host "Fastfetch config copied to $fastfetchDir" -ForegroundColor Green

# --------------------------------------------------
# 8b. Copy VSCode settings
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
# 9. Done
# --------------------------------------------------
Write-Host "`n[9/9] Setup complete!" -ForegroundColor Cyan
Write-Host "Please restart your terminal to apply all changes." -ForegroundColor White
