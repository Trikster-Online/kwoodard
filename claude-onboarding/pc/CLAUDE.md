# Claude Code Onboarding Kit (Windows / PC)

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose
This folder contains the new-user onboarding kit for Claude Code for Windows PC users.
It mirrors `../mac/` but targets Windows 11 with VS Code as the primary Claude Code interface.

## Contents
- `setup-claude-code-generic.ps1` -- PowerShell bootstrap script for new users (run this first)
- `templates/` -- CLAUDE.md starter templates deployed by the script
- `docs/` -- plain-language setup guide for new users

## Parallel Mac Kit
Always keep this kit in sync with `../mac/` for:
- Security rules and data privacy language (must be identical)
- CLAUDE.md template content (role/preferences sections)

Mac-only items that have NO PC equivalent:
- Xcode Command Line Tools -- not applicable on Windows
- Homebrew -- replaced by winget (Windows Package Manager)
- `swiftlint` -- Swift is macOS only, omit on PC
- `zsh` / bash script -- replaced by PowerShell `.ps1` script

## Key PC-Specific Architecture

### Primary Interface
PC users use VS Code with the Claude Code extension as their primary interface,
not a standalone terminal app. The Claude Desktop app is secondary.
- VS Code extension ID: `anthropic.claude-code`
- Users access Claude via the VS Code sidebar and integrated terminal

### Script Language
The bootstrap script is PowerShell (`setup-claude-code-generic.ps1`), not zsh.
- Run from PowerShell 7 (pwsh): `pwsh -ExecutionPolicy Bypass -File setup-claude-code-generic.ps1`
- Or right-click and choose "Run with PowerShell" from File Explorer

### Package Manager
Uses **winget** (built into Windows 11) instead of Homebrew.
- Node.js: `winget install OpenJS.NodeJS.LTS`
- VS Code: `winget install Microsoft.VisualStudioCode`
- Pandoc: `winget install JohnMacFarlane.Pandoc`
- Git: `winget install Git.Git`

### Config Directory
Claude Code on Windows uses `~\.claude\` (`$env:USERPROFILE\.claude\`)
Same file structure as Mac: `CLAUDE.md`, `settings.json`, `hooks\`, `commands\`

### Credential Guard
The credential guard hook must be a `.ps1` script, not bash.
Hook path in `settings.json`: `~\.claude\hooks\credential-guard.ps1`
Run via: `pwsh -File "$HOME\.claude\hooks\credential-guard.ps1"`

## VS Code Extensions Installed by Script
| Extension ID | Purpose |
|---|---|
| `anthropic.claude-code` | Claude AI interface (primary tool) |
| `ms-vscode.powershell` | PowerShell syntax, linting, debugging |
| `ms-python.python` | Python support + Pylance |

## Code Quality Tools on PC
| Tool | Install Method |
|---|---|
| PSScriptAnalyzer | `Install-Module PSScriptAnalyzer` |
| flake8, black, isort, mypy, pytest | `pip install <tool>` |
| pandoc + typst | winget |

## What This Kit Does NOT Include
- Any organization-specific MCP server setup -- share separately with users
  who need live API or tool access
- Any credentials or API tokens
- WSL (Windows Subsystem for Linux) -- not required; everything runs native PowerShell

## Keeping This Kit Current
When updating:
1. Update the version number in the `.ps1` script header
2. Update `docs/Claude-Code-New-User-Setup-PC-Generic.md` to match
3. Regenerate the PDF (open .md in Word or LibreOffice, export as PDF)
4. Mirror any security rule or template changes to the Mac kit as well
5. Commit and push
