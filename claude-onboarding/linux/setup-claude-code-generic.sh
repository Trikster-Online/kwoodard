#!/bin/bash

# =============================================================================
# setup-claude-code-generic.sh (Linux)
# Purpose:     Bootstrap a new Linux Mint machine with everything needed to use
#              Claude Code. Installs required packages, creates a starter folder
#              structure in ~/Workspaces/, deploys starter configuration files
#              to ~/.claude/, and installs a credential guard security hook.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-06-16
# Version:     1.0
# Platform:    Linux Mint 21+ (Ubuntu 22.04 base or newer)
# Usage:       bash ~/Desktop/setup-claude-code-generic.sh
# Notes:       Do NOT run with sudo -- individual package installs use sudo
#              internally as needed. You will be prompted for your password.
#              Requires internet access for Steps 1-7.
#              Existing config files are never overwritten.
#
# Version History:
#   1.0  2026-06-16  Initial Linux version. Replaces Xcode CLT and Homebrew
#                    with apt. Claude Desktop is not available on Linux (Step 5
#                    is advisory). Replaces osascript notification with
#                    notify-send. Removes swiftlint (macOS only). Uses NodeSource
#                    for a current Node.js LTS build.
# =============================================================================

# -- Guard: refuse to run as root --
if [[ "$EUID" -eq 0 ]]; then
    echo "ERROR: Do not run this script as root or with sudo."
    echo "Run it as your normal user account. Individual steps use sudo internally."
    exit 1
fi

# -- Output helpers --
print_header() { echo "" && echo "============================================" && echo "  $1" && echo "============================================" && echo ""; }
print_step()   { echo "[ STEP $1 ] $2"; }
print_ok()     { echo "  ✓ $1"; }
print_warn()   { echo "  ⚠ $1"; }
print_err()    { echo "  ✗ ERROR: $1"; }

ERRORS=()
INSTALLED=()
SKIPPED=()

print_header "Claude Code New User Setup (Linux)"
echo "  This script sets up Claude Code on this Linux Mint machine from scratch."
echo ""
echo "  It will:"
echo "    1. Install build essentials, curl, git, and Python"
echo "    2. Update the apt package index"
echo "    3. Install Node.js LTS via NodeSource"
echo "    4. Install Claude Code CLI"
echo "    5. Claude Desktop -- not available on Linux (advisory note)"
echo "    6. Install Pandoc, Typst, and Poppler (document tools)"
echo "    7. Install developer tools (shellcheck, gh, jq, Python linters)"
echo "    8. Create ~/Workspaces/ folder structure"
echo "    9. Create ~/.claude/ starter configuration"
echo "   10. Install security hooks and notifications"
echo ""
echo "  Existing files are never overwritten."
echo "  Do NOT run with sudo -- individual steps use sudo as needed."
echo "  You may be prompted for your sudo password during package installs."
echo ""
echo "Press ENTER to begin, or Ctrl+C to cancel..."
read -r
echo ""

# =============================================================================
# STEP 1 -- Build essentials, curl, git, and Python
# Installs the C compiler toolchain, make, curl, git, Python 3, pip, and the
# desktop notification library. These are the Linux equivalent of Xcode Command
# Line Tools on Mac -- required by many developer packages used in later steps.
# =============================================================================
print_step 1 "Build essentials, curl, git, and Python"

PREREQS=(build-essential curl git python3 python3-pip libnotify-bin)
needs_prereqs=0

for pkg in "${PREREQS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        needs_prereqs=1
        break
    fi
done

if [[ $needs_prereqs -eq 0 ]]; then
    print_ok "All prerequisites already installed"
    SKIPPED+=("Build essentials and prerequisites")
else
    print_warn "Installing prerequisites via apt (sudo required)..."
    if sudo apt install -y "${PREREQS[@]}"; then
        all_ok=1
        for pkg in "${PREREQS[@]}"; do
            if dpkg -s "$pkg" &>/dev/null; then
                print_ok "$pkg installed"
            else
                print_err "$pkg install failed"
                ERRORS+=("$pkg")
                all_ok=0
            fi
        done
        if [[ $all_ok -eq 1 ]]; then
            INSTALLED+=("Build essentials and prerequisites")
        fi
    else
        print_err "apt install failed for prerequisites."
        ERRORS+=("Build essentials")
    fi
