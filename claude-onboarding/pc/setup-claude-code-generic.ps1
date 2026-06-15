# =============================================================================
# setup-claude-code-generic.ps1
# Purpose:     Bootstrap a Windows PC with everything needed to use Claude Code.
#              Installs required software, creates a starter folder structure in
#              $HOME\Workspaces\, deploys starter configuration files to
#              $HOME\.claude\, and installs a credential guard security hook.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-05-14
# Version:     1.4
# Usage:       pwsh -ExecutionPolicy Bypass -File setup-claude-code-generic.ps1
#              Or: Right-click the file -> Run with PowerShell
# Notes:       Do NOT run as Administrator -- most installs are per-user.
#              Requires internet access for Steps 1-10.
#              Existing config files are never overwritten.
#              After this script finishes, run the language pack scripts
#              for any languages you develop in (.NET, Python, Rust).
# =============================================================================

# -- Output helpers --
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

# Reload PATH from the registry so winget-installed tools become available
# in the current session without requiring a new window.
function Update-SessionPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH    = "$machinePath;$userPath"
}

Write-Header "Claude Code New User Setup (Windows)"
Write-Host "  This script sets up Claude Code on this PC from scratch."
Write-Host ""
Write-Host "  It will:"
Write-Host "    1.  Verify winget (Windows Package Manager)"
Write-Host "    2.  Install PowerShell 7"
Write-Host "    3.  Install Git"
Write-Host "    4.  Install Node.js"
Write-Host "    5.  Install Claude Code CLI"
Write-Host "    6.  Install Visual Studio Code"
Write-Host "    7.  Install Claude Desktop"
Write-Host "    8.  Install Pandoc and Typst (document tools)"
Write-Host "    9.  Install code quality tools (PSScriptAnalyzer + Python linters)"
Write-Host "    10. Install core VS Code extensions"
Write-Host "    11. Create $HOME\Workspaces\ folder structure"
Write-Host "    12. Create $HOME\.claude\ starter configuration"
Write-Host "    13. Install credential guard security hook"
Write-Host ""
Write-Host "  Existing files are never overwritten."
Write-Host "  Do NOT run as Administrator."
Write-Host ""
Write-Host "Press ENTER to begin, or Ctrl+C to cancel..."
Read-Host | Out-Null
Write-Host ""

# =============================================================================
# STEP 1 -- winget (Windows Package Manager)
# winget is built into Windows 11. It installs software from the command line
# and is used by this script to install all required tools.
# If winget is missing, visit the Microsoft Store and install "App Installer".
# =============================================================================
Write-Step 1 "winget (Windows Package Manager)"

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Ok "winget available: $(winget --version 2>$null)"
    $SKIPPED += "winget"
} else {
    Write-Err "winget is not available on this PC."
    Write-Host "  winget requires Windows 10 (version 1809 or later) with App Installer."
    Write-Host "  Open the Microsoft Store, search for 'App Installer', and install it."
    Write-Host "  Then re-run this script."
    Write-Host ""
    Read-Host "Press ENTER to close..."
    exit 1
}
Write-Host ""

# =============================================================================
# STEP 2 -- PowerShell 7
# PowerShell 7 (pwsh) is the current, actively maintained version of
# PowerShell. Windows ships with version 5.1, which lacks some features
# used in modern PowerShell scripts. Installing it early ensures all remaining
# steps and the credential guard hook (Step 13) can use pwsh. Both versions
# remain available side by side -- use 'pwsh' to open PowerShell 7.
# =============================================================================
Write-Step 2 "PowerShell 7"

if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    Write-Ok "Already installed: $(pwsh --version)"
    $SKIPPED += "PowerShell 7"
} else {
    Write-Warn "PowerShell 7 not found. Installing via winget..."
    winget install --id Microsoft.PowerShell -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Write-Ok "PowerShell 7 installed: $(pwsh --version)"
        $INSTALLED += "PowerShell 7"
    } else {
        Write-Err "PowerShell 7 install failed."
        $ERRORS += "PowerShell 7"
    }
}
Write-Host ""

