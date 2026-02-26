# ============================================================
# PowerShell Profile
# Loaded automatically at the start of every new PowerShell session.
# ============================================================

# --------------------------------------------------
# Display system info with Fastfetch
# --------------------------------------------------
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}

# --------------------------------------------------
# Aliases
# --------------------------------------------------
function ll { Get-ChildItem -Force @args }
