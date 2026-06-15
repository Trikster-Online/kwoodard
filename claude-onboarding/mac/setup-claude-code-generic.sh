#!/bin/zsh

# =============================================================================
# setup-claude-code-generic.sh
# Purpose:     Bootstrap a new Mac with everything needed to use Claude Code.
#              Installs required binaries, creates a starter folder structure
#              in ~/Workspaces/, deploys starter configuration files to
#              ~/.claude/, and installs a credential guard security hook.
#              Safe to re-run -- each step checks before installing or creating.
# Author:      [Your Name]
# Date:        2026-05-12
# Version:     2.3
# Usage:       zsh ~/Desktop/setup-claude-code-generic.sh
# Notes:       Do NOT run with sudo -- Homebrew will refuse to install.
#              Requires internet access for Steps 1-7.
#              Existing config files are never overwritten.
#
# Version History:
#   2.1  2026-05-12  Initial release. Installs Xcode CLT, Homebrew, Node.js,
#                    Claude Code, Pandoc/Typst/Poppler, code quality tools,
#                    ~/Workspaces/ structure, ~/.claude/ config, and credential
#                    guard hook.
#   2.2  2026-06-03  Fixed PATH setup for Homebrew and Claude Code. Previously,
#                    ~/.zshrc entries were only written during a fresh install;
#                    on re-runs or pre-installed machines the entries were skipped.
#                    Both PATH blocks now run unconditionally after the install
#                    check, so all Homebrew-installed tools and claude are always
#                    reachable in new Terminal sessions.
#   2.3  2026-06-15  Added Step 5: Claude Desktop app (brew --cask claude).
#                    Renumbered subsequent steps 5-9 to 6-10.
# =============================================================================

# -- Output helpers --
print_header() { echo "" && echo "============================================" && echo "  $1" && echo "============================================" && echo ""; }
print_step()   { echo "[ STEP $1 ] $2"; }
print_ok()     { echo "  ✓ $1"; }
print_warn()   { echo "  ⚠ $1"; }
print_err()    { echo "  ✗ ERROR: $1"; }

ERRORS=()
INSTALLED=()
SKIPPED=()

print_header "Claude Code New User Setup"
echo "  This script sets up Claude Code on this Mac from scratch."
echo ""
echo "  It will:"
echo "    1. Install Xcode Command Line Tools (if needed)"
echo "    2. Install Homebrew package manager (if needed)"
echo "    3. Install Node.js via Homebrew (if needed)"
echo "    4. Install Claude Code CLI (if needed)"
echo "    5. Install Claude Desktop app"
echo "    6. Install Pandoc, Typst, and Poppler (document tools)"
echo "    7. Install code quality tools (shellcheck, swiftlint, Python linters)"
echo "    8. Create ~/Workspaces/ folder structure"
echo "    9. Create ~/.claude/ starter configuration"
echo "   10. Install credential guard security hook"
echo ""
echo "  Existing files are never overwritten."
echo "  Do NOT run with sudo."
echo ""
echo "Press ENTER to begin, or Ctrl+C to cancel..."
read -r
echo ""

# =============================================================================
# STEP 1 — Xcode Command Line Tools
# Required by Homebrew and by many command-line developer tools on macOS.
# =============================================================================
print_step 1 "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    print_ok "Already installed at: $(xcode-select -p)"
    SKIPPED+=("Xcode CLT")
else
    print_warn "Not installed. Launching installer (follow the GUI prompt)..."
    xcode-select --install 2>/dev/null
    echo ""
    echo "  The Xcode CLT installer window has opened."
    echo "  Click Install, wait for it to complete, then press ENTER here to continue..."
    read -r
    if xcode-select -p &>/dev/null; then
        print_ok "Installed successfully."
        INSTALLED+=("Xcode CLT")
    else
        print_err "Xcode CLT still not found. Cannot continue without it."
        echo "  Try: sudo xcode-select --reset"
        echo "  Or install Xcode from the App Store, then re-run this script."
        exit 1
    fi
fi
echo ""

# =============================================================================
# STEP 2 — Homebrew
# Homebrew is the package manager used to install Node.js. It installs Node
# to a fixed path that Claude Code can always find, regardless of shell state.
# =============================================================================
print_step 2 "Homebrew"

if command -v brew &>/dev/null; then
    print_ok "Already installed: $(brew --version | head -1)"
    SKIPPED+=("Homebrew")
else
    print_warn "Not installed. Installing Homebrew (this may take a few minutes)..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if command -v brew &>/dev/null || [[ -f /opt/homebrew/bin/brew ]]; then
        print_ok "Homebrew installed"
        INSTALLED+=("Homebrew")
    else
        print_err "Homebrew installation failed."
        ERRORS+=("Homebrew")
    fi