# =============================================================================
# STEP 3 -- Git
# Git is the version control system used for all projects and required by
# several developer tools. Installs via winget.
# =============================================================================
Write-Step 3 "Git"

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Ok "Already installed: $(git --version)"
    $SKIPPED += "Git"
} else {
    Write-Warn "Not installed. Installing via winget..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Ok "Git installed: $(git --version)"
        $INSTALLED += "Git"
    } else {
        Write-Err "Git install failed."
        $ERRORS += "Git"
    }
}
Write-Host ""

# =============================================================================
# STEP 4 -- Node.js
# Node.js is required by the Claude Code CLI. Installed via winget to a fixed
# system path that Claude Code can always locate, regardless of shell state.
# =============================================================================
Write-Step 4 "Node.js"

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Ok "Already installed: $(node --version) at $(Get-Command node | Select-Object -ExpandProperty Source)"
    $SKIPPED += "Node.js"
} else {
    Write-Warn "Not installed. Installing via winget..."
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Ok "Node.js installed: $(node --version)"
        $INSTALLED += "Node.js"
    } else {
        Write-Err "Node.js install failed."
        $ERRORS += "Node.js"
    }
}
Write-Host ""

# =============================================================================
# STEP 5 -- Claude Code CLI
# The Claude Code command-line tool. Installed as a global npm package so it
# is available in any terminal (PowerShell, Windows Terminal, VS Code terminal).
# Run 'claude' in any terminal to start a session.
# =============================================================================
Write-Step 5 "Claude Code CLI"

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Ok "Already installed: $(claude --version 2>$null) at $(Get-Command claude | Select-Object -ExpandProperty Source)"
    $SKIPPED += "Claude Code CLI"
} else {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Err "npm not found -- Node.js install may have failed. Resolve Step 4 first."
        $ERRORS += "Claude Code CLI (npm missing)"
    } else {
        Write-Warn "Not installed. Installing via npm..."
        npm install -g @anthropic-ai/claude-code
        Update-SessionPath
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Ok "Claude Code installed: $(claude --version 2>$null)"
            $INSTALLED += "Claude Code CLI"
        } else {
            Write-Err "Claude Code install failed."
            $ERRORS += "Claude Code CLI"
        }
    }
}
Write-Host ""

# =============================================================================
# STEP 6 -- Visual Studio Code
# VS Code is the primary interface for Claude Code on Windows. The Claude Code
# extension (installed in Step 10) runs inside VS Code, giving you AI assistance
# directly in your editor without switching windows.
# =============================================================================
Write-Step 6 "Visual Studio Code"

if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Ok "Already installed: $(code --version 2>$null | Select-Object -First 1)"
    $SKIPPED += "VS Code"
} else {
    Write-Warn "Not installed. Installing via winget..."
    winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Ok "VS Code installed: $(code --version 2>$null | Select-Object -First 1)"
        $INSTALLED += "VS Code"
    } else {
        Write-Err "VS Code install failed."
        $ERRORS += "VS Code"
    }
}
Write-Host ""

# =============================================================================
# STEP 7 -- Claude Desktop
# Claude Desktop is a standalone AI application. On Windows it is the primary
# way to use Claude alongside full Visual Studio, which does not have a Claude
# Code extension. It is also useful for quick questions and tasks outside of
# a coding context.
# =============================================================================
Write-Step 7 "Claude Desktop"

$claudeDesktopExe = "$env:LOCALAPPDATA\AnthropicClaude\claude.exe"
if (Test-Path $claudeDesktopExe) {
    Write-Ok "Already installed at $claudeDesktopExe"
    $SKIPPED += "Claude Desktop"
} else {
    Write-Warn "Not found. Installing via winget..."
    winget install --id Anthropic.Claude -e --source winget --accept-package-agreements --accept-source-agreements 2>$null
    if (Test-Path $claudeDesktopExe) {
        Write-Ok "Claude Desktop installed"
        $INSTALLED += "Claude Desktop"
    } else {
        Write-Warn "Could not confirm Claude Desktop install via winget."
        Write-Warn "If it did not install, download it manually from claude.ai/download"
        $SKIPPED += "Claude Desktop (verify manually)"
    }
}
Write-Host ""