fi
echo ""

# =============================================================================
# STEP 2 -- apt package index update
# Refreshes the local package list so all subsequent installs pick up current
# versions. Equivalent to the implicit index refresh Homebrew performs on Mac.
# =============================================================================
print_step 2 "apt package index update"

print_warn "Updating apt package index (sudo required)..."
if sudo apt update -qq 2>/dev/null; then
    print_ok "Package index updated"
    INSTALLED+=("apt update")
else
    print_err "apt update failed -- package installs may use stale versions."
    ERRORS+=("apt update")
fi
echo ""

# =============================================================================
# STEP 3 -- Node.js LTS (via NodeSource)
# Installs the current Node.js LTS release using the NodeSource binary
# distribution. The version bundled in the default Ubuntu/Mint apt repository
# is often several major versions behind. NodeSource ensures a current LTS
# build that meets Claude Code's minimum requirement (v18+).
# =============================================================================
print_step 3 "Node.js LTS (via NodeSource)"

if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [[ "$NODE_MAJOR" -ge 18 ]]; then
        print_ok "Already installed: $NODE_VER at $(command -v node)"
        SKIPPED+=("Node.js")
    else
        print_warn "Node.js $NODE_VER is installed but Claude Code requires v18 or newer."
        print_warn "Upgrading via NodeSource LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
        sudo apt install -y nodejs
        if command -v node &>/dev/null; then
            print_ok "Node.js updated to: $(node --version)"
            INSTALLED+=("Node.js (NodeSource LTS)")
        else
            print_err "Node.js upgrade failed."
            ERRORS+=("Node.js")
        fi
    fi
else
    print_warn "Not installed. Installing Node.js LTS via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
    sudo apt install -y nodejs
    if command -v node &>/dev/null; then
        print_ok "Installed: $(node --version) at $(command -v node)"
        INSTALLED+=("Node.js")
    else
        print_err "Node.js install failed."
        ERRORS+=("Node.js")
    fi
fi
echo ""

# =============================================================================
# STEP 4 -- Claude Code CLI (native installer)
# Uses the official native installer, which places claude at ~/.local/bin/claude.
# This is preferred over the npm global install because the native binary stays
# stable even if Node.js versions change later.
# =============================================================================
print_step 4 "Claude Code CLI (native installer)"

if command -v claude &>/dev/null; then
    CURRENT_CLAUDE=$(command -v claude)
    print_ok "Already installed: $(claude --version 2>/dev/null || echo 'version unknown') at $CURRENT_CLAUDE"
    if echo "$CURRENT_CLAUDE" | grep -q "nvm\|npm"; then
        print_warn "Claude appears to be installed via npm/nvm. This can break if Node versions change."
        print_warn "Consider reinstalling: curl -fsSL https://claude.ai/install.sh | sh"
    fi
    SKIPPED+=("Claude Code")
else
    print_warn "Not installed. Installing via native installer..."
    curl -fsSL https://claude.ai/install.sh | sh
    if [[ -f "$HOME/.local/bin/claude" ]]; then
        print_ok "Claude Code installed: $("$HOME/.local/bin/claude" --version 2>/dev/null)"
        INSTALLED+=("Claude Code")
    else
        print_err "Claude Code installer did not produce ~/.local/bin/claude"
        ERRORS+=("Claude Code")
    fi
fi