fi

# Always ensure Homebrew (Apple Silicon path) is active in this session and in .zshrc,
# regardless of whether it was just installed or already present.
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if ! grep -q 'homebrew' ~/.zshrc 2>/dev/null; then
        echo '' >> ~/.zshrc
        echo '# Homebrew' >> ~/.zshrc
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        print_ok "Added Homebrew to ~/.zshrc"
    fi
fi
echo ""

# =============================================================================
# STEP 3 — Node.js (via Homebrew)
# Node.js must be installed via Homebrew, not via nvm. Homebrew installs Node
# to a fixed path (/opt/homebrew/bin/node) that Claude Code can always locate
# at launch. nvm installs to a shell-dependent path that Claude Code cannot
# reliably find when it starts in the background.
# =============================================================================
print_step 3 "Node.js (via Homebrew)"

if /opt/homebrew/bin/node --version &>/dev/null; then
    print_ok "Already installed: $(/opt/homebrew/bin/node --version) at /opt/homebrew/bin/node"
    SKIPPED+=("Node.js")
elif command -v node &>/dev/null; then
    print_warn "node found at $(which node) but not at /opt/homebrew/bin/node"
    print_warn "Claude Code requires Node at the fixed Homebrew path. Installing via Homebrew..."
    brew install node
    if /opt/homebrew/bin/node --version &>/dev/null; then
        print_ok "Homebrew Node installed: $(/opt/homebrew/bin/node --version)"
        INSTALLED+=("Node.js (Homebrew)")
    else
        print_err "Homebrew Node install failed."
        ERRORS+=("Node.js")
    fi
else
    print_warn "Not installed. Installing via Homebrew..."
    brew install node
    if /opt/homebrew/bin/node --version &>/dev/null; then
        print_ok "Installed: $(/opt/homebrew/bin/node --version)"
        INSTALLED+=("Node.js")
    else
        print_err "Node.js install failed."
        ERRORS+=("Node.js")
    fi
fi
echo ""

# =============================================================================
# STEP 4 — Claude Code CLI (native installer)
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
    if [[ -f ~/.local/bin/claude ]]; then
        print_ok "Claude Code installed: $(~/.local/bin/claude --version 2>/dev/null)"
        INSTALLED+=("Claude Code")
    else
        print_err "Claude Code installer did not produce ~/.local/bin/claude"
        ERRORS+=("Claude Code")
    fi
fi