# =============================================================================
# STEP 8 -- Pandoc and Typst (document tools)
# Pandoc converts files between formats (Markdown -> PDF, Word, HTML, etc.).
# Typst is a lightweight PDF engine that Pandoc uses to generate PDFs without
# a full LaTeX installation. Together they let Claude Code produce finished
# documents from any Markdown source file.
# =============================================================================
Write-Step 8 "Pandoc and Typst (document tools)"

$pandocOk = $false
$typstOk  = $false

if (Get-Command pandoc -ErrorAction SilentlyContinue) {
    Write-Ok "Pandoc already installed: $(pandoc --version 2>$null | Select-Object -First 1)"
    $SKIPPED += "Pandoc"
    $pandocOk = $true
} else {
    Write-Warn "Pandoc not installed. Installing via winget..."
    winget install --id JohnMacFarlane.Pandoc -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command pandoc -ErrorAction SilentlyContinue) {
        Write-Ok "Pandoc installed: $(pandoc --version 2>$null | Select-Object -First 1)"
        $INSTALLED += "Pandoc"
        $pandocOk = $true
    } else {
        Write-Err "Pandoc install failed."
        $ERRORS += "Pandoc"
    }
}

if (Get-Command typst -ErrorAction SilentlyContinue) {
    Write-Ok "Typst already installed: $(typst --version 2>$null)"
    $SKIPPED += "Typst"
    $typstOk = $true
} else {
    Write-Warn "Typst not installed. Installing via winget..."
    winget install --id Typst.Typst -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command typst -ErrorAction SilentlyContinue) {
        Write-Ok "Typst installed: $(typst --version 2>$null)"
        $INSTALLED += "Typst"
        $typstOk = $true
    } else {
        Write-Warn "Typst winget install did not succeed."
        Write-Warn "Download manually from: https://github.com/typst/typst/releases"
        $ERRORS += "Typst"
    }
}

if ($pandocOk -and $typstOk) {
    Write-Ok "PDF generation available: pandoc --pdf-engine=typst input.md -o output.pdf"
}
Write-Host ""

# =============================================================================
# STEP 9 -- Code quality tools (PSScriptAnalyzer + Python linters)
# PSScriptAnalyzer lints PowerShell scripts for errors, security issues, and
# style problems. The Python tools (flake8, black, isort, mypy, pytest) are
# general-purpose tools useful regardless of primary scripting language.
# Python linters are skipped gracefully if Python is not yet installed --
# run setup-python.ps1 first if needed.
# =============================================================================
Write-Step 9 "Code quality tools (PSScriptAnalyzer + Python linters)"

# -- PSScriptAnalyzer --
# Ensure NuGet provider is available for Install-Module
$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget -or $nuget.Version -lt [Version]"2.8.5.201") {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}

if (Get-Module -ListAvailable -Name PSScriptAnalyzer -ErrorAction SilentlyContinue) {
    Write-Ok "PSScriptAnalyzer already installed"
    $SKIPPED += "PSScriptAnalyzer"
} else {
    Write-Warn "PSScriptAnalyzer not installed. Installing from PSGallery..."
    Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    if (Get-Module -ListAvailable -Name PSScriptAnalyzer -ErrorAction SilentlyContinue) {
        Write-Ok "PSScriptAnalyzer installed"
        $INSTALLED += "PSScriptAnalyzer"
    } else {
        Write-Err "PSScriptAnalyzer install failed."
        $ERRORS += "PSScriptAnalyzer"
    }
}