# Always ensure ~/.local/bin is active in this session and in .bashrc,
# regardless of whether Claude was just installed or already present.
if [[ -f "$HOME/.local/bin/claude" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q '\.local/bin' ~/.bashrc 2>/dev/null; then
        # SC2016 intentional: $HOME must be literal in .bashrc so it expands at shell startup
        # shellcheck disable=SC2016
        { echo ''; echo '# Claude Code (native install)'; echo 'export PATH="$HOME/.local/bin:$PATH"'; } >> ~/.bashrc
        print_ok "Added ~/.local/bin to ~/.bashrc PATH"
    fi
fi
echo ""

# =============================================================================
# STEP 5 -- Claude Desktop app (not available on Linux)
# The Claude Desktop GUI application does not have an official Linux release.
# Claude Code CLI (installed in Step 4) is the primary interface on Linux.
# For a GUI-based Claude experience, use claude.ai in a browser.
# =============================================================================
print_step 5 "Claude Desktop app"

print_warn "Claude Desktop does not have an official Linux release -- skipping."
print_warn "Claude Code CLI (claude) is your primary interface on Linux."
print_warn "For a browser-based GUI, visit claude.ai."
SKIPPED+=("Claude Desktop (not available on Linux)")
echo ""

# =============================================================================
# STEP 6 -- Pandoc, Typst, and Poppler (document tools)
# Pandoc converts documents between formats (Markdown -> PDF, Word, HTML, etc.).
# Typst is a lightweight PDF engine Pandoc uses to generate PDFs without a full
# LaTeX installation. Poppler provides PDF utilities including pdftoppm, which
# lets Claude Code read and render existing PDF files.
# Typst may not be in apt on older Mint/Ubuntu releases; this script falls back
# to the latest GitHub release binary if apt does not have it.
# =============================================================================
print_step 6 "Pandoc, Typst, and Poppler (document tools)"

pandoc_ok=0
typst_ok=0
poppler_ok=0

# -- Pandoc --
if command -v pandoc &>/dev/null; then
    print_ok "Pandoc already installed: $(pandoc --version | head -1)"
    SKIPPED+=("Pandoc")
    pandoc_ok=1
else
    print_warn "Pandoc not installed. Installing via apt..."
    sudo apt install -y pandoc
    if command -v pandoc &>/dev/null; then
        print_ok "Pandoc installed: $(pandoc --version | head -1)"
        INSTALLED+=("Pandoc")
        pandoc_ok=1
    else
        print_err "Pandoc install failed."
        ERRORS+=("Pandoc")
    fi
fi

# -- Typst --
# Try apt first. If not available (older Mint releases), download the latest
# x86_64 musl binary from the GitHub releases API.
if command -v typst &>/dev/null; then
    print_ok "Typst already installed: $(typst --version)"
    SKIPPED+=("Typst")
    typst_ok=1
else
    print_warn "Typst not installed. Trying apt..."
    if sudo apt install -y typst 2>/dev/null && command -v typst &>/dev/null; then
        print_ok "Typst installed via apt: $(typst --version)"
        INSTALLED+=("Typst")
        typst_ok=1
    else
        print_warn "Typst not in apt. Downloading latest binary from GitHub releases..."
        TYPST_URL=$(curl -fsSL "https://api.github.com/repos/typst/typst/releases/latest" \
            | python3 -c "
import sys, json
try:
    rel = json.load(sys.stdin)
    url = next(
        (a['browser_download_url'] for a in rel.get('assets', [])
         if 'x86_64-unknown-linux-musl' in a['name'] and a['name'].endswith('.tar.xz')),
        ''
    )
    print(url)
except Exception:
    print('')
" 2>/dev/null)

        if [[ -n "$TYPST_URL" ]]; then
            TYPST_TMP=$(mktemp -d)
            curl -fsSL "$TYPST_URL" -o "$TYPST_TMP/typst.tar.xz"
            tar -xJf "$TYPST_TMP/typst.tar.xz" -C "$TYPST_TMP" 2>/dev/null
            TYPST_BIN=$(find "$TYPST_TMP" -name "typst" -type f | head -1)
            if [[ -n "$TYPST_BIN" ]]; then
                sudo mv "$TYPST_BIN" /usr/local/bin/typst
                sudo chmod +x /usr/local/bin/typst
                rm -rf "$TYPST_TMP"
                if command -v typst &>/dev/null; then
                    print_ok "Typst installed from GitHub: $(typst --version)"
                    INSTALLED+=("Typst (GitHub release)")
                    typst_ok=1
                else
                    print_err "Typst binary not found after install."
                    ERRORS+=("Typst")
                fi
            else
                print_err "Could not extract Typst binary from archive."
                ERRORS+=("Typst")
                rm -rf "$TYPST_TMP"
            fi
        else
            print_err "Could not determine Typst download URL."
            print_err "Install manually from https://typst.app"
            ERRORS+=("Typst")
        fi
    fi
fi

# -- Poppler --
if command -v pdftoppm &>/dev/null; then
    print_ok "Poppler already installed: $(pdftoppm -v 2>&1 | head -1)"
    SKIPPED+=("Poppler")
    poppler_ok=1
else
    print_warn "Poppler not installed. Installing via apt..."
    sudo apt install -y poppler-utils
    if command -v pdftoppm &>/dev/null; then
        print_ok "Poppler installed: $(pdftoppm -v 2>&1 | head -1)"
        INSTALLED+=("Poppler")
        poppler_ok=1
    else
        print_err "Poppler install failed."
        ERRORS+=("Poppler")
    fi
fi

if [[ $pandoc_ok -eq 1 && $typst_ok -eq 1 ]]; then
    print_ok "PDF generation available: pandoc --pdf-engine=typst"
fi
if [[ $poppler_ok -eq 1 ]]; then
    print_ok "PDF reading available: pdftoppm, pdfinfo, pdftotext"
fi
echo ""

# =============================================================================
# STEP 7 -- Developer tools (shellcheck, gh, jq, Python linters)
# Installs code quality linters and general CLI utilities used alongside
# Claude Code. shellcheck lints Bash scripts. gh is the GitHub CLI for managing
# repos and pull requests from the terminal. jq is a JSON processor useful for
# parsing API and curl output.
# Note: swiftlint is macOS/Swift-specific and is skipped on Linux.
# The Python tools (flake8, black, isort, mypy, pytest) cover linting,
# formatting, and testing. PSScriptAnalyzer lints PowerShell if pwsh is present.
# Python tools are invoked as "python3 -m <tool>".
# =============================================================================
print_step 7 "Developer tools (shellcheck, gh, jq, Python linters)"

shellcheck_ok=0
python_tools_ok=1

# -- shellcheck --
if command -v shellcheck &>/dev/null; then
    print_ok "shellcheck already installed: $(shellcheck --version | head -1)"
    SKIPPED+=("shellcheck")
    shellcheck_ok=1
else
    print_warn "shellcheck not installed. Installing via apt..."
    sudo apt install -y shellcheck
    if command -v shellcheck &>/dev/null; then
        print_ok "shellcheck installed: $(shellcheck --version | head -1)"
        INSTALLED+=("shellcheck")
        shellcheck_ok=1
    else
        print_err "shellcheck install failed."
        ERRORS+=("shellcheck")
    fi
fi

# -- swiftlint (macOS only -- not applicable on Linux) --
print_ok "swiftlint is macOS-only -- skipping"
SKIPPED+=("swiftlint (macOS only)")

# -- gh (GitHub CLI) --
# gh is in the Ubuntu/Mint apt repos on 22.04+. Falls back to the GitHub
# official apt repository if the default repo does not have it.
if command -v gh &>/dev/null; then
    print_ok "gh already installed: $(gh --version | head -1)"
    SKIPPED+=("gh (GitHub CLI)")
else
    print_warn "gh not installed. Trying apt..."
    sudo apt install -y gh 2>/dev/null
    if command -v gh &>/dev/null; then
        print_ok "gh installed: $(gh --version | head -1)"
        INSTALLED+=("gh (GitHub CLI)")
    else
        print_warn "gh not in default apt. Adding GitHub official apt repository..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update -qq 2>/dev/null
        sudo apt install -y gh
        if command -v gh &>/dev/null; then
            print_ok "gh installed via GitHub repo: $(gh --version | head -1)"
            INSTALLED+=("gh (GitHub CLI)")
        else
            print_err "gh install failed."
            ERRORS+=("gh (GitHub CLI)")
        fi
    fi
fi

# -- jq --
if command -v jq &>/dev/null; then
    print_ok "jq already installed: $(jq --version)"
    SKIPPED+=("jq")
else
    print_warn "jq not installed. Installing via apt..."
    sudo apt install -y jq
    if command -v jq &>/dev/null; then
        print_ok "jq installed: $(jq --version)"
        INSTALLED+=("jq")
    else
        print_err "jq install failed."
        ERRORS+=("jq")
    fi
fi

# -- Python dev tools (flake8, black, isort, mypy, pytest) --
# Newer Ubuntu/Mint releases (22.04+) enforce PEP 668 and require
# --break-system-packages to install pip packages outside a virtualenv.
# This flag is safe here because these are dev tools, not system libraries.
PIP_FLAGS="--quiet"
if pip3 install --help 2>/dev/null | grep -q 'break-system-packages'; then
    PIP_FLAGS="--quiet --break-system-packages"
fi

PYTHON_TOOLS=(flake8 black isort mypy pytest)
for tool in "${PYTHON_TOOLS[@]}"; do
    if python3 -m "$tool" --version &>/dev/null 2>&1; then
        print_ok "python3 -m $tool already available"
        SKIPPED+=("$tool")
    else
        print_warn "python3 -m $tool not found. Installing via pip3..."
        # shellcheck disable=SC2086
        pip3 install $PIP_FLAGS "$tool"
        if python3 -m "$tool" --version &>/dev/null 2>&1; then
            print_ok "$tool installed"
            INSTALLED+=("$tool")
        else
            print_err "$tool install failed."
            ERRORS+=("$tool")
            python_tools_ok=0
        fi
    fi
done

# -- PSScriptAnalyzer (PowerShell only -- skip if pwsh not installed) --
if command -v pwsh &>/dev/null; then
    if pwsh -Command "Get-Module -ListAvailable PSScriptAnalyzer" &>/dev/null; then
        print_ok "PSScriptAnalyzer already installed"
        SKIPPED+=("PSScriptAnalyzer")
    else
        print_warn "PSScriptAnalyzer not installed. Installing..."
        pwsh -Command "Install-Module PSScriptAnalyzer -Scope CurrentUser -Force" 2>/dev/null
        if pwsh -Command "Get-Module -ListAvailable PSScriptAnalyzer" &>/dev/null; then
            print_ok "PSScriptAnalyzer installed"
            INSTALLED+=("PSScriptAnalyzer")
        else
            print_err "PSScriptAnalyzer install failed."
            ERRORS+=("PSScriptAnalyzer")
        fi
    fi
else
    print_ok "PowerShell (pwsh) not installed -- skipping PSScriptAnalyzer"
    SKIPPED+=("PSScriptAnalyzer (pwsh not present)")
fi

if [[ $shellcheck_ok -eq 1 && $python_tools_ok -eq 1 ]]; then
    print_ok "Core linting tools ready"
fi
echo ""

# =============================================================================
# STEP 8 -- ~/Workspaces/ folder structure
# Creates a starter working folder layout at ~/Workspaces/. These folders
# provide a standard layout for organizing Claude-assisted work.
# =============================================================================
print_step 8 "$HOME/Workspaces/ folder structure"

FOLDERS=(
    "$HOME/Workspaces/_Global"
    "$HOME/Workspaces/Reference"
    "$HOME/Workspaces/IT-Documentation"
    "$HOME/Workspaces/Scripting/sandbox"
    "$HOME/Workspaces/Scripting/zsh"
)

created=0
for folder in "${FOLDERS[@]}"; do
    if [[ -d "$folder" ]]; then
        print_ok "Already exists: ${folder/$HOME/~}"
    else
        mkdir -p "$folder"
        print_ok "Created: ${folder/$HOME/~}"
        ((created++))
    fi
done

if [[ $created -gt 0 ]]; then
    INSTALLED+=("$HOME/Workspaces/ structure ($created folders created)")
else
    SKIPPED+=("$HOME/Workspaces/ structure")
fi
echo ""

# =============================================================================
# STEP 9 -- ~/.claude/ starter configuration
# Creates Claude Code's config directory and populates it with starter files:
#   - ~/.claude/CLAUDE.md         Personal instructions (fill in your info)
#   - _Global/CLAUDE.md           Organization context (fill in your info)
#   - ~/.claude/settings.json     Basic settings with credential guard wired in
#   - ~/.claude/commands/         Ready for custom slash commands you add later
#   - ~/.claude/hooks/            Ready for automation hooks (Step 10 adds three)
# Existing files are never overwritten.
# =============================================================================
print_step 9 "$HOME/.claude/ starter configuration"

mkdir -p ~/.claude/commands ~/.claude/hooks

# -- Personal CLAUDE.md --
if [[ -f ~/.claude/CLAUDE.md ]]; then
    print_ok "$HOME/.claude/CLAUDE.md already exists -- skipping (will not overwrite)"
    SKIPPED+=("$HOME/.claude/CLAUDE.md")
else
    cat > ~/.claude/CLAUDE.md << 'PERSONAL_TEMPLATE'
# My Claude Code Setup

## Who I Am
- Name:        [Your name]
- Role:        [Your role -- e.g. Help Desk Technician, IT Specialist, Developer]
- Organization: [Your organization name]
- Focus areas: [What you work on most -- e.g. Mac support, scripting, documentation]

## My Technical Environment
- [List the tools and platforms you use most]
- [e.g. MDM platform, endpoint management, Microsoft 365, Google Workspace]
- Linux Mint and bash for shell scripting
- [Add or remove as needed]

## How I Work
- Explain code clearly with comments -- I am not a developer by trade
- Always explain what a script does before writing it
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
- Descriptive file names: verb-noun-v1.sh, not script1.sh
PERSONAL_TEMPLATE
    print_ok "Created $HOME/.claude/CLAUDE.md (starter template -- fill in your info)"
    INSTALLED+=("$HOME/.claude/CLAUDE.md")
fi

# -- Global organization CLAUDE.md --
GLOBAL_CLAUDE="$HOME/Workspaces/_Global/CLAUDE.md"
if [[ -f "$GLOBAL_CLAUDE" ]]; then
    print_ok "$HOME/Workspaces/_Global/CLAUDE.md already exists -- skipping"
    SKIPPED+=("_Global/CLAUDE.md")
else
    cat > "$GLOBAL_CLAUDE" << 'GLOBAL_TEMPLATE'
# Global Context -- [Your Organization]

## Who I Am
- [Your name] -- [Your role]
- [Your organization name]
- [Your location]
- [Brief description of your responsibilities]

## My Technical Environment
- [List your primary tools, e.g.:]
- Microsoft 365 (Teams, Outlook, SharePoint, OneDrive)
- Google Workspace (Gmail, Drive, Docs, Sheets)
- [Add tools specific to your role]

## How I Work
- I am not a developer by trade -- explain code clearly with comments
- Always explain what a script does before writing it
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
All project folders live at ~/Workspaces/
When referencing files across folders, use absolute paths: ~/Workspaces/FolderName/

## Context
- [Describe your environment -- e.g. higher education, healthcare, corporate IT]
- Users range from very tech-savvy to non-technical
- [Any compliance requirements applicable to your organization]
- All significant work should reference a ticket in [Your Ticketing System]
GLOBAL_TEMPLATE
    print_ok "Created ~/Workspaces/_Global/CLAUDE.md (starter template -- fill in your info)"
    INSTALLED+=("_Global/CLAUDE.md")
fi

# -- settings.json --
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
    print_ok "$HOME/.claude/settings.json already exists -- skipping"
    SKIPPED+=("settings.json")
else
    cat > "$SETTINGS" << 'SETTINGS_TEMPLATE'
{
  "effortLevel": "high",
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "date +%s > /tmp/claude-turn-start.txt",
            "timeout": 3,
            "async": true
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/credential-guard.sh",
            "timeout": 5,
            "statusMessage": "Checking for inline credentials..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/credential-settings-guard.sh",
            "timeout": 5,
            "statusMessage": "Checking settings.json for credentials..."
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/stop-notify.sh",
            "timeout": 5,
            "async": true
          }
        ]
      }
    ]
  }
}
SETTINGS_TEMPLATE
    print_ok "Created ~/.claude/settings.json"
    INSTALLED+=("settings.json")