# Always ensure ~/.local/bin is active in this session and in .zshrc,
# regardless of whether Claude was just installed or already present.
if [[ -f "$HOME/.local/bin/claude" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q '\.local/bin' ~/.zshrc 2>/dev/null; then
        echo '' >> ~/.zshrc
        echo '# Claude Code (native install)' >> ~/.zshrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        print_ok "Added ~/.local/bin to ~/.zshrc PATH"
    fi
fi
echo ""

# =============================================================================
# STEP 5 — Claude Desktop app
# Claude Desktop is the GUI application for Claude. It provides the Cowork
# interface (folder-based autonomous tasks) and is the recommended entry point
# for non-technical users who are not working in a terminal. Installed via
# Homebrew cask so it can be detected and skipped on re-runs.
# =============================================================================
print_step 5 "Claude Desktop app"

if [[ -d "/Applications/Claude.app" ]]; then
    print_ok "Already installed at /Applications/Claude.app"
    SKIPPED+=("Claude Desktop")
else
    print_warn "Not installed. Installing via Homebrew cask..."
    brew install --cask claude
    if [[ -d "/Applications/Claude.app" ]]; then
        print_ok "Claude Desktop installed"
        INSTALLED+=("Claude Desktop")
    else
        print_warn "Could not confirm Claude Desktop install via Homebrew."
        print_warn "If it is not in /Applications, download it manually from claude.ai/download"
        SKIPPED+=("Claude Desktop (verify manually)")
    fi
fi
echo ""

# =============================================================================
# STEP 6 — Pandoc, Typst, and Poppler (document tools)
# Pandoc converts documents between formats (Markdown -> PDF, Word, HTML, etc.).
# Typst is a lightweight PDF engine Pandoc uses to generate PDFs without a full
# LaTeX installation. Poppler provides PDF utilities including pdftoppm, which
# lets Claude Code read and render existing PDF files.
# =============================================================================
print_step 6 "Pandoc, Typst, and Poppler (document tools)"

pandoc_ok=0
typst_ok=0
poppler_ok=0

if command -v pandoc &>/dev/null; then
    print_ok "Pandoc already installed: $(pandoc --version | head -1)"
    SKIPPED+=("Pandoc")
    pandoc_ok=1
else
    print_warn "Pandoc not installed. Installing via Homebrew..."
    brew install pandoc
    if command -v pandoc &>/dev/null; then
        print_ok "Pandoc installed: $(pandoc --version | head -1)"
        INSTALLED+=("Pandoc")
        pandoc_ok=1
    else
        print_err "Pandoc install failed."
        ERRORS+=("Pandoc")
    fi
fi

if command -v typst &>/dev/null; then
    print_ok "Typst already installed: $(typst --version)"
    SKIPPED+=("Typst")
    typst_ok=1
else
    print_warn "Typst not installed. Installing via Homebrew..."
    brew install typst
    if command -v typst &>/dev/null; then
        print_ok "Typst installed: $(typst --version)"
        INSTALLED+=("Typst")
        typst_ok=1
    else
        print_err "Typst install failed."
        ERRORS+=("Typst")
    fi
fi

if command -v pdftoppm &>/dev/null; then
    print_ok "Poppler already installed: $(pdftoppm -v 2>&1 | head -1)"
    SKIPPED+=("Poppler")
    poppler_ok=1
else
    print_warn "Poppler not installed. Installing via Homebrew..."
    brew install poppler
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
# STEP 7 — Code quality tools (shellcheck, swiftlint, Python linters)
# These tools are used for code quality checks across your projects.
# shellcheck lints Bash and Zsh scripts. swiftlint lints Swift source files.
# The Python tools (flake8, black, isort, mypy, pytest) are used for Python
# projects. PSScriptAnalyzer lints PowerShell scripts and is installed
# automatically if PowerShell Core (pwsh) is already present.
# Note: Python tools are invoked as "python3 -m <tool>" because pip3 on macOS
# installs them to a path that is not in $PATH by default.
# =============================================================================
print_step 7 "Code quality tools (shellcheck, swiftlint, Python linters)"

shellcheck_ok=0
swiftlint_ok=0
python_tools_ok=1

# -- shellcheck --
if command -v shellcheck &>/dev/null; then
    print_ok "shellcheck already installed: $(shellcheck --version | head -1)"
    SKIPPED+=("shellcheck")
    shellcheck_ok=1
else
    print_warn "shellcheck not installed. Installing via Homebrew..."
    brew install shellcheck
    if command -v shellcheck &>/dev/null; then
        print_ok "shellcheck installed: $(shellcheck --version | head -1)"
        INSTALLED+=("shellcheck")
        shellcheck_ok=1
    else
        print_err "shellcheck install failed."
        ERRORS+=("shellcheck")
    fi
fi

# -- swiftlint --
if command -v swiftlint &>/dev/null; then
    print_ok "swiftlint already installed: $(swiftlint version)"
    SKIPPED+=("swiftlint")
    swiftlint_ok=1
else
    print_warn "swiftlint not installed. Installing via Homebrew..."
    brew install swiftlint
    if command -v swiftlint &>/dev/null; then
        print_ok "swiftlint installed: $(swiftlint version)"
        INSTALLED+=("swiftlint")
        swiftlint_ok=1
    else
        print_err "swiftlint install failed."
        ERRORS+=("swiftlint")
    fi
fi

# -- Python dev tools (flake8, black, isort, mypy, pytest) --
PYTHON_TOOLS=(flake8 black isort mypy pytest)
for tool in "${PYTHON_TOOLS[@]}"; do
    if python3 -m "$tool" --version &>/dev/null 2>&1; then
        print_ok "python3 -m $tool already available"
        SKIPPED+=("$tool")
    else
        print_warn "python3 -m $tool not found. Installing via pip3..."
        pip3 install --quiet "$tool"
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

# -- PSScriptAnalyzer (PowerShell only — skip if pwsh not installed) --
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
    print_ok "PowerShell (pwsh) not installed — skipping PSScriptAnalyzer"
    SKIPPED+=("PSScriptAnalyzer (pwsh not present)")
fi

if [[ $shellcheck_ok -eq 1 && $python_tools_ok -eq 1 ]]; then
    print_ok "Core linting tools ready"
fi
echo ""

# =============================================================================
# STEP 8 — ~/Workspaces/ folder structure
# Creates a starter working folder layout at ~/Workspaces/. These folders
# provide a standard layout for organizing Claude-assisted work. All your
# project files, documentation, and scripts will live here.
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
# STEP 9 — ~/.claude/ starter configuration
# Creates Claude Code's config directory and populates it with starter files:
#   - ~/.claude/CLAUDE.md         Personal instructions (fill in your info)
#   - _Global/CLAUDE.md           Project context (fill in your info)
#   - ~/.claude/settings.json     Basic settings with credential guard wired in
#   - ~/.claude/commands/         Ready for custom slash commands you add later
#   - ~/.claude/hooks/            Ready for automation hooks (Step 10 adds one)
# Existing files are never overwritten.
# =============================================================================
print_step 9 "$HOME/.claude/ starter configuration"

mkdir -p ~/.claude/commands ~/.claude/hooks

# -- Personal CLAUDE.md --
if [[ -f ~/.claude/CLAUDE.md ]]; then
    print_ok "$HOME/.claude/CLAUDE.md already exists — skipping (will not overwrite)"
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
- [e.g. MDM, endpoint management tools, Microsoft 365, Google Workspace]
- macOS and zsh for shell scripting
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
    print_ok "Created $HOME/.claude/CLAUDE.md (starter template — fill in your info)"
    INSTALLED+=("$HOME/.claude/CLAUDE.md")
fi

# -- Global project CLAUDE.md --
GLOBAL_CLAUDE="$HOME/Workspaces/_Global/CLAUDE.md"
if [[ -f "$GLOBAL_CLAUDE" ]]; then
    print_ok "$HOME/Workspaces/_Global/CLAUDE.md already exists — skipping"
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
    print_ok "Created ~/Workspaces/_Global/CLAUDE.md (starter template — fill in your info)"
    INSTALLED+=("_Global/CLAUDE.md")
fi

# -- settings.json --
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
    print_ok "$HOME/.claude/settings.json already exists — skipping"
    SKIPPED+=("settings.json")
else
    cat > "$SETTINGS" << 'SETTINGS_TEMPLATE'
{
  "hooks": {
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
    ]
  }
}
SETTINGS_TEMPLATE
    print_ok "Created ~/.claude/settings.json"
    INSTALLED+=("settings.json")
fi
echo ""

# =============================================================================
# STEP 10 — Credential guard hook
# Installs a security hook that watches every shell command Claude runs and
# blocks any command that appears to contain an inline credential (password,
# token, API key, etc.). This is an automatic safety net -- it does not replace
# good security habits, but it catches common mistakes before they happen.
# =============================================================================
print_step 10 "Credential guard hook"

HOOK="$HOME/.claude/hooks/credential-guard.sh"

if [[ -f "$HOOK" ]]; then
    print_ok "Already installed at ~/.claude/hooks/credential-guard.sh"
    SKIPPED+=("Credential guard hook")
else
    cat > "$HOOK" << 'HOOKSCRIPT'
#!/bin/bash
#
# credential-guard.sh
# PreToolUse/Bash hook -- warns when a shell command contains an inline credential.
#
# Looks for patterns like:  VARIABLE_NAME="long-value"
# where the variable name suggests a secret (SECRET, PASSWORD, TOKEN, KEY, etc.)
# and the value is long enough to be a real credential (not a short placeholder).
# Placeholders like YOUR_VALUE_HERE, ${VAR}, or <VALUE> are allowed through.
#

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

# Block if a known credential variable name is followed by a long value
if echo "$CMD" | grep -qiE \
  '(SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_TOKEN|BEARER_TOKEN|CLIENT_SECRET|PRIVATE_KEY)\s*=\s*["\x27]?[A-Za-z0-9_.\-]{20,}["\x27]?'; then

    # Allow if the value looks like a placeholder
    if ! echo "$CMD" | grep -qiE '(YOUR_[A-Z]|_HERE["\x27 \\]|\$\{[A-Z]|\$[A-Z_][A-Z_0-9]+|<[A-Z_]+>)'; then
        echo '{"systemMessage": "WARNING: Credential guard: This command appears to contain a real credential value inline. Store credentials in a .env file and reference them as environment variables instead of passing them directly in commands."}'
    fi

fi
HOOKSCRIPT

    chmod +x "$HOOK"
    print_ok "Installed credential guard hook"
    INSTALLED+=("Credential guard hook")
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
    echo "  1. Open a new Terminal window (to pick up any PATH changes)"
    echo "  2. Verify Claude Code works:   claude --version"
    echo "  3. Fill in your personal context:"
    echo "       open ~/.claude/CLAUDE.md"
    echo "  4. Fill in your organization context:"
    echo "       open ~/Workspaces/_Global/CLAUDE.md"
    echo "  5. Start Claude Code:"
    echo "       claude"
    echo ""
    echo "  Tip: Inside Claude Code, type /help to see available commands."
    echo "  Your work files go in ~/Workspaces/."
fi

echo ""
echo "Press ENTER to close..."
read -r
