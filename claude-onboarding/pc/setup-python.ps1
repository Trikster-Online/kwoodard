# =============================================================================
# setup-python.ps1
# Purpose:     Install Python 3 and code quality tools for Python development.
#              Run this after setup-claude-code-generic.ps1.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-05-12
# Version:     1.0
# Usage:       pwsh -ExecutionPolicy Bypass -File setup-python.ps1
# Notes:       Installs Python from the Microsoft Store via winget.
#              Tools (flake8, black, etc.) are installed into the user's
#              Python environment and invoked as: python -m <tool>
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

Write-Header "Python Language Pack Setup"
Write-Host "  Installs Python 3 and code quality tools (flake8, black, isort, mypy, pytest)."
Write-Host ""
Write-Host "Press ENTER to begin, or Ctrl+C to cancel..."
Read-Host | Out-Null
Write-Host ""

# =============================================================================
# STEP 1 -- Python 3
# Installs the latest Python 3 release via winget. If Python is already
# installed, this step is skipped. The version check uses 'python' (not
# 'python3') because Windows does not alias python3 by default.
# =============================================================================
Write-Step 1 "Python 3"

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyVer = python --version 2>&1
    if ($pyVer -match '^Python 3') {
        Write-Ok "Already installed: $pyVer at $(Get-Command python | Select-Object -ExpandProperty Source)"
        $SKIPPED += "Python 3"
    } else {
        Write-Warn "Found '$pyVer' -- this is not Python 3. Installing Python 3 via winget..."
        winget install --id Python.Python.3 -e --source winget --accept-package-agreements --accept-source-agreements
        Update-SessionPath
        if (Get-Command python -ErrorAction SilentlyContinue) {
            Write-Ok "Python 3 installed: $(python --version)"
            $INSTALLED += "Python 3"
        } else {
            Write-Err "Python 3 install failed."
            $ERRORS += "Python 3"
        }
    }
} else {
    Write-Warn "Python not found. Installing via winget..."
    winget install --id Python.Python.3 -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Ok "Python installed: $(python --version)"
        $INSTALLED += "Python 3"
    } else {
        Write-Err "Python install failed. Open a new PowerShell window and re-run if PATH was just updated."
        $ERRORS += "Python 3"
    }
}
Write-Host ""

# =============================================================================
# STEP 2 -- pip (package installer)
# pip is included with Python 3 but may need to be updated. This step
# ensures pip is current before installing the code quality tools.
# =============================================================================
Write-Step 2 "pip (Python package installer)"

if (Get-Command python -ErrorAction SilentlyContinue) {
    python -m pip install --upgrade pip --quiet
    $pipVer = python -m pip --version 2>$null
    if ($pipVer) {
        Write-Ok "pip ready: $pipVer"
        $SKIPPED += "pip"
    } else {
        Write-Err "pip not available. Python may not be installed correctly."
        $ERRORS += "pip"
    }
} else {
    Write-Warn "Python not in PATH -- skipping pip check."
}
Write-Host ""

# =============================================================================
# STEP 3 -- Python code quality tools
# These tools are used for general code quality checks in Python projects:
#   flake8  -- style and error linting
#   black   -- opinionated code formatter
#   isort   -- import statement sorter
#   mypy    -- static type checker
#   pytest  -- test runner
# All are invoked as: python -m <tool>  (not as standalone commands)
# because Windows pip installs scripts to a path that may not be in PATH.
# =============================================================================
Write-Step 3 "Python code quality tools (flake8, black, isort, mypy, pytest)"

$pythonTools = @("flake8", "black", "isort", "mypy", "pytest")

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Warn "Python not in PATH -- skipping tool installs."
    $ERRORS += "Python tools (Python not in PATH)"
} else {
    foreach ($tool in $pythonTools) {
        $check = python -m $tool --version 2>$null
        if ($check) {
            Write-Ok "python -m $tool already available: $check"
            $SKIPPED += $tool
        } else {
            Write-Warn "$tool not found. Installing via pip..."
            python -m pip install --quiet $tool
            $check = python -m $tool --version 2>$null
            if ($check) {
                Write-Ok "$tool installed: $check"
                $INSTALLED += $tool
            } else {
                Write-Err "$tool install failed."
                $ERRORS += $tool
            }
        }
    }
}
Write-Host ""

# =============================================================================
# STEP 4 -- Python VS Code extension
# Provides IntelliSense, linting integration, debugging, and the Pylance
# language server for Python files in VS Code.
# =============================================================================
Write-Step 4 "Python VS Code extension"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Warn "VS Code (code) not found in PATH -- skipping extension install."
    $ERRORS += "Python VS Code extension (VS Code not in PATH)"
} else {
    $extId = "ms-python.python"
    $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $extId }
    if ($installed) {
        Write-Ok "Python extension already installed"
        $SKIPPED += "VS Code: Python"
    } else {
        Write-Warn "Python extension not installed. Installing..."
        code --install-extension $extId --force 2>$null
        $installed = code --list-extensions 2>$null | Where-Object { $_ -ieq $extId }
        if ($installed) {
            Write-Ok "Python extension installed"
            $INSTALLED += "VS Code: Python"
        } else {
            Write-Err "Python extension install failed."
            $ERRORS += "VS Code: Python"
        }
    }
}
Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Header "Python Setup Complete"

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
    Write-Host "  Python is ready. Invoke tools as: python -m <tool>"
    Write-Host ""
    Write-Host "  Examples:"
    Write-Host "    python -m flake8 myscript.py     -- check for style errors"
    Write-Host "    python -m black myscript.py      -- auto-format the file"
    Write-Host "    python -m pytest                 -- run all tests in current folder"
    Write-Host "    python -m mypy myscript.py       -- check types"
}

Write-Host ""
Write-Host "Press ENTER to close..."
Read-Host | Out-Null