# -- Python linters --
if (Get-Command pip -ErrorAction SilentlyContinue) {
    $pythonTools = @("flake8", "black", "isort", "mypy", "pytest")
    foreach ($tool in $pythonTools) {
        $installed = pip show $tool 2>$null
        if ($installed) {
            Write-Ok "$tool already installed"
            $SKIPPED += $tool
        } else {
            Write-Warn "$tool not installed. Installing via pip..."
            pip install --quiet $tool 2>$null
            $installed = pip show $tool 2>$null
            if ($installed) {
                Write-Ok "$tool installed"
                $INSTALLED += $tool
            } else {
                Write-Err "$tool install failed."
                $ERRORS += $tool
            }
        }
    }
} else {
    Write-Warn "pip not found -- Python linters skipped."
    Write-Warn "Run setup-python.ps1 to install Python, then re-run this script."
    $SKIPPED += "Python linters (pip not available)"
}

Write-Host ""

# =============================================================================
# STEP 10 -- Core VS Code extensions
# Installs extensions needed for Claude Code and PowerShell scripting.
# Language-specific extensions (.NET, Python, Rust) are installed separately
# by the language pack scripts.
# =============================================================================
Write-Step 10 "Core VS Code extensions"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Warn "VS Code not found in PATH -- skipping extension installs."
    Write-Warn "Open VS Code manually and install extensions from the Extensions panel (Ctrl+Shift+X)."
    $ERRORS += "VS Code extensions (code not in PATH -- open a new window and re-run)"
} else {
    $coreExtensions = @(
        @{ id = "anthropic.claude-code";  label = "Claude Code" },
        @{ id = "ms-vscode.powershell";   label = "PowerShell" }
    )
    foreach ($ext in $coreExtensions) {
        $found = code --list-extensions 2>$null | Where-Object { $_ -ieq $ext.id }
        if ($found) {
            Write-Ok "$($ext.label) extension already installed"
            $SKIPPED += "VS Code: $($ext.label)"
        } else {
            Write-Warn "$($ext.label) extension not installed. Installing..."
            code --install-extension $ext.id --force
            $found = code --list-extensions 2>$null | Where-Object { $_ -ieq $ext.id }
            if (-not $found) {
                # Fallback: retry without --force (works on some machines where --force fails)
                Write-Warn "$($ext.label) first attempt did not confirm install. Retrying..."
                code --install-extension $ext.id
                $found = code --list-extensions 2>$null | Where-Object { $_ -ieq $ext.id }
            }
            if ($found) {
                Write-Ok "$($ext.label) extension installed"
                $INSTALLED += "VS Code: $($ext.label)"
            } else {
                Write-Err "$($ext.label) extension install failed."
                $ERRORS += "VS Code: $($ext.label)"
            }
        }
    }
}
Write-Host ""

# =============================================================================
# STEP 11 -- Workspaces\ folder structure
# Creates a starter working folder layout in your home directory. These folders
# provide a standard layout for organizing Claude-assisted work.
# =============================================================================
Write-Step 11 "Workspaces\ folder structure"

$folders = @(
    "$HOME\Workspaces\_Global",
    "$HOME\Workspaces\Reference",
    "$HOME\Workspaces\IT-Documentation",
    "$HOME\Workspaces\Scripting\sandbox",
    "$HOME\Workspaces\Scripting\powershell",
    "$HOME\Workspaces\Development"
)

$created = 0
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Write-Ok "Already exists: $folder"
    } else {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Ok "Created: $folder"
        $created++
    }
}

if ($created -gt 0) {
    $INSTALLED += "Workspaces\ folders ($created folders created)"
} else {
    $SKIPPED += "Workspaces\ folders"
}
Write-Host ""

# =============================================================================
# STEP 12 -- .claude\ starter configuration
# Creates Claude Code's configuration directory with three starter files:
#   $HOME\.claude\CLAUDE.md              Personal instructions (fill in your info)
#   $HOME\Workspaces\_Global\CLAUDE.md   Organization context (fill in your info)
#   $HOME\.claude\settings.json          Wires up the credential guard (Step 13)
# Existing files are never overwritten.
# =============================================================================
Write-Step 12 ".claude\ starter configuration"

