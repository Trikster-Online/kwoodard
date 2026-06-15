# Claude Code Onboarding Kit (Mac)

## Purpose
This folder contains the new-user onboarding kit for Claude Code.
It is meant to be shared with colleagues who are setting up Claude Code for
the first time on a Mac.

## Contents
- `setup-claude-code-generic.sh` -- bootstrap script for new users (run this first)
- `templates/` -- CLAUDE.md starter templates deployed by the script
- `docs/` -- plain-language setup guide for new users

## What This Kit Does NOT Include
- Any organization-specific MCP server setup -- share separately with users
  who need live API or tool access
- Any credentials or API tokens

## Keeping This Kit Current
When updating the script or templates:
1. Update the version number in the script header
2. Update `docs/Claude-Code-New-User-Setup-Generic.md` to match
3. Regenerate the PDF from the .md source (open in Word or LibreOffice, export as PDF)
4. Commit and push
