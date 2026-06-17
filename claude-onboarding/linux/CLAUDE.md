# Claude Code Onboarding Kit (Linux)

## Purpose
This folder contains the new-user onboarding kit for Claude Code.
It is meant to be shared with colleagues who are setting up Claude Code for
the first time on a Linux Mint machine.

## Contents
- `setup-claude-code-generic.sh` -- bootstrap script for new users (run this first)
- `templates/` -- CLAUDE.md starter templates deployed by the script
- `docs/` -- plain-language setup guide for new users

## What This Kit Does NOT Include
- Any organization-specific MCP server setup -- share separately with users
  who need live API or tool access
- Any credentials or API tokens

## Key Differences from the Mac Kit
- Uses apt and NodeSource instead of Homebrew
- Claude Desktop is not available on Linux -- Step 5 is advisory only
- Browser guide replaces the Desktop app guide
- swiftlint is not installed (macOS only)
- Notifications use notify-send instead of osascript
- Shell is bash; PATH changes write to ~/.bashrc instead of ~/.zshrc

## Keeping This Kit Current
When updating the script or templates:
1. Update the version number in the script header
2. Update `docs/Claude-Code-New-User-Setup-Linux-Generic.md` to match
3. Regenerate the PDF from the .md source
4. Commit and push