New-Item -ItemType Directory -Path "$HOME\.claude\commands" -Force | Out-Null
New-Item -ItemType Directory -Path "$HOME\.claude\hooks"    -Force | Out-Null

# -- Personal CLAUDE.md --
$personalClaude = "$HOME\.claude\CLAUDE.md"
if (Test-Path $personalClaude) {
    Write-Ok "$HOME\.claude\CLAUDE.md already exists -- skipping (will not overwrite)"
    $SKIPPED += ".claude\CLAUDE.md"
} else {
    @'
# My Claude Code Setup

## Who I Am
- Name:        [Your name]
- Role:        [Your role -- e.g. Software Developer, IT Specialist, Help Desk Technician]
- Organization: [Your organization name]
- Focus areas: [What you work on most -- e.g. .NET development, Windows scripting, documentation]

## My Technical Environment
- [List the tools and platforms you use most]
- [e.g. Visual Studio, VS Code, .NET, PowerShell, Microsoft 365]
- Windows and PowerShell for scripting
- [Add or remove as needed]

## How I Work
- Explain code clearly with comments -- I prefer well-documented examples
- Always explain what a script or block of code does before writing it
- Show me a plan before executing any multi-step task
- Flag anything destructive or irreversible before taking action
- When uncertain about my intent, ask rather than assume

## Security Rules
- Never include real passwords, API tokens, or credentials in any file
- Always use placeholder values: YOUR_VALUE_HERE
- Never include student records, employee HR data, or health information
- When in doubt about whether data is sensitive, stop and ask

## Output Preferences
- Plain language -- my audience is often non-technical
- Error handling and logging in all scripts
- Descriptive file names: verb-noun-v1.ps1, not script1.ps1
'@ | Set-Content -Path $personalClaude -Encoding UTF8
    Write-Ok "Created $HOME\.claude\CLAUDE.md (starter template -- fill in your info)"
    $INSTALLED += ".claude\CLAUDE.md"
}

# -- Global organization project CLAUDE.md --
$globalClaude = "$HOME\Workspaces\_Global\CLAUDE.md"
if (Test-Path $globalClaude) {
    Write-Ok "$HOME\Workspaces\_Global\CLAUDE.md already exists -- skipping"
    $SKIPPED += "_Global\CLAUDE.md"
} else {
    @'
# Global Context -- [Your Organization]

## Who I Am
- [Your name] -- [Your role]
- [Your organization name]
- [Your location]
- [Brief description of your responsibilities]

## My Technical Environment
- [List your primary tools, e.g.:]
- Microsoft 365 (Teams, Outlook, SharePoint, OneDrive)
- Visual Studio / VS Code
- .NET, PowerShell
- [Add tools specific to your role]

## How I Work
- Explain code clearly with comments
- Always explain what a script or block of code does before writing it
- Show me a plan before executing any multi-step task
- Flag anything destructive or irreversible before taking action
- Do not save files without showing me the result first
- When uncertain about intent, ask rather than assume

## Security Rules -- Non-Negotiable
- Never include real passwords, API tokens, or credentials in any file
- Always use placeholder values: YOUR_VALUE_HERE
- Never include student records, employee HR data, or protected information
- Never include health or medical information of any kind
- When in doubt about whether data is sensitive, stop and ask

## Writing and Documentation Standards
- Plain language -- our audience is often non-technical
- [Your brand colors, fonts, and logo standards]
- Always produce both .docx and .pdf unless told otherwise
- [Your documentation audience]

## Workspace Location
All project folders live at $HOME\Workspaces\
When referencing files across folders, use absolute paths: $HOME\Workspaces\[ProjectName]\

## Context
- [Describe your environment -- e.g. higher education, healthcare, corporate IT]
- Users range from very tech-savvy to non-technical
- [Any compliance requirements applicable to your organization]
- All significant work should reference a ticket in [Your Ticketing System]
'@ | Set-Content -Path $globalClaude -Encoding UTF8
    Write-Ok "Created $HOME\Workspaces\_Global\CLAUDE.md (starter template -- fill in your info)"
    $INSTALLED += "_Global\CLAUDE.md"
}