fi
echo ""

# =============================================================================
# STEP 10 -- Security hooks and notifications
# Installs three automation hooks:
#   credential-guard.sh          -- blocks inline credentials in Bash commands
#   credential-settings-guard.sh -- checks settings.json for credentials after writes
#   stop-notify.sh               -- desktop notification when Claude finishes a long turn
# The notification hook uses notify-send (Linux) instead of osascript (macOS).
# notify-send requires libnotify-bin, installed in Step 1.
# =============================================================================
print_step 10 "Security hooks and notifications"

# -- credential-guard.sh --
HOOK="$HOME/.claude/hooks/credential-guard.sh"

if [[ -f "$HOOK" ]]; then
    print_ok "credential-guard.sh already installed"
    SKIPPED+=("Credential guard hook")
else
    cat > "$HOOK" << 'HOOKSCRIPT'
#!/bin/bash
# credential-guard.sh -- PreToolUse/Bash hook
# Warns when a shell command contains an inline credential value.
# Allows short values and placeholder patterns (YOUR_VALUE_HERE, ${VAR}, etc.).

INPUT=$(cat)

CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

[ -z "$CMD" ] && exit 0

if echo "$CMD" | grep -qiE \
  '(SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_TOKEN|BEARER_TOKEN|CLIENT_SECRET|PRIVATE_KEY)\s*=\s*["\x27]?[A-Za-z0-9_.\-]{20,}["\x27]?'; then

    if ! echo "$CMD" | grep -qiE '(YOUR_[A-Z]|_HERE["\x27 \\]|\$\{[A-Z]|\$[A-Z_][A-Z_0-9]+|<[A-Z_]+>)'; then
        echo '{"systemMessage": "WARNING: Credential guard: This command appears to contain a real credential value inline. Store credentials in a .env file and reference them as environment variables instead of passing them directly in commands."}'
    fi

