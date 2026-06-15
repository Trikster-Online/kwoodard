# =============================================================================
# setup-rust.ps1
# Purpose:     Install Rust via rustup and the VS Code extension for Rust
#              development. Run this after setup-claude-code-generic.ps1.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-05-12
# Version:     1.0
# Usage:       pwsh -ExecutionPolicy Bypass -File setup-rust.ps1
# Notes:       Rust on Windows requires the Microsoft C++ Build Tools (MSVC
#              linker). If you have Visual Studio installed, these are already
#              present. If rustup prompts you to install them, follow the prompt
#              and then re-run this script.
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
    # Rust tools install to %USERPROFILE%\.cargo\bin -- include it explicitly
    $cargoBin    = "$env:USERPROFILE\.cargo\bin"
    $env:PATH    = "$machinePath;$userPath;$cargoBin"
}

Write-Header "Rust Language Pack Setup"
Write-Host "  Installs Rust via rustup (stable toolchain) and the rust-analyzer VS Code extension."
Write-Host ""
Write-Host "  IMPORTANT: Rust on Windows requires the Microsoft C++ Build Tools."
Write-Host "  If you have Visual Studio installed, these are already present."
Write-Host "  If rustup asks you to install them, follow its instructions and"
Write-Host "  then re-run this script."
Write-Host ""
Write-Host "Press ENTER to begin, or Ctrl+C to cancel..."
Read-Host | Out-Null
Write-Host ""

# =============================================================================
# STEP 1 -- Check for Microsoft C++ Build Tools (MSVC linker)
# Rust on Windows requires the MSVC linker (cl.exe) to compile native code.
# It is included with any Visual Studio installation (including Build Tools).
# If it is missing, rustup will prompt to install it during Step 2.
# =============================================================================
Write-Step 1 "Microsoft C++ Build Tools (MSVC linker)"

$clExe = Get-Command cl.exe -ErrorAction SilentlyContinue
if ($clExe) {
    Write-Ok "MSVC linker found at: $($clExe.Source)"
    $SKIPPED += "MSVC Build Tools"
} else {
    # Check common Visual Studio installation paths as a fallback
    $vsPath = Get-ChildItem "C:\Program Files\Microsoft Visual Studio" -ErrorAction SilentlyContinue |
              Where-Object { $_.PSIsContainer } |
              Select-Object -First 1
    if ($vsPath) {
        Write-Ok "Visual Studio found at $($vsPath.FullName) -- MSVC tools should be present."
        Write-Warn "cl.exe is not in PATH. rustup will locate it automatically during compile."
        $SKIPPED += "MSVC Build Tools (VS present, not in PATH)"
    } else {
        Write-Warn "MSVC Build Tools not detected."
        Write-Host "  If rustup fails in the next step, install Visual Studio Build Tools:"
        Write-Host "    winget install Microsoft.VisualStudio.2022.BuildTools"
        Write-Host "  Select 'Desktop development with C++' during install, then re-run this script."
    }
}
Write-Host ""

# =============================================================================
# STEP 2 -- rustup and stable toolchain
# rustup is the Rust toolchain installer and version manager. Installing
# rustup also installs the stable Rust toolchain (rustc compiler + cargo
# package manager). All Rust tools land in %USERPROFILE%\.cargo\bin\.
# =============================================================================
Write-Step 2 "rustup and stable Rust toolchain"

if (Get-Command rustup -ErrorAction SilentlyContinue) {
    Write-Ok "rustup already installed: $(rustup --version 2>$null)"
    Write-Warn "Checking for toolchain updates..."
    rustup update stable 2>$null
    Write-Ok "Rust stable toolchain: $(rustc --version 2>$null)"
    $SKIPPED += "rustup"
    $SKIPPED += "Rust stable toolchain"
} else {
    Write-Warn "rustup not installed. Installing via winget..."
    winget install --id Rustlang.Rustup -e --source winget --accept-package-agreements --accept-source-agreements

    Update-SessionPath

    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Write-Ok "rustup installed: $(rustup --version 2>$null)"
        $INSTALLED += "rustup"

        # Ensure stable toolchain is initialized
        rustup install stable 2>$null
        rustup default stable 2>$null

        if (Get-Command cargo -ErrorAction SilentlyContinue) {
            Write-Ok "Rust stable toolchain ready: $(rustc --version 2>$null)"
            Write-Ok "cargo available: $(cargo --version 2>$null)"
            $INSTALLED += "Rust stable toolchain"
        } else {
            Write-Warn "cargo not yet in PATH. Open a new PowerShell window and run: rustup default stable"
        }
    } else {
        Write-Err "rustup install failed."
        Write-Host "  If MSVC Build Tools are missing, install them first:"
        Write-Host "    winget install Microsoft.VisualStudio.2022.BuildTools"
        $ERRORS += "rustup"
    }
}
Write-Host ""

# =============================================================================
# STEP 3 -- rust-analyzer VS Code extension
# rust-analyzer provides IntelliSense, inline type hints, go-to-definition,
# and real-time error checking for Rust code in VS Code. It is the official
# language server for Rust.
# =============================================================================
Write-Step 3 "rust-analyzer VS Code extension"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Warn "VS Code (code) not found in PATH -- skipping extension install."
    $ERRORS += "rust-analyzer (VS Code not in PATH)"
} else {
    $extId = "rust-lang.rust-analyzer"
    $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $extId }
    if ($installed) {
        Write-Ok "rust-analyzer already installed"
        $SKIPPED += "VS Code: rust-analyzer"
    } else {
        Write-Warn "rust-analyzer not installed. Installing..."
        code --install-extension $extId --force 2>$null
        $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $extId }
        if ($installed) {
            Write-Ok "rust-analyzer installed"
            $INSTALLED += "VS Code: rust-analyzer"
        } else {
            Write-Err "rust-analyzer install failed."
            $ERRORS += "VS Code: rust-analyzer"
        }
    }
}
Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Header "Rust Setup Complete"

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
    Write-Host "  Rust is ready."
    Write-Host ""
    Write-Host "  Common cargo commands:"
    Write-Host "    cargo new my-project      -- create a new project"
    Write-Host "    cargo build               -- compile the project"
    Write-Host "    cargo test                -- run tests"
    Write-Host "    cargo clippy              -- run the Rust linter"
    Write-Host "    cargo fmt                 -- format code"
    Write-Host ""
    Write-Host "  Rust tools are in: $env:USERPROFILE\.cargo\bin"
    Write-Host "  This folder is added to PATH automatically by rustup."
}

Write-Host ""
Write-Host "Press ENTER to close..."
Read-Host | Out-Null