# -- settings.json --
$settings = "$HOME\.claude\settings.json"
if (Test-Path $settings) {
    Write-Ok "$HOME\.claude\settings.json already exists -- skipping"
    $SKIPPED += ".claude\settings.json"
} else {
    $hookCmd = "pwsh -File `"$HOME\.claude\hooks\credential-guard.ps1`""
    $settingsObj = @{
        hooks = @{
            PreToolUse = @(
                @{
                    matcher = "Bash"
                    hooks   = @(
                        @{
                            type          = "command"
                            command       = $hookCmd
                            timeout       = 5
                            statusMessage = "Checking for inline credentials..."
                        }
                    )
                }
            )
        }
    }
    $settingsObj | ConvertTo-Json -Depth 10 | Set-Content -Path $settings -Encoding UTF8
    Write-Ok "Created $HOME\.claude\settings.json"
    $INSTALLED += ".claude\settings.json"
}
Write-Host ""

# =============================================================================
# STEP 13 -- Credential guard hook
# Installs a PowerShell security hook that monitors every shell command Claude
# runs and blocks any command that appears to contain an inline credential
# (password, token, API key, etc.). A safety net -- it does not replace good
# security habits, but it catches common mistakes before they happen.
# =============================================================================
Write-Step 13 "Credential guard hook"

$hook = "$HOME\.claude\hooks\credential-guard.ps1"
if (Test-Path $hook) {
    Write-Ok "Already installed at $HOME\.claude\hooks\credential-guard.ps1"
    $SKIPPED += "Credential guard hook"
} else {
    # Written as an array of strings to avoid nested here-string quoting issues.
    $guardLines = @(
        '# credential-guard.ps1',
        '# PreToolUse/Bash hook -- warns when a shell command contains an inline credential.',
        '#',
        '# Matches patterns like:  VARIABLE_NAME="long-value"',
        '# where the name suggests a secret (SECRET, PASSWORD, TOKEN, KEY, etc.)',
        '# and the value is long enough to be a real credential.',
        '# Placeholders like YOUR_VALUE_HERE or <VALUE> are allowed through.',
        '',
        '$inputJson = [Console]::In.ReadToEnd()',
        'try {',
        '    $data = $inputJson | ConvertFrom-Json',
        '    $cmd  = $data.tool_input.command',
        '} catch { exit 0 }',
        'if (-not $cmd) { exit 0 }',
        '',
        '$credPat = "(?i)(SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_TOKEN|BEARER_TOKEN|CLIENT_SECRET|PRIVATE_KEY)\s*=\s*[A-Za-z0-9_.\-]{20,}"',
        '$safePat = "(?i)(YOUR_[A-Z_]+|_HERE\b|PLACEHOLDER|<[A-Z_]+>)"',
        '',
        'if ($cmd -match $credPat -and $cmd -notmatch $safePat) {',
        '    @{',
        '        systemMessage = "WARNING: Credential guard: This command appears to contain a real credential value inline. Store credentials in a .env file and reference them as environment variables instead of passing them directly in commands."',
        '    } | ConvertTo-Json | Write-Output',
        '}'
    )
    ($guardLines -join [System.Environment]::NewLine) | Set-Content -Path $hook -Encoding UTF8
    Write-Ok "Installed credential guard hook"
    $INSTALLED += "Credential guard hook"
}
Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Header "Setup Complete"

if ($INSTALLED.Count -gt 0) {
    Write-Host "  Installed / Created:"
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
    Write-Host ""
} else {
    Write-Host "  All done. Here is what to do next:"
    Write-Host ""
    Write-Host "  1. Close this window and open a new PowerShell session"
    Write-Host "       (so PATH changes take effect)"
    Write-Host "  2. Verify Claude Code works:"
    Write-Host "       claude --version"
    Write-Host "  3. Fill in your personal context:"
    Write-Host "       code `$HOME\.claude\CLAUDE.md"
    Write-Host "  4. Fill in your organization context:"
    Write-Host "       code `$HOME\Workspaces\_Global\CLAUDE.md"
    Write-Host "  5. Start Claude Code:"
    Write-Host "       In any terminal:  claude"
    Write-Host "       Or open VS Code and use the Claude Code panel (Ctrl+Shift+P -> Claude)"
    Write-Host ""
    Write-Host "  Tip: Inside Claude Code, type /help to see available commands."
    Write-Host "  Your work files go in $HOME\Workspaces\."
}