fi
HOOKSCRIPT
    chmod +x "$HOOK"
    print_ok "Installed credential-guard.sh"
    INSTALLED+=("Credential guard hook")
fi

# -- credential-settings-guard.sh --
SETTINGS_HOOK="$HOME/.claude/hooks/credential-settings-guard.sh"

if [[ -f "$SETTINGS_HOOK" ]]; then
    print_ok "credential-settings-guard.sh already installed"
    SKIPPED+=("Settings credential guard")
else
    cat > "$SETTINGS_HOOK" << 'SETTINGSHOOK'
#!/bin/bash
# credential-settings-guard.sh -- PostToolUse/Write|Edit hook
# Scans settings.json after writes for credential values in mcpServers.env blocks.
# AI assistants sometimes write real credentials into settings.json when
# configuring MCP servers -- this catches that immediately after the write.

INPUT=$(cat)

FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    path = d.get('tool_input', {}).get('file_path', '') or \
           d.get('tool_response', {}).get('filePath', '')
    print(path)
except:
    print('')
" 2>/dev/null)

[ -z "$FILE" ] && exit 0

case "$FILE" in
  */settings.json|*/settings.local.json) ;;
  *) exit 0 ;;
esac

[ ! -f "$FILE" ] && exit 0

RESULT=$(python3 - "$FILE" << 'PYEOF' 2>/dev/null
import json, sys, re

filepath = sys.argv[1]
try:
    data = json.load(open(filepath))
except:
    sys.exit(0)

SENSITIVE_KEYS = {'SECRET', 'PASSWORD', 'KEY', 'TOKEN', 'CLIENT_ID', 'CLIENT_SECRET'}
PLACEHOLDER_PATTERNS = re.compile(
    r'^(YOUR_|PLACEHOLDER|_HERE$|<[A-Z_]+>|\$\{|\$[A-Z_])', re.IGNORECASE
)

found = []
for server_name, cfg in data.get('mcpServers', {}).items():
    env = cfg.get('env', {})
    for k, v in env.items():
        if not any(s in k.upper() for s in SENSITIVE_KEYS):
            continue
        if not v or not isinstance(v, str):
            continue
        if PLACEHOLDER_PATTERNS.match(v):
            continue
        if len(v) < 10:
            continue
        found.append(f"{server_name}.env.{k}")

if found:
    print('FOUND:' + ', '.join(found))
PYEOF
)

