# =============================================================================
# setup-dotnet.ps1
# Purpose:     Install .NET 10 SDK and VS Code extensions for .NET / C#
#              development. Run this after setup-claude-code-generic.ps1.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-05-12
# Version:     1.0
# Usage:       pwsh -ExecutionPolicy Bypass -File setup-dotnet.ps1
# Notes:       Installs .NET 10 (current LTS). If your project requires an
#              older SDK version, install it separately -- multiple SDKs
#              coexist on the same machine. The correct version is selected
#              automatically per project via global.json.
# =============================================================================

function Write-Header($msg) {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "  $msg"
    Write-Host "============================================"
    Write-Host ""
}
function Write-Step($num, $msg) { Write-Host "[ STEP $num ] $msg" }
function Write-Ok($msg)   { Write-Host "  [+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  [x] ERROR: $msg" -ForegroundColor Red }

$ERRORS    = @()
$INSTALLED = @()
$SKIPPED   = @()

function Update-SessionPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH    = "$machinePath;$userPath"
}

Write-Header ".NET Language Pack Setup"
Write-Host "  Installs .NET 10 SDK and C# Dev Kit for VS Code."
Write-Host ""
Write-Host "Press ENTER to begin, or Ctrl+C to cancel..."
Read-Host | Out-Null
Write-Host ""

# =============================================================================
# STEP 1 -- List existing .NET SDK versions
# Multiple .NET SDK versions can coexist on the same machine. This step
# inventories what is already installed so nothing is overwritten or removed.
# Each project's global.json pins which SDK version that project uses.
# =============================================================================
Write-Step 1 "Existing .NET SDK versions (inventory)"

if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Ok "dotnet CLI found at: $(Get-Command dotnet | Select-Object -ExpandProperty Source)"
    Write-Host ""
    Write-Host "  Installed SDKs:"
    dotnet --list-sdks | ForEach-Object { Write-Host "    $_" }
    Write-Host ""
    Write-Host "  Installed runtimes:"
    dotnet --list-runtimes | ForEach-Object { Write-Host "    $_" }
    Write-Host ""
} else {
    Write-Warn "No .NET SDK found -- will install .NET 10 in the next step."
    Write-Host ""
}

# =============================================================================
# STEP 2 -- .NET 10 SDK
# .NET 10 is the current long-term support (LTS) release. Installing it
# alongside older SDK versions does not affect existing projects -- each
# project continues to use the version pinned in its global.json file.
# If a project has no global.json, dotnet uses the newest installed SDK.
# =============================================================================
Write-Step 2 ".NET 10 SDK"

$dotnet10 = dotnet --list-sdks 2>$null | Where-Object { $_ -match '^10\.' }
if ($dotnet10) {
    Write-Ok ".NET 10 SDK already installed: $dotnet10"
    $SKIPPED += ".NET 10 SDK"
} else {
    Write-Warn ".NET 10 SDK not found. Installing via winget..."
    winget install --id Microsoft.DotNet.SDK.10 -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    $dotnet10 = dotnet --list-sdks 2>$null | Where-Object { $_ -match '^10\.' }
    if ($dotnet10) {
        Write-Ok ".NET 10 SDK installed: $dotnet10"
        $INSTALLED += ".NET 10 SDK"
    } else {
        Write-Err ".NET 10 SDK install failed."
        $ERRORS += ".NET 10 SDK"
    }
}
Write-Host ""

# =============================================================================
# STEP 3 -- dotnet format (verify)
# dotnet format is built into the .NET SDK 6 and later. It enforces C# code
# style (indentation, spacing, naming conventions) based on .editorconfig rules
# in each project. No separate install is needed -- this step verifies it works.
# =============================================================================
Write-Step 3 "dotnet format (built-in code formatter)"

if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    $fmtHelp = dotnet format --help 2>$null
    if ($fmtHelp) {
        Write-Ok "dotnet format is available (built into .NET SDK)"
        Write-Host "    Usage: dotnet format                     -- format changed files"
        Write-Host "    Usage: dotnet format --verify-no-changes -- check without modifying"
        $SKIPPED += "dotnet format"
    } else {
        Write-Warn "dotnet format not responding -- may require .NET 6 or later SDK."
        $ERRORS += "dotnet format"
    }
} else {
    Write-Warn "dotnet not in PATH -- skipping format check."
}
Write-Host ""

# =============================================================================
# STEP 4 -- C# Dev Kit (VS Code extension)
# The C# Dev Kit is Microsoft's official .NET extension for VS Code. It
# provides IntelliSense, navigation, refactoring, and a built-in test runner
# for .NET projects.
# =============================================================================
Write-Step 4 "C# Dev Kit VS Code extension"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Warn "VS Code (code) not found in PATH -- skipping extension install."
    Write-Warn "Install VS Code first (run setup-claude-code-generic.ps1), then re-run this script."
    $ERRORS += "C# Dev Kit (VS Code not in PATH)"
} else {
    $csExt = @(
        @{ id = "ms-dotnettools.csdevkit"; label = "C# Dev Kit" }
    )
    foreach ($ext in $csExt) {
        $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $ext.id }
        if ($installed) {
            Write-Ok "$($ext.label) already installed"
            $SKIPPED += "VS Code: $($ext.label)"
        } else {
            Write-Warn "$($ext.label) not installed. Installing..."
            code --install-extension $ext.id --force 2>$null
            $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $ext.id }
            if ($installed) {
                Write-Ok "$($ext.label) installed"
                $INSTALLED += "VS Code: $($ext.label)"
            } else {
                Write-Err "$($ext.label) install failed."
                $ERRORS += "VS Code: $($ext.label)"
            }
        }
    }
}
Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Header ".NET Setup Complete"

if ($INSTALLED.Count -gt 0) {
    Write-Host "  Installed:"
    foreach ($item in $INSTALLED) { Write-Host "    [+] $item" -ForegroundColor Green }
    Write-Host ""
}
if ($SKIPPED.Count -gt 0) {
    Write-Host "  Already present (skipped):"
    foreach ($item in $SKIPPED) { Write-Host "    - $item" }
    Write-Host ""
}
if ($ERRORS.Count -gt 0) {
    Write-Host "  Failed (action required):"
    foreach ($item in $ERRORS) { Write-Host "    [x] $item" -ForegroundColor Red }
    Write-Host ""
    Write-Host "  Resolve the errors above, then re-run this script."
} else {
    Write-Host "  .NET is ready. A few things to know:"
    Write-Host ""
    Write-Host "  Legacy projects (older .NET versions):"
    Write-Host "    If a project requires .NET 8, install it alongside .NET 10:"
    Write-Host "      winget install Microsoft.DotNet.SDK.8"
    Write-Host "    The project's global.json will pin the correct version automatically."
    Write-Host ""
    Write-Host "  Check what SDKs are installed at any time:"
    Write-Host "    dotnet --list-sdks"
    Write-Host ""
    Write-Host "  Format your code before committing:"
    Write-Host "    dotnet format"
}

Write-Host ""
Write-Host "Press ENTER to close..."
Read-Host | Out-Null