Write-Host ""

# =============================================================================
# OPTIONAL -- Language Packs
# Installs runtimes, linters, and VS Code extensions for .NET, Python, and/or
# Rust. Select only what you use. Each pack takes 5-15 minutes. You can skip
# now and run the individual scripts from this folder any time later.
# =============================================================================
Write-Header "Language Packs (Optional)"

Write-Host "  Select the language packs to install. Each one adds the runtime,"
Write-Host "  linter, and VS Code extension for that language."
Write-Host "  Tip: select all if you are unsure -- they do not conflict."
Write-Host ""
Write-Host "    [1]  .NET    C# development and Visual Studio projects (~10 min)"
Write-Host "    [2]  Python  Scripting, automation, and data work     (~5 min)"
Write-Host "    [3]  Rust    Systems programming                       (~15 min)"
Write-Host "    [A]  All of the above"
Write-Host "    [N]  Skip -- I will run these separately later"
Write-Host ""
$langChoice = Read-Host "Enter your choice (e.g.  1  or  1 2  or  A  or  N)"
Write-Host ""

$installDotnet = $false
$installPython = $false
$installRust   = $false

$langNorm = $langChoice.Trim().ToUpper()
if ($langNorm -eq "A") {
    $installDotnet = $true
    $installPython = $true
    $installRust   = $true
} elseif ($langNorm -ne "N" -and $langNorm -ne "") {
    if ($langNorm -match "1") { $installDotnet = $true }
    if ($langNorm -match "2") { $installPython = $true }
    if ($langNorm -match "3") { $installRust   = $true }
}

if (-not $installDotnet -and -not $installPython -and -not $installRust) {
    Write-Host "  Skipping language packs."
    Write-Host "  Run them any time from the folder containing this script:"
    Write-Host "    pwsh -ExecutionPolicy Bypass -File setup-dotnet.ps1"
    Write-Host "    pwsh -ExecutionPolicy Bypass -File setup-python.ps1"
    Write-Host "    pwsh -ExecutionPolicy Bypass -File setup-rust.ps1"
    Write-Host ""
} else {
    if ($installDotnet) {
        $s = Join-Path $PSScriptRoot "setup-dotnet.ps1"
        if (Test-Path $s) { pwsh -ExecutionPolicy Bypass -File $s }
        else { Write-Warn "setup-dotnet.ps1 not found alongside this script -- skipping" }
    }
    if ($installPython) {
        $s = Join-Path $PSScriptRoot "setup-python.ps1"
        if (Test-Path $s) { pwsh -ExecutionPolicy Bypass -File $s }
        else { Write-Warn "setup-python.ps1 not found alongside this script -- skipping" }
    }
    if ($installRust) {
        $s = Join-Path $PSScriptRoot "setup-rust.ps1"
        if (Test-Path $s) { pwsh -ExecutionPolicy Bypass -File $s }
        else { Write-Warn "setup-rust.ps1 not found alongside this script -- skipping" }
    }
}

Write-Host ""
Write-Host "Press ENTER to close..."
Read-Host | Out-Null