if echo "$RESULT" | grep -q "^FOUND:"; then
  FIELDS=$(echo "$RESULT" | sed 's/^FOUND://')
  echo "{\"systemMessage\": \"WARNING: Credential guard: settings.json appears to contain a real credential in an mcpServers.env block (fields: ${FIELDS}). Credentials must be stored in a .env file -- never directly in settings.json. Remove those values now.\"}"
fi
SETTINGSHOOK
    chmod +x "$SETTINGS_HOOK"
    print_ok "Installed credential-settings-guard.sh"
    INSTALLED+=("Settings credential guard")
fi

# -- stop-notify.sh --
NOTIFY_HOOK="$HOME/.claude/hooks/stop-notify.sh"

if [[ -f "$NOTIFY_HOOK" ]]; then
    print_ok "stop-notify.sh already installed"
    SKIPPED+=("Stop notification hook")
else
    cat > "$NOTIFY_HOOK" << 'NOTIFYHOOK'
#!/bin/bash
# stop-notify.sh -- Stop hook
# Sends a Linux desktop notification when Claude finishes a turn that took
# more than 20 seconds. Lets you step away during long tasks without polling.
# Requires notify-send (libnotify-bin) and a running desktop session.
# Requires the companion UserPromptSubmit timestamp hook in settings.json.

TURN_START_FILE="/tmp/claude-turn-start.txt"

[ ! -f "$TURN_START_FILE" ] && exit 0

TURN_START=$(cat "$TURN_START_FILE" 2>/dev/null)
NOW=$(date +%s)
ELAPSED=$(( NOW - TURN_START ))

[ "$ELAPSED" -lt 20 ] && exit 0

# DISPLAY defaults to :0 if not set (typical for single-monitor desktop sessions).
DISPLAY="${DISPLAY:-:0}" notify-send "Claude Code" \
    "Claude finished -- waiting for your input." 2>/dev/null || true
NOTIFYHOOK
    chmod +x "$NOTIFY_HOOK"
    print_ok "Installed stop-notify.sh"
    INSTALLED+=("Stop notification hook")
fi
echo ""

# =============================================================================
# SUMMARY
# =============================================================================
print_header "Setup Complete"

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
    echo "  Installed / Created:"
    for item in "${INSTALLED[@]}"; do echo "    ✓ $item"; done
    echo ""
fi

if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo "  Already present (skipped):"
    for item in "${SKIPPED[@]}"; do echo "    - $item"; done
    echo ""
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "  Failed (action required):"
    for item in "${ERRORS[@]}"; do echo "    ✗ $item"; done
    echo ""
    echo "  Resolve the errors above, then re-run this script."
    echo ""
else
    echo "  All done. Here is what to do next:"
    echo ""
    echo "  1. Open a new terminal (to pick up any PATH changes to ~/.bashrc)"
    echo "  2. Verify Claude Code works:   claude --version"
    echo "  3. Fill in your personal context:"
    echo "       nano ~/.claude/CLAUDE.md"
    echo "  4. Fill in your organization context:"
    echo "       nano ~/Workspaces/_Global/CLAUDE.md"
    echo "  5. Start Claude Code:"
    echo "       claude"
    echo ""
    echo "  Tip: Inside Claude Code, type /help to see available commands."
    echo "  Your work files go in ~/Workspaces/."
fi

echo ""
echo "Press ENTER to close..."
read -r
